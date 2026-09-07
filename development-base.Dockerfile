# syntax=docker/dockerfile:1

ARG BASE_IMAGE=debian:trixie
FROM ${BASE_IMAGE}

ARG UID=1000
ARG USER_GID=1000
ARG USERNAME=devuser

ARG HOME=/home/${USERNAME}
ARG PROGRAMS_DIR=${HOME}/.local
ARG CHEZMOI_PROGRAM_PATH=${PROGRAMS_DIR}/bin

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

USER ${USERNAME}

RUN curl -fsLS https://get.chezmoi.io \
    | sh -s -- -b "${CHEZMOI_PROGRAM_PATH}" \
    && test -x "${CHEZMOI_PROGRAM_PATH}/chezmoi" \
    && "${CHEZMOI_PROGRAM_PATH}/chezmoi" --version

WORKDIR /home/${USERNAME}
