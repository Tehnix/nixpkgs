{ kdeFramework, lib, extra-cmake-modules, qtbase, qttools }:

kdeFramework {
  name = "kconfig";
  meta = {
    maintainers = [ lib.maintainers.ttuegel ];
    broken = builtins.compareVersions qtbase.version "5.6.0" < 0;
  };
  nativeBuildInputs = [ extra-cmake-modules qttools ];
  buildInputs = [ qtbase ];
}
