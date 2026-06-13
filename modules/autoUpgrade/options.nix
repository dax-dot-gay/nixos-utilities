{
    config,
    lib,
    inputs,
    pkgs,
    system,
    ...
}:
with lib;
let
    cfg = config.nixos-utilities.services.autoUpgrade;
in
{
    options.nixos-utilities.services.autoUpgrade = {
        enable = mkEnableOption "Automatic system updates backed by comin";

        # Comin internals
        comin = {
            package = mkOption {
                description = "Comin package to use";
                type = types.nullOr types.package;
                default = pkgs.comin or inputs.comin.packages.system.default or null;
            };
            debug = mkOption {
                description = "Enable Comin debug mode (WARN: shows secrets)";
                type = types.bool;
                default = false;
            };
        };
    };
}
