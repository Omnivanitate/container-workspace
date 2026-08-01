#!/bin/sh
set -eu

echo "Start special pull"

env -C /home/devuser/.local/share/chezmoi git submodule update --init --recursive
env -C "${HOME}/.config/nvim" git submodule update --init --recursive

echo "End special pull"
