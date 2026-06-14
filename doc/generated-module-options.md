## nixos-utilities\.services\.autoUpgrade\.enable



Whether to enable automatic system updates backed by comin\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.comin\.package



Comin package to use



*Type:*
null or package



*Default:*

```nix
"pkgs.comin or inputs.comin.packages.system.default or null"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.comin\.debug

Enable comin debug mode

**Warning:**
This setting will display secrets!



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.comin\.repositorySubdir



Subdirectory in the repository, containing a flake\.nix file\.



*Type:*
string



*Default:*

```nix
"."
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.comin\.retention\.deployment_any_capacity



Total number of deployments to keep\. Includes all deployments
regardless of status (including failed deployments)\.



*Type:*
signed integer



*Default:*

```nix
5
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.comin\.retention\.deployment_boot_entry_capacity



Number of boot entries to keep\. Controls how many successful
deployments generating boot entries (boot or switch operations)
with unique storepaths are retained\.



*Type:*
signed integer



*Default:*

```nix
3
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.comin\.retention\.deployment_successful_capacity



Number of successful deployments to keep\. Includes all deployments
with status=done, regardless of operation type\.



*Type:*
signed integer



*Default:*

```nix
3
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.comin\.submodules



Whether to fetch and include Git submodules when cloning the repository\. When enabled, this adds ?submodules=1 to the flake URL\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.confirmation\.build\.enable



Whether to enable the build confirmer (` comin.buildConfirmer `)
Specifically, sets ` comin.buildConfirmer.mode ` to “without” if not enabled
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.confirmation\.build\.autoconfirm_duration



Duration for the autoconfirmer, or ` null ` to disable auto-confirmation
Implies ` comin.buildConfirmer.mode ` based on this setting



*Type:*
null or (unsigned integer, meaning >=0)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.confirmation\.build\.confirmation_command



Command to run when a build confirmation is waiting



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.confirmation\.deploy\.enable



Whether to enable the deploy confirmer (` comin.deployConfirmer `)
Specifically, sets ` comin.deployConfirmer.mode ` to “without” if not enabled
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.confirmation\.deploy\.autoconfirm_duration



Duration for the autoconfirmer, or ` null ` to disable auto-confirmation
Implies ` comin.deployConfirmer.mode ` based on this setting



*Type:*
null or (unsigned integer, meaning >=0)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.confirmation\.deploy\.confirmation_command



Command to run when a deploy confirmation is waiting



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.enable



Whether to enable features relating to use in a graphical environment\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.buildConfirmation\.enable



Whether to enable the standard build confirmation dialog\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.buildConfirmation\.action



Name of confirmation action



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"Build"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.buildConfirmation\.summary



Notifcation summary



*Type:*
string



*Default:*

```nix
"Build confirmation pending: "
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.buildConfirmation\.title



Title of generated notification



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"Updater"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.buildConfirmation\.urgency



Notification urgency



*Type:*
one of “low”, “normal”, “critical”



*Default:*

```nix
"critical"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.deployConfirmation\.enable



Whether to enable the standard deploy confirmation dialog\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.deployConfirmation\.action



Name of confirmation action



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"Deploy"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.deployConfirmation\.summary



Notifcation summary



*Type:*
string



*Default:*

```nix
"Deploy confirmation pending: "
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.deployConfirmation\.title



Title of generated notification



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"Updater"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.desktop\.deployConfirmation\.urgency



Notification urgency



*Type:*
one of “low”, “normal”, “critical”



*Default:*

