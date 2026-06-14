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
    scripts = (import ./scripts.nix) { inherit pkgs lib; };
in
{
    options.nixos-utilities.services.autoUpgrade = {
        enable = mkEnableOption "automatic system updates backed by comin";

        enableDesktop = mkEnableOption ''
            features relevant to a GUI environment:
            - Confirmation will show a desktop notification by default, if enabled
        '';

        # Comin internals
        comin = {
            package = mkOption {
                description = "Comin package to use";
                type = types.nullOr types.package;
                defaultText = "pkgs.comin or inputs.comin.packages.system.default or null";
            };
            debug = mkOption {
                description = "comin debug mode (WARN: shows secrets)";
                type = types.bool;
                default = false;
            };
        };

        # Confirmation configuration
        confirmation = {
            build = {
                enable = mkEnableOption ''
                    the build confirmer (`comin.buildConfirmer`)
                    Specifically, sets `comin.buildConfirmer.mode` to "without" if not enabled
                '';
                autoconfirm_duration = mkOption {
                    description = ''
                        Duration for the autoconfirmer, or `null` to disable auto-confirmation
                        Implies `comin.buildConfirmer.mode` based on this setting
                    '';
                    type = types.nullOr types.ints.unsigned;
                    default = null;
                };
                confirmation_command = mkOption {
                    description = "Command to run when a build confirmation is waiting";
                    type = types.nullOr types.path;
                    default = if cfg.enableDesktop then "${scripts.notifier-build}/bin/notifier-build" else null;
                };
            };
            deploy = {
                enable = mkEnableOption ''
                    the deploy confirmer (`comin.deployConfirmer`)
                    Specifically, sets `comin.deployConfirmer.mode` to "without" if not enabled
                '';
                autoconfirm_duration = mkOption {
                    description = ''
                        Duration for the autoconfirmer, or `null` to disable auto-confirmation
                        Implies `comin.deployConfirmer.mode` based on this setting
                    '';
                    type = types.nullOr types.ints.unsigned;
                    default = null;
                };
                confirmation_command = mkOption {
                    description = "Command to run when a deploy confirmation is waiting";
                    type = types.nullOr types.path;
                    default = if cfg.enableDesktop then "${scripts.notifier-deploy}/bin/notifier-deploy" else null;
                };
            };
        };

        hooks =
            let
                mkCominHooks = events: ((mapAttrs' (eventName: eventType: {
                    name = "on${eventName}";
                    value = mkOption {
                        description = ''
                            **Comin Event Hook:**

                            Commands to run on comin.events.${eventName} (see [nlewo/comin](https://github.com/nlewo/comin/blob/main/pkg/protobuf/services.proto))
                            Should be an attrset of `{hook_name: "<path to executable>"}`
                        '';
                        type = types.attrsOf types.path;
                        default = {};
                    };
                }) events) // {
                    _cominEventTypes = mkOption {
                        description = "INTERNAL: mapping event names to event types for script utility";
                        type = types.attrsOf types.singleLineStr;
                        readOnly = true;
                        internal = true;
                        default = events;
                    };
                });
            in
            ({
                enable = mkEnableOption "running commands as hooks based on different events and upgrade stages";
            } // mkCominHooks {
                EvalStarted = "evalStartedType";
                EvalFinished = "evalFinishedType";
                BuildStarted = "buildStartedType";
                BuildFinished = "buildFinishedType";
                ConfirmationSubmitted = "confirmationSubmittedType";
                ConfirmationCancelled = "confirmationCancelledType";
                ConfirmationConfirmed = "confirmationConfirmedType";
                Resume = "resume";
                Suspend = "suspend";
                DeploymentStarted = "deploymentStartedType";
                DeploymentFinished = "deploymentFinishedType";
                RebootRequired = "rebootRequired";
                Fetched = "fetched";
            });

        gpgKeys = mkOption {
            description = "A list of GPG public key file paths. Each of this file should contains an armored GPG key.";
            type = types.listOf types.singleLineStr;
            default = [ ];
        };

        identification = {
            hostname = mkOption {
                description = ''
                    The name of the configuration to evaluate and deploy. This value is used by comin to evaluate the flake output nixosConfigurations.“<hostname>” or darwinConfigurations.“<hostname>”. 
                    Defaults to networking.hostName - you MUST set either this option or networking.hostName in your configuration.
                '';
                type = types.singleLineStr;
                default = config.networking.hostName;
            };
            machineId = mkOption {
                description = ''
                    The expected machine-id of the machine configured by comin. If not null, the configuration is only deployed when this specified machine-id is equal to the actual machine-id. 
                    This is mainly useful for server migration: this allows to migrate a configuration from a machine to another machine (with different hardware for instance) without impacting both. 
                    Note it is only used by comin at evaluation.
                '';
                type = types.nullOr types.singleLineStr;
                default = null;
            };
        };
    };
}
