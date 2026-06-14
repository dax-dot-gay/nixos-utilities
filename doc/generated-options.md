# NixOS Module Options


## [`nixos-utilities.services.autoUpgrade.enable`](../modules/autoUpgrade/options.nix#L16)

Whether to enable automatic system updates backed by comin.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.services.autoUpgrade.enableDesktop`](../modules/autoUpgrade/options.nix#L18)

Whether to enable 
features relevant to a GUI environment:
- Confirmation will show a desktop notification by default, if enabled
.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.services.autoUpgrade.comin.package`](../modules/autoUpgrade/options.nix#L25)

Comin package to use

**Type:** `types.nullOr types.package`

## [`nixos-utilities.services.autoUpgrade.comin.debug`](../modules/autoUpgrade/options.nix#L30)

comin debug mode (WARN: shows secrets)

**Type:** `types.bool`

**Default:** `false`

## [`nixos-utilities.services.autoUpgrade.comin.repositorySubdir`](../modules/autoUpgrade/options.nix#L35)

Subdirectory in the repository, containing a flake.nix file.

**Type:** `types.str`

**Default:** `"."`

## [`nixos-utilities.services.autoUpgrade.comin.submodules`](../modules/autoUpgrade/options.nix#L40)

Whether to fetch and include Git submodules when cloning the repository. When enabled, this adds ?submodules=1 to the flake URL.

**Type:** `types.bool`

**Default:** `false`

## [`nixos-utilities.services.autoUpgrade.comin.retention.deployment_boot_entry_capacity`](../modules/autoUpgrade/options.nix#L46)


Number of boot entries to keep. Controls how many successful
deployments generating boot entries (boot or switch operations)
with unique storepaths are retained.


**Type:** `int`

**Default:** `3`

## [`nixos-utilities.services.autoUpgrade.comin.retention.deployment_successful_capacity`](../modules/autoUpgrade/options.nix#L55)


Number of successful deployments to keep. Includes all deployments
with status=done, regardless of operation type.


**Type:** `int`

**Default:** `3`

## [`nixos-utilities.services.autoUpgrade.comin.retention.deployment_any_capacity`](../modules/autoUpgrade/options.nix#L63)


Total number of deployments to keep. Includes all deployments
regardless of status (including failed deployments).


**Type:** `int`

**Default:** `5`

## [`nixos-utilities.services.autoUpgrade.confirmation.build.enable`](../modules/autoUpgrade/options.nix#L77)

Whether to enable 
the build confirmer (`comin.buildConfirmer`)
Specifically, sets `comin.buildConfirmer.mode` to "without" if not enabled
.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.services.autoUpgrade.confirmation.build.autoconfirm_duration`](../modules/autoUpgrade/options.nix#L81)


Duration for the autoconfirmer, or `null` to disable auto-confirmation
Implies `comin.buildConfirmer.mode` based on this setting


**Type:** `types.nullOr types.ints.unsigned`

**Default:** `null`

## [`nixos-utilities.services.autoUpgrade.confirmation.build.confirmation_command`](../modules/autoUpgrade/options.nix#L89)

Command to run when a build confirmation is waiting

**Type:** `types.nullOr types.path`

**Default:**

```nix
if cfg.enableDesktop then "${scripts.notifier-build}/bin/notifier-build" else null
```

## [`nixos-utilities.services.autoUpgrade.confirmation.deploy.enable`](../modules/autoUpgrade/options.nix#L96)

Whether to enable 
the deploy confirmer (`comin.deployConfirmer`)
Specifically, sets `comin.deployConfirmer.mode` to "without" if not enabled
.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.services.autoUpgrade.confirmation.deploy.autoconfirm_duration`](../modules/autoUpgrade/options.nix#L100)


Duration for the autoconfirmer, or `null` to disable auto-confirmation
Implies `comin.deployConfirmer.mode` based on this setting


**Type:** `types.nullOr types.ints.unsigned`

**Default:** `null`

## [`nixos-utilities.services.autoUpgrade.confirmation.deploy.confirmation_command`](../modules/autoUpgrade/options.nix#L108)

Command to run when a deploy confirmation is waiting

**Type:** `types.nullOr types.path`

**Default:**

```nix
if cfg.enableDesktop then "${scripts.notifier-deploy}/bin/notifier-deploy" else null
```

## [`nixos-utilities.services.autoUpgrade.gpgKeys`](../modules/autoUpgrade/options.nix#L166)

A list of GPG public key file paths. Each of this file should contains an armored GPG key.

**Type:** `types.listOf types.singleLineStr`

**Default:** `[ ]`

## [`nixos-utilities.services.autoUpgrade.identification.hostname`](../modules/autoUpgrade/options.nix#L173)


The name of the configuration to evaluate and deploy. This value is used by comin to evaluate the flake output nixosConfigurations.“<hostname>” or darwinConfigurations.“<hostname>”. 
Defaults to networking.hostName - you MUST set either this option or networking.hostName in your configuration.


**Type:** `types.singleLineStr`

**Default:** `config.networking.hostName`

## [`nixos-utilities.services.autoUpgrade.identification.machineId`](../modules/autoUpgrade/options.nix#L181)


The expected machine-id of the machine configured by comin. If not null, the configuration is only deployed when this specified machine-id is equal to the actual machine-id. 
This is mainly useful for server migration: this allows to migrate a configuration from a machine to another machine (with different hardware for instance) without impacting both. 
Note it is only used by comin at evaluation.


**Type:** `types.nullOr types.singleLineStr`

**Default:** `null`

## [`nixos-utilities.services.autoUpgrade.remotes`](../modules/autoUpgrade/options.nix#L192)


Git remotes to pull from
Maps directly to `comin.remotes`


**Type:**

```nix
types.listOf (
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
)
```

## [`nixos-utilities.systems.router.enable`](../modules/router/options.nix#L57)

Whether to enable Enable router subsystem.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.domain`](../modules/router/options.nix#L59)

DNS search domain

**Type:** `types.singleLineStr`

**Example:** `"example.com"`

## [`nixos-utilities.systems.router.config.nameservers`](../modules/router/options.nix#L64)

Nameservers for /etc/resolv.conf

**Type:** `types.nullOr (types.listOf types.singleLineStr)`

**Default:** `null`

**Example:**

```nix
[
    "1.1.1.1"
    "9.9.9.9"
]
```

## [`nixos-utilities.systems.router.config.wan.type`](../modules/router/options.nix#L74)

WAN type

**Type:**

```nix
types.enum [
    "dhcp"
    "pppoe"
    "static"
]
```

**Default:** `"dhcp"`

## [`nixos-utilities.systems.router.config.wan.interface`](../modules/router/options.nix#L83)

WAN interface

**Type:** `types.singleLineStr`

**Example:** `"eno1"`

## [`nixos-utilities.systems.router.config.wan.cake.enable`](../modules/router/options.nix#L89)

Whether to enable Enable CAKE on WAN.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.wan.cake.aggressiveness`](../modules/router/options.nix#L90)


Options: "auto", "conservative", "moderate", "aggressive"
- auto: Monitors bandwidth and adjusts automatically (recommended)
- conservative: Minimal shaping, best for high-speed links
- moderate: Balanced latency/throughput
- aggressive: Maximum latency reduction, best for slower links


**Type:**

```nix
types.enum [
    "auto"
    "conservative"
    "moderate"
    "aggressive"
]
```

**Default:** `"auto"`

## [`nixos-utilities.systems.router.config.wan.cake.uploadBandwidth`](../modules/router/options.nix#L106)

Optional upload bandwidth

**Type:** `types.nullOr types.singleLineStr`

**Default:** `null`

**Example:** `"100Mbit"`

## [`nixos-utilities.systems.router.config.wan.cake.downloadBandwidth`](../modules/router/options.nix#L112)

Optional download bandwidth

**Type:** `types.nullOr types.singleLineStr`

**Default:** `null`

**Example:** `"100Mbit"`

## [`nixos-utilities.systems.router.config.wan.static.ipv4.address`](../modules/router/options.nix#L121)

Static IPv4 address assigned to the WAN interface.

**Type:** `types.str`

**Default:** `"203.0.113.2"`

## [`nixos-utilities.systems.router.config.wan.static.ipv4.prefixLength`](../modules/router/options.nix#L126)

Prefix length for the static IPv4 network.

**Type:** `types.int`

**Default:** `24`

## [`nixos-utilities.systems.router.config.wan.static.ipv4.gateway`](../modules/router/options.nix#L131)

Default IPv4 gateway for static mode.

**Type:** `types.nullOr types.str`

**Default:** `null`

## [`nixos-utilities.systems.router.config.wan.static.ipv6.enable`](../modules/router/options.nix#L138)

Whether to enable Enable static IPv6 configuration on the WAN interface..

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.wan.static.ipv6.address`](../modules/router/options.nix#L139)

Static IPv6 address in static mode.

**Type:** `types.str`

**Default:** `"2001:db8::2"`

## [`nixos-utilities.systems.router.config.wan.static.ipv6.prefixLength`](../modules/router/options.nix#L144)

Prefix length for the static IPv6 network.

**Type:** `types.int`

**Default:** `64`

## [`nixos-utilities.systems.router.config.wan.static.ipv6.gateway`](../modules/router/options.nix#L149)

Default IPv6 gateway for static mode.

**Type:** `types.nullOr types.str`

**Default:** `null`

## [`nixos-utilities.systems.router.config.wan.static.dnsServers`](../modules/router/options.nix#L155)

DNS servers to use when static addressing is selected.

**Type:** `types.listOf types.str`

**Default:** `[ ]`

## [`nixos-utilities.systems.router.config.wan.pppoe.logicalInterface`](../modules/router/options.nix#L163)

Name of the PPPoE interface created by pppd.

**Type:** `types.str`

**Default:** `"ppp0"`

## [`nixos-utilities.systems.router.config.wan.pppoe.user`](../modules/router/options.nix#L168)

PPPoE username supplied by the ISP.

**Type:** `types.str`

**Default:** `""`

## [`nixos-utilities.systems.router.config.wan.pppoe.passwordFile`](../modules/router/options.nix#L173)

Absolute path to the PPPoE password file.

**Type:** `types.str`

**Default:** `"/etc/nixos/secrets/pppoe-password"`

## [`nixos-utilities.systems.router.config.wan.pppoe.service`](../modules/router/options.nix#L178)

Optional PPPoE service name.

**Type:** `types.nullOr types.str`

**Default:** `null`

## [`nixos-utilities.systems.router.config.wan.pppoe.ipv6`](../modules/router/options.nix#L183)

Enable IPv6 negotiation on the PPPoE session.

**Type:** `types.bool`

**Default:** `true`

## [`nixos-utilities.systems.router.config.wan.pppoe.mtu`](../modules/router/options.nix#L188)

Override MTU for the PPPoE session.

**Type:** `types.nullOr types.int`

**Default:** `null`

## [`nixos-utilities.systems.router.config.lan.isolation.enable`](../modules/router/options.nix#L197)

Whether to enable Enable NAT isolation.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.lan.isolation.exceptions`](../modules/router/options.nix#L198)

Isolation exceptions

**Type:**

```nix
types.listOf (
    types.submodule {
        options = {
            address = mkOption {
                description = "IP address to allow through isolation";
                type = types.singleLineStr;
            };
            source = mkOption {
                description = "Source network name";
                type = types.singleLineStr;
            };
            destination = mkOption {
                description = "Destination network name";
                type = types.singleLineStr;
            };
            description = mkOption {
                description = "Reasoning for this exception";
                type = types.str;
                default = "Generic exception";
            };
        };
    }
)
```

**Default:** `[ ]`

## [`nixos-utilities.systems.router.config.lan.networks`](../modules/router/options.nix#L226)

Configuration of LAN networks

**Type:**

```nix
types.attrsOf (
    types.submodule (
        { config, ... }:
        let
            netcfg = cfg.config.lan.networks.${config._module.args.name};
        in
        {
            options = {
                name = mkOption {
                    description = "Network name (should generally be left as the default)";
                    type = types.singleLineStr;
                    default = config._module.args.name;
                };
                ipv4 = mkOption {
                    description = "IPv4 configuration";
                    type = types.submodule {
                        options = {
                            gateway = mkOption {
                                description = "Gateway IP";
                                type = types.singleLineStr;
                                example = "192.168.0.1";
                            };
                            subnet = mkOption {
                                description = "Subnet specifier";
                                type = types.singleLineStr;
                                example = "192.168.0.0/24";
                            };
                            prefixLength = mkOption {
                                description = "Subnet prefix length";
                                type = types.int;
                                example = 24;
                            };
                        };
                    };
                };
                ipv6 = mkOption {
                    description = "IPv6 configuration";
                    type = types.submodule {
                        options = {
                            enable = mkEnableOption "Enable IPv6";
                            gateway = mkOption {
                                description = "Gateway IP";
                                type = types.singleLineStr;
                                example = "fd00:dead:beef::1";
                            };
                            subnet = mkOption {
                                description = "Subnet specifier";
                                type = types.singleLineStr;
                                example = "fd00:dead:beef::0/64";
                            };
                            prefixLength = mkOption {
                                description = "Subnet prefix length";
                                type = types.int;
                                example = 64;
                            };
                        };
                    };
                };
                bridge = mkOption {
                    description = "Associated bridge";
                    type = types.submodule {
                        options = {
                            name = mkOption {
                                description = "Bridge name";
                                type = types.singleLineStr;
                                example = "br0";
                            };
                            interfaces = mkOption {
                                description = "Associated interfaces";
                                type = types.listOf types.singleLineStr;
                                example = [
                                    "enp6s0"
                                    "enp7s0"
                                ];
                            };
                        };
                    };
                };
                dhcp = {
                    enable = mkEnableOption "Enable DHCP for this network";
                    start = mkOption {
                        description = "DHCP start address";
                        type = types.singleLineStr;
                        example = "192.168.0.100";
                    };
                    end = mkOption {
                        description = "DHCP end address";
                        type = types.singleLineStr;
                        example = "192.168.0.200";
                    };
                    leaseTime = mkOption {
                        description = "DHCP lease time";
                        type = types.singleLineStr;
                        example = "1h";
                        default = "1h";
                    };
                    dnsServers = mkOption {
                        description = ''
                            DHCP-provided DNS servers.
                            Defaults to the provided gateway address(es) of this network
                        '';
                        type = types.listOf types.singleLineStr;
                        default = [ netcfg.ipv4.gateway ] ++ (optional netcfg.ipv6.enable netcfg.ipv6.gateway);
                    };
                    dynamicDomain = mkOption {
                        description = ''
                            DHCP option 15 — see dhcp-lan.nix for wildcard/suffix interaction with *.zone in dns-*.nix.
                            option15Domain = "dhcp.homelab.local";

                            Dynamic DNS domain for DHCP clients (optional)
                            If set, ALL DHCP clients get automatic DNS entries
                            Example: client with hostname "phone" gets "phone.dhcp.homelab.local"
                            If no hostname provided, uses: "dhcp-<last-octet>.dhcp.homelab.local"
                        '';
                        type = types.nullOr types.singleLineStr;
                        default = null;
                        example = "dhcp.lan";
                    };
                    reservations = mkOption {
                        description = "DHCP reservations";
                        type = types.listOf (
                            types.submodule {
                                options = {
                                    hostname = mkOption {
                                        description = "Reservation hostname";
                                        type = types.singleLineStr;
                                    };
                                    hwAddress = mkOption {
                                        description = "Reservation hardware address";
                                        type = types.singleLineStr;
                                    };
                                    ipAddress = mkOption {
                                        description = "Reservation IP address";
                                        type = types.singleLineStr;
                                    };
                                    comment = mkOption {
                                        description = "Reservation comment";
                                        type = types.str;
                                        default = "";
                                    };
                                };
                            }
                        );
                        default = [ ];
                    };
                };
                dns = {
                    enable = mkEnableOption "Enable DNS for this network";
                    forwardUnlisted = mkOption {
                        description = "Forward unlisted DNS records to upstream";
                        type = types.bool;
                        default = true;
                    };
                    records = mkOption {
                        description = "DNS records";
                        type = types.submodule {
                            options = {
                                a_records = mkOption {
                                    description = "A Records";
                                    type = types.attrsOf types.submodule {
                                        options = {
                                            target = mkOption {
                                                description = "Record target";
                                                type = types.singleLineStr;
                                            };
                                            comment = mkOption {
                                                description = "Record comment";
                                                type = types.str;
                                                default = "";
                                            };
                                        };
                                    };
                                    default = { };
                                };
                                cname_records = mkOption {
                                    description = "CNAME Records";
                                    type = types.attrsOf types.submodule {
                                        options = {
                                            target = mkOption {
                                                description = "Record target";
                                                type = types.singleLineStr;
                                            };
                                            comment = mkOption {
                                                description = "Record comment";
                                                type = types.str;
                                                default = "";
                                            };
                                        };
                                    };
                                    default = { };
                                };
                            };
                        };
                    };
                    whitelist = mkOption {
                        description = "Domains to whitelist";
                        type = types.listOf types.singleLineStr;
                        default = [ ];
                        example = [
                            "example.com"
                        ];
                    };
                    blocklists = mkOption {
                        description = "DNS Blocklists";
                        type = types.attrsOf (
                            types.submodule {
                                options = {
                                    enable = mkEnableOption "Enable this blocklist";
                                    url = mkOption {
                                        description = "Blocklist URL";
                                        type = types.singleLineStr;
                                    };
                                    description = mkOption {
                                        description = "Blocklist description";
                                        type = types.str;
                                        default = "";
                                    };
                                    updateInterval = mkOption {
                                        description = "Blocklist update frequency";
                                        type = types.singleLineStr;
                                        default = "24h";
                                    };
                                };
                            }
                        );
                        default = { };
                    };
                };
            };
        }
    )
)
```

## [`nixos-utilities.systems.router.config.lan.primaryNetwork`](../modules/router/options.nix#L461)

Name of primary network for search domain

**Type:** `types.nullOr types.str`

**Default:** `null`

## [`nixos-utilities.systems.router.config.portForwarding`](../modules/router/options.nix#L467)

Port forwarding rules

**Type:** `types.listOf portForwardingConfigType`

**Default:** `[ ]`

## [`nixos-utilities.systems.router.config.dynamicDns.enable`](../modules/router/options.nix#L473)

Whether to enable Enable DynamicDNS with ddns-updater.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.dynamicDns.server_enabled`](../modules/router/options.nix#L474)

Whether to enable Enable ddns-updater server (SERVER_ENABLED=yes/no).

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.dynamicDns.config_file`](../modules/router/options.nix#L475)

Path to config file

**Type:** `types.path`

**Default:** `cfg.secrets.paths.dyndns-config`

## [`nixos-utilities.systems.router.config.dynamicDns.period`](../modules/router/options.nix#L480)

Period to update dyndns

**Type:** `types.singleLineStr`

**Default:** `"5m"`

## [`nixos-utilities.systems.router.config.dynamicDns.extra_environment`](../modules/router/options.nix#L485)

Additional envvars for ddns-updater

**Type:** `types.attrsOf types.str`

**Default:** `{ }`

## [`nixos-utilities.systems.router.config.dns.enable`](../modules/router/options.nix#L492)

Whether to enable Enable global DNS.

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.dns.upstreamServers`](../modules/router/options.nix#L493)

Upstream DNS servers

**Type:** `types.listOf types.singleLineStr`

**Default:**

```nix
[
    "1.1.1.1" # Cloudflare
]
```

**Example:**

```nix
[
    "1.1.1.1" # Cloudflare
    "9.9.9.9" # Quad9
]
```

## [`nixos-utilities.systems.router.config.firewall.allowPing`](../modules/router/options.nix#L506)

Allow ICMP echo requests on the firewall.

**Type:** `types.bool`

**Default:** `true`

## [`nixos-utilities.systems.router.config.firewall.allowedTCPPorts`](../modules/router/options.nix#L511)

TCP ports open on untrusted interfaces (e.g. WAN). Do not add SSH (22); it is only reachable from trusted LAN interfaces.

**Type:** `types.listOf types.port`

**Default:**

```nix
[
    80
    443
]
```

## [`nixos-utilities.systems.router.config.firewall.allowedUDPPorts`](../modules/router/options.nix#L519)

UDP ports open on untrusted interfaces (e.g. WAN). Do not add DNS (53) or DHCP (67/68); they are opened only on LAN interfaces by the DNS module.

**Type:** `types.listOf types.port`

**Default:** `[ ]`

## [`nixos-utilities.systems.router.config.nat.enable`](../modules/router/options.nix#L526)

Whether to enable Enable NAT between LAN and WAN..

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.config.nat.externalInterface`](../modules/router/options.nix#L527)


Interface used for outbound NAT. If left null, it is derived
from the WAN type (ppp0/pptp0 for PPP variants, otherwise the WAN physical interface).


**Type:** `types.nullOr types.str`

**Default:** `null`

## [`nixos-utilities.systems.router.config.nat.internalInterfaces`](../modules/router/options.nix#L535)

Interfaces treated as internal networks for NAT.

**Type:** `types.listOf types.str`

**Default:** `[ ]`

## [`nixos-utilities.systems.router.config.nat.enableIPv6`](../modules/router/options.nix#L540)

Enable IPv6 masquerading (if supported).

**Type:** `types.bool`

**Default:** `true`

## [`nixos-utilities.systems.router.secrets.sops.enable`](../modules/router/options.nix#L549)

Whether to enable automatic sops-nix configuration (assumes sops-nix is already configured globally).

**Type:** `boolean`

**Default:** `false`

**Example:** `true`

## [`nixos-utilities.systems.router.secrets.sops.pppoe.username`](../modules/router/options.nix#L551)

Secret name for PPPOE username

**Type:** `types.singleLineStr`

**Default:** `"pppoe-username"`

## [`nixos-utilities.systems.router.secrets.sops.pppoe.password`](../modules/router/options.nix#L556)

Secret name for PPPOE password

**Type:** `types.singleLineStr`

**Default:** `"pppoe-password"`

## [`nixos-utilities.systems.router.secrets.sops.pppoe.config`](../modules/router/options.nix#L561)

Name of the PPPOE config file generated

**Type:** `types.singleLineStr`

**Default:** `"pppoe-peer.conf"`

## [`nixos-utilities.systems.router.secrets.sops.dyndns`](../modules/router/options.nix#L567)

Secret name for dyndns configuration

**Type:** `types.singleLineStr`

**Default:** `"ddns-updater.conf"`

## [`nixos-utilities.systems.router.secrets.paths.pppoe-username`](../modules/router/options.nix#L574)

Path to pppoe-username secret

**Type:** `types.str`

**Default:**

```nix
mkIf cfg.secrets.sops.enable config.sops.secrets.${cfg.secrets.sops.pppoe.username}.path
```

## [`nixos-utilities.systems.router.secrets.paths.pppoe-password`](../modules/router/options.nix#L579)

Path to pppoe-password secret

**Type:** `types.str`

**Default:**

```nix
mkIf cfg.secrets.sops.enable config.sops.secrets.${cfg.secrets.sops.pppoe.password}.path
```

## [`nixos-utilities.systems.router.secrets.paths.pppoe-config`](../modules/router/options.nix#L584)

Path to pppoe-config secret

**Type:** `types.str`

**Default:**

```nix
mkIf cfg.secrets.sops.enable config.sops.templates.${cfg.secrets.sops.pppoe.config}.path
```

## [`nixos-utilities.systems.router.secrets.paths.dyndns-config`](../modules/router/options.nix#L589)

Path to dyndns-config secret

**Type:** `types.str`

**Default:**

```nix
mkIf cfg.secrets.sops.enable config.sops.secrets.${cfg.secrets.sops.dyndns}.path
```

---
*Generated with [nix-options-doc](https://github.com/Thunderbottom/nix-options-doc)*
