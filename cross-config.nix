{ config, lib, pkgs, ... }: let
  toplevel = import ./default.nix { inherit pkgs; };
in {
  nixpkgs = {
    inherit (toplevel) crossSystem;
    overlays = toplevel.crossOverlays;
  };

  # disable more stuff to minimize cross-compilation
  # some from: https://github.com/illegalprime/nixos-on-arm/blob/master/images/mini/default.nix
  environment.noXlibs = true;
  documentation.info.enable = false;
  documentation.man.enable = false;
  programs.command-not-found.enable = false;
  security.polkit.enable = false;
  security.audit.enable = false;
  services.udisks2.enable = false;
  boot.enableContainers = false;
}
