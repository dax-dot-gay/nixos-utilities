{ inputs, pkgs, ... }:
rec {
    optionsDocCommonMark =
        let
            eval = pkgs.lib.evalModules {
                modules = [
                    {
                        imports = [
                            ../modules/autoUpgrade/options.nix
                            ../modules/router/options.nix
                        ];
                    }
                    {
                        options = {
                            _module.args = pkgs.lib.mkOption {
                                internal = true;
                            };
                            assertions = pkgs.lib.mkOption {
                                type = pkgs.lib.types.anything;
                                description = "";
                                internal = true;
                            };
                            networking.hostName = pkgs.lib.mkOption {
                                type = pkgs.lib.types.str;
                                internal = true;
                                default = "the-machine-hostname";
                            };
                        };
                    }
                ];
            };
            optionsDoc = pkgs.nixosOptionsDoc {
                inherit (eval) options;
            };
        in
        pkgs.runCommand "options-doc.md" { } ''
            cat ${optionsDoc.optionsCommonMark} >> $out
        '';
    optionsDocCommonMarkGenerator = pkgs.writers.writeBashBin "optionsDocCommonMarkGenerator" ''
        cp -v ${optionsDocCommonMark} ./doc/generated-module-options.md
        chmod u+w ./doc/generated-module-options.md
    '';
}
