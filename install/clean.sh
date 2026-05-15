#!/usr/bin/env bash

set -euo pipefail

source ./envpaths.sh

echo "Cleaning selected components..."

# Helper: strip BASK_PATH prefix to get repo-relative path for git commands
rel() { echo "${1#$BASK_PATH/}"; }

# CrocoDash
if [[ "$INSTALL_CROCODASH" -eq 1 ]]; then
    echo "Removing CrocoDash..."
    cd "$BASK_PATH"
    git submodule deinit -f "$(rel "$CROCODASH_PATH")" 2>/dev/null || true
    git rm -rf --cached "$(rel "$CROCODASH_PATH")" 2>/dev/null || true
    rm -rf "$CROCODASH_PATH"
    rm -rf ".git/modules/$(rel "$CROCODASH_PATH")" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$(rel "$CROCODASH_PATH")" 2>/dev/null || true
    echo "CrocoDash removed."
fi

# model2obs
if [[ "$INSTALL_MODEL2OBS" -eq 1 ]]; then
    echo "Removing model2obs..."
    cd "$BASK_PATH"
    git submodule deinit -f "$(rel "$MODEL2OBS_PATH")" 2>/dev/null || true
    git rm -rf --cached "$(rel "$MODEL2OBS_PATH")" 2>/dev/null || true
    rm -rf "$MODEL2OBS_PATH"
    rm -rf ".git/modules/$(rel "$MODEL2OBS_PATH")" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$(rel "$MODEL2OBS_PATH")" 2>/dev/null || true
    echo "model2obs removed."
fi

# CUPiD
if [[ "$INSTALL_CUPID" -eq 1 ]]; then
    echo "Removing CUPiD..."
    cd "$BASK_PATH"
    git submodule deinit -f "$(rel "$CUPID_PATH")" 2>/dev/null || true
    git rm -rf --cached "$(rel "$CUPID_PATH")" 2>/dev/null || true
    rm -rf "$CUPID_PATH"
    rm -rf ".git/modules/$(rel "$CUPID_PATH")" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$(rel "$CUPID_PATH")" 2>/dev/null || true
    echo "CUPiD removed."
fi

# CESM
if [[ "$INSTALL_CESM" -eq 1 ]]; then
    echo "Removing CESM..."
    cd "$BASK_PATH"
    git submodule deinit -f "$(rel "$CESM_PATH")" 2>/dev/null || true
    git rm -rf --cached "$(rel "$CESM_PATH")" 2>/dev/null || true
    rm -rf "$CESM_PATH"
    rm -rf ".git/modules/$(rel "$CESM_PATH")" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$(rel "$CESM_PATH")" 2>/dev/null || true
    echo "CESM removed."
fi

echo "Cleanup complete."
