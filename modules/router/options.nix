{
    config,
    lib,
    ...
}:
with lib;
let
    cfg = config.flake.nixos-utilities.systems.router;

    # Configuration of CAKE service
    wanCakeConfigType = types.submodule {
        options = {
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
                type = mkNullOr types.singleLineStr;
                default = null;
                example = "100Mbit";
            };
            downloadBandwidth = mkOption {
                description = "Optional download bandwidth";
                type = mkNullOr types.singleLineStr;
                default = null;
                example = "100Mbit";
            };
        };
    };

    # Configuration of WAN interface
    wanConfigType = types.submodule {
        options = {
            type = mkOption {
                description = "WAN type";
                type = types.enum [
                    "dhcp"
                    "pppoe"
                ];
            };
            interface = mkOption {
                description = "WAN interface";
                type = types.singleLineStr;
                example = "eno1";
            };
            cake = mkOption {
                description = "CAKE configuration";
                type = wanCakeConfigType;
                default = {
                    enable = false;
                };
            };
        };
    };

    # Configuration of LAN IP space
    lanIpConfiguration =
        enabled:
        (types.submodule {
            options = {
                enable = mkOption {
                    description = "Enable this IP version";
                    type = types.bool;
                    default = enabled;
                };
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
        });

    DNSRecord = types.submodule {
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

    # Per-network DNS configuration
    lanNetworkDNSConfiguration =
        netcfg:
        (types.submodule {
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
                            type = types.attrsOf DNSRecord;
                            default = { };
                        };
                        cname_records = mkOption {
                            description = "CNAME Records";
                            type = types.attrsOf DNSRecord;
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
        });

    # Per-network DHCP configuration
    lanNetworkDHCPConfiguration =
        netcfg:
        (types.submodule {
            options = {
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
                    default =
                        (optional netcfg.ipv4.enable netcfg.ipv4.gateway)
                        ++ (optional netcfg.ipv6.enable netcfg.ipv6.gateway);
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
        });

    # Configuration of LAN networks
    lanNetworkConfiguration = types.attrsOf (
        types.submodule (
            { config, ... }:
            let
                netcfg = cfg.lan.networks.${config._module.args.name};
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
                        type = lanIpConfiguration true;
                    };
                    ipv6 = mkOption {
                        description = "IPv6 configuration";
                        type = lanIpConfiguration false;
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
                    dhcp = mkOption {
                        description = "DHCP configuration for this network";
                        type = lanNetworkDHCPConfiguration netcfg;
                    };
                    dns = mkOption {
                        description = "DNS configuration for this network";
                        type = lanNetworkDNSConfiguration netcfg;
                    };
                };
            }
        )
    );

    # LAN configuration
    lanConfigType = types.submodule {
        options = {
            isolation = mkOption {
                description = "Network isolation";
                type = types.submodule {
                    options = {
                        enable = mkOption {
                            description = "Enable isolation (defaults to TRUE)";
                            type = types.bool;
                        };
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
                };
            };
            networks = mkOption {
                description = "Configuration of LAN networks";
                type = lanNetworkConfiguration;
            };
        };
    };

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

    # Dynamic DNS configuration (ddns-updater)
    dynamicDnsConfigType = types.submodule {
        options = {
            enable = mkEnableOption "Enable DynamicDNS with ddns-updater";
            server_enabled = mkEnableOption "Enable ddns-updater server (SERVER_ENABLED=yes/no)";
            config_file = mkOption {
                description = "Path to config file";
                type = types.path;
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
    };

    # Config for [NixRTR/nixos-router](https://github.com/NixRTR/nixos-router) WebUI
    webUiConfigType = types.submodule {
        options = {
            enable = mkEnableOption "Enable WebUI";
            port = mkOption {
                type = types.port;
                default = 8080;
                description = "Port for nginx (public-facing)";
            };

            backendPort = mkOption {
                type = types.port;
                default = 8081;
                description = "Port for the FastAPI backend (internal)";
            };

            database = {
                host = mkOption {
                    type = types.str;
                    default = "localhost";
                    description = "PostgreSQL host";
                };

                port = mkOption {
                    type = types.port;
                    default = 5432;
                    description = "PostgreSQL port";
                };

                name = mkOption {
                    type = types.str;
                    default = "router_webui";
                    description = "PostgreSQL database name";
                };

                user = mkOption {
                    type = types.str;
                    default = "router_webui";
                    description = "PostgreSQL user";
                };
            };

            collectionInterval = mkOption {
                type = types.int;
                default = 2;
                description = "Data collection interval in seconds";
            };

            jwtSecretFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Path to JWT secret key file (managed by sops)";
            };

            debug = mkOption {
                type = types.bool;
                default = false;
                description = "Enable debug mode (verbose logging, auto-reload, etc.)";
            };

            aggregationCpuQuota = mkOption {
                type = types.str;
                default = "50%";
                description = "Systemd CPUQuota for the aggregation Celery worker (percentage of one CPU core). Recommended: 4+ cores → 50%, 2–3 cores → 25%, 1 core → 15%. When Postgres is also throttled (postgresqlCpuQuota), aggregation will take longer but both DB and worker are capped so core router functions stay responsive.";
            };

            postgresqlCpuQuota = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Optional systemd CPUQuota for PostgreSQL (e.g. \"100%\" = one core max). Limits DB CPU during aggregation so core router functions stay responsive. Increase if frontend feels slow and you rely on Redis cache.";
            };

            metricsRetentionDays = mkOption {
                type = types.int;
                default = 30;
                description = "Delete router time-series metrics (system, interfaces, disk I/O, temperature, services, CAKE, speedtest) older than this many days.";
            };

            bandwidthStatsRetentionDays = mkOption {
                type = types.int;
                default = 180;
                description = "Maximum age in days for client bandwidth and connection stats after tiered aggregation.";
            };

            bandwidthAggregateRawAfterDays = mkOption {
                type = types.int;
                default = 2;
                description = "Aggregate raw bandwidth/connection stats to 1m after data is this many days old.";
            };

            bandwidthAggregate1mAfterDays = mkOption {
                type = types.int;
                default = 7;
                description = "Aggregate 1m stats to 5m after data is this many days old.";
            };

            bandwidthAggregate5mAfterDays = mkOption {
                type = types.int;
                default = 30;
                description = "Aggregate 5m stats to 1h after data is this many days old.";
            };

            bandwidthAggregate1hAfterDays = mkOption {
                type = types.int;
                default = 90;
                description = "Aggregate 1h stats to 1d after data is this many days old.";
            };

            metricsMaxDatabaseGb = mkOption {
                type = types.int;
                default = 0;
                description = "If greater than 0, after daily retention delete oldest bandwidth/connection rows (below metricsEmergencyMinRetentionDays floor) until database size is under this many GiB. Disabled when 0.";
            };

            metricsEmergencyMinRetentionDays = mkOption {
                type = types.int;
                default = 30;
                description = "Emergency size trim never removes data newer than this many days (floor).";
            };

            metricsVacuumAnalyzeEnabled = mkOption {
                type = types.bool;
                default = true;
                description = "Schedule nightly VACUUM ANALYZE on metric tables (requires psql on the aggregation Celery worker PATH).";
            };
        };
    };

    # Router config options
    routerConfigType = types.submodule {
        options = {
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
            wan = mkOption {
                description = "WAN configuration";
                type = wanConfigType;
            };
            lan = mkOption {
                description = "LAN configuration";
                type = lanConfigType;
            };
            portForwarding = mkOption {
                description = "Port forwarding rules";
                type = types.listOf portForwardingConfigType;
                default = [ ];
            };
            dynamicDns = mkOption {
                description = "Dynamic DNS config";
                type = dynamicDnsConfigType;
            };
            dns = mkOption {
                description = "Global DNS configuration";
                type = types.submodule {
                    options = {
                        enable = mkOption {
                            description = "Enable global DNS (enabled by default)";
                            type = types.bool;
                            default = true;
                        };
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
                };
            };
            webui = mkOption {
                description = "WebUI configuration";
                type = webUiConfigType;
            };
        };
    };
in
{
    options = {
        flake.nixos-utilities.systems.router = {
            enable = mkEnableOption "Enable router subsystem";
            config = mkOption {
                description = "Router configuration";
                type = routerConfigType;
            };
        };
    };
}
