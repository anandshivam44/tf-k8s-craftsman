# Node Application

Commands to build and push the Docker image to Docker Hub.

### Login to Docker Hub

```sh
echo "YOUR_DOCKER_HUB_PAT" | docker login -u anandshivam44 --password-stdin
```

### Build and Push Multi-arch Image (amd64 & arm64)

First, ensure `buildx` is set up (this is usually default in modern Docker versions):
```sh
docker buildx create --use
```

Now, build and push the image for both architectures. The `--push` flag handles pushing.

```sh
docker buildx build --platform linux/amd64,linux/arm64 -t anandshivam44/node-application:latest --push .
```