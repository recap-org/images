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

## Temporary: vscode-R session-watcher shim (remove for q4)

`install_R.sh` writes a four-line `.First` hook into `$(R RHOME)/etc/Rprofile.site`.
**It is a workaround, and q4 planning should start by checking whether it can go.**

vscode-R is a **VS Code extension** — the image does not ship it and never will.
It installs from the marketplace (via `devcontainer.json`'s `extensions` list, or
the user's own VS Code) and auto-updates itself. What the image ships is the set
of R packages that extension needs: `languageserver`, `httpgd`, `vscDebugger`.

Why the shim exists: vscode-R (<= 2.8.8) arms its session watcher by assigning
`.First.sys` into the global environment and relying on R invoking that copy at
the end of startup. R 4.6.0 resolves `.First.sys` from the base environment
instead, so the override is armed but never called — no `tools:vscode`, no
`View()`, and `options(device=)` is never set, so plots bypass httpgd. It fails
silently. Verified broken on 4.6.0 **and 4.6.1**; unaffected on 4.5.3. Tracked
upstream as REditorSupport/vscode-R#1696 (open since 2026-04-27); the hook is
upstream's own suggestion from #1725.

The site profile is the only startup stage that survives both rv's and renv's
project `.Rprofile` and vscode-R's `R_PROFILE_USER` redirection — `~/.Rprofile`
does not work, because R sources exactly one user profile and both dependency
managers write a project-local one.

**Removal condition**: vscode-R **3.0.0** is released. Because the extension
auto-updates from the marketplace, that release alone retires the shim — no
image change is needed for it to take effect. Upstream rewrote the watcher on
master around a bundled `sess` package (`R/session/` deleted 2026-05-02);
unreleased as of 2026-08. Check for a `v3.*` tag — do *not* trust
`releases/latest`, which is an untagged rolling development build.

To remove: delete the `SITE_PROFILE` block from `scripts/install_R.sh` and this
section. The shim goes inert rather than harmful once 3.0.0 ships, so there is no
urgency to patch a frozen quarterly release.

### What 3.0.0 is expected to change for this image

- **`sess`** — the IPC package the new watcher is built on, versioned in lockstep
  (its `DESCRIPTION` on master already reads `Version: 3.0.0`). Expected to be on
  CRAN by release; it is not today, and the same `DESCRIPTION` still carries
  placeholder author/maintainer fields, so it is not submittable as-is. If it
  lands on CRAN it is declarable like any other dev dependency. If it does not,
  `install_sess.R` calls `install.packages(..., repos = NULL)` with no `lib=`, so
  it installs into `.libPaths()[1]` — the rv/renv *project* library, where
  `rv sync` deletes it as undeclared.
- **Plot backend moves toward `jgd`.** Master's auto mode prefers
  `jgd > httpgd > standard` by package availability, with `r.plot.useHttpgd: true`
  still forcing httpgd for backwards compatibility. `jgd` ("JSON Graphics
  Device", `grantmcdermott/jgd`) is lighter than httpgd and is **already on CRAN**
  (0.1.1), so unlike `sess` it is declarable today. Expect `install_R.sh` to
  install `jgd` — possibly in place of `httpgd`.

## Dependency: miktex repo

The core Dockerfile fetches MiKTeX via `curl -fsSL https://raw.githubusercontent.com/recap-org/miktex/dev/install.sh | bash`. The `MIKTEX_VERSION` arg in `docker-bake.hcl` must match a GitHub release tag in `recap-org/miktex`.

## Publishing

Images are pushed to `ghcr.io/recap-org/{core,r,stata}` with three tags each: `IMAGE_VERSION`, `RECAP_RELEASE`, and `latest`.
