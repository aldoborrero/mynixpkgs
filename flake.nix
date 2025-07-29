{
  description = "My repository of custom (nix)pkgs";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    # packages
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # utilities
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lib-extras = {
      url = "github:aldoborrero/lib-extras/v1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:nix-community/flake-compat";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    systems,
    ...
  }: let
    lib = nixpkgs.lib.extend (l: _: (inputs.lib-extras.lib l));
  in
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {inherit lib;};
    }
    {
      imports =
        (with inputs; [
          devshell.flakeModule
          flake-parts.flakeModules.easyOverlay
          flake-parts.flakeModules.flakeModules
          treefmt-nix.flakeModule
        ])
        ++  [
          ./pkgs
          ./flake-modules/autoNixosModules.nix
        ];

      debug = false;

      systems = import systems;

      auto.nixosModules = {
        path = ./nixos-modules;
        includeDefaults = true;
      };

      flake.flakeModules = {
        default = {};
        autoNixosModules = ./flake-modules/autoNixosModules.nix;
        autoPkgs = ./flake-modules/autoPkgs.nix;
        homeConfigurations = ./flake-modules/homeConfigurations.nix;
        nixosConfigurations = ./flake-modules/nixosConfigurations.nix;
        sopsSecrets = ./flake-modules/sopsSecrets.nix;
      };

      perSystem = {
        pkgs,
        lib,
        system,
        ...
      }: {
        # nixpkgs
        _module.args = {
          pkgs = lib.nix.mkNixpkgs {
            inherit system;
            inherit (inputs) nixpkgs;
                      };
        };

        # devshells
        devshells.default = {
          name = "mynixpkgs";
          packages = [];
          commands = [
            {
              name = "fmt";
              category = "nix";
              help = "format the source tree";
              command = ''nix fmt'';
            }
            {
              name = "check";
              category = "nix";
              help = "check the source tree";
              command = ''nix flake check'';
            }
          ];
        };

        # treefmt
        treefmt.config = {
          projectRootFile = "flake.nix";
          flakeFormatter = true;
          flakeCheck = true;
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            mdformat.enable = true;
            shfmt.enable = true;
            terraform.enable = true;
            yamlfmt.enable = true;
          };
          settings.formatter = {
            deadnix.priority = 1;
            statix.priority = 2;
            alejandra.priority = 3;
            mdformat.command = lib.mkForce (pkgs.mdformat.withPlugins (p: [
              p.mdformat-footnote
              p.mdformat-frontmatter
              p.mdformat-gfm
              p.mdformat-simple-breaks
            ]));
            yamlfmt.includes = [".yamlfmt"];
          };
        };
      };
    };
}
