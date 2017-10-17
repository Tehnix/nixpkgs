{ stdenv, fetchurl, pkgconfig, zlib, kmod, which }:

stdenv.mkDerivation rec {
  name = "pciutils-3.5.6"; # with database from 2017-07

  src = fetchurl {
    url = "mirror://kernel/software/utils/pciutils/${name}.tar.xz";
    sha256 = "08dvsk1b5m1r7qqzsm849h4glq67mngf8zw7bg0102ff1jwywipk";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ zlib kmod which ];

  # We'll strip the binaries ourselves if we want to
  postPatch = '' substituteInPlace Makefile --replace 'STRIP=-s' "STRIP=" '';

  # The build system is missing a -lz by default
  makeFlags = "SHARED=yes PREFIX=\${out} CC=${stdenv.cc.prefix}gcc";

  installTargets = "install install-lib";

  # Get rid of update-pciids as it won't work.
  postInstall = "rm $out/sbin/update-pciids $out/man/man8/update-pciids.8";

  meta = with stdenv.lib; {
    homepage = http://mj.ucw.cz/pciutils.html;
    description = "A collection of programs for inspecting and manipulating configuration of PCI devices";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = [ maintainers.vcunat ]; # not really, but someone should watch it
  };
}

