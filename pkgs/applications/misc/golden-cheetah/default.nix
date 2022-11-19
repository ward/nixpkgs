{ lib, fetchFromGitHub, fetchpatch, mkDerivation
, qtbase, qtsvg, qtserialport, qtwebengine, qtmultimedia, qttools
, qtconnectivity, qtcharts, libusb-compat-0_1, gsl, blas
, bison, flex, zlib, qmake, makeDesktopItem, makeWrapper
, python39Full, python39Packages
}:

let
  desktopItem = makeDesktopItem {
    name = "goldencheetah";
    exec = "GoldenCheetah";
    icon = "goldencheetah";
    desktopName = "GoldenCheetah";
    genericName = "GoldenCheetah";
    comment = "Performance software for cyclists, runners and triathletes";
    categories = [ "Utility" ];
  };
in mkDerivation rec {
  pname = "golden-cheetah";
  version = "3.6-RC1";

  src = fetchFromGitHub {
    owner = "GoldenCheetah";
    repo = "GoldenCheetah";
    rev = "v${version}";
    sha256 = "0r2yafqfamvm5wpy5zm5jnzjbllrs76xbbavxfsdppq4h42qndn3";
  };

  # runtime?
  buildInputs = [
    qtbase
    qtsvg
    qtserialport
    qtwebengine
    qtmultimedia
    qttools
    zlib
    qtconnectivity
    qtcharts
    libusb-compat-0_1
    gsl
    blas
    python39Full
    python39Packages.sip_4
  ];
  # build time?
  nativeBuildInputs = [ flex makeWrapper qmake bison ];

  patches = [
    # allow building with bison 3.7
    # Included in https://github.com/GoldenCheetah/GoldenCheetah/pull/3590,
    # which is periodically rebased but pre 3.6 release, as it'll break other CI systems
    ./0001-Fix-building-with-bison-3.7.patch
    # The sip 4.x available in nixpkgs (4.19.25) is more recent than the one
    # used by GoldenCheetah (4.19.8). It seems to have removed a #define
    # SIP_MODULE_NAME that GoldenCheetah was relying on. Instead add it
    # ourselves with as value the value given to it by sip's nixpkgs build.
    ./0002-fix-sip-version-difference.patch
  ];

  NIX_LDFLAGS = "-lz -lgsl -lblas";

  qtWrapperArgs = [ "--prefix" "LD_LIBRARY_PATH" ":" "${zlib.out}/lib" ];

  preConfigure = ''
    cp src/gcconfig.pri.in src/gcconfig.pri
    cp qwt/qwtconfig.pri.in qwt/qwtconfig.pri
    echo 'QMAKE_LRELEASE = ${qttools.dev}/bin/lrelease' >> src/gcconfig.pri
    echo 'LIBUSB_INSTALL = ${libusb-compat-0_1}' >> src/gcconfig.pri
    echo 'LIBUSB_INCLUDE = ${libusb-compat-0_1.dev}/include' >> src/gcconfig.pri
    echo 'LIBUSB_LIBS = -L${libusb-compat-0_1}/lib -lusb' >> src/gcconfig.pri
    echo 'DEFINES += GC_VERSION=\\\"v${version}\\\"' >> src/gcconfig.pri
    sed -i "s|#\(CONFIG += release.*\)|\1 static|" src/gcconfig.pri
    sed -i "s|^#QMAKE_CXXFLAGS|QMAKE_CXXFLAGS|" src/gcconfig.pri
    sed -i -e '21,23d' qwt/qwtconfig.pri # Removed forced installation to /usr/local
    echo 'DEFINES += GC_WANT_PYTHON' >> src/gcconfig.pri
    echo 'PYTHONINCLUDES = -I${python39Full}/include/python3.9 -I${python39Packages.sip_4}/include' >> src/gcconfig.pri
    echo 'PYTHONLIBS = -L${python39Full}/lib/python3.9/config-3.9-x86_64-linux-gnu -llibpython3.9.a' >> src/gcconfig.pri
  '';
    # Getting error about not finding python3.9m, so adding its include folder explicitly in PYTHONLIBS too
    #echo 'PYTHONLIBS = -L${python39Full}/lib/python3.9/config-3.9-x86_64-linux-gnu -lpython3.9m' >> src/gcconfig.pri

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp src/GoldenCheetah $out/bin
    install -Dm644 "${desktopItem}/share/applications/"* -t $out/share/applications/
    install -Dm644 src/Resources/images/gc.png $out/share/pixmaps/goldencheetah.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Performance software for cyclists, runners and triathletes";
    platforms = platforms.linux;
    maintainers = [ ];
    license = licenses.gpl2Plus;
  };
}