```nix
"critical"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.gpgKeys



A list of GPG public key file paths\. Each of this file should contains an armored GPG key\.



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.enable



Whether to enable running commands as hooks based on different events and upgrade stages\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onBuildFinished



**Comin Event Hook:**

Commands to run on comin\.events\.BuildFinished (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onBuildStarted



**Comin Event Hook:**

Commands to run on comin\.events\.BuildStarted (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onConfirmationCancelled



**Comin Event Hook:**

Commands to run on comin\.events\.ConfirmationCancelled (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onConfirmationConfirmed



**Comin Event Hook:**

Commands to run on comin\.events\.ConfirmationConfirmed (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onConfirmationSubmitted



**Comin Event Hook:**

Commands to run on comin\.events\.ConfirmationSubmitted (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onDeploymentFinished



**Comin Event Hook:**

Commands to run on comin\.events\.DeploymentFinished (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onDeploymentStarted



**Comin Event Hook:**

Commands to run on comin\.events\.DeploymentStarted (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onEvalFinished



**Comin Event Hook:**

Commands to run on comin\.events\.EvalFinished (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onEvalStarted



**Comin Event Hook:**

Commands to run on comin\.events\.EvalStarted (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onFetched



**Comin Event Hook:**

Commands to run on comin\.events\.Fetched (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onRebootRequired



**Comin Event Hook:**

Commands to run on comin\.events\.RebootRequired (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onResume



**Comin Event Hook:**

Commands to run on comin\.events\.Resume (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.hooks\.onSuspend



**Comin Event Hook:**

Commands to run on comin\.events\.Suspend (see [nlewo/comin](https://github\.com/nlewo/comin/blob/main/pkg/protobuf/services\.proto))
Should be a list of executable paths, to be run in order



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.identification\.hostname



The name of the configuration to evaluate and deploy\. This value is used by comin to evaluate the flake output nixosConfigurations\.“\<hostname>” or darwinConfigurations\.“\<hostname>”\.
Defaults to networking\.hostName - you MUST set either this option or networking\.hostName in your configuration\.



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"the-machine-hostname"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.identification\.machineId



The expected machine-id of the machine configured by comin\. If not null, the configuration is only deployed when this specified machine-id is equal to the actual machine-id\.
This is mainly useful for server migration: this allows to migrate a configuration from a machine to another machine (with different hardware for instance) without impacting both\.
Note it is only used by comin at evaluation\.



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes



Git remotes to pull from
Maps directly to ` comin.remotes `



*Type:*
list of (submodule)

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.auth\.access_token_path



The path of the auth file\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.auth\.username



The username used to authenticate to the Git remote repository\. Note that any non empty username is valid on GitLab and GitHub\.



*Type:*
string



*Default:*

```nix
"comin"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.branches\.main\.name



The name of the main branch\.



*Type:*
string



*Default:*

```nix
"main"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.branches\.main\.operation



The switch-to-configuration operation to do on this branch\.



*Type:*
one of “switch”, “test”, “boot”



*Default:*

```nix
"switch"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.branches\.testing\.name



The name of the testing branch\.



*Type:*
string



*Default:*

```nix
"testing-the-machine-hostname"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.branches\.testing\.operation



The switch-to-configuration operation to do on this branch\.



*Type:*
one of “switch”, “test”, “boot”



*Default:*

```nix
"test"
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.name



The name of the remote\.



*Type:*
string

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.poller\.period



The poller period in seconds\.



*Type:*
signed integer



*Default:*

```nix
60
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.poller\.timeout



Git fetch timeout in seconds\.



*Type:*
signed integer



*Default:*

```nix
300
```

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.services\.autoUpgrade\.remotes\.\*\.url



The URL of the repository\.



*Type:*
string

*Declared by:*
 - [modules/autoUpgrade/options\.nix](../modules/autoUpgrade/options.nix)



## nixos-utilities\.systems\.router\.enable



Whether to enable Enable router subsystem\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.dns\.enable



Whether to enable Enable global DNS\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.dns\.upstreamServers



Upstream DNS servers



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*

```nix
[
  "1.1.1.1"
]
```



*Example:*

```nix
[
  "1.1.1.1"
  "9.9.9.9"
]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.domain



DNS search domain



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"example.com"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.dynamicDns\.enable



Whether to enable Enable DynamicDNS with ddns-updater\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.dynamicDns\.config_file



Path to config file



*Type:*
absolute path



*Default:*

```nix
"config.nixos-utilities.systems.router.secrets.paths.dyndns-config"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.dynamicDns\.extra_environment



Additional envvars for ddns-updater



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.dynamicDns\.period



Period to update dyndns



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"5m"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.dynamicDns\.server_enabled



Whether to enable Enable ddns-updater server (SERVER_ENABLED=yes/no)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.firewall\.allowPing



Allow ICMP echo requests on the firewall\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.firewall\.allowedTCPPorts



TCP ports open on untrusted interfaces (e\.g\. WAN)\. Do not add SSH (22); it is only reachable from trusted LAN interfaces\.



*Type:*
list of 16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
[
  80
  443
]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.firewall\.allowedUDPPorts



UDP ports open on untrusted interfaces (e\.g\. WAN)\. Do not add DNS (53) or DHCP (67/68); they are opened only on LAN interfaces by the DNS module\.



*Type:*
list of 16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan



LAN configuration, including arbitrary subnets and subnet isolation



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.isolation



Configuration of isolation between networks



*Type:*
submodule



*Default:*

```nix
{
  enable = true;
}
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.isolation\.enable



Whether to enable Enable NAT isolation\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.isolation\.exceptions



Isolation exceptions



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.isolation\.exceptions\.\*\.address



IP address to allow through isolation



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.isolation\.exceptions\.\*\.description



