#!/usr/bin/env bash

set -euo pipefail

source ./envpaths.sh

echo "Cleaning selected components..."

# CrocoDash
if [[ "$INSTALL_CROCODASH" -eq 1 ]]; then
    echo "Removing CrocoDash..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CROCODASH_PATH" 2>/dev/null || true
    git rm -rf --cached "$CROCODASH_PATH" 2>/dev/null || true
    rm -rf "$CROCODASH_PATH"
    rm -rf ".git/modules/$CROCODASH_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CROCODASH_PATH" 2>/dev/null || true
    echo "CrocoDash removed."
fi

# model2obs
if [[ "$INSTALL_MODEL2OBS" -eq 1 ]]; then
    echo "Removing model2obs..."
    cd "$BASK_PATH"
    git submodule deinit -f "$MODEL2OBS_PATH" 2>/dev/null || true
    git rm -rf --cached "$MODEL2OBS_PATH" 2>/dev/null || true
    rm -rf "$MODEL2OBS_PATH"
    rm -rf ".git/modules/$MODEL2OBS_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$MODEL2OBS_PATH" 2>/dev/null || true
    echo "model2obs removed."
fi

# CUPiD
if [[ "$INSTALL_CUPID" -eq 1 ]]; then
    echo "Removing CUPiD..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CUPID_PATH" 2>/dev/null || true
    git rm -rf --cached "$CUPID_PATH" 2>/dev/null || true
    rm -rf "$CUPID_PATH"
    rm -rf ".git/modules/$CUPID_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CUPID_PATH" 2>/dev/null || true
    echo "CUPiD removed."
fi

# CESM
if [[ "$INSTALL_CESM" -eq 1 ]]; then
    echo "Removing CESM..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CESM_PATH" 2>/dev/null || true
    git rm -rf --cached "$CESM_PATH" 2>/dev/null || true
    rm -rf "$CESM_PATH"
    rm -rf ".git/modules/$CESM_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CESM_PATH" 2>/dev/null || true
    echo "CESM removed."
fi

echo "Cleanup complete."
