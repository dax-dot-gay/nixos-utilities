{
    description = "A flake containing a number of utilities for my nixos configurations";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    };

    outputs =
        { self, ... }@inputs:
        let
            inherit (inputs.nixpkgs) lib;

            supportedSystems = [
                "x86_64-linux"
                "aarch64-linux"
                "aarch64-darwin"
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
                };
                router = lib.modules.importApply ./modules/router {
                    inherit self;
                    inputs = inputs;
                };
            };
        };
}
