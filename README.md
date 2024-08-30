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

TODO

#### Azure subscription and storage account

TODO

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
          packages: path/to/your/new/package.deb
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

Copyright (C) 2024 Kaitai Project.

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