Reasoning for this exception



*Type:*
string



*Default:*

```nix
"Generic exception"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.isolation\.exceptions\.\*\.destination



Destination network name



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.isolation\.exceptions\.\*\.source



Source network name



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks



Configuration of LAN networks



*Type:*
attribute set of (submodule)

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.bridge



Associated bridge



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.bridge\.interfaces



Associated interfaces



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "enp6s0"
  "enp7s0"
]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.bridge\.name



Bridge name



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"br0"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp



DHCP configuration for this network



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.enable



Whether to enable Enable DHCP for this network\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.dnsServers



DHCP-provided DNS servers\.
Defaults to the provided gateway address(es) of this network



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*

```nix
"[ netcfg.ipv4.gateway ] ++ (optional netcfg.ipv6.enable netcfg.ipv6.gateway)"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.dynamicDomain



DHCP option 15 — see dhcp-lan\.nix for wildcard/suffix interaction with *\.zone in dns-*\.nix\.
option15Domain = “dhcp\.homelab\.local”;

Dynamic DNS domain for DHCP clients (optional)
If set, ALL DHCP clients get automatic DNS entries
Example: client with hostname “phone” gets “phone\.dhcp\.homelab\.local”
If no hostname provided, uses: “dhcp-\<last-octet>\.dhcp\.homelab\.local”



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*

```nix
null
```



*Example:*

```nix
"dhcp.lan"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.end



DHCP end address



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"192.168.0.200"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.leaseTime



DHCP lease time



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"1h"
```



*Example:*

```nix
"1h"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.reservations



DHCP reservations



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.reservations\.\*\.comment



Reservation comment



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.reservations\.\*\.hostname



Reservation hostname



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.reservations\.\*\.hwAddress



Reservation hardware address



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.reservations\.\*\.ipAddress



Reservation IP address



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dhcp\.start



DHCP start address



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"192.168.0.100"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns



DNS configuration for this network



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.enable



Whether to enable Enable DNS for this network\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.blocklists



DNS Blocklists



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.blocklists\.\<name>\.enable



Whether to enable Enable this blocklist\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.blocklists\.\<name>\.description



Blocklist description



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.blocklists\.\<name>\.updateInterval



Blocklist update frequency



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"24h"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.blocklists\.\<name>\.url



Blocklist URL



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.forwardUnlisted



Forward unlisted DNS records to upstream



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.records



DNS records



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.records\.a_records



A Records



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.records\.a_records\.\<name>\.comment



Record comment



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.records\.a_records\.\<name>\.target



Record target



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.records\.cname_records

CNAME Records



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.records\.cname_records\.\<name>\.comment



Record comment



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.records\.cname_records\.\<name>\.target



Record target



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.dns\.whitelist



Domains to whitelist



*Type:*
list of (optionally newline-terminated) single-line string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "example.com"
]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv4



IPv4 configuration



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv4\.gateway



Gateway IP



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"192.168.0.1"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv4\.prefixLength



Subnet prefix length



*Type:*
signed integer



*Example:*

```nix
24
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv4\.subnet



Subnet specifier



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"192.168.0.0/24"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv6



IPv6 configuration



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv6\.enable



Whether to enable Enable IPv6\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv6\.gateway



Gateway IP



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"fd00:dead:beef::1"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv6\.prefixLength



Subnet prefix length



*Type:*
signed integer



*Example:*

```nix
64
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.ipv6\.subnet



Subnet specifier



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"fd00:dead:beef::0/64"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.networks\.\<name>\.name



Network name (should generally be left as the default)



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"‹name›"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.lan\.primaryNetwork



Name of primary network for search domain



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.nameservers



Nameservers for /etc/resolv\.conf



*Type:*
null or (list of (optionally newline-terminated) single-line string)



*Default:*

```nix
null
```



*Example:*

```nix
[
  "1.1.1.1"
  "9.9.9.9"
]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.nat\.enable



Whether to enable Enable NAT between LAN and WAN…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.nat\.enableIPv6



Enable IPv6 masquerading (if supported)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.nat\.externalInterface



Interface used for outbound NAT\. If left null, it is derived
from the WAN type (ppp0/pptp0 for PPP variants, otherwise the WAN physical interface)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.nat\.internalInterfaces



Interfaces treated as internal networks for NAT\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.portForwarding



Port forwarding rules



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.portForwarding\.\*\.destinationIp



IP to route to internally



*Type:*
(optionally newline-terminated) single-line string

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.portForwarding\.\*\.externalPort



External port (or range) to forward from



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive) or (submodule)

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.portForwarding\.\*\.internalPort



