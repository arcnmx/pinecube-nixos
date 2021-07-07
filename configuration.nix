{ config, lib, pkgs, ... }:

{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.consoleLogLevel = 7;

  # cma is 64M by default which is waay too much and we can't even unpack initrd
  boot.kernelParams = [ "console=ttyS0,115200n8" "cma=32M" ];

  # See: https://lore.kernel.org/patchwork/project/lkml/list/?submitter=22013&order=name
  boot.kernelPackages = pkgs.linuxPackages_5_13;
  boot.kernelPatches = [
    { name = "ks8551-fix-build";
      patch = pkgs.fetchpatch {
        url = "https://patches.linaro.org/series/97185/mbox/";
        sha256 = "10vcfch1bfxbf9gdxycmi5gzp9gi9i6fxqqwbbs7ngcprlvy87i9";
      };
    }
    { name = "pine64-pinecube";
      patch = ./kernel/Pine64-PineCube-support.patch;
    }
  ];
  boot.initrd = {
    includeDefaultModules = false;
    availableKernelModules = lib.mkForce [
      "mmc_block"
      "usbhid"
      "hid_generic" "hid_lenovo" "hid_apple" "hid_roccat"
      "hid_logitech_hidpp" "hid_logitech_dj" "hid_microsoft"
    ];
  };

  boot.kernelModules = [ "spi-nor" ]; # Not sure why this doesn't autoload. Provides SPI NOR at /dev/mtd0
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8189es ];

  zramSwap.enable = true; # 128MB is not much to work with

  sound.enable = true;

  environment.systemPackages = with pkgs; with gst_all_1; [
    ffmpeg
    v4l_utils
    usbutils
    gstreamer.dev
  ];
  environment.sessionVariables = {
    GST_PLUGIN_SYSTEM_PATH_1_0 = with pkgs.gst_all_1; lib.makeSearchPath "lib/gstreamer-1.0" [
      gstreamer
      gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
    ];
  };

  ###

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  users.users.root.initialPassword = "nixos"; # Log in without a password

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "nixos";
  };
  services.getty.autologinUser = "nixos";

  networking.wireless.enable = true;

}
