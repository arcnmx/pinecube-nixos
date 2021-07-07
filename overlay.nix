self: super: let
  overridePackage = package: override: overrideAttrs: (package.override override).overrideAttrs overrideAttrs;
in {
  # Dependency minimization for cross-compiling
  cairo = super.cairo.override { glSupport = false; };
  gnutls = super.gnutls.override { guileBindings = false; };
  polkit = super.polkit.override { withIntrospection = false; };
  lv2 = super.lv2.override { gtk2 = null; };
  v4l_utils = super.v4l_utils.override { withGUI = false; };

  # Overlay kernel drivers
  linuxPackagesFor = let
    koverlay = kself: ksuper: {
      rtl8189es = ksuper.rtl8189es or (
        kself.callPackage ./rtl8189es.nix { linux = kself.kernel; }
      );
    };
  in kernel: (super.linuxPackagesFor kernel).extend koverlay;

  # Fix some broken derivations
  hdf5 = super.hdf5.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ self.buildPackages.cmake ];
    cmakeFlags = [
      "-DONLY_SHARED_LIBS=ON"
      "-DHDF5_ENABLE_PARALLEL=ON"
      "-DBUILD_TESTING=OFF"
    ];
  });
  rtmpdump = super.rtmpdump.overrideAttrs (old: {
    makeFlags = old.makeFlags ++ [
      "CC=${self.stdenv.cc.targetPrefix}cc"
      "AR=${self.stdenv.cc.targetPrefix}ar"
    ];
  });
  pango = overridePackage super.pango {
    x11Support = false;
    gi-docgen = null;
  } (old: {
    mesonFlags = old.mesonFlags or [ ] ++ [ "-Dintrospection=disabled" "-Dgtk_doc=false" ];
    outputs = [ "bin" "out" "dev" ];
    postInstall = ":";
  });
  gdk-pixbuf = overridePackage super.gdk-pixbuf {
    gi-docgen = null; gobject-introspection = null;
    libxslt = null; docbook-xsl-nons = null; docbook_xml_dtd_43 = null;
  } (old: {
    mesonFlags = old.mesonFlags or [ ] ++ [ "-Dgtk_doc=false" ];
    outputs = [ "out" "dev" ];
    postInstall = ":";
  });
  libnice = overridePackage super.libnice {
    gtk-doc = null; docbook_xsl = null; docbook_xml_dtd_412 = null; gobject-introspection = null;
  } (old: {
    mesonFlags = old.mesonFlags or [ ] ++ [ "-Dgtk_doc=false" ];
    outputs = [ "out" "dev" ];
  });

  # gstreamer packages
  gst_all_1 = with super.gst_all_1; super.gst_all_1 // {
    gstreamer = overridePackage gstreamer {
      gobject-introspection = null;
    } (old: {
      mesonFlags = old.mesonFlags ++ [
        "-Dintrospection=disabled"
      ];
    });
    gst-plugins-base = overridePackage gst-plugins-base {
      inherit (self.gst_all_1) gstreamer;
      enableX11 = false; enableWayland = false; enableCdparanoia = false;
      libGL = null;
    } (old: {
      mesonFlags = old.mesonFlags ++ [ "-Dintrospection=disabled" "-Dtests=disabled" ];
      buildInputs = old.buildInputs ++ [ self.pango ];
      doCheck = false;
    });
    gst-plugins-good = overridePackage gst-plugins-good {
      inherit (self.gst_all_1) gst-plugins-base;
      enableJack = false; wayland = null; wayland-protocols = null; libpulseaudio = null;
      libvpx = null;
      libXdamage = null; libXext = null; libXfixes = null; xorg = {
        libXdamage = null;
        libXfixes = null;
      };
      libshout = null;
      libcaca = null;
      libsoup = null;
    } (old: {
      mesonFlags = old.mesonFlags or [ ] ++ [
        "-Dx11=disabled"
        "-Dximagesrc=disabled"
        "-Dlibcaca=disabled"
        "-Ddv=disabled"
        "-Dvpx=disabled"
        "-Dpulse=disabled"
        "-Dshout2=disabled"
        "-Dsoup=disabled"
      ];
      nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [
        self.buildPackages.orc
      ];
    });
    gst-plugins-bad = overridePackage gst-plugins-bad {
      inherit (self.gst_all_1) gst-plugins-base;
      wayland = null; wayland-protocols = null; bluez = null;
      libgme = null;
      libGL = null; libGLU = null;
      gnutls = null;
      libva = null; libvdpau = null;
      libdvdread = null; libdvdnav = null;
      libkate = null;
      gobject-introspection = null;
      libaom = null;
      libbs2b = null;
      libnice = null;
      librsvg = null;
      neon = null;
      openh264 = null;
      sord = null;
      serd = null;
      sratom = null;
      spandsp = null;
      srtp = null;
      directfb = null;
      libdrm = null;
      opencv4 = null;
      lrdf = null;
      lilv = null;
      fluidsynth = null;
      lv2 = null;
      openal = null;
      libwebp = null;
    } (old: {
      nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [
        self.buildPackages.glib
      ];
      mesonFlags = old.mesonFlags ++ [
        "-Dintrospection=disabled"
        "-Dx11=disabled"
        "-Dwayland=disabled"
        "-Dkms=disabled"
        "-Daom=disabled"
        "-Dbluez=disabled"
        "-Dbs2b=disabled"
        "-Ddirectfb=disabled"
        "-Dgl=disabled"
        "-Dgme=disabled"
        "-Dkate=disabled"
        "-Dlv2=disabled"
        "-Dneon=disabled"
        "-Dopenal=disabled"
        "-Drsvg=disabled"
        "-Dfluidsynth=disabled"
        "-Dva=disabled"
        "-Dwebp=disabled"
        "-Dlrdf=disabled"
        "-Dladspa=disabled"
        "-Dopenh264=disabled"
        "-Ddvdspu=disabled"
        "-Dresindvd=disabled"
        "-Dopencv=disabled"
        "-Dspandsp=disabled"
        "-Dsrtp=disabled"
        "-Dwebrtc=disabled"
      ];
    });
    gst-plugins-ugly = overridePackage gst-plugins-ugly {
      inherit (self.gst_all_1) gst-plugins-base;
      libcdio = null; libdvdread = null;
      a52dec = null;
    } (old: {
      mesonFlags = old.mesonFlags ++ [
        "-Da52dec=disabled"
        "-Dcdio=disabled"
        "-Ddvdread=disabled"
      ];
    });
    gst-libav = gst-plugins-ugly.override {
      inherit (self.gst_all_1) gst-plugins-base;
    };
    gst-vaapi = gst-plugins-ugly.override {
      inherit (self.gst_all_1) gst-plugins-base gstreamer gst-plugins-bad;
    };
    gst-rtsp-server = overridePackage gst-rtsp-server {
      inherit (self.gst_all_1) gst-plugins-base gst-plugins-bad;
      gobject-introspection = null;
    } (old: {
      mesonFlags = old.mesonFlags or [ ] ++ [ "-Dintrospection=disabled" "-Dexamples=enabled" ];
    });
  };
}