Internal port (or range) to forward to\. Defaults to ` externalPort ` if null



*Type:*
null or 16 bit unsigned integer; between 0 and 65535 (both inclusive) or (submodule)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.portForwarding\.\*\.protocol



Which protocol to forward



*Type:*
one of “both”, “tcp”, “udp”



*Default:*

```nix
"both"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan



WAN interface \& behavior config



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.cake



CAKE configuration



*Type:*
submodule



*Default:*

```nix
{
  enable = false;
}
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.cake\.enable



Whether to enable Enable CAKE on WAN\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.cake\.aggressiveness



Options: “auto”, “conservative”, “moderate”, “aggressive”

 - auto: Monitors bandwidth and adjusts automatically (recommended)
 - conservative: Minimal shaping, best for high-speed links
 - moderate: Balanced latency/throughput
 - aggressive: Maximum latency reduction, best for slower links



*Type:*
one of “auto”, “conservative”, “moderate”, “aggressive”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.cake\.downloadBandwidth



Optional download bandwidth



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*

```nix
null
```



*Example:*

```nix
"100Mbit"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.cake\.uploadBandwidth



Optional upload bandwidth



*Type:*
null or (optionally newline-terminated) single-line string



*Default:*

```nix
null
```



*Example:*

```nix
"100Mbit"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.interface



WAN interface



*Type:*
(optionally newline-terminated) single-line string



*Example:*

```nix
"eno1"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.pppoe



Configuration for PPPOE addressing on the WAN interface, if ` wan.type ` == ` pppoe `



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.pppoe\.ipv6



Enable IPv6 negotiation on the PPPoE session\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.pppoe\.logicalInterface



Name of the PPPoE interface created by pppd\.



*Type:*
string



*Default:*

```nix
"ppp0"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.pppoe\.mtu



Override MTU for the PPPoE session\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.pppoe\.passwordFile



Absolute path to the PPPoE password file\.



*Type:*
string



*Default:*

```nix
"/etc/nixos/secrets/pppoe-password"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.pppoe\.service



Optional PPPoE service name\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.pppoe\.user



PPPoE username supplied by the ISP\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static



Configuration for static addressing on the WAN interface, if ` wan.type ` == ` static `



*Type:*
submodule

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.dnsServers



DNS servers to use when static addressing is selected\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.ipv4\.address



Static IPv4 address assigned to the WAN interface\.



*Type:*
string



*Default:*

```nix
"203.0.113.2"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.ipv4\.gateway



Default IPv4 gateway for static mode\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.ipv4\.prefixLength



Prefix length for the static IPv4 network\.



*Type:*
signed integer



*Default:*

```nix
24
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.ipv6\.enable



Whether to enable Enable static IPv6 configuration on the WAN interface…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.ipv6\.address



Static IPv6 address in static mode\.



*Type:*
string



*Default:*

```nix
"2001:db8::2"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.ipv6\.gateway



Default IPv6 gateway for static mode\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.static\.ipv6\.prefixLength



Prefix length for the static IPv6 network\.



*Type:*
signed integer



*Default:*

```nix
64
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.config\.wan\.type



WAN type



*Type:*
one of “dhcp”, “pppoe”, “static”



*Default:*

```nix
"dhcp"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.paths\.dyndns-config



Path to dyndns-config secret



*Type:*
string



*Default:*

```nix
"mkIf cfg.secrets.sops.enable config.sops.secrets.ddns-updater.conf.path"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.paths\.pppoe-config



Path to pppoe-config secret



*Type:*
string



*Default:*

```nix
"mkIf cfg.secrets.sops.enable config.sops.templates.pppoe-peer.conf.path"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.paths\.pppoe-password



Path to pppoe-password secret



*Type:*
string



*Default:*

```nix
"mkIf cfg.secrets.sops.enable config.sops.secrets.pppoe-password.path"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.paths\.pppoe-username



Path to pppoe-username secret



*Type:*
string



*Default:*

```nix
"mkIf cfg.secrets.sops.enable config.sops.secrets.pppoe-username.path"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.sops\.enable



Whether to enable automatic sops-nix configuration (assumes sops-nix is already configured globally)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.sops\.dyndns



Secret name for dyndns configuration



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"ddns-updater.conf"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.sops\.pppoe\.config



Name of the PPPOE config file generated



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"pppoe-peer.conf"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.sops\.pppoe\.password



Secret name for PPPOE password



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"pppoe-password"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)



## nixos-utilities\.systems\.router\.secrets\.sops\.pppoe\.username



Secret name for PPPOE username



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"pppoe-username"
```

*Declared by:*
 - [modules/router/options\.nix](../modules/router/options.nix)


