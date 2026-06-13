{
    config,
    lib,
    ...
}:
with lib;
let
    cfg = config.nixos-utilities.services.autoUpgrade;
in
{
    options.nixos-utilities.services.autoUpgrade = {
        enable = mkEnableOption "Automatic system updates backed by comin";
    };
}
