{ pkgs ? import <nixpkgs> { } }: with pkgs.lib; let
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
    nixosConfig nixos
    crossPkgs crossSystem crossOverlays overlays;
}
