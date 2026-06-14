{
    config,
    lib,
    ...
}:
with lib;
let
    cfg = config.nixos-utilities.systems.router;

    # Port or port range
    portSpecType = types.either types.port (
        types.submodule {
            options = {
                from = mkOption {
                    type = types.port;
                    description = "Starting port in the range.";
                };
                to = mkOption {
                    type = types.port;
                    description = "Ending port in the range.";
                };
            };
        }
    );

    # Options for configuring a single port forward
    portForwardingConfigType = types.submodule {
        options = {
            protocol = mkOption {
                description = "Which protocol to forward";
                type = types.enum [
                    "both"
                    "tcp"
                    "udp"
                ];
                default = "both";
            };
            externalPort = mkOption {
                description = "External port (or range) to forward from";
                type = portSpecType;
            };
            internalPort = mkOption {
                description = "Internal port (or range) to forward to. Defaults to `externalPort` if null";
                type = types.nullOr portSpecType;
                default = null;
            };
            destinationIp = mkOption {
                description = "IP to route to internally";
                type = types.singleLineStr;
            };
        };
    };
in
{
    options = {
        nixos-utilities.systems.router = {
            enable = mkEnableOption "Enable router subsystem";
            config = {
                domain = mkOption {
                    description = "DNS search domain";
                    type = types.singleLineStr;
                    example = "example.com";
                };
                nameservers = mkOption {
                    description = "Nameservers for /etc/resolv.conf";
                    type = types.nullOr (types.listOf types.singleLineStr);
                    example = [
                        "1.1.1.1"
                        "9.9.9.9"
                    ];
                    default = null;
                };
                wan = {
                    type = mkOption {
                        description = "WAN type";
                        type = types.enum [
                            "dhcp"
                            "pppoe"
                            "static"
                        ];
                        default = "dhcp";
                    };
                    interface = mkOption {
                        description = "WAN interface";
                        type = types.singleLineStr;
                        example = "eno1";
                    };
                    cake = {
                        enable = mkEnableOption "Enable CAKE on WAN";
                        aggressiveness = mkOption {
                            description = ''
                                Options: "auto", "conservative", "moderate", "aggressive"
                                - auto: Monitors bandwidth and adjusts automatically (recommended)
                                - conservative: Minimal shaping, best for high-speed links
                                - moderate: Balanced latency/throughput
                                - aggressive: Maximum latency reduction, best for slower links
                            '';
                            type = types.enum [
                                "auto"
                                "conservative"
                                "moderate"
                                "aggressive"
                            ];
                            default = "auto";
                        };
                        uploadBandwidth = mkOption {
                            description = "Optional upload bandwidth";
                            type = types.nullOr types.singleLineStr;
                            default = null;
                            example = "100Mbit";
                        };
                        downloadBandwidth = mkOption {
                            description = "Optional download bandwidth";
                            type = types.nullOr types.singleLineStr;
                            default = null;
                            example = "100Mbit";
                        };
                    };
                    static = {
                        ipv4 = {
                            address = mkOption {
                                type = types.str;
                                default = "203.0.113.2";
                                description = "Static IPv4 address assigned to the WAN interface.";
                            };
                            prefixLength = mkOption {
                                type = types.int;
                                default = 24;
                                description = "Prefix length for the static IPv4 network.";
                            };
                            gateway = mkOption {
                                type = types.nullOr types.str;
                                default = null;
                                description = "Default IPv4 gateway for static mode.";
                            };
                        };
                        ipv6 = {
                            enable = mkEnableOption "Enable static IPv6 configuration on the WAN interface.";
                            address = mkOption {
                                type = types.str;
                                default = "2001:db8::2";
                                description = "Static IPv6 address in static mode.";
                            };
                            prefixLength = mkOption {
                                type = types.int;
                                default = 64;
                                description = "Prefix length for the static IPv6 network.";
                            };
                            gateway = mkOption {
                                type = types.nullOr types.str;
                                default = null;
                                description = "Default IPv6 gateway for static mode.";
                            };
                        };
                        dnsServers = mkOption {
                            type = types.listOf types.str;
                            default = [ ];
                            description = "DNS servers to use when static addressing is selected.";
                        };
                    };

                    pppoe = {
                        logicalInterface = mkOption {
                            type = types.str;
                            default = "ppp0";
                            description = "Name of the PPPoE interface created by pppd.";
                        };
                        user = mkOption {
                            type = types.str;
                            default = "";
                            description = "PPPoE username supplied by the ISP.";
                        };
                        passwordFile = mkOption {
                            type = types.str;
                            default = "/etc/nixos/secrets/pppoe-password";
                            description = "Absolute path to the PPPoE password file.";
                        };
                        service = mkOption {
                            type = types.nullOr types.str;
                            default = null;
                            description = "Optional PPPoE service name.";
                        };
                        ipv6 = mkOption {
                            type = types.bool;
                            default = true;
                            description = "Enable IPv6 negotiation on the PPPoE session.";
                        };
                        mtu = mkOption {
                            type = types.nullOr types.int;
                            default = null;
                            description = "Override MTU for the PPPoE session.";
                        };
                    };
                };
                lan = {
                    isolation = {
                        enable = mkEnableOption "Enable NAT isolation";
                        exceptions = mkOption {
                            description = "Isolation exceptions";
                            type = types.listOf (
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
                            );
                            default = [ ];
                        };
                    };
                    networks = mkOption {
                        description = "Configuration of LAN networks";
                        type = types.attrsOf (
                            types.submodule (
                                { config, ... }:
                                let
                                    netcfg = cfg.config.lan.networks.${config._module.args.name or "*"};
                                in
                                {
                                    options = {
                                        name = mkOption {
                                            description = "Network name (should generally be left as the default)";
                                            type = types.singleLineStr;
                                            default = config._module.args.name or "";
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
                                                defaultText = "[ netcfg.ipv4.gateway ] ++ (optional netcfg.ipv6.enable netcfg.ipv6.gateway)";
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
                                                            type = types.attrsOf (types.submodule {
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
                                                            });
                                                            default = { };
                                                        };
                                                        cname_records = mkOption {
                                                            description = "CNAME Records";
                                                            type = types.attrsOf (types.submodule {
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
                                                            });
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
                        );
                    };
                    primaryNetwork = mkOption {
                        description = "Name of primary network for search domain";
                        type = types.nullOr types.str;
                        default = null;
                    };
                };
                portForwarding = mkOption {
                    description = "Port forwarding rules";
                    type = types.listOf portForwardingConfigType;
                    default = [ ];
                };
                dynamicDns = {
                    enable = mkEnableOption "Enable DynamicDNS with ddns-updater";
                    server_enabled = mkEnableOption "Enable ddns-updater server (SERVER_ENABLED=yes/no)";
                    config_file = mkOption {
                        description = "Path to config file";
                        type = types.path;
                        defaultText = "config.nixos-utilities.systems.router.secrets.paths.dyndns-config";
                    };
                    period = mkOption {
                        description = "Period to update dyndns";
                        type = types.singleLineStr;
                        default = "5m";
                    };
                    extra_environment = mkOption {
                        description = "Additional envvars for ddns-updater";
                        type = types.attrsOf types.str;
                        default = { };
                    };
                };
                dns = {
                    enable = mkEnableOption "Enable global DNS";
                    upstreamServers = mkOption {
                        description = "Upstream DNS servers";
                        type = types.listOf types.singleLineStr;
                        default = [
                            "1.1.1.1" # Cloudflare
                        ];
                        example = [
                            "1.1.1.1" # Cloudflare
                            "9.9.9.9" # Quad9
                        ];
                    };
                };
                firewall = {
                    allowPing = mkOption {
                        type = types.bool;
                        default = true;
                        description = "Allow ICMP echo requests on the firewall.";
                    };
                    allowedTCPPorts = mkOption {
                        type = types.listOf types.port;
                        default = [
                            80
                            443
                        ];
                        description = "TCP ports open on untrusted interfaces (e.g. WAN). Do not add SSH (22); it is only reachable from trusted LAN interfaces.";
                    };
                    allowedUDPPorts = mkOption {
                        type = types.listOf types.port;
                        default = [ ];
                        description = "UDP ports open on untrusted interfaces (e.g. WAN). Do not add DNS (53) or DHCP (67/68); they are opened only on LAN interfaces by the DNS module.";
                    };
                };
                nat = {
                    enable = mkEnableOption "Enable NAT between LAN and WAN.";
                    externalInterface = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                        description = ''
                            Interface used for outbound NAT. If left null, it is derived
                            from the WAN type (ppp0/pptp0 for PPP variants, otherwise the WAN physical interface).
                        '';
                    };
                    internalInterfaces = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                        description = "Interfaces treated as internal networks for NAT.";
                    };
                    enableIPv6 = mkOption {
                        type = types.bool;
                        default = true;
                        description = "Enable IPv6 masquerading (if supported).";
                    };
                };
            };
            secrets = {
                sops = {
                    enable = mkEnableOption "automatic sops-nix configuration (assumes sops-nix is already configured globally)";
                    pppoe = {
                        username = mkOption {
                            description = "Secret name for PPPOE username";
                            type = types.singleLineStr;
                            default = "pppoe-username";
                        };
                        password = mkOption {
                            description = "Secret name for PPPOE password";
                            type = types.singleLineStr;
                            default = "pppoe-password";
                        };
                        config = mkOption {
                            description = "Name of the PPPOE config file generated";
                            type = types.singleLineStr;
                            default = "pppoe-peer.conf";
                        };
                    };
                    dyndns = mkOption {
                        description = "Secret name for dyndns configuration";
                        type = types.singleLineStr;
                        default = "ddns-updater.conf";
                    };
                };
                paths = {
                    pppoe-username = mkOption {
                        description = "Path to pppoe-username secret";
                        type = types.str;
                        defaultText = "mkIf cfg.secrets.sops.enable config.sops.secrets.${cfg.secrets.sops.pppoe.username}.path";
                    };
                    pppoe-password = mkOption {
                        description = "Path to pppoe-password secret";
                        type = types.str;
                        defaultText = "mkIf cfg.secrets.sops.enable config.sops.secrets.${cfg.secrets.sops.pppoe.password}.path";
                    };
                    pppoe-config = mkOption {
                        description = "Path to pppoe-config secret";
                        type = types.str;
                        defaultText = "mkIf cfg.secrets.sops.enable config.sops.templates.${cfg.secrets.sops.pppoe.config}.path";
                    };
                    dyndns-config = mkOption {
                        description = "Path to dyndns-config secret";
                        type = types.str;
                        defaultText = "mkIf cfg.secrets.sops.enable config.sops.secrets.${cfg.secrets.sops.dyndns}.path";
                    };
                };
            };
        };
    };
}
