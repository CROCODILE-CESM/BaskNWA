#!/usr/bin/env bash

set -euo pipefail

# Check for help flag
for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        cat << EOF
Usage: ./install.sh [OPTIONS]

Package Selection:
  --cesm            Install CESM model
  --model2obs       Install model2obs diagnostics tools
  --crocodash       Install CrocoDash model components
  --cupid           Install CUPiD diagnostics framework
  --dart            Install DART data assimilation system
  --all             Install all packages

Installation Options:
  -d, --default     Use default paths for all packages (non-interactive)
  -f, --force       Remove and reinstall selected packages if they already exist
  -s, --ssh-github  Use SSH URLs instead of HTTPS for GitHub submodules (requires SSH key)
  -e, --envname     Specify prefix for conda environment names (default: 'bask')
  -h, --help        Display this help message

Examples:
  ./install.sh --crocodash --model2obs -d
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
INSTALL_DIR="$PWD"
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
    CROCODASH_ENV_NAME="${ENV_PREFIX}-${ENV_NAME}"
    mamba env create -f "$CROCODASH_PATH"/environment.yml --name ${CROCODASH_ENV_NAME} --yes
    add_env_vars_to_conda "$CROCODASH_ENV_NAME"
    echo "CrocoDash environment installed."
fi

# model2obs
if [[ "$INSTALL_MODEL2OBS" -eq 1 ]]; then
    echo "Installing model2obs environment..."
    cd "$MODEL2OBS_PATH"/install
    cp envpaths.sh.template envpaths.sh
    MODEL2OBS_ENV_NAME="${ENV_PREFIX}-model2obs"
    DART_ROOT_PATH=${DART_PATH} CONDA_ENV_NAME=${MODEL2OBS_ENV_NAME} ./install.sh
    cd "$INSTALL_DIR"
    echo "model2obs environment installed."
fi

# CUPiD
if [[ "$INSTALL_CUPID" -eq 1 ]]; then
    echo "Installing CUPiD environments..."

    ENV_NAME=$(awk -F ": " '/^name:/ {print $2}' "$CUPID_PATH"/environments/cupid-infrastructure.yml)
    CUPID_ENV1_NAME="${ENV_PREFIX}-${ENV_NAME}"
    mamba env create -f "$CUPID_PATH"/environments/cupid-infrastructure.yml --name ${CUPID_ENV1_NAME} --yes
    add_env_vars_to_conda "$CUPID_ENV1_NAME"

    ENV_NAME=$(awk -F ": " '/^name:/ {print $2}' "$CUPID_PATH"/environments/cupid-analysis.yml)
    CUPID_ENV2_NAME="${ENV_PREFIX}-${ENV_NAME}"
    mamba env create -f "$CUPID_PATH"/environments/cupid-analysis.yml --name ${CUPID_ENV2_NAME} --yes
    add_env_vars_to_conda "$CUPID_ENV2_NAME"

    echo "CUPiD environments installed."
fi

# CESM
if [[ "$INSTALL_CESM" -eq 1 ]]; then
    echo "Installing CESM..."
    cd "$CESM_PATH"
    ./bin/git-fleximod update --path "$CESM_PATH"
    cd "$INSTALL_DIR"
    echo "CESM installed."
fi

echo ""
echo "------------------------------------------------------------------"
echo "Install complete."
echo "Components, environments and paths installed:"

if [[ "$INSTALL_CROCODASH" -eq 1 ]]; then
    echo "CrocoDash:"
    echo "  path: $CROCODASH_PATH"
    echo "  conda environments: $CROCODASH_ENV_NAME"
fi
if [[ "$INSTALL_CESM" -eq 1 ]]; then
    echo "CESM:"
    echo "  path: $CESM_PATH"
fi
if [[ "$INSTALL_MODEL2OBS" -eq 1 ]]; then
    echo "MODEL2OBS:"
    echo "  path: $MODEL2OBS_PATH"
    echo "  conda environment: $MODEL2OBS_ENV_NAME"
fi
if [[ "$INSTALL_CUPID" -eq 1 ]]; then
    echo "CUPiD:"
    echo "  path: $CUPID_PATH"
    echo "  conda environments: $CUPID_ENV1_NAME"
    echo "                      $CUPID_ENV2_NAME"
fi
