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
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lib-extras = {
      url = "github:aldoborrero/lib-extras/v1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
    flake-compat.url = "github:nix-community/flake-compat";
  };

  outputs = inputs @ {
    flake-parts,
    haumea,
    nixpkgs,
    systems,
    ...
  }: let
    lib = nixpkgs.lib.extend (l: _: (inputs.lib-extras.lib l));
    flakeInputs = haumea.lib.load {
      src = ./.;
      loader = haumea.lib.loaders.path;
    };
  in
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {inherit lib flakeInputs;};
    }
    {
      imports =
        (with inputs; [
          devshell.flakeModule
          flake-parts.flakeModules.easyOverlay
          flake-parts.flakeModules.flakeModules
          treefmt-nix.flakeModule
        ])
        ++ (with flakeInputs; [
          pkgs.default
          flake-modules.autoNixosModules
        ]);

      debug = false;

      systems = import systems;

      auto.nixosModules = {
        path = ./nixos-modules;
        includeDefaults = true;
      };

      flake.flakeModules = {
        default = {};
        inherit (flakeInputs.flake-modules) autoNixosModules;
        inherit (flakeInputs.flake-modules) autoPkgs;
        inherit (flakeInputs.flake-modules) homeConfigurations;
        inherit (flakeInputs.flake-modules) nixosConfigurations;
        inherit (flakeInputs.flake-modules) sopsSecrets;
      };

      perSystem = {
        pkgs,
        lib,
        system,
        self',
        ...
      }: {
        # nixpkgs
        _module.args = {
          pkgs = lib.nix.mkNixpkgs {
            inherit system;
            inherit (inputs) nixpkgs;
            overlays = [
              (final: _: {
                devour-flake = final.callPackage inputs.devour-flake {};
              })
            ];
          };
        };

        # packages
        packages = {
          mdformat = pkgs.mdformat.withPlugins (p: [
            p.mdformat-footnote
            p.mdformat-frontmatter
            p.mdformat-gfm
            p.mdformat-simple-breaks
          ]);
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
            mdformat.command = lib.mkDefault self'.packages.mdformat;
          };
        };

        # checks
        checks = {
          nix-build-all = pkgs.writeShellApplication {
            name = "nix-build-all";
            runtimeInputs = [
              pkgs.nix
              pkgs.devour-flake
            ];
            text = ''
              # Make sure that flake.lock is sync
              nix flake lock --no-update-lock-file

              # Do a full nix build (all outputs)
              devour-flake . "$@"
            '';
          };
        };
      };
    };
}
