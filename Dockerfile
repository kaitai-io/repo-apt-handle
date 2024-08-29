# Central Dockerfile for GitHub Action invoking `az-repo-apt-add`

# Use Ubuntu 24.04 as base image - it's simpler to start off Debian-based OS,
# given that we'll be using `dpkg-scanpackages`
FROM ubuntu:24.04

# Install Ubuntu native prerequisites
RUN \
	apt-get update && \
	apt-get install -y \
		dpkg-dev \
		ca-certificates \
		curl \
		apt-transport-https \
		lsb-release \
		gnupg

# Install Azure CLI
RUN \
	curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
	apt-get update && \
	apt-get install azure-cli

COPY \
	az-repo-apt-add \
	repo-apt-handle \
	common.sh \
	./

# Ensures that Action maps all the paths in invoking workspace, e.g.
# paths to .deb files to publish
WORKDIR /github/workspace

ENTRYPOINT ["/az-repo-apt-add"]
