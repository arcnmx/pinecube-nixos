{ pkgs ? import <nixpkgs> { } }: with pkgs.lib; let
  nixpkgsPinned = builtins.fetchTarball {
    # curl -v https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.xz
    name = "source";
    url = "https://releases.nixos.org/nixos/unstable-small/nixos-21.11pre300992.ce35e2852d2/nixexprs.tar.xz";
    sha256 = "19m6nhlvp9m6zf3glyywlgwg7d77idryqia9nnf75zh7c2xkwdfh";
  };
  pkgsPinned = import nixpkgsPinned { };
  pinned = import ./. {
    pkgs = pkgsPinned;
  };
  crossSystem = systems.examples.armv7l-hf-multiplatform // {
    gcc = {
      arch = "armv7-a";
      tune = "cortex-a7";
      #cpu = "cortex-a7+mp";
      #fpu = "vfpv3-d16";
      fpu = "neon-vfpv4";
    };
    name = "pinecube";
    linux-kernel = systems.platforms.armv7l-hf-multiplatform.linux-kernel // {
      name = "pinecube";
      # sunxi_defconfig is missing wireless support
      # TODO: Are all of these options needed here?
      baseConfig = "sunxi_defconfig";
      extraConfig = ''
        CFG80211 m
        WIRELESS y
        WLAN y
        RFKILL y
        RFKILL_INPUT y
        RFKILL_GPIO y
        KERNEL_LZMA y
      '';
    };
  };
  overlays = [ ];
  crossOverlays = [
    (import ./overlay.nix)
  ];
  crossPkgs = import pkgs.path {
    inherit crossSystem crossOverlays overlays;
  };
  nixosConfig = import ./sd-image.nix;
  nixos = crossPkgs.nixos nixosConfig;
in {
  inherit (nixos) config;
  inherit (nixos.config.system.build) sdImage;
  inherit
    nixpkgsPinned pinned pkgs
    nixosConfig nixos
    crossPkgs crossSystem crossOverlays overlays;
}
