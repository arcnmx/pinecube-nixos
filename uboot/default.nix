{ lib, buildUBoot }: with lib;

buildUBoot {
  patches = [
    ./Pine64-PineCube-uboot-support.patch
  ];

  defconfig = "pinecube_defconfig";

  extraConfig = concatStringsSep "\n" [
    "CONFIG_CMD_BOOTMENU=y"
    #"CONFIG_LOG=y" "CONFIG_LOGLEVEL=6"
    #CONFIG_EXTRA_ENV_SETTINGS= # set uboot env defaults
  ];

  extraMeta.platforms = ["armv7l-linux"];
  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
}
