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
