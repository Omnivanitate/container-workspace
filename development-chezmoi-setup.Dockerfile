# syntax=docker/dockerfile:1

ARG BASE_IMAGE=development-base:latest
FROM ${BASE_IMAGE}

ARG USERNAME=devuser

ARG LOCAL_CHEZMOI_CONFIG=./default_chezmoi.toml
ARG GITHUB_USER=Omnivanitate
ARG DOTFILES_REPO=

ARG HOME=/home/${USERNAME}

USER root

RUN printf '%s\n' "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

USER ${USERNAME}

# Configure chezmoi
RUN mkdir -p "${HOME}/.config/chezmoi"

COPY --chown="${USERNAME}:${USERNAME}" "${LOCAL_CHEZMOI_CONFIG}" \
    "${HOME}/.config/chezmoi/chezmoi.toml"

# Apply the dotfiles from DOTFILES_REPO or from GITHUB_USER's "dotfiles" repository
RUN if [ -n "${DOTFILES_REPO}" ]; then \
        chezmoi init --recurse-submodules=false --apply "${DOTFILES_REPO}"; \
    elif [ -n "${GITHUB_USER}" ]; then \
        chezmoi init --recurse-submodules=false --apply "${GITHUB_USER}"; \
    fi

# Drop the passwordless sudo access used for the dotfiles installation
USER root
RUN rm -f "/etc/sudoers.d/${USERNAME}"
USER ${USERNAME}

WORKDIR "${HOME}"

CMD ["start-shell.sh"]
