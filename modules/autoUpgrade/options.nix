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
        enable = mkEnableOption "automatic system updates backed by comin";

        desktop = {
            enable = mkEnableOption "features relating to use in a graphical environment";
            buildConfirmation = {
                enable = mkEnableOption "the standard build confirmation dialog";
                title = mkOption {
                    description = "Title of generated notification";
                    type = types.singleLineStr;
                    default = "Updater";
                };
                summary = mkOption {
                    description = "Notifcation summary";
                    type = types.str;
                    default = "Build confirmation pending: ";
                };
                action = mkOption {
                    description = "Name of confirmation action";
                    type = types.singleLineStr;
                    default = "Build";
                };
                urgency = mkOption {
                    description = "Notification urgency";
                    type = types.enum [
                        "low"
                        "normal"
                        "critical"
                    ];
                    default = "critical";
                };
            };
            deployConfirmation = {
                enable = mkEnableOption "the standard deploy confirmation dialog";
                title = mkOption {
                    description = "Title of generated notification";
                    type = types.singleLineStr;
                    default = "Updater";
                };
                summary = mkOption {
                    description = "Notifcation summary";
                    type = types.str;
                    default = "Deploy confirmation pending: ";
                };
                action = mkOption {
                    description = "Name of confirmation action";
                    type = types.singleLineStr;
                    default = "Deploy";
                };
                urgency = mkOption {
                    description = "Notification urgency";
                    type = types.enum [
                        "low"
                        "normal"
                        "critical"
                    ];
                    default = "critical";
                };
            };
            rebootConfirmation = {
                enable = mkEnableOption "the standard auto-reboot confirmation dialog";
                title = mkOption {
                    description = "Title of generated notification";
                    type = types.singleLineStr;
                    default = "Updater";
                };
                summary = mkOption {
                    description = "Notifcation summary";
                    type = types.str;
                    default = "Reboot required: ";
                };
                action = mkOption {
                    description = "Name of confirmation action";
                    type = types.singleLineStr;
                    default = "Reboot Now";
                };
                urgency = mkOption {
                    description = "Notification urgency";
                    type = types.enum [
                        "low"
                        "normal"
                        "critical"
                    ];
                    default = "critical";
                };
            };
        };

        # Comin internals
        comin = {
            package = mkOption {
                description = "Comin package to use";
                type = types.nullOr types.package;
                defaultText = "pkgs.comin or inputs.comin.packages.system.default or null";
            };
            debug = mkOption {
                description = ''
                    Enable comin debug mode

                    **Warning:**
                    This setting will display secrets!
                '';
                type = types.bool;
                default = false;
            };
            repositorySubdir = mkOption {
                description = "Subdirectory in the repository, containing a flake.nix file.";
                type = types.str;
                default = ".";
            };
            submodules = mkOption {
                description = "Whether to fetch and include Git submodules when cloning the repository. When enabled, this adds ?submodules=1 to the flake URL.";
                type = types.bool;
                default = false;
            };
            retention = {
                deployment_boot_entry_capacity = mkOption {
                    type = types.int;
                    default = 3;
                    description = ''
                        Number of boot entries to keep. Controls how many successful
                        deployments generating boot entries (boot or switch operations)
                        with unique storepaths are retained.
                    '';
                };
                deployment_successful_capacity = mkOption {
                    type = types.int;
                    default = 3;
                    description = ''
                        Number of successful deployments to keep. Includes all deployments
                        with status=done, regardless of operation type.
                    '';
                };
                deployment_any_capacity = mkOption {
                    type = types.int;
                    default = 5;
                    description = ''
                        Total number of deployments to keep. Includes all deployments
                        regardless of status (including failed deployments).
                    '';
                };
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
                    default = null;
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
                    default = null;
                };
            };
        };

        hooks =
            let
                mkCominHooks =
                    events:
                    (
                        (mapAttrs' (eventName: eventType: {
                            name = "on${eventName}";
                            value = mkOption {
                                description = ''
                                    **Comin Event Hook:**

                                    Commands to run on comin.events.${eventName} (see [nlewo/comin](https://github.com/nlewo/comin/blob/main/pkg/protobuf/services.proto))
                                    Should be a list of executable paths, to be run in order
                                '';
                                type = types.listOf types.path;
                                default = [ ];
                            };
                        }) events)
                        // {
                            _cominEventTypes = mkOption {
                                description = "INTERNAL: mapping event names to event types for script utility";
                                type = types.attrsOf types.singleLineStr;
                                readOnly = true;
                                internal = true;
                                default = events;
                            };
                        }
                    );
            in
            (
                {
                    enable = mkEnableOption "running commands as hooks based on different events and upgrade stages";
                }
                // mkCominHooks {
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
                }
            );

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

        remotes = mkOption {
            description = ''
                Git remotes to pull from
                Maps directly to `comin.remotes`
            '';
            type = types.listOf (
                types.submodule {
                    options = {
                        name = mkOption {
                            description = "The name of the remote.";
                            type = types.str;
                        };
                        url = mkOption {
                            description = "The URL of the repository.";
                            type = types.str;
                        };
                        auth = {
                            access_token_path = mkOption {
                                description = "The path of the auth file.";
                                type = types.str;
                                default = "";
                            };
                            username = mkOption {
                                description = "The username used to authenticate to the Git remote repository. Note that any non empty username is valid on GitLab and GitHub.";
                                type = types.str;
                                default = "comin";
                            };
                        };
                        branches = {
                            main = {
                                name = mkOption {
                                    description = "The name of the main branch.";
                                    type = types.str;
                                    default = "main";
                                };
                                operation = mkOption {
                                    description = "The switch-to-configuration operation to do on this branch.";
                                    type = types.enum [
                                        "switch"
                                        "test"
                                        "boot"
                                    ];
                                    default = "switch";
                                };
                            };
                            testing = {
                                name = mkOption {
                                    description = "The name of the testing branch.";
                                    type = types.str;
                                    default = "testing-${cfg.identification.hostname}";
                                };
                                operation = mkOption {
                                    description = "The switch-to-configuration operation to do on this branch.";
                                    type = types.enum [
                                        "switch"
                                        "test"
                                        "boot"
                                    ];
                                    default = "test";
                                };
                            };
                        };
                        poller = {
                            period = mkOption {
                                description = "The poller period in seconds.";
                                type = types.int;
                                default = 60;
                            };
                            timeout = mkOption {
                                description = "Git fetch timeout in seconds.";
                                type = types.int;
                                default = 300;
                            };
                        };
                    };
                }
            );
        };

        reboot = {
            enable = mkEnableOption "detection and automation of required reboots";
            mode = mkOption {
                description = ''
                    Shutdown automation mode

                    **Allowed Modes:**
                     - `auto`: Shuts down immediately upon receiving event
                     - `desktop`: Sends a desktop notification prompting for reboot. `desktop.rebootConfirmation` must be enabled.
                     - `command`: Delegates shutdown to a command
                '';
                type = types.enum [
                    "auto"
                    "desktop"
                    "command"
                ];
                default = "auto";
            };
            rebootWindow = mkOption {
                description = ''
                    Define a lower and upper time value (in HH:MM format) which
                    constitute a time window during which reboots are allowed after an upgrade.
                    This option only has an effect when {option}`allowReboot` is enabled.
                    The default value of `null` means that reboots are allowed at any time.
                '';
                default = null;
                example = {
                    lower = "01:00";
                    upper = "05:00";
                };
                type = types.nullOr (
                    types.submodule {
                        options = {
                            lower = mkOption {
                                description = "Lower limit of the reboot window";
                                type = types.strMatching "[[:digit:]]{2}:[[:digit:]]{2}";
                                example = "01:00";
                            };

                            upper = mkOption {
                                description = "Upper limit of the reboot window";
                                type = types.strMatching "[[:digit:]]{2}:[[:digit:]]{2}";
                                example = "05:00";
                            };
                        };
                    }
                );
            };
            rebootCommand = mkOption {
                description = ''
                    Command to run when `reboot.mode` == `command`
                '';
                type = types.str;
                default = "shutdown -r now";
            };
        };
    };
}
