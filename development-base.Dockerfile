# syntax=docker/dockerfile:1

ARG BASE_IMAGE=debian:trixie
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ARG UID=1000
ARG USER_GID=1000
ARG USERNAME=devuser

ARG HOME=/home/${USERNAME}
ARG PROGRAMS_DIR=${HOME}/.local
ARG CHEZMOI_PROGRAM_PATH=${PROGRAMS_DIR}/bin

ENV PROGRAMS_DIR="${PROGRAMS_DIR}" \
    CHEZMOI_PROGRAM_PATH="${CHEZMOI_PROGRAM_PATH}"
ENV PATH="${CHEZMOI_PROGRAM_PATH}:${PATH}"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        curl \
        git \
        sudo \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --home-dir "${HOME}" \
        --no-log-init \
        --shell /bin/bash \
        "${USERNAME}" \
    && usermod --append --groups sudo "${USERNAME}"

USER ${USERNAME}

RUN mkdir -p "${CHEZMOI_PROGRAM_PATH}" \
    && curl -fsLS https://get.chezmoi.io | sh -s -- -b "${CHEZMOI_PROGRAM_PATH}" \
    && test -x "${CHEZMOI_PROGRAM_PATH}/chezmoi" \
    && chezmoi --version

WORKDIR "${HOME}"
