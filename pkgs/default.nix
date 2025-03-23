{
  perSystem = {
    self',
    pkgs,
    lib,
    ...
  }: {
    packages =
      lib.pipe (lib.makeScope pkgs.newScope (
        self:
          lib.packagesFromDirectoryRecursive {
            inherit (self) callPackage;
            directory = ./by-name;
          }
      )) [
        (lib.collect lib.isDerivation)
        (map (x: lib.nameValuePair (builtins.head (builtins.split "-[0-9].*$" x.name)) x))
        builtins.listToAttrs
      ];

    apps =
      lib.mapAttrs (_name: package: {
        type = "app";
        program = lib.getExe package;
      }) (lib.filterAttrs (
          _name: package:
            lib.isDerivation package && package ? meta.mainProgram
        )
        self'.packages);

    overlayAttrs = self'.packages;
  };
}
