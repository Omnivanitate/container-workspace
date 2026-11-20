# Container workspace

A project for starting development inside a container.

## Images

- `development-base.Dockerfile`: Debian-based development image with `curl`,
  `git`, `sudo`, a non-root user, and `chezmoi` installed.
- `development-chezmoi-setup.Dockerfile`: builds on top of the base image,
  configures chezmoi, and applies the dotfiles.

## Build

```sh
docker build --file development-base.Dockerfile --tag development-base .
docker build --file development-chezmoi-setup.Dockerfile --tag development-chezmoi-setup .
```

The setup image can be pointed at another dotfiles repository:

```sh
docker build --file development-chezmoi-setup.Dockerfile \
    --build-arg DOTFILES_REPO=https://github.com/example/dotfiles.git \
    --tag development-chezmoi-setup .
```

## Run

```sh
docker run --rm -it development-chezmoi-setup
```
