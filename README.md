# images
Docker images for the RECAP project
## Building Images

This project uses Docker Buildx and `docker-bake.hcl` to build multi-platform Docker images.

### Environment Files

Two environment files control the build configuration:

- **`.env.local`** (git-ignored): For local development
  - Builds for `linux/arm64` only
  - Outputs to local Docker daemon (`type=docker`)
  - Used by default when running `docker buildx bake`

- **`.env.ci`** (committed): For CI/CD builds
  - Builds for both `linux/amd64` and `linux/arm64`
  - Outputs to container registry (`type=registry`)
  - Used by GitHub Actions workflow

### Local Development

To build locally for arm64:

```bash
# Uses .env.local by default
docker buildx bake default

# Or explicitly specify:
docker buildx bake --file .env.local default
```

To build just the core image:

```bash
docker buildx bake --file .env.local core
```

### CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/build.yml`) automatically:

- **On pull requests**: Builds images locally for validation (no push to registry)
- **On pushes to main**: Builds multi-platform images and pushes to GitHub Container Registry (GHCR)

Images are tagged as:
- `ghcr.io/recap-org/recap-core:2026.1` (version)
- `ghcr.io/recap-org/recap-core:2026-q1` (release cycle)
- `ghcr.io/recap-org/recap-core:latest`

### Multi-Platform Builds

To build multi-platform images locally (requires Docker Buildx):

```bash
docker buildx bake --file .env.ci default
```

To push to a registry from local development:

```bash
# Requires authentication with GHCR
docker buildx bake --file .env.ci --push default
```

### Image Dependencies

The `recap-r` image depends on `recap-core` being built first (declared via `depends_on` in the bake file). When rebuilding either image:

- If the dependency already exists in the registry, Buildx will reuse it
- If the dependency is newer and needs rebuilding, it will be built automatically