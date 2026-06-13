{
    config,
    pkgs,
    lib,
    ...
}:
with lib;
let
    cfg = config.flake.nixos-utilities.systems.router;
    routerConfig = cfg.config;

    expandPortSpec =
        spec:
        if spec ? from then
            let
                start = spec.from;
                stop = spec.to;
            in
            if start > stop then throw "router.portForwards: range start must be <= end" else range start stop
        else
            [ spec ];

    mkPortPairs =
        forward:
        let
            externalPorts = expandPortSpec forward.externalPort;
            destinationPortsRaw =
                if forward.destinationPort == null then externalPorts else expandPortSpec forward.destinationPort;
            destinationPorts =
                if (builtins.length destinationPortsRaw) == (builtins.length externalPorts) then
                    destinationPortsRaw
                else
                    throw "router.portForwards: destinationPort range must match externalPort range length";
            protoList =
                if forward.proto == "both" then
                    [
                        "tcp"
                        "udp"
                    ]
                else
                    [ forward.proto ];
        in
        concatMap (
            proto:
            zipListsWith (ext: dest: {
                proto = proto;
                sourcePort = ext;
                destination = "${forward.destination}:${toString dest}";
            }) externalPorts destinationPorts
        ) protoList;
in
{
    config = mkIf cfg.enable (
        let
            wanConf = routerConfig.wan;
            lanConf = routerConfig.lan;
            bridges = map (net: {
                name = net.bridge.name;
                interfaces = net.bridge.interfaces;
                ipv4 = {
                    address = net.ipv4.gateway;
                    prefixLength = net.ipv4.prefixLength;
                };
                ipv6 = optionalAttrs net.ipv6.enable {
                    enable = true;
                    address = net.ipv6.gateway;
                    prefixLength = net.ipv6.prefixLength;
                };
            }) (attrValues lanConf.networks);
            bridgeNames = map (b: b.name) bridges;
            firewallCfg = routerConfig.firewall;
            natCfg = routerConfig.nat;
            lanIsolation = lanConf.isolation.enable;
            isolationExceptions = map (exception: {
                source = exception.address;
                sourceBridge = lanConf.networks.${exception.source}.bridge.name;
                destBridge = lanConf.networks.${exception.destination}.bridge.name;
                description = exception.description;
            }) lanConf.isolation.exceptions;
            portForwards = map (pf: {
                proto = pf.protocol;
                externalPort = pf.externalPort;
                destination = pf.destinationIp;
                destinationPort = pf.internalPort;
            }) routerConfig.portForwarding;
            natForwardEntries = concatMap mkPortPairs portForwards;
            natExternalInterface =
                if natCfg.externalInterface != null then
                    natCfg.externalInterface
                else if wanConf.type == "pppoe" then
                    pppoeCfg.logicalInterface
                else
                    wanConf.interface;
        in
        mkMerge [
            {
                # Set global required features
                networking.networkmanager.enable = false;
                networking.useNetworkd = true;
                systemd.network.enable = true;
                systemd.network.wait-online.enable = false;
                networking.useDHCP = false;
            }
            {
                # Setup WAN interfaces
                networking.interfaces.${wanConf.interface} = mkMerge [
                    (mkIf (wanConf.type == "dhcp") { useDHCP = true; })
                    (mkIf (wanConf.type == "static") {
                        useDHCP = false;
                        ipv4.addresses = [
                            {
                                address = wanConf.static.ipv4.address;
                                prefixLength = wanConf.static.ipv4.prefixLength;
                            }
                        ];
                    })
                    (mkIf (wanConf.type == "static" && wanConf.static.ipv6.enable) {
                        ipv6.addresses = [
                            {
                                address = wanConf.static.ipv6.address;
                                prefixLength = wanConf.static.ipv6.prefixLength;
                            }
                        ];
                    })
                    (mkIf (wanConf.type == "pppoe") { useDHCP = false; })
                ];
            }
            {
                # Create network bridges
                systemd.network = {
                    netdevs = listToAttrs (
                        map (bridge: {
                            name = bridge.name;
                            value = {
                                netdevConfig = {
                                    Kind = "bridge";
                                    Name = bridge.name;
                                };
                            };
                        }) bridges
                    );

                    networks = listToAttrs (
                        map (bridge: {
                            name = "${bridge.name}-members";
                            value = {
                                matchConfig.Name = concatStringsSep " " bridge.interfaces;
                                networkConfig.Bridge = bridge.name;
                            };
                        }) bridges
                    );

                    # Enable hardware offloading on WAN interface
                    links."10-${wanConf.interface}" = {
                        matchConfig.Name = wanConf.interface;
                        linkConfig = {
                            # Enable all hardware offload features
                            ReceiveChecksumOffload = true;
                            TransmitChecksumOffload = true;
                            TCPSegmentationOffload = true;
                            GenericSegmentationOffload = true;
                            GenericReceiveOffload = true;
                            LargeReceiveOffload = true;
                        };
                    };
                };
            }
            {
                # Assign IP addrs to each bridge
                networking.firewall = {
                    enable = true;
                    allowPing = firewallCfg.allowPing;
                    trustedInterfaces = bridgeNames; # Trust all LAN bridges; SSH/DNS/DHCP only from LAN
                    allowedTCPPorts = firewallCfg.allowedTCPPorts;
                    allowedUDPPorts = firewallCfg.allowedUDPPorts;

                    # Block traffic between bridges if isolation is enabled
                    extraCommands = mkIf (lanIsolation && (length bridges) > 1) (
                        let
                            # Generate all bridge pairs for blocking
                            bridgePairs = flatten (
                                map (
                                    i:
                                    map (j: {
                                        from = elemAt bridgeNames i;
                                        to = elemAt bridgeNames j;
                                    }) (range (i + 1) ((length bridgeNames) - 1))
                                ) (range 0 ((length bridgeNames) - 2))
                            );

                            # Allow multicast traffic between bridges (UPnP/DLNA support)
                            # These rules MUST come before isolation drop rules
                            multicastRules = concatMapStrings (pair: ''
                                # Allow IGMP protocol between ${pair.from} and ${pair.to}
                                iptables -I FORWARD -p igmp -i ${pair.from} -o ${pair.to} -j ACCEPT
                                iptables -I FORWARD -p igmp -i ${pair.to} -o ${pair.from} -j ACCEPT
                                # Allow SSDP multicast (239.255.255.250:1900) for UPnP discovery
                                iptables -I FORWARD -p udp -d 239.255.255.250 --dport 1900 -i ${pair.from} -o ${pair.to} -j ACCEPT
                                iptables -I FORWARD -p udp -d 239.255.255.250 --dport 1900 -i ${pair.to} -o ${pair.from} -j ACCEPT
                                # Allow general multicast traffic (224.0.0.0/4) for DLNA
                                iptables -I FORWARD -p udp -d 224.0.0.0/4 -i ${pair.from} -o ${pair.to} -j ACCEPT
                                iptables -I FORWARD -p udp -d 224.0.0.0/4 -i ${pair.to} -o ${pair.from} -j ACCEPT
                            '') bridgePairs;

                            # Generate exception rules (must come BEFORE drop rules)
                            exceptionRules = concatMapStrings (ex: ''
                                # Exception: ${ex.description}
                                # Allow ${ex.source} (${ex.sourceBridge}) -> ${ex.destBridge}
                                iptables -I FORWARD -s ${ex.source} -i ${ex.sourceBridge} -o ${ex.destBridge} -j ACCEPT
                                # Allow return traffic from ${ex.destBridge} -> ${ex.source}
                                iptables -I FORWARD -d ${ex.source} -i ${ex.destBridge} -o ${ex.sourceBridge} -j ACCEPT
                            '') isolationExceptions;
                        in
                        # Apply multicast rules first, then exceptions, then blocking rules
                        multicastRules
                        + exceptionRules
                        + (concatMapStrings (pair: ''
                            # Block ${pair.from} <-> ${pair.to}
                            iptables -A FORWARD -i ${pair.from} -o ${pair.to} -j DROP
                            iptables -A FORWARD -i ${pair.to} -o ${pair.from} -j DROP
                        '') bridgePairs)
                    );

                    extraStopCommands = mkIf (lanIsolation && (length bridges) > 1) (
                        let
                            bridgePairs = flatten (
                                map (
                                    i:
                                    map (j: {
                                        from = elemAt bridgeNames i;
                                        to = elemAt bridgeNames j;
                                    }) (range (i + 1) ((length bridgeNames) - 1))
                                ) (range 0 ((length bridgeNames) - 2))
                            );

                            # Clean up multicast rules
                            cleanupMulticast = concatMapStrings (pair: ''
                                iptables -D FORWARD -p igmp -i ${pair.from} -o ${pair.to} -j ACCEPT || true
                                iptables -D FORWARD -p igmp -i ${pair.to} -o ${pair.from} -j ACCEPT || true
                                iptables -D FORWARD -p udp -d 239.255.255.250 --dport 1900 -i ${pair.from} -o ${pair.to} -j ACCEPT || true
                                iptables -D FORWARD -p udp -d 239.255.255.250 --dport 1900 -i ${pair.to} -o ${pair.from} -j ACCEPT || true
                                iptables -D FORWARD -p udp -d 224.0.0.0/4 -i ${pair.from} -o ${pair.to} -j ACCEPT || true
                                iptables -D FORWARD -p udp -d 224.0.0.0/4 -i ${pair.to} -o ${pair.from} -j ACCEPT || true
                            '') bridgePairs;

                            # Clean up exception rules
                            cleanupExceptions = concatMapStrings (ex: ''
                                iptables -D FORWARD -s ${ex.source} -i ${ex.sourceBridge} -o ${ex.destBridge} -j ACCEPT || true
                                iptables -D FORWARD -d ${ex.source} -i ${ex.destBridge} -o ${ex.sourceBridge} -j ACCEPT || true
                            '') isolationExceptions;
                        in
                        cleanupMulticast
                        + cleanupExceptions
                        + (concatMapStrings (pair: ''
                            iptables -D FORWARD -i ${pair.from} -o ${pair.to} -j DROP || true
                            iptables -D FORWARD -i ${pair.to} -o ${pair.from} -j DROP || true
                        '') bridgePairs)
                    );
                };
            }
            {
                # NAT configuration
                networking.nat = {
                    enable = natCfg.enable;
                    externalInterface = natExternalInterface;
                    internalInterfaces =
                        if natCfg.internalInterfaces == [ ] then bridgeNames else natCfg.internalInterfaces;
                    enableIPv6 = natCfg.enableIPv6;
                    forwardPorts = natForwardEntries;

                    # MSS clamping to fix MTU issues (prevents slow loading/fragmentation)
                    extraCommands = ''
                        iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
                    '';

                    extraStopCommands = ''
                        iptables -t mangle -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu || true
                    '';
                };
            }
            {
                # Initialize nftables sets
                systemd.services."nft-device-block-init" = {
                    description = "Initialize nftables sets for per-device blocking";
                    wantedBy = [ "multi-user.target" ];
                    after = [ "network-pre.target" ];
                    before = [ "network.target" ];
                    serviceConfig = {
                        Type = "oneshot";
                        RemainAfterExit = true;
                    };
                    script = ''
                        ${pkgs.nftables}/bin/nft -f - <<'EOF'
                        table inet router_block {
                          set blocked_v4 {
                            type ipv4_addr
                            flags interval
                          }
                          set blocked_v6 {
                            type ipv6_addr
                            flags interval
                          }
                          chain forward {
                            type filter hook forward priority 0; policy accept;
                            ip saddr @blocked_v4 drop
                            ip daddr @blocked_v4 drop
                            ip6 saddr @blocked_v6 drop
                            ip6 daddr @blocked_v6 drop
                          }
                          chain input {
                            type filter hook input priority 0; policy accept;
                            ip saddr @blocked_v4 drop
                            ip6 saddr @blocked_v6 drop
                          }
                        }
                        table bridge router_block_mac {
                          set blocked_macs {
                            type ether_addr
                          }
                          chain forward {
                            type filter hook forward priority 0; policy accept;
                            ether saddr @blocked_macs drop
                          }
                        }
                        EOF
                    '';
                };
            }
            {
                # Initialize nftables counters
                systemd.services."nft-bandwidth-tracking-init" = {
                    description = "Initialize nftables counters for per-client bandwidth tracking";
                    wantedBy = [ "multi-user.target" ];
                    after = [
                        "network-pre.target"
                        "nft-device-block-init.service"
                    ];
                    before = [ "network.target" ];
                    serviceConfig = {
                        Type = "oneshot";
                        RemainAfterExit = true;
                    };
                    script = ''
                        ${pkgs.nftables}/bin/nft -f - <<'EOF'
                        table inet router_bandwidth {
                          # Sets to track client IPs (IPv4 only)
                          # IPs will be added dynamically by the bandwidth collector
                          set client_ips {
                            type ipv4_addr
                            flags timeout
                          }
                          
                          chain forward {
                            type filter hook forward priority 10; policy accept;
                            # Count download (rx) - traffic destined to client IPs
                            # Match destination IP in set and count bytes
                            ip daddr @client_ips counter
                            # Count upload (tx) - traffic sourced from client IPs
                            # Match source IP in set and count bytes
                            ip saddr @client_ips counter
                          }
                        }
                        EOF

                        # Note: Per-IP counters will be tracked by adding individual rules per IP
                        # The collector will dynamically add/remove rules as clients appear/disappear
                    '';
                };
            }
            {
                # Kernel & system configuration
                boot.kernel.sysctl = {
                    "net.ipv4.ip_forward" = 1;
                    "net.ipv6.conf.all.forwarding" = 1;

                    # Multicast routing for UPnP/DLNA across subnets
                    "net.ipv4.conf.all.mc_forwarding" = 1;
                    "net.ipv4.conf.all.igmpv2_unsolicited_report_interval" = 100;
                    "net.ipv4.conf.all.igmpv3_unsolicited_report_interval" = 1000;

                    # TCP optimization for router performance
                    "net.ipv4.tcp_window_scaling" = 1;
                    "net.ipv4.tcp_timestamps" = 1;
                    "net.ipv4.tcp_sack" = 1;
                    "net.ipv4.tcp_no_metrics_save" = 1;

                    # Use BBR congestion control (modern, better performance)
                    "net.ipv4.tcp_congestion_control" = "bbr";
                    "net.core.default_qdisc" = "fq"; # Fair Queue required for BBR

                    # Increase TCP buffer sizes for better throughput
                    "net.core.rmem_max" = 134217728; # 128 MB
                    "net.core.wmem_max" = 134217728; # 128 MB
                    "net.ipv4.tcp_rmem" = "4096 87380 67108864"; # min default max
                    "net.ipv4.tcp_wmem" = "4096 65536 67108864";

                    # Enable TCP Fast Open
                    "net.ipv4.tcp_fastopen" = 3;

                    # Reduce TIME_WAIT connections
                    "net.ipv4.tcp_fin_timeout" = 30;
                    "net.ipv4.tcp_tw_reuse" = 1;

                    # Connection tracking optimization
                    "net.netfilter.nf_conntrack_max" = 262144; # Handle more concurrent connections
                    "net.netfilter.nf_conntrack_tcp_timeout_established" = 86400; # 24 hours
                    "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = 30;
                    "net.netfilter.nf_conntrack_acct" = 1; # Enable byte/packet counting per connection

                    # SYN flood protection
                    "net.ipv4.tcp_syncookies" = 1;
                    "net.ipv4.tcp_max_syn_backlog" = 8192;
                    "net.ipv4.tcp_synack_retries" = 2;

                    # Increase network device backlog for high-speed networks
                    "net.core.netdev_max_backlog" = 5000;

                    # Optimize for routing/forwarding
                    "net.ipv4.conf.all.accept_redirects" = 0;
                    "net.ipv4.conf.all.send_redirects" = 0;
                    "net.ipv4.conf.all.accept_source_route" = 0;
                    "net.ipv4.conf.all.rp_filter" = 1; # Reverse path filtering (security)

                    # Reduce swappiness (router shouldn't swap)
                    "vm.swappiness" = 10;

                    # Optimize file handle limits
                    "fs.file-max" = 2097152;
                };

                # CPU governor for performance
                powerManagement.cpuFreqGovernor = "ondemand";

                # Enable kernel modules for BBR
                boot.kernelModules = [ "tcp_bbr" ];
            }
            {
                # igmpproxy for multicast (UPnP/DLNA)
                environment.systemPackages = [ pkgs.igmpproxy ];

                # Configure igmpproxy for multicast forwarding between bridges
                # This enables UPnP/DLNA discovery across subnets
                systemd.services.igmpproxy = mkIf ((length bridges) > 1) {
                    description = "IGMP Proxy for multicast routing (UPnP/DLNA)";
                    wantedBy = [ "multi-user.target" ];
                    after = [ "network.target" ];
                    serviceConfig = {
                        Type = "forking";
                        ExecStart = "${pkgs.igmpproxy}/bin/igmpproxy /etc/igmpproxy.conf";
                        Restart = "on-failure";
                        RestartSec = "5s";
                    };
                };

                # Create igmpproxy configuration file
                environment.etc."igmpproxy.conf" = mkIf ((length bridges) > 1) {
                    text =
                        let
                            # First bridge is typically upstream (HOMELAB - servers)
                            # Remaining bridges are downstream (LAN - clients)
                            upstreamBridge = if length bridges > 0 then (elemAt bridges 0).name else "";
                            downstreamBridges = if length bridges > 1 then map (b: b.name) (tail bridges) else [ ];
                        in
                        "quickleave\n"
                        + (
                            if upstreamBridge != "" then "phyint ${upstreamBridge} upstream ratelimit 0 threshold 1\n" else ""
                        )
                        + (concatMapStrings (
                            bridge: "phyint ${bridge} downstream ratelimit 0 threshold 1\n"
                        ) downstreamBridges);
                    mode = "0644";
                };
            }
            # WAN Nameservers
            (mkIf (wanConf.type == "static" && wanConf.static.dnsServers != [ ]) {
                networking.nameservers = wanConf.static.dnsServers;
            })

            # WAN static gateway
            (mkIf
                (wanConf.type == "static" && wanConf.static.ipv6.enable && wanConf.static.ipv6.gateway != null)
                {
                    networking.defaultGateway6 = {
                        interface = wanConf.interface;
                        address = wanConf.static.ipv6.gateway;
                    };
                }
            )

            # WAN PPPOE config
            (mkIf (wanConf.type == "pppoe") {
                # Install rp-pppoe package for the PPPoE plugin
                environment.systemPackages = [ pkgs.rpPPPoE ];

                # Setup PPPoE session using pppd
                # Based on: https://francis.begyn.be/blog/nixos-home-router
                services.pppd = {
                    enable = true;
                    peers.${wanConf.interface} = {
                        enable = true;
                        autostart = true;
                        config = ''
                            plugin ${pkgs.rpPPPoE}/lib/rp-pppoe.so
                            nic-${wanConf.interface}
                            # Credentials are injected from sops template
                            file ${cfg.secrets.paths.pppoe-config}
                            noauth
                            persist
                            maxfail 0
                            holdoff 5
                            noipdefault
                            defaultroute
                            replacedefaultroute
                            lcp-echo-interval 15
                            lcp-echo-failure 3
                            usepeerdns
                            ${optionalString (pppoeCfg.service != null) "rp_pppoe_service '${pppoeCfg.service}'"}
                            ${optionalString pppoeCfg.ipv6 "+ipv6"}
                            ${optionalString (pppoeCfg.mtu != null) "mtu ${toString pppoeCfg.mtu}"}
                            ${optionalString (pppoeCfg.mtu != null) "mru ${toString pppoeCfg.mtu}"}
                        '';
                    };
                };
            })
            {
                networking.interfaces = mapAttrs' (key: network: {
                    name = network.bridge.name;
                    value = {
                        ipv4.addresses = [
                            {
                                address = network.ipv4.gateway;
                                prefixLength = network.ipv4.prefixLength;
                            }
                        ];
                        ipv6.addresses = optional network.ipv6.enable [
                            {
                                address = network.ipv6.gateway;
                                prefixLength = network.ipv6.prefixLength;
                            }
                        ];
                    };
                }) lanConf.networks;
            }
        ]

    );
}
