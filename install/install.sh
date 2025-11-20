#!/usr/bin/env sh

set -euo pipefail

./generate_envpaths.sh "$@" # pass all flags
./init.sh
source ./envpaths.sh

# CrocoDash
if [[ "$INSTALL_CROCODASH" -eq 1 ]]; then
    echo "Installing CrocoDash environment..."
    ENV_NAME=$(yq -r '.name' "$CROCODASH_PATH"/environment.yml)
    NEW_ENV_NAME="bask_${ENV_NAME}"
    mamba env create -f "$CROCODASH_PATH"/environment.yml --name ${NEW_ENV_NAME} --yes
    echo "CrocoDash environment installed."
fi

# CrocoCamp
if [[ "$INSTALL_CROCOCAMP" -eq 1 ]]; then
    echo "Installing CrocoCamp environment..."
    cd "$CROCOCAMP_PATH"/install
    cp envpaths.sh.template envpaths.sh
    DART_ROOT_PATH=${DART_PATH} ./install.sh
    cd "$BASK_PATH"
    echo "CrocoCamp environment installed."
fi

# CUPiD
if [[ "$INSTALL_CROCOCAMP" -eq 1 ]]; then
    echo "Installing CUPiD environments..."

    ENV_NAME=$(yq -r '.name' "$CUPID_PATH"/cupid-infrastructure.yml)
    NEW_ENV_NAME="bask_${ENV_NAME}"
    mamba env create -f "$CUPID_PATH"/environments/cupid-infrastructure.yml --name ${NEW_ENV_NAME} --yes

    ENV_NAME=$(yq -r '.name' "$CUPID_PATH"/cupid-analysis.yml)
    NEW_ENV_NAME="bask_${ENV_NAME}"
    mamba env create -f "$CUPID_PATH"/environments/cupid-analysis.yml --name ${NEW_ENV_NAME} --yes

    echo "CUPiD environments installed."
fi
