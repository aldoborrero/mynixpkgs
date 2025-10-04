{
  pkgs,
  perSystem,
}:
perSystem.devshell.mkShell {
  packages = [
    perSystem.self.formatter
    pkgs.nix-update
  ];

  env = [
    {
      name = "NIX_PATH";
      value = "nixpkgs=${toString pkgs.path}";
    }
    {
      name = "NIX_DIR";
      eval = "$PRJ_ROOT/nix";
    }
  ];
}
