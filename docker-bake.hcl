variable "IMAGE_VERSION" {
  default = "2026.1.4"
}
variable "RECAP_RELEASE" {
  default = "2026-q1"
}

variable "UBUNTU_VERSION" {
  default = "24.04"
}
variable "MIKTEX_VERSION" {
  default = "25.12"
}
variable "TEX_FMT_VERSION" {
  default = "0.5.6"
}
variable "COOKIECUTTER_VERSION" {
  default = "2.6.0"
}
variable "R_VERSION" {
  default = "4.5.2"
}
variable "QUARTO_VERSION" {
  default = "1.8.27"
}
variable "RADIAN_VERSION" {
  default = "0.6.15"
}
variable "STATA_VERSION" {
  default = "Now 19 MP"
}

variable "PLATFORMS" {
  type = list(string)
  default = ["linux/amd64", "linux/arm64"]
  description = "Platforms to build for"
}

target "common" {
  platforms = PLATFORMS
  labels = {
    "org.opencontainers.image.source" = "https://github.com/recap-org/images"
    "org.opencontainers.image.vendor" = "RECAP"
    "org.opencontainers.image.licenses" = "MIT"
    "org.opencontainers.image.source"  = "https://github.com/recap-org/recap"
    "org.recap.release.cycle"          = RECAP_RELEASE
    "org.recap.ubuntu.version"          = UBUNTU_VERSION
    "org.recap.miktex.version"          = MIKTEX_VERSION
    "org.recap.tex-fmt.version"          = TEX_FMT_VERSION
  }
}

target "extra" {
  contexts = {
    core = "target:core"
  }
}

group "default" {
  targets = ["core", "r", "stata"]
}

group "core" {
  targets = ["core"]
}

group "extra" {
  targets = ["r", "stata"]
}

target "core" {
  inherits = ["common"]
  dockerfile = "core/Dockerfile"
  args = {
    UBUNTU_VERSION       = UBUNTU_VERSION
    MIKTEX_VERSION       = MIKTEX_VERSION
    TEX_FMT_VERSION      = TEX_FMT_VERSION
    COOKIECUTTER_VERSION = COOKIECUTTER_VERSION
    R_VERSION          = R_VERSION
    QUARTO_VERSION     = QUARTO_VERSION
    RADIAN_VERSION     = RADIAN_VERSION
    STATA_VERSION      = STATA_VERSION
  }
  labels = {
    "org.opencontainers.image.version" = IMAGE_VERSION
    "org.opencontainers.image.title"="RECAP Core"
    "org.opencontainers.image.description"="Core RECAP development environment with MikTeX and common utilities"
  }
  tags = [
    "ghcr.io/recap-org/core:${IMAGE_VERSION}",
    "ghcr.io/recap-org/core:${RECAP_RELEASE}",
    "ghcr.io/recap-org/core:latest"
  ]
}

target "r" {
  inherits = ["common", "extra"]
  contexts = {
    core = "target:core"
  }
  dockerfile = "r/Dockerfile"
  labels = {
    "org.opencontainers.image.version"     = IMAGE_VERSION
    "org.opencontainers.image.title"       = "RECAP R"
    "org.opencontainers.image.description" = "R RECAP development environment with MikTeX, R and Quarto"
    "org.recap.r.version"                  = R_VERSION
    "org.recap.quarto.version"             = QUARTO_VERSION
    "org.recap.radian.version"             = RADIAN_VERSION
  }
  tags = [
    "ghcr.io/recap-org/r:${IMAGE_VERSION}",
    "ghcr.io/recap-org/r:${RECAP_RELEASE}",
    "ghcr.io/recap-org/r:latest"
  ]
}

target "stata" {
  inherits = ["common", "extra"]
  platforms = ["linux/amd64"]
  contexts = {
    core = "target:core"
  }
  dockerfile = "stata/Dockerfile"
  labels = {
    "org.opencontainers.image.version"     = IMAGE_VERSION
    "org.opencontainers.image.title"       = "RECAP Stata"
    "org.opencontainers.image.description" = "Stata RECAP development environment with MikTeX and Stata"
    "org.recap.stata.version"              = STATA_VERSION
  }
  tags = [
    "ghcr.io/recap-org/stata:${IMAGE_VERSION}",
    "ghcr.io/recap-org/stata:${RECAP_RELEASE}",
    "ghcr.io/recap-org/stata:latest"
  ]
}