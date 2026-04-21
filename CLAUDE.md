# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
docker buildx bake default       # Build all images (core, r, stata)
docker buildx bake core          # Build core only
docker buildx bake extra         # Build r and stata only
```

For local development (amd64 only, faster):
```bash
docker buildx bake core --set '*.platform=linux/amd64'
```

All version pins and build args live in `docker-bake.hcl`. CI (`build.yml`) builds on push/PR to main; pushes to GHCR only on main. PRs build amd64 only.

## Image Layering

```
ubuntu:24.04
  └─ core (MiKTeX + tex-fmt + cookiecutter + oh-my-zsh + dev tools)
       ├─ r   (R + Quarto + radian + R packages)
       └─ stata (Stata MP, amd64 only, with xpra for GUI)
```

`r` and `stata` use Docker Bake's `contexts = { core = "target:core" }` to inherit from core — their Dockerfiles start with `FROM core`, not a registry tag.

## Key Conventions

- **Install scripts run as `ubuntu` user with sudo**, not as root. Scripts in `/scripts/` enforce this with an `id -u` check. The MiKTeX installer (`install.sh` from the miktex repo) follows the same pattern.
- **Feature flags**: scripts write to `/features/<name>` to mark themselves as already installed (idempotent).
- **Cleanup pattern**: every `apt-get install` block ends with `purge --auto-remove` + removal of `/var/lib/apt/lists/*`, doc files, and man pages.
- **Quarterly releases**: version scheme is `<year>-q<quarter>` (e.g., `2026-q2`). `IMAGE_VERSION` is the precise semver; `RECAP_RELEASE` is the cycle tag.

## Dependency: miktex repo

The core Dockerfile fetches MiKTeX via `curl -fsSL https://raw.githubusercontent.com/recap-org/miktex/dev/install.sh | bash`. The `MIKTEX_VERSION` arg in `docker-bake.hcl` must match a GitHub release tag in `recap-org/miktex`.

## Publishing

Images are pushed to `ghcr.io/recap-org/{core,r,stata}` with three tags each: `IMAGE_VERSION`, `RECAP_RELEASE`, and `latest`.
