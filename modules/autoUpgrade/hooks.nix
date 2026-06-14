{
    config,
    lib,
    ...
}:
with lib;
let
    cfg = config.nixos-utilities.services.autoUpgrade;
    scripts = (import ./scripts.nix) { inherit pkgs lib; };

    deployConfirmerEnabled =
        (cfg.confirmation.deploy.confirmation_command != null)
        || (cfg.desktop.enable && cfg.desktop.deployConfirmation.enable);
    buildConfirmerEnabled =
        (cfg.confirmation.build.confirmation_command != null)
        || (cfg.desktop.enable && cfg.desktop.buildConfirmation.enable);
in
{
    config = {
        systemd.services."autoUpgrade-hook-deploy-confirmation" = mkIf deployConfirmerEnabled {
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
                                if (cfg.desktop.enable && cfg.desktop.deployConfirmation.enable) then
                                    (
                                        let
                                            args = cfg.desktop.deployConfirmation;
                                        in
                                        ''
                                            ${scripts.notifier-deploy}/bin/notifier-deploy "${args.title}" "${args.urgency}" "${args.summary}" "${args.action}"
                                        ''
                                    )
                                else
                                    ""
                            }
                            ${
                                if (cfg.confirmation.deploy.confirmation_command != null) then
                                    ''
                                        echo "HOOK/confirmation-deploy -> Running \"${cfg.confirmation.deploy.confirmation_command}\""
                                        ${cfg.confirmation.deploy.confirmation_command}
                                    ''
                                else
                                    ""
                            }
                        fi
                    fi
                done < <(comin events)
            '';
            path = [ "/run/current-system/sw" ];
        };
        systemd.services."autoUpgrade-hook-build-confirmation" = mkIf buildConfirmerEnabled {
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
                                if (cfg.desktop.enable && cfg.desktop.buildConfirmation.enable) then
                                    (
                                        let
                                            args = cfg.desktop.buildConfirmation;
                                        in
                                        ''
                                            ${scripts.notifier-build}/bin/notifier-build "${args.title}" "${args.urgency}" "${args.summary}" "${args.action}"
                                        ''
                                    )
                                else
                                    ""
                            }
                            ${
                                if (cfg.confirmation.build.confirmation_command != null) then
                                    ''
                                        echo "HOOK/confirmation-build -> Running \"${cfg.confirmation.build.confirmation_command}\""
                                        ${cfg.confirmation.build.confirmation_command}
                                    ''
                                else
                                    ""
                            }
                        fi
                    fi
                done < <(comin events)
            '';
            path = [ "/run/current-system/sw" ];
        };
        systemd.services."autoUpgrade-hook-hooks-comin" =
            mkIf
                (any (execs: (length execs) > 0) (
                    map (hookName: cfg.hooks."on${hookName}") (attrNames cfg.hooks._cominEventTypes)
                ))
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
        systemd.services."autoUpgrade-reboot-handler" = mkIf cfg.reboot.enabled {
            wantedBy = [ "default.target" ];
            wants = [ "multi-user.target" ];
            serviceConfig = {
                Restart = "on-failure";
                StartLimitIntervalSec = "5s";
                StartLimitBurst = 10;
                User = "root";
            };
            path = [ "/run/current-system/sw" ];
            script =
                let
                    date = "${pkgs.coreutils}/bin/date";
                    readlink = "${pkgs.coreutils}/bin/readlink";
                    shutdown = "${config.systemd.package}/bin/shutdown";
                in
                ''
                    while read -r event
                    do
                        if [[ $event == rebootRequired* ]]; then
                            ${
                                if (cfg.reboot.rebootWindow == null) then
                                    ''
                                        do_reboot="true"
                                    ''
                                else
                                    ''
                                        current_time="$(${date} +%H:%M)"
                                        lower="${cfg.reboot.rebootWindow.lower}"
                                        upper="${cfg.reboot.rebootWindow.upper}"

                                        if [[ "''${lower}" < "''${upper}" ]]; then
                                            if [[ "''${current_time}" > "''${lower}" ]] && \
                                               [[ "''${current_time}" < "''${upper}" ]]; then
                                                do_reboot="true"
                                            else
                                                do_reboot="false"
                                            fi
                                        else
                                            # lower > upper, so we are crossing midnight (e.g. lower=23h, upper=6h)
                                            # we want to reboot if cur > 23h or cur < 6h
                                            if [[ "''${current_time}" < "''${upper}" ]] || \
                                               [[ "''${current_time}" > "''${lower}" ]]; then
                                                do_reboot="true"
                                            else
                                                do_reboot="false"
                                            fi
                                        fi
                                    ''
                            }

                            if [ "''${do_reboot}" == true ]; then
                                ${optionalString (cfg.reboot.mode == "auto") ''
                                    shutdown -r now
                                ''}
                                ${optionalString (cfg.reboot.mode == "command") ''
                                    echo "Automatic reboot running \"${cfg.reboot.rebootCommand}\""
                                    ${cfg.reboot.rebootCommand}
                                ''}
                                ${optionalString (cfg.reboot.mode == "desktop") (
                                    if (cfg.desktop.enable && cfg.desktop.rebootConfirmation.enable) then
                                        (
                                            let
                                                args = cfg.desktop.rebootConfirmation;
                                            in
                                            ''
                                                ${scripts.notifier-reboot}/bin/notifier-reboot "${args.title}" "${args.urgency}" "${args.summary}" "${args.action}"
                                            ''
                                        )
                                    else
                                        ''
                                            echo "Attempted to perform a desktop reboot confirmation, but desktop services are disabled."
                                        ''
                                )}
                            else
                                echo "Outside of reboot window, skipping action"
                            fi
                        fi
                    done < <(comin events)
                '';
        };
    };
}
