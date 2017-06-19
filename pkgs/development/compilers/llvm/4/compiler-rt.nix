{ stdenv
, fetch
, buildPlatform, hostPlatform
}:

stdenv.mkDerivation {
  src = fetch "compiler-rt" "059ipqq27gd928ay06f1ck3vw6y5h5z4zd766x8k0k7jpqimpwnk";

  # TSAN requires XPC on Darwin, which we have no public/free source files for. We can depend on the Apple frameworks
  # to get it, but they're unfree. Since LLVM is rather central to the stdenv, we patch out TSAN support so that Hydra
  # can build this. If we didn't do it, basically the entire nixpkgs on Darwin would have an unfree dependency and we'd
  # get no binary cache for the entire platform. If you really find yourself wanting the TSAN, make this controllable by
  # a flag and turn the flag off during the stdenv build.
  postPatch = stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace ./projects/compiler-rt/cmake/config-ix.cmake \
      --replace 'set(COMPILER_RT_HAS_TSAN TRUE)' 'set(COMPILER_RT_HAS_TSAN FALSE)'
  '';

  # Note from John to Will. This was a build dep for llvm; I'm guessing it's really used by just compiler-rt.
  buildInputs = stdenv.lib.optionals stdenv.isDarwin [ libcxxabi ];
}
