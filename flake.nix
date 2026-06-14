{
    description = "A flake containing a number of utilities for my nixos configurations";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        comin = {
            url = "github:nlewo/comin";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        { self, nixpkgs, ... }@inputs:
        let
            inherit (inputs.nixpkgs) lib;

            supportedSystems = [
                "x86_64-linux"
            ];

            forEachSupportedSystem =
                f:
                lib.genAttrs supportedSystems (
                    system:
                    f {
                        inherit system;
                        pkgs = import inputs.nixpkgs {
                            inherit system;
                            config.allowUnfree = true;
                        };
                        pkgs-unstable = import inputs.nixpkgs {
                            inherit system;
                            config.allowUnfree = true;
                        };
                    }
                );
            system = "x86_64-linux";
            optionsDocFor = forEachSupportedSystem ({ pkgs, ... }: import ./util/generate-docs.nix {inherit pkgs inputs;});
        in
        {
            /*
              devShells = forEachSupportedSystem (
                { pkgs, system }:
                {
                  default = pkgs.mkShellNoCC {
                    packages = with pkgs; [
                      self.formatter.${system}
                    ];
                  };
                }
              );

              formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
            */
            nixosModules = {
                default = lib.modules.importApply ./modules {
                    inherit self;
                    inputs = inputs;
                    system = system;
                };
                router = lib.modules.importApply ./modules/router {
                    inherit self;
                    inputs = inputs;
                    system = system;
                };
                autoUpgrade = lib.modules.importApply ./modules/autoUpgrade {
                    inherit self;
                    inputs = inputs;
                    system = system;
                };
            };
            nixosConfigurations = {
                vms-router = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit inputs system; };
                    modules = [
                        "${nixpkgs}/nixos/modules/virtualisation/proxmox-image.nix"
                        self.nixosModules.default
                        inputs.comin.nixosModules.comin
                        inputs.sops-nix.nixosModules.sops
                        ./tests/vms/router
                    ];
                };
            };
            packages."${system}" = {
                vms-router-vma = self.nixosConfigurations.vms-router.config.system.build.VMA;
                generate-module-options = optionsDocFor."${system}".optionsDocCommonMarkGenerator;
            };
        };
}
