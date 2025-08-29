{
  description = "Flake-based NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # stable or pinned version
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";  # explicitly for unstable packages
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, unstable, flake-utils, ... }@inputs:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./configuration.nix

            # Provide both stable and unstable to config
            ({ config, pkgs, ... }: {
              _module.args = {
                unstablePkgs = import unstable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              };
            })
          ];
        };
      };
    };
}
