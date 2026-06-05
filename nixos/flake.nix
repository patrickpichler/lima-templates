{
  description = "NixOS lima configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-lima,
    }:
    let
      helpers = import ./helpers.nix { };

      overlays = [
        (final: _prev: {
          unstable = import nixpkgs-unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        })
      ];

      default-config = {
        system = "aarch64-linux";

        # Pass the `nixos-lima` input along with the default module system parameters
        specialArgs = {
          inherit nixos-lima;
        };

        modules = [
          { nixpkgs.overlays = overlays; }
          nixos-lima.nixosModules.lima
          ./nixos-lima-config.nix
          ./nixos-ebpf.nix
        ];
      };
    in
    {
      nixosConfigurations = {
        nixos-ebpf-aarch64 = nixpkgs.lib.nixosSystem default-config;

        nixos-ebpf-k3s-aarch64 = nixpkgs.lib.nixosSystem (
          helpers.deepMerge default-config {
            modules = [
              ./k3s.nix
            ];
          }
        );

        nixsample-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          # Pass the `nixos-lima` input along with the default module system parameters
          specialArgs = { inherit nixos-lima; };
          modules = [
            ./nixos-lima-config.nix
          ];
        };

        nixsample-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          # Pass the `nixos-lima` input along with the default module system parameters
          specialArgs = { inherit nixos-lima; };
          modules = [
            ./nixos-lima-config.nix
          ];
        };
      };
    };
}
