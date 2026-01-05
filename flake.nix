{
  inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { self, ... }@inputs: let

    removeDefault = attrs: removeAttrs attrs [ "default" ];

  in inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    perSystem = { pkgs, lib, system, ... }: let
      nixvimLib = inputs.nixvim.lib.${system};
      nixvim' = inputs.nixvim.legacyPackages.${system};

      # Use makeNixvimWithModule for proper module support
      mkPackage = package: nixvim'.makeNixvimWithModule {
        inherit pkgs;
        module = {
          imports = [ self.nixvimModules.default ];
          inherit package;
        };
      };

      nvimPackage = mkPackage pkgs.neovim-unwrapped;

    in {
      packages = {
        default = nvimPackage;
        nvim = nvimPackage;
      };
      apps = rec {
        default = nvim;
        nvim = {
          type = "app";
          program = lib.getExe nvimPackage;
        };
        nixvim-print-init = {
          type = "app";
          program = "${nvim}/bin/nixvim-print-init";
        };
      };

      # Optional: Add checks back if you want CI validation
      # checks.default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
      # check = (
      #   lib.mapAttrs
      #   (name: module: nixvimLib.check.mkTestDerivationFromNixvimModule {
      #     inherit name pkgs system module;
      #   })
      #   (removeDefault self.nixvimModules)
      # );

      formatter = pkgs.nixfmt-rfc-style;
    };

    flake = {
      nixvimModules = {
        default = { ... }: {
          imports = builtins.attrValues (removeDefault self.nixvimModules);
        };
        config = import ./config;
        modules = import ./modules;
      };

      nixosModules = rec {
        default = nixvim;
        nixvim = args: {
          imports = [ inputs.nixvim.nixosModules.nixvim ];
          programs.nixvim = self.nixvimModules.default args;
        };
      };

      homeManagerModules = rec {
        default = nixvim;
        nixvim = args: {
          imports = [ inputs.nixvim.homeModules.nixvim ];
          programs.nixvim = self.nixvimModules.default args;
        };
      };

      darwinModules = rec {
        default = nixvim;
        nixvim = args: {
          imports = [ inputs.nixvim.darwinModules.nixvim ];
          programs.nixvim = self.nixvimModules.default args;
        };
      };
    };
  };
}
