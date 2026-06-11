#!/usr/bin/env bash

set -euo pipefail

source ./envpaths.sh

# Set GitHub URLs based on SSH_GITHUB flag
if [[ "$SSH_GITHUB" -eq 1 ]]; then
    CROCODASH_GITHUB="git@github.com:CROCODILE-CESM/CrocoDash.git"
    MODEL2OBS_GITHUB="git@github.com:CROCODILE-CESM/model2obs.git"
    CUPID_GITHUB="git@github.com:NCAR/CUPiD.git"
    CESM_GITHUB="git@github.com:CROCODILE-CESM/CESM"
else
    CROCODASH_GITHUB="https://github.com/CROCODILE-CESM/CrocoDash.git"
    MODEL2OBS_GITHUB="https://github.com/CROCODILE-CESM/model2obs.git"
    CUPID_GITHUB="https://github.com/NCAR/CUPiD.git"
    CESM_GITHUB="https://github.com/CROCODILE-CESM/CESM"
fi

#### CrocoDash

if [[ "$INSTALL_CROCODASH" -eq 1 ]]; then
    if [ -d "$CROCODASH_PATH" ]; then
        echo "CrocoDash already exists at $CROCODASH_PATH. Use -f or --force to reinstall."
    else
        echo "Downloading CrocoDash..."
        git submodule add "$CROCODASH_GITHUB" "$CROCODASH_PATH"
        cd "$CROCODASH_PATH"
        git fetch --tags
        git checkout v0.1.0-beta
        cd "$BASK_PATH"
        cd "$CROCODASH_PATH"
        git submodule update --init --recursive
        cd "$BASK_PATH"
        echo "CrocoDash downloaded."
    fi
fi
#### model2obs

if [[ "$INSTALL_MODEL2OBS" -eq 1 ]]; then
    if [ -d "$MODEL2OBS_PATH" ]; then
        echo "model2obs already exists at $MODEL2OBS_PATH. Use -f or --force to reinstall."
    else
        echo "Downloading model2obs..."
        git submodule add "$MODEL2OBS_GITHUB" "$MODEL2OBS_PATH"
        cd "$MODEL2OBS_PATH"
        git fetch --tags
        git checkout 4b785f3
        cd "$BASK_PATH"
        echo "model2obs downloaded."
    fi
fi

#### CUPiD

if [[ "$INSTALL_CUPID" -eq 1 ]]; then
    if [ -d "$CUPID_PATH" ]; then
        echo "CUPiD already exists at $CUPID_PATH. Use -f or --force to reinstall."
    else
        echo "Downloading CUPiD..."
        git submodule add "$CUPID_GITHUB" "$CUPID_PATH"
        cd "$CUPID_PATH"
        git fetch --tags
        git checkout v0.3.1
        cd "$BASK_PATH"
        cd "$CUPID_PATH"
        git submodule update --init --recursive
        cd "$BASK_PATH"
        echo "CUPiD downloaded."
    fi
fi

#### CESM

if [[ "$INSTALL_CESM" -eq 1 ]]; then
    if [ -d "$CESM_PATH" ]; then
        echo "CESM already exists at $CESM_PATH. Use -f or --force to reinstall."
    else
        echo "Downloading CESM..."
        git submodule add -b workshop_2025 "$CESM_GITHUB" "$CESM_PATH"
        cd "$CESM_PATH"
        git pull
        echo "CESM downloaded."
    fi
fi
