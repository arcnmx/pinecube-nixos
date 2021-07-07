self: super: {
  # Dependency minimization for cross-compiling
  cairo = super.cairo.override { glSupport = false; };
  gnutls = super.gnutls.override { guileBindings = false; };
  polkit = super.polkit.override { withIntrospection = false; };
  v4l_utils = super.v4l_utils.override { withGUI = false; };

  # Overlay kernel drivers
  linuxPackagesFor = let
    koverlay = kself: ksuper: {
      rtl8189es = ksuper.rtl8189es or (
        kself.callPackage ./rtl8189es.nix { linux = kself.kernel; }
      );
    };
  in kernel: (super.linuxPackagesFor kernel).extend koverlay;
}
