#!/usr/bin/env sh

set -euo pipefail

source ./envpaths.sh
#### CrocoDash

if [[ "$INSTALL_CROCODASH" -eq 1 ]]; then
    echo "Downloading CrocoDash..."
    git submodule add https://github.com/CROCODILE-CESM/CrocoDash.git "$CROCODASH_PATH"
    cd "$CROCODASH_PATH"
    git fetch --tags
    git checkout v0.1.0-beta
    cd "$BASK_PATH"
    # git add "$CROCODASH_PATH"
    # git add .gitmodules
    # git commit -m "Add submodule CrocoDash pinned at v0.1.0-beta"
    cd "$CROCODASH_PATH"
    git submodule update --init --recursive
    cd "$BASK_PATH"
    echo "CrocoDash downloaded."
fi
#### CrocoCamp

if [[ "$INSTALL_CROCOCAMP" -eq 1 ]]; then
    echo "Downloading CrocoCamp..."
    git submodule add https://github.com/CROCODILE-CESM/CrocoCamp.git "$CROCOCAMP_PATH"
    cd "$CROCOCAMP_PATH"
    git fetch --tags
    git checkout 90b391c
    cd "$BASK_PATH"
    # git add "$CROCOCAMP_PATH"
    # git add .gitmodules
    # git commit -m "Add submodule CrocoCamp pinned at v0.2.0"
    echo "CrocoCamp downloaded."
fi

#### CUPiD

if [[ "$INSTALL_CROCOCAMP" -eq 1 ]]; then
    echo "Downloading CUPiD..."
    git submodule add https://github.com/NCAR/CUPiD.git "$CUPID_PATH"
    cd "$CUPID_PATH"
    git fetch --tags
    git checkout v0.3.1
    cd "$BASK_PATH"
    # git add "$CUPID_PATH"
    # git add .gitmodules
    # git commit -m "Add submodule CUPiD pinned at v0.3.1"
    cd "$CUPID_PATH"
    git submodule update --init --recursive
    cd "$BASK_PATH"
    echo "CUPiD downloaded."
fi

