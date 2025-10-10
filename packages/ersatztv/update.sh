#!/usr/bin/env bash

set -euo pipefail

# Just use nix-update with stable flag - it handles everything including .NET deps
nix-update --flake --version=stable ersatztv

# Update nuget deps if the package was updated
if git diff --quiet packages/ersatztv/default.nix; then
  echo "No changes detected"
else
  echo "Updating nuget dependencies..."
  NIXPKGS_ALLOW_UNFREE=1 $(nix build .#ersatztv.fetch-deps --impure --no-link --print-out-paths) packages/ersatztv/nuget-deps.nix
fi
