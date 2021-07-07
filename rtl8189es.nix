{ stdenv, lib, fetchFromGitHub, linux }: stdenv.mkDerivation rec {
  version = "2021-03-02";
  pname = "rtl8189es-${linux.version}";

  src = fetchFromGitHub {
    owner = "jwrdegoede";
    repo = "rtl8189ES_linux";
    rev = "03ac413135a355b55b693154c44b70f86a39732e";
    sha256 = "0wiikviwyvy6h55rgdvy7csi1zqniqg26p8x44rd6mhbw0g00h56";
  };
  sourceRoot = "source";

  kernelVersion = linux.modDirVersion;
  modules = [ "8189es" ];
  makeFlags = [
    "-C" "${linux.dev}/lib/modules/${linux.modDirVersion}/build" "modules"
    "CROSS_COMPILE=${linux.stdenv.cc.targetPrefix or ""}"
    "M=$(NIX_BUILD_TOP)/$(sourceRoot)"
    "VERSION=$(version)"
    "CONFIG_RTL8189ES=m"
  ] ++ (if linux.stdenv.hostPlatform ? linuxArch then [
    "ARCH=${linux.stdenv.hostPlatform.linuxArch}"
  ] else [ ]);
  enableParallelBuilding = true;

  installPhase = ''
    install -Dm644 -t $out/lib/modules/$kernelVersion/kernel/drivers/net/wireless 8189es.ko
  '';

  meta.platforms = lib.platforms.linux;
}
