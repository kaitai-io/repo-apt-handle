detect_docker()
{
	if docker --version >/dev/null 2>/dev/null; then
		DOCKER_BIN=docker
	elif podman --version >/dev/null 2>/dev/null; then
		DOCKER_BIN=podman
		DOCKER_EXTRA_OPTS='--security-opt label=disable'
	else
		echo "ERROR: Docker or Podman binary not found."
		exit 1
	fi
}

docker_run()
{
	DOCKER_IMAGE=kaitai-dpkg:latest

	"$DOCKER_BIN" run --rm \
		$DOCKER_EXTRA_OPTS \
		-e REPO_DIR \
		-e PKGS_SRC \
		-v $(pwd):/work \
		-w /work \
		"$DOCKER_IMAGE" \
		$*
}

detect_docker
