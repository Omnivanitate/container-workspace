# syntax=docker/dockerfile:1

ARG BASE_IMAGE=debian:trixie
FROM ${BASE_IMAGE}

ARG UID=1000
ARG USER_GID=1000
ARG USERNAME=devuser

ARG LOCAL_CHEZMOI_CONFIG="./default_chezmoi.toml"
ARG GITHUB_USER="Omnivanitate"
ARG DOTFILES_REPO=""
ARG CHEZMOI_PROFILE="default"

ARG HOME=/home/${USERNAME}
ENV PROGRAMS_DIR=${HOME}/.local
ENV CHEZMOI_PROGRAM_PATH=${PROGRAMS_DIR}/bin

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
    && usermod -aG sudo ${USERNAME}

RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

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
        chezmoi init --recurse-submodules=false --apply "${DOTFILES_REPO}"; \
    elif [ -n "${GITHUB_USER}" ]; then \
        chezmoi init --recurse-submodules=false --apply "${GITHUB_USER}"; \
    fi

RUN sudo rm -f /etc/sudoers.d/${USERNAME}

WORKDIR /home/${USERNAME}

CMD ["start-shell.sh"]
