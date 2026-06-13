{
    config,
    lib,
}:
with lib;
let
    cfg = config.flake.nixos-utilities.systems.router;
    dyndns = cfg.config.dynamicDns;
in
{
    services.ddns-updater = mkIf dyndns.enable {
        enable = true;
        environment = {
            SERVER_ENABLED = if dyndns.server_enabled then "yes" else "no";
            CONFIG_FILEPATH = dyndns.config_file;
            PERIOD = dyndns.period;
        }
        // dyndns.extra_environment;
    };
}
