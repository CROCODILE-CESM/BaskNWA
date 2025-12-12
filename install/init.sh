#!/usr/bin/env bash

set -euo pipefail

source ./envpaths.sh

# Set GitHub URLs based on SSH_GITHUB flag
if [[ "$SSH_GITHUB" -eq 1 ]]; then
    CROCODASH_GITHUB="git@github.com:CROCODILE-CESM/CrocoDash.git"
    CROCOCAMP_GITHUB="git@github.com:CROCODILE-CESM/CrocoCamp.git"
    CUPID_GITHUB="git@github.com:NCAR/CUPiD.git"
    CESM_GITHUB="git@github.com:CROCODILE-CESM/CESM"
else
    CROCODASH_GITHUB="https://github.com/CROCODILE-CESM/CrocoDash.git"
    CROCOCAMP_GITHUB="https://github.com/CROCODILE-CESM/CrocoCamp.git"
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
#### CrocoCamp

if [[ "$INSTALL_CROCOCAMP" -eq 1 ]]; then
    if [ -d "$CROCOCAMP_PATH" ]; then
        echo "CrocoCamp already exists at $CROCOCAMP_PATH. Use -f or --force to reinstall."
    else
        echo "Downloading CrocoCamp..."
        git submodule add "$CROCOCAMP_GITHUB" "$CROCOCAMP_PATH"
        cd "$CROCOCAMP_PATH"
        git fetch --tags
        git checkout 4b785f3
        cd "$BASK_PATH"
        echo "CrocoCamp downloaded."
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
