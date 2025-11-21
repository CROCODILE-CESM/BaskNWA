#!/usr/bin/env bash

# Only enable strict mode if not being sourced
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && set -euo pipefail

export BASK_PATH="$(realpath -m "$(dirname "$PWD")")"

# Array of package names and their relative default paths
declare -A PKG_PATHS=(
    [CESM]="model/CESM"
    [CROCOCAMP]="diagnostics/CrocoCamp"
    [CROCODASH]="model/CrocoDash"
    [CUPID]="diagnostics/CUPiD"
    [DART]="data_assimilation/DART"
)

# Initialize flags to 0 and paths to empty
for PKG in "${!PKG_PATHS[@]}"; do
    declare "${PKG}=0"
    export "${PKG}_PATH="
done
DEFAULT=0
FORCE=0
SSH_GITHUB=0

# Register what packages need to be installed from CLI flags
for arg in "$@"; do
    case "$arg" in
        --cesm) CESM=1 ;;
        --crococamp) CROCOCAMP=1 ;;
        --crocodash) CROCODASH=1 ;;
        --cupid) CUPID=1 ;;
        --dart) DART=1 ;;
        --all)
            for PKG in "${!PKG_PATHS[@]}"; do
                declare "${PKG}=1"
            done
            ;;
        -d|--default) DEFAULT=1 ;;
        -f|--force) FORCE=1 ;;
        -s|--ssh-github) SSH_GITHUB=1 ;;
    esac
done

# Assign paths
if [[ "$DEFAULT" -eq 1 ]]; then
    for PKG in "${!PKG_PATHS[@]}"; do
        export "${PKG}_PATH"="$(realpath -m "$BASK_PATH/${PKG_PATHS[$PKG]}")"
        echo "$PKG root path set to $(eval echo \${${PKG}_PATH})"
    done
elif [ -t 0 ]; then
    for PKG in "${!PKG_PATHS[@]}"; do
        DEF="$BASK_PATH/${PKG_PATHS[$PKG]}"
        printf "Please provide %s root path (default: %s): " "$PKG" "$DEF"
        read input_path
        if [ -n "$input_path" ]; then
            export "${PKG}_PATH"="$(realpath -m "$input_path")"
        else
            export "${PKG}_PATH"="$(realpath -m "$DEF")"
        fi
        echo "$PKG root path set to $(eval echo \${${PKG}_PATH})"
    done
fi

# Write all paths to envpaths.sh
ENV_FILE="envpaths.sh"
: > "$ENV_FILE"  # Truncate file

echo "export BASK_PATH=\"${BASK_PATH}\"" >> "$ENV_FILE"
for PKG in "${!PKG_PATHS[@]}"; do
    # Use eval to expand the actual value of the variable
    VAL=$(eval echo "\${${PKG}_PATH}")
    echo "export ${PKG}_PATH=\"$VAL\"" >> "$ENV_FILE"
done
for PKG in "${!PKG_PATHS[@]}"; do
    # Use eval to expand the actual value of the variable
    VAL=$(eval echo "\${${PKG}}")
    echo "export INSTALL_${PKG}=\"$VAL\"" >> "$ENV_FILE"
done
echo "export FORCE=\"$FORCE\"" >> "$ENV_FILE"
echo "export SSH_GITHUB=\"$SSH_GITHUB\"" >> "$ENV_FILE"
