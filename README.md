# GitHub action to publish Debian packages into apt repository

If you develop an free/open source project and want to publish it as Debian packages, you might want to publish them into an apt repository. Normally, Debian project strives to keep all packages in [one central repo](https://www.debian.org/mirror/list), but it takes quite a long time for a package to get there. For faster turnaround, many projects maintain their own apt repositories, and this action is here to help with that.

## Getting started

### Prerequisites

To publish apt repository using this action, you'll require:

* Debian (.deb) packages to be published
* GPG key to sign your repository
* Azure subscription and storage account to publish repository to

#### Debian packages

Building .deb packages is a complicated topic which is way out of scope for this action, see:

* [Building Debian packages](https://wiki.debian.org/BuildingAPackage)
* [Guide for Debian Maintainers](https://www.debian.org/doc/manuals/debmake-doc/index.en.html)

#### GPG key

The repository must be signed with a GPG key so that apt clients can verify package integrity. You'll need:

* A **private key** (ASCII-armored) — used by this action to sign the repository
* A **passphrase** for the private key
* A **public key** — distributed to end users so they can verify the repository

To generate a dedicated GPG signing key:

```sh
# Choose an identifier for the key and a passphrase
GPG_KEY_ID="your-repo@example.com"
GPG_PASSPHRASE="your-strong-passphrase"

# Generate the key (RSA 4096-bit, sign-only, valid for 1 year)
echo "$GPG_PASSPHRASE" > /tmp/passphrase.txt
gpg --batch --passphrase-file /tmp/passphrase.txt \
    --quick-generate-key "$GPG_KEY_ID" rsa4096 sign 1y

# Export the public key (distribute this to your users)
gpg --export --armor "$GPG_KEY_ID" >repo-pubkey.asc

# Export the private key (store as a GitHub secret)
echo "$GPG_PASSPHRASE" | gpg --batch --yes --armor \
    --pinentry-mode loopback --passphrase-fd 0 \
    --export-secret-keys "$GPG_KEY_ID" > repo-privkey.asc

# Clean up
rm /tmp/passphrase.txt
```

Then store the secrets in your GitHub repository:

1. Go to your repo → "Settings" → "Secrets and variables" → "Actions".
2. Add `MY_GPG_PRIV_KEY` — paste the full contents of `repo-privkey.asc`.
3. Add `MY_GPG_PASSPHRASE` — paste the passphrase you chose.

Publish `repo-pubkey.asc` somewhere your users can download it (e.g. in the storage account itself or on your project website).

#### Azure subscription and storage account

This action hosts the apt repository on [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction). You'll need:

* Azure subscription
* Resource group
* Storage account
* Blob container with public read access
* SAS token with read, write, and list permissions on the container

Assuming you've got Azure subscription set up, Azure CLI installed, and you're logged in:

```sh
MY_RESOURCE_GROUP=myResourceGroup
MY_STORAGE_ACCOUNT=mystorageaccount
MY_CONTAINER=myaptrepo
MY_LOCATION=westeurope

# Create a resource group
az group create --name "$MY_RESOURCE_GROUP" --location "$MY_LOCATION"

# Create a storage account
az storage account create \
    --name "$MY_STORAGE_ACCOUNT" \
    --resource-group "$MY_RESOURCE_GROUP" \
    --location "$MY_LOCATION" \
    --sku Standard_LRS

# Create a Blob container with public (anonymous) read access, so that apt clients can fetch packages:
az storage container create \
    --name "$MY_CONTAINER" \
    --account-name "$MY_STORAGE_ACCOUNT" \
    --public-access blob

# Generate a SAS token for CI/CD use. The token needs `read`, `write`, and `list` permissions and should have an appropriate expiry:
az storage container generate-sas \
    --name "$MY_CONTAINER" \
    --account-name "$MY_STORAGE_ACCOUNT" \
    --permissions rwl \
    --expiry $(date -u -d "+1 year" +%Y-%m-%dT%H:%MZ) \
    --output tsv
```

After you've got the SAS token, store the SAS token as a GitHub secret:

1. Go to your repo → "Settings" → "Secrets and variables" → "Actions".
2. Add `MY_SAS_TOKEN` — paste the SAS token value.

### Usage

Once you have all the prerequisites in place:

1. Add your Azure Storage SAS token, GPG private key file and GIG private key passphrase to your GitHub secrets (e.g. as `MY_SAS_TOKEN`, `MY_GPG_PRIV_KEY`, `MY_GPG_PASSPHRASE`).

2. Add this to your GitHub Actions workflow:

```yaml
jobs:
  your_job_name:
    runs-on: ubuntu-latest
    steps:
      # ...
      # Some steps here to build your .deb packages
      # ...
      - name: Publish packages to apt repo
        uses: kaitai-io/repo-apt-handle@v1
        with:
          az_storage_sas_token: ${{ secrets.MY_SAS_TOKEN }}
          az_storage_account: your_storage_account
          az_storage_container: your_storage_container
          gpg_priv_key: ${{ secrets.MY_GPG_PRIV_KEY }}
          gpg_passphrase: ${{ secrets.MY_GPG_PASSPHRASE }}
          packages: path/to/your-package.deb
```

### Consuming the repository

To be able to install packages the repository, users will need to add it to their apt keyring first:

```sh
curl -fsSL https://repo.example.com/repo-pubkey.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/your-repo.gpg
```

or apt-key (deprecated but still widely used):

```sh
curl -fsSL https://repo.example.com/repo-pubkey.asc | sudo apt-key add -
```

Once configured, users can add your repository to their apt sources:

```sh
echo "deb [arch=all] https://<account>.blob.core.windows.net/<container> stable main" \
    | sudo tee /etc/apt/sources.list.d/your-repo.list
sudo apt-get update
sudo apt-get install your-package
```

## Caveats and limitations

* This action is designed to work in CI/CD environment and is not reenterrable. If you run several instances of this action in parallel (e.g. in different CI branches to publish several packages), they will can interfere with each other and this will likely result in repository containing all the .deb files in `pool/`, but lacking proper indexing. In theory, it's possible to avoid that by building some kind of locking mechanism, but it's not implemented yet.
* [Repo structure](README.repo-apt-handle.md#repo-structure) is quite simple.

## Implementation details

Internally, this action uses:

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) to work with Azure
* [repo-apt-handle](repo-apt-handle) tool to create/update partial apt repositories locally. See [its README](README.repo-apt-handle.md) for more details.

## License

See [LICENSE](LICENSE) file.

Copyright (C) 2024-2026 Kaitai Project.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
