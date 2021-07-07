#!/usr/bin/env bash

# curl -v https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.xz
NIXPKGS_PIN=https://releases.nixos.org/nixos/unstable-small/nixos-21.11pre300992.ce35e2852d2/nixexprs.tar.xz

nix-build . \
    -I nixpkgs=$NIXPKGS_PIN \
    -A sdImage
