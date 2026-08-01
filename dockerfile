# syntax=docker/dockerfile:1

ARG BASE_IMAGE=debian:trixie
FROM ${BASE_IMAGE}

ARG GITHUB_USER="Omnivanitate"
ARG DOTFILES_REPO=""
ARG CHEZMOI_PROFILE="default"

ARG UID=1000
ARG USER_GID=1000
ARG LOCAL_CHEZMOI_CONFIG="./default_chezmoi.toml"
ARG USERNAME=devuser

ENV HOME=/home/${USERNAME}
ENV PROGRAMS_DIR=${HOME}/.local
ENV CHEZMOI_PROGRAM_PATH=${PROGRAMS_DIR}/bin
ENV USER=${USERNAME}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt update && apt upgrade -y \
    && apt install -y \
        curl \
        git \
        sudo

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${UID} \
        --gid ${USER_GID} \
        --create-home \
        --shell /bin/bash \
            ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


USER ${USERNAME}

#install chezmoi
RUN mkdir -p "${CHEZMOI_PROGRAM_PATH}" \
    && mkdir -p "${HOME}/.config/chezmoi"

COPY --chown=${USERNAME}:${USERNAME} ${LOCAL_CHEZMOI_CONFIG} \
    ${HOME}/.config/chezmoi/chezmoi.toml

RUN curl -fsLS https://get.chezmoi.io \
    | sh -s -- -b "${CHEZMOI_PROGRAM_PATH}" \
    && test -x "${CHEZMOI_PROGRAM_PATH}/chezmoi" \
    && "${CHEZMOI_PROGRAM_PATH}/chezmoi" --version


ENV PATH="${PROGRAMS_DIR}/bin:${PATH}"

RUN if [ -n "${DOTFILES_REPO}" ]; then \
        CHEZMOI_PROFILE="${CHEZMOI_PROFILE}" \
        chezmoi init --recurse-submodules=false --apply "${DOTFILES_REPO}"; \
    elif [ -n "${GITHUB_USER}" ]; then \
        CHEZMOI_PROFILE="${CHEZMOI_PROFILE}" \
        chezmoi init --recurse-submodules=false --apply "${GITHUB_USER}"; \
    fi


WORKDIR /home/${USER}

CMD ["start-shell.sh"]
