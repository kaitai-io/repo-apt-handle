# Minimal apt repo handling

[repo-apt-handle](repo-apt-handle) is a minimalistic tool to handle Debian apt repositories, namely, it can:

* Create minimal repository from scratch, given .deb packages
* Add packages to existing repository in incremental way, which is friendly towards uploading only one package to a repository from CI/CD pipeline, without having to download all packages, reindexing them and uploading them all again.

## Usage

See header of [repo-apt-handle](repo-apt-handle) for details.

## Testing

To allow testing to be done in arbitrary Linux system without changing state of the system itself, testing is done in several Docker containers (podman on Fedora can be used too). To run all tests in full auto, launch:

```sh
./docker-test-all
```

This requires:

* 3 files in `all_pkgs/`:
  * kaitai-struct-compiler_0.7_all.deb
  * kaitai-struct-compiler_0.8_all.deb
  * kaitai-struct-compiler_0.9_all.deb
* Docker container `kaitai-dpkg` to be prebuilt (run `./docker-build-kaitai-dpkg` to build it)

## Repo structure

This tool creates the following repo structure:

* dists/stable/
  * Release
  * Release.gpg
  * main/binary-$REPO_ARCH/
    * Packages
    * Packages.gz
* pool/main/
  * All `*.deb` files go here

During initial repo creation, all these files will be created from scratch.

During incremental update:

* New .deb packages will be added to `pool/main/`
* Old `Packages.gz` will be downloaded
* New `Packages` and `Packages.gz` will be generated from old `Packages.gz` by adding info on new .deb files
* New `Release` and `Release.gpg` will be generated to reflect new `Packages` and `Packages.gz`
