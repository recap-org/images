# RECAP Docker Images
Docker images for the RECAP project

## Our Images

- **core**: Base image built on Ubuntu 24.04, with a lightweight installation of LaTeX ([our build](https://github.com/recap-org/miktex) of [MiKTeX](https://miktex.org/), optimized for Docker), and common development dependencies. It can be used as a standalone image for writing in LaTeX or as a base for other images.
- **r**: Adds [R](https://cran.r-project.org/) and [Quarto](https://quarto.org/) to the the `core` image.

See our [Releases](https://github.com/recap-org/images/releases) page for the full list of available images and details about their software stack.

## Releases and Tags

We release new versions of our images quarterly. Each image is tagged with `latest` and the corresponding version number. Each image is tagged as follows:

- `<image>:latest`: the latest image in the series; e.g., `r:latest` 
- `<image>:<year>-q<quarter>`: the latest quarterly release; e.g., `r:2024-q2`
- `<image>:<year>.<quarter>.<build>`: specific builds of the quarterly release; used for bugfixes; e.g., `r:2024.2.1` would be the first bugfix release of the 2024 Q2 version.

## Usage

To use the images, you can pull them from GitHub Container Registry:

```bash
docker pull ghcr.io/recap-project/images/core:latest
docker pull ghcr.io/recap-project/images/r:latest
```

## Building Images

This project uses Docker Buildx and `docker-bake.hcl` to build multi-platform Docker images.

### Local Builds

To build locally:

```bash
docker buildx bake default
```