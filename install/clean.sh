#!/usr/bin/env bash

set -euo pipefail

# Check for help flag only if arguments are provided
if [[ $# -gt 0 ]]; then
    for arg in "$@"; do
        if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
            cat << EOF
Usage: ./clean.sh [OPTIONS]

Package Selection:
  --cesm            Remove CESM model
  --model2obs       Remove model2obs diagnostics tools
  --crocodash       Remove CrocoDash model components
  --cupid           Remove CUPiD diagnostics framework
  --dart            Remove DART data assimilation system
  --all             Remove all packages

Options:
  -h, --help        Display this help message

Examples:
  ./clean.sh --crocodash
  ./clean.sh --all
  ./clean.sh --cesm --model2obs

Notes:
  - Multiple flags can be combined
  - Without flags, uses envpaths.sh if it exists
EOF
            exit 0
        fi
    done
fi

# If no arguments provided, use envpaths.sh (preserves original behavior when called from install.sh)
PKGS=(CESM MODEL2OBS CROCODASH CUPID DART)
source ./envpaths.sh

if [[ $# -eq 0 ]]; then
    # Export CLEAN_* variables
    for PKG in "${PKGS[@]}"; do
        export "CLEAN_${PKG}"="$(eval echo \${INSTALL_${PKG}})"
    done
else
    # Initialize all packages to 0
    for PKG in "${PKGS[@]}"; do
        export "CLEAN_${PKG}=0"
    done
    
    # Parse arguments
    for ((i=1; i<=$#; i++)); do
        arg="${!i}"
        
        case "$arg" in
            --all)
                for PKG in "${PKGS[@]}"; do
                    export "CLEAN_${PKG}=1"
                done
                ;;
            *)
                upper="${arg#--}"
                upper="${upper^^}"
                for PKG in "${PKGS[@]}"; do
                    if [[ "$PKG" == "$upper" ]]; then
                        export "CLEAN_${upper}=1"
                        break
                    fi
                done
                ;;
        esac
    done
fi

echo "Cleaning selected components..."

# CrocoDash
if [ "$CLEAN_CROCODASH" -eq 1 ] && [ -e "$CROCODASH_PATH" ]; then
    echo "Removing CrocoDash..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CROCODASH_PATH" 2>/dev/null || true
    git rm -f "$CROCODASH_PATH" 2>/dev/null || true
    rm -rf "$CROCODASH_PATH"
    rm -rf ".git/modules/$CROCODASH_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CROCODASH_PATH" 2>/dev/null || true
    git add .gitmodules 2>/dev/null || true
    echo "CrocoDash removed."
fi

# model2obs
if [ "$CLEAN_MODEL2OBS" -eq 1 ] && [ -n "$MODEL2OBS_PATH" ]; then
    echo "Removing model2obs..."
    cd "$BASK_PATH"
    git submodule deinit -f "$MODEL2OBS_PATH" 2>/dev/null || true
    git rm -f "$MODEL2OBS_PATH" 2>/dev/null || true
    rm -rf "$MODEL2OBS_PATH"
    rm -rf ".git/modules/$MODEL2OBS_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$MODEL2OBS_PATH" 2>/dev/null || true
    git add .gitmodules 2>/dev/null || true
    echo "model2obs removed."
fi

# CUPiD
if [ "$CLEAN_CUPID" -eq 1 ] && [ -n "$CUPID_PATH" ]; then
    echo "Removing CUPiD..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CUPID_PATH" 2>/dev/null || true
    git rm -f "$CUPID_PATH" 2>/dev/null || true
    rm -rf "$CUPID_PATH"
    rm -rf ".git/modules/$CUPID_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CUPID_PATH" 2>/dev/null || true
    git add .gitmodules 2>/dev/null || true
    echo "CUPiD removed."
fi

# CESM
if [ "$CLEAN_CESM" -eq 1 ] && [ -n "$CESM_PATH" ]; then
    echo "Removing CESM..."
    cd "$BASK_PATH"
    git submodule deinit -f "$CESM_PATH" 2>/dev/null || true
    git rm -f "$CESM_PATH" 2>/dev/null || true
    rm -rf "$CESM_PATH"
    rm -rf ".git/modules/$CESM_PATH" 2>/dev/null || true
    git config -f .gitmodules --remove-section "submodule.$CESM_PATH" 2>/dev/null || true
    git add .gitmodules 2>/dev/null || true
    echo "CESM removed."
fi

echo "Cleanup complete."
