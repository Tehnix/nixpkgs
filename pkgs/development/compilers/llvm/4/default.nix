{ newScope, stdenv, cmake, libxml2, python2, isl, fetchurl, overrideCC, wrapCC, darwin, ccWrapperFun
, # The same LLVM from `buildPackages`, for building the libraries and getting the tools
  buildTools
}:
let
  release_version = "4.0.0";
  version = release_version; # differentiating these is important for rc's

  fetch = name: sha256: fetchurl {
    url = "http://llvm.org/releases/${release_version}/${name}-${version}.src.tar.xz";
    inherit sha256;
  };

  clang-tools-extra_src = fetch "clang-tools-extra" "16bwckgcxfn56mbqjlxi7fxja0zm9hjfa6s3ncm3dz98n5zd7ds1";

  tools = let
    callPackage = newScope (tools // { inherit stdenv cmake libxml2 python2 isl release_version version fetch; });
  in {
    llvm = callPackage ./llvm.nix { };

    clang-unwrapped = callPackage ./clang {
      inherit clang-tools-extra_src stdenv;
    };


    lld = callPackage ./lld.nix {};

    lldb = callPackage ./lldb.nix {};
  };

  libraries = let
    callPackage = newScope (libraries // buildTools // { inherit stdenv cmake libxml2 python2 isl release_version version fetch; });
  in {
    compiler-rt = callPackage ./compiler-rt.nix {};

    openmp = callPackage ./openmp.nix {};

    libcxxClang = ccWrapperFun {
      cc = tools.clang-unwrapped;
      isClang = true;
      inherit (tools) stdenv;
      /* FIXME is this right? */
      inherit (stdenv.cc) libc nativeTools nativeLibc;
      extraPackages = [ libraries.libcxx tools.libcxxabi tools.compiler-rt ];
    };

    clang = wrapCC tools.clang-unwrapped;

    stdenv = overrideCC stdenv tools.clang;

    libcxxStdenv = overrideCC stdenv tools.libcxxClang;

    libcxx = callPackage ./libc++ {};

    libcxxabi = callPackage ./libc++abi.nix {};
  };
in { inherit tools libraries; } // libraries // tools
