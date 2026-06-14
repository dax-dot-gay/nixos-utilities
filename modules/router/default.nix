{ inputs, ... }:
{
    config,
    lib,
    ...
}:
with lib;
let
    cfg = config.nixos-utilities.systems.router;
in
{
    imports = [
        ./options.nix
        ./modules
    ];

    config = mkMerge [
        (mkIf cfg.secrets.sops.enable (
            let
                sopscfg = cfg.secrets.sops;
            in
            {
                sops = mkMerge [
                    (mkIf (cfg.config.wan.type == "pppoe") {
                        secrets.${sopscfg.pppoe.username} = {
                            owner = "root";
                            mode = "0400";
                        };
                        secrets.${sopscfg.pppoe.password} = {
                            owner = "root";
                            mode = "0400";
                        };
                        templates.${sopscfg.pppoe.config} = {
                            content = ''
                                user ${config.sops.placeholder.${sopscfg.pppoe.username}}
                                password ${config.sops.placeholder.${sopscfg.pppoe.password}}
                            '';
                            owner = "root";
                            mode = "0400";
                        };
                    })
                    (mkIf cfg.config.dynamicDns.enable {
                        secrets.${sopscfg.dyndns} = {
                            owner = "root";
                            mode = "0400";
                        };
                    })
                ];
            }
        ))
    ];
}
