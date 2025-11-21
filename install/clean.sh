#!/usr/bin/env bash

set -euo pipefail

source ./envpaths.sh

echo "Cleaning selected components..."

# CrocoDash
if [[ "$INSTALL_CROCODASH" -eq 1 ]] && [ -d "$CROCODASH_PATH" ]; then
    echo "Removing CrocoDash..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CROCODASH_PATH" 2>/dev/null || true
    git rm -f "$CROCODASH_PATH" 2>/dev/null || true
    rm -rf "$CROCODASH_PATH"
    rm -rf ".git/modules/$CROCODASH_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CROCODASH_PATH" 2>/dev/null || true
    echo "CrocoDash removed."
fi

# CrocoCamp
if [[ "$INSTALL_CROCOCAMP" -eq 1 ]] && [ -d "$CROCOCAMP_PATH" ]; then
    echo "Removing CrocoCamp..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CROCOCAMP_PATH" 2>/dev/null || true
    git rm -f "$CROCOCAMP_PATH" 2>/dev/null || true
    rm -rf "$CROCOCAMP_PATH"
    rm -rf ".git/modules/$CROCOCAMP_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CROCOCAMP_PATH" 2>/dev/null || true
    echo "CrocoCamp removed."
fi

# CUPiD
if [[ "$INSTALL_CUPID" -eq 1 ]] && [ -d "$CUPID_PATH" ]; then
    echo "Removing CUPiD..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CUPID_PATH" 2>/dev/null || true
    git rm -f "$CUPID_PATH" 2>/dev/null || true
    rm -rf "$CUPID_PATH"
    rm -rf ".git/modules/$CUPID_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CUPID_PATH" 2>/dev/null || true
    echo "CUPiD removed."
fi

# CESM
if [[ "$INSTALL_CESM" -eq 1 ]] && [ -d "$CESM_PATH" ]; then
    echo "Removing CESM..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CESM_PATH" 2>/dev/null || true
    git rm -f "$CESM_PATH" 2>/dev/null || true
    rm -rf "$CESM_PATH"
    rm -rf ".git/modules/$CESM_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CESM_PATH" 2>/dev/null || true
    echo "CESM removed."
fi

echo "Cleanup complete."
