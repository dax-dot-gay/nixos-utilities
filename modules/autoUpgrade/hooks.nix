{
    config,
    lib,
    ...
}:
with lib;
let
    cfg = config.nixos-utilities.services.autoUpgrade;
    scripts = (import ./scripts.nix) { inherit pkgs lib; };

    deployConfirmerEnabled = (cfg.confirmation.deploy.confirmation_command != null) || (cfg.desktop.enable && cfg.desktop.deployConfirmation.enable);
    buildConfirmerEnabled = (cfg.confirmation.build.confirmation_command != null) || (cfg.desktop.enable && cfg.desktop.buildConfirmation.enable);
in
{
    config = {
        systemd.services."autoUpgrade-hook-deploy-confirmation" =
            mkIf deployConfirmerEnabled
                {
                    wantedBy = [ "default.target" ];
                    wants = [ "multi-user.target" ];
                    serviceConfig = {
                        Restart = "on-failure";
                        StartLimitIntervalSec = "5s";
                        StartLimitBurst = 10;
                        User = "root";
                    };
                    script = ''
                        while read -r event
                        do
                            if [[ $event == buildFinishedType* ]]; then
                                if [ ! "$(comin status --json | jq .deploy_confirmer.submitted)" == '""' ]; then
                                    ${
                                        if (cfg.desktop.enable && cfg.desktop.deployConfirmation.enable) then (let args = cfg.desktop.deployConfirmation; in ''
                                            ${scripts.notifier-deploy}/bin/notifier-deploy "${args.title}" "${args.urgency}" "${args.summary}" "${args.action}"
                                        '') else ""
                                    }
                                    ${
                                        if (cfg.confirmation.deploy.confirmation_command != null) then ''
                                            echo "HOOK/confirmation-deploy -> Running \"${cfg.confirmation.deploy.confirmation_command}\""
                                            ${cfg.confirmation.deploy.confirmation_command}
                                        '' else ""
                                    }
                                fi
                            fi
                        done < <(comin events)
                    '';
                    path = [ "/run/current-system/sw" ];
                };
        systemd.services."autoUpgrade-hook-build-confirmation" =
            mkIf buildConfirmerEnabled
                {
                    wantedBy = [ "default.target" ];
                    wants = [ "multi-user.target" ];
                    serviceConfig = {
                        Restart = "on-failure";
                        StartLimitIntervalSec = "5s";
                        StartLimitBurst = 10;
                        User = "root";
                    };
                    script = ''
                        while read -r event
                        do
                            if [[ $event == evalFinishedType* ]]; then
                                if [ ! "$(comin status --json | jq .build_confirmer.submitted)" == '""' ]; then
                                    ${
                                        if (cfg.desktop.enable && cfg.desktop.buildConfirmation.enable) then (let args = cfg.desktop.buildConfirmation; in ''
                                            ${scripts.notifier-build}/bin/notifier-build "${args.title}" "${args.urgency}" "${args.summary}" "${args.action}"
                                        '') else ""
                                    }
                                    ${
                                        if (cfg.confirmation.build.confirmation_command != null) then ''
                                            echo "HOOK/confirmation-build -> Running \"${cfg.confirmation.build.confirmation_command}\""
                                            ${cfg.confirmation.build.confirmation_command}
                                        '' else ""
                                    }
                                fi
                            fi
                        done < <(comin events)
                    '';
                    path = [ "/run/current-system/sw" ];
                };
        systemd.services."autoUpgrade-hook-hooks-comin" =
            mkIf
                (any (execs: (length execs) > 0) (map (hookName: cfg.hooks."on${hookName}") (attrNames cfg.hooks._cominEventTypes)))
                {
                    wantedBy = [ "default.target" ];
                    wants = [ "multi-user.target" ];
                    serviceConfig = {
                        Restart = "on-failure";
                        StartLimitIntervalSec = "5s";
                        StartLimitBurst = 10;
                        User = "root";
                    };
                    script = ''
                        while read -r event
                        do
                            ${concatStringsSep "\n\n" (
                                mapAttrsToList (
                                    eventName: eventType:
                                    (
                                        if ((length cfg.hooks."on${eventName}") > 0) then
                                            ''
                                                if [[ $event == ${eventType}* ]]; then
                                                    ${concatStringsSep "\n" (
                                                        map (executable: ''
                                                            echo "HOOK/hooks-comin/${eventName} -> Running \"${executable}\""
                                                            ${executable}
                                                        '') cfg.hooks."on${eventName}"
                                                    )}
                                                fi
                                            ''
                                        else
                                            ""
                                    )
                                ) cfg.hooks._cominEventTypes
                            )}
                        done < <(comin events)
                    '';
                    path = [ "/run/current-system/sw" ];
                };
    };
}
