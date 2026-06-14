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
    config = {
        services.comin = mkIf cfg.enable {
            enable = true;
            package = cfg.comin.package;
            debug = cfg.comin.debug;
            repositoryType = "flake";
            repositorySubdir = cfg.comin.repositorySubdir;
            submodules = cfg.comin.submodules;
            retention = cfg.comin.retention;
            gpgPublicKeyPaths = cfg.gpgKeys;
            hostname = cfg.identification.hostname;
            machineId = cfg.identification.machineId;
            remotes = cfg.remotes;
            buildConfirmer = mkIf cfg.confirmation.build.enable (
                let
                    duration = cfg.confirmation.build.autoconfirm_duration;
                in
                {
                    autoconfirm_duration = if duration == null then 0 else duration;
                    mode = if duration == null then "manual" else "auto";
                }
            );
            deployConfirmer = mkIf cfg.confirmation.deploy.enable (
                let
                    duration = cfg.confirmation.deploy.autoconfirm_duration;
                in
                {
                    autoconfirm_duration = if duration == null then 0 else duration;
                    mode = if duration == null then "manual" else "auto";
                }
            );
        };
    };
}
