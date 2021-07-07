#!/usr/bin/env bash

rm ./result*
nix-store --delete /nix/store/*-nixos-sd-image-*-armv7l-linux.img-armv7l-unknown-linux-gnueabihf
