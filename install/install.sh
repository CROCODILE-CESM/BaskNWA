#!/usr/bin/env bash

set -euo pipefail

# Check for help flag
for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        cat << EOF
Usage: ./install.sh [OPTIONS]

Package Selection:
  --cesm            Install CESM model
  --crococamp       Install CrocoCamp diagnostics tools
  --crocodash       Install CrocoDash model components
  --cupid           Install CUPiD diagnostics framework
  --dart            Install DART data assimilation system
  --all             Install all packages

Installation Options:
  -d, --default     Use default paths for all packages (non-interactive)
  -f, --force       Remove and reinstall selected packages if they already exist
  -s, --ssh-github  Use SSH URLs instead of HTTPS for GitHub submodules (requires SSH key)
  -h, --help        Display this help message

Examples:
  ./install.sh --crocodash --crococamp -d
  ./install.sh --all --default
  ./install.sh --cesm -d -f
  ./install.sh --crocodash --cupid -d -s

Notes:
  - Multiple flags can be combined
  - Without -d/--default, the script will prompt for custom paths
  - If a package already exists, it will be skipped unless -f/--force is used
EOF
        exit 0
    fi
done

# generate environmental variables
./generate_envpaths.sh "$@" # pass all flags

# clean already installed submodules
source ./envpaths.sh
if [[ "$FORCE" -eq 1 ]]; then
    ./clean.sh
fi

# download submodules
./init.sh

# install submodules

# Source helper function
source ./setup_conda_env.sh

# CrocoDash
if [[ "$INSTALL_CROCODASH" -eq 1 ]]; then
    echo "Installing CrocoDash environment..."
    ENV_NAME=$(awk -F ": " '/^name:/ {print $2}' "$CROCODASH_PATH/environment.yml")
    NEW_ENV_NAME="bask-${ENV_NAME}"
    mamba env create -f "$CROCODASH_PATH"/environment.yml --name ${NEW_ENV_NAME} --yes
    add_env_vars_to_conda "$NEW_ENV_NAME"
    echo "CrocoDash environment installed."
fi

# CrocoCamp
if [[ "$INSTALL_CROCOCAMP" -eq 1 ]]; then
    echo "Installing CrocoCamp environment..."
    cd "$CROCOCAMP_PATH"/install
    cp envpaths.sh.template envpaths.sh
    DART_ROOT_PATH=${DART_PATH} CONDA_ENV_NAME="bask-crococamp" ./install.sh
    cd "$BASK_PATH"
    echo "CrocoCamp environment installed."
fi

# CUPiD
if [[ "$INSTALL_CUPID" -eq 1 ]]; then
    echo "Installing CUPiD environments..."

    ENV_NAME=$(awk -F ": " '/^name:/ {print $2}' "$CUPID_PATH"/environments/cupid-infrastructure.yml)
    NEW_ENV_NAME="bask-${ENV_NAME}"
    mamba env create -f "$CUPID_PATH"/environments/cupid-infrastructure.yml --name ${NEW_ENV_NAME} --yes
    add_env_vars_to_conda "$NEW_ENV_NAME"

    ENV_NAME=$(awk -F ": " '/^name:/ {print $2}' "$CUPID_PATH"/environments/cupid-analysis.yml)
    NEW_ENV_NAME="bask-${ENV_NAME}"
    mamba env create -f "$CUPID_PATH"/environments/cupid-analysis.yml --name ${NEW_ENV_NAME} --yes
    add_env_vars_to_conda "$NEW_ENV_NAME"

    echo "CUPiD environments installed."
fi

# CESM
if [[ "$INSTALL_CESM" -eq 1 ]]; then
    echo "Installing CESM..."
    cd "$CESM_PATH"
    ./bin/git-fleximod update
    echo "CESM installed."
fi
