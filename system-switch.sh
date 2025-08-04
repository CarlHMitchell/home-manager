#! /usr/bin/env sh

SYSTEM_RESULT_DIR="$(nix run 'github:numtide/system-manager' -- build --flake '.' 2>/dev/null)"
sudo "${SYSTEM_RESULT_DIR}/bin/activate"
