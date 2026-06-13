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

    dns = mapAttrs (key: value: value.dns) routerConfig.lan.networks;
    dnsForwardUnlisted = mapAttrs (key: value: value.forwardUnlisted) dns;
    dnsEnabled = mapAttrs (key: value: value.enable) dns;

    dhcp = mapAttrs (key: value: value.dhcp) routerConfig.lan.networks;
    dhcpEnabled = mapAttrs (key: value: value.enable) dhcp;

    bridges = mapAttrs (key: net: {
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
    }) routerConfig.lan.networks;
    bridgeNames = mapAttrs (key: value: value.name) bridges;

    # Helper function to convert lease time string to seconds
    /*leaseToSeconds =
        lease:
        let
            numeric = builtins.match "^[0-9]+$" lease;
            unitMatch = builtins.match "^([0-9]+)([smhd])$" lease;
            multiplier =
                unit:
                if unit == "s" then
                    1
                else if unit == "m" then
                    60
                else if unit == "h" then
                    3600
                else if unit == "d" then
                    86400
                else
                    1;
        in
        if lease == null then
            86400
        else if numeric != null then
            lib.toInt lease
        else if unitMatch != null then
            let
                num = lib.toInt (builtins.elemAt unitMatch 0);
                unit = builtins.elemAt unitMatch 1;
            in
            num * multiplier unit
        else
            86400;*/

    # Helper function to extract domain from A records (for DHCP option 15)
    extractDomain =
        aRecords:
        if aRecords == { } || aRecords == null then
            "local"
        else
            let
                firstRecord = builtins.head (builtins.attrNames aRecords);
                parts = lib.splitString "." firstRecord;
                numParts = builtins.length parts;
            in
            if numParts >= 2 then
                "${builtins.elemAt parts (numParts - 2)}.${builtins.elemAt parts (numParts - 1)}"
            else
                firstRecord;

    # DHCP option 15 (domain name / Windows DNS suffix). If unset, derived from A records (legacy).
    # If set to "", omit option 15 entirely. See dhcp-*.nix comments: apex wildcards (*.zone) + same suffix break public names.
    dhcpOption15OrNull =
        dhcpCfg: aRecords:
        let
            v =
                if builtins.hasAttr "option15Domain" dhcpCfg then
                    dhcpCfg.option15Domain
                else
                    extractDomain aRecords;
        in
        if v == "" then null else v;

    # Helper to extract the primary domain from A records
    extractPrimaryDomain =
        aRecords:
        let
            domains = lib.attrNames aRecords;
        in
        if domains == [ ] then
            "local"
        else
            let
                firstRecord = builtins.head domains;
                parts = lib.splitString "." firstRecord;
                numParts = builtins.length parts;
            in
            if numParts >= 2 then
                "${builtins.elemAt parts (numParts - 2)}.${builtins.elemAt parts (numParts - 1)}"
            else
                firstRecord;

    # Helper to convert DHCP reservations to DNS host records
    dhcpReservationsToHostRecords =
        reservations: domain:
        map (res: {
            hostname = "${res.hostname}.${domain}";
            ip = res.ipAddress;
            comment = "DHCP reservation for ${res.hostname}";
        }) reservations;

    # Get primary domains for each network
    primaryDomains = mapAttrs (key: value: (extractPrimaryDomain value.records.a_records)) dns;

    # Convert DHCP reservations to host records
    dhcpHostRecords = mapAttrs (key: value: (dhcpReservationsToHostRecords value.reservations primaryDomains.${key})) dhcp;

    # Get wildcard domains and their target ips
    dnsWildcards = mapAttrs (
        key: value:
        (lib.filter (x: x != null) (
            lib.mapAttrsToList (
                name: record:
                if lib.hasPrefix "*." name then
                    let
                        domain = lib.removePrefix "*." name;
                        # Find the IP for the target (usually the main domain)
                        # Try target first, then fall back to domain itself
                        targetRecord =
                            value.records.a_records.${record.target} or value.records.a_records.${domain} or null;
                    in
                    if targetRecord != null then
                        {
                            domain = domain;
                            ip = targetRecord.target;
                            comment = record.comment or "";
                        }
                    else
                        null
                else
                    null
            ) (value.records.cname_records or { })
        ))
    ) dns;

    # Convert A records to host records format
    # Filter out wildcard entries (they should be in CNAME records, not A records)
    dnsARecordsToHostRecords = mapAttrs (
        key: value:
        (lib.mapAttrsToList (name: record: {
            hostname = name;
            ip = record.ip;
            comment = record.comment or "";
        }) (lib.filterAttrs (name: record: !lib.hasPrefix "*." name) (value.records.a_records or { })))
    ) dns;

    # Get list of wildcard base domains (to exclude from host records)
    dnsWildcardDomains = mapAttrs (key: value: map (w: w.domain) value) dnsWildcards;

    # Get DHCP option 15
    dhcpOption15 = mapAttrs (
        key: value: dhcpOption15OrNull dhcp.${key} (value.records.a_records or { })
    ) dns;

    # Filter out base domains that have wildcards (address= already handles them)
    hostRecordsFiltered = mapAttrs (
        key: value: lib.filter (record: !(lib.elem record.hostname dnsWildcardDomains.${key})) value
    ) dnsARecordsToHostRecords;

    # Merge DHCP and manual host records (manual takes precedence)
    # Exclude base domains that have wildcards
    allHostRecords = mapAttrs (key: value: hostRecordsFiltered.${key} ++ dhcpHostRecords.${key}) dhcp;

    # Get mapped blocklists
    blocklistsRaw = mapAttrs (key: value: value.blocklists) dns;
    blocklistsEnabled = mapAttrs (key: value: any (bl: bl.enable) (attrValues value)) blocklistsRaw;
    blocklists = mapAttrs (
        key: value:
        (
            if blocklistsEnabled.${key} then
                (lib.filterAttrs (name: cfg: (name != "enable") && (cfg.enable or false)) value)
            else
                { }
        )
    ) blocklistsRaw;
    blocklistUrls = mapAttrs (key: value: lib.mapAttrsToList (name: cfg: cfg.url) value) blocklists;

    # Helper to parse upstream servers (remove DoT format if present)
    parseUpstreamServer =
        server:
        let
            # Remove @853#... format if present
            parts = lib.splitString "@" server;
        in
        builtins.head parts;
in
{
    config = mkIf routerConfig.dns.enable {
        systemd.services = mkMerge (
            [ ]
            ++ (attrValues (
                mapAttrs' (key: network: {
                    name = "dnsmasq-net-${key}";
                    value = {
                        "dnsmasq-net-${key}" = {
                            description = "dnsmasq DNS Server for NET-${toUpper key}";
                            after = [ "network.target" ];
                            wantedBy = if dnsEnabled.${key} then [ "multi-user.target" ] else [ ];

                            preStart = ''
                                # Create state directory
                                mkdir -p /var/lib/dnsmasq/net-${key}

                                # Download and process blocklists
                                echo "Downloading blocklists for NET-${toUpper key}..."
                                > /tmp/blocklist-net-${key}-combined.txt  # Clear combined file

                                ${concatMapStringsSep "\n" (url: ''
                                    echo "  - Downloading: ${url}"
                                    ${pkgs.curl}/bin/curl -s -f -L "${url}" >> /tmp/blocklist-net-${key}-combined.txt || echo "Warning: Failed to download ${url}"
                                '') blocklistUrls.${key}}

                                # Convert hosts file to dnsmasq format
                                if [ -s /tmp/blocklist-net-${key}-combined.txt ]; then
                                  echo "Processing blocklists..."
                                  ${pkgs.gawk}/bin/awk '/^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]/ {
                                    if ($2 !~ /^(localhost|local|broadcasthost|ip6-)/) {
                                      print "address=/" $2 "/"
                                    }
                                  }' /tmp/blocklist-net-${key}-combined.txt | sort -u > /var/lib/dnsmasq/net-${key}/blocklist.conf
                                  
                                  # Count blocked domains
                                  BLOCKED_COUNT=$(wc -l < /var/lib/dnsmasq/net-${key}/blocklist.conf)
                                  echo "NET-${toUpper key}: Blocking $BLOCKED_COUNT domains"
                                  
                                  rm /tmp/blocklist-net-${key}-combined.txt
                                else
                                  echo "Warning: No blocklists downloaded, creating empty blocklist"
                                  touch /var/lib/dnsmasq/net-${key}/blocklist.conf
                                fi

                                # Generate dynamic DNS entries from DHCP leases
                                echo "Generating dynamic DNS entries from DHCP leases..."
                                > /var/lib/dnsmasq/net-${key}/dynamic-dns.conf

                                ${
                                    if (dhcp.${key}.dynamicDomain or "") != "" then
                                        ''
                                            if [ -f /var/lib/dnsmasq/net-${key}/dhcp.leases ]; then
                                              ${pkgs.gawk}/bin/awk -v domain="${dhcp.${key}.dynamicDomain}" -v subnet="${network.ipv4.subnet}" '
                                                BEGIN {
                                                  split(subnet, parts, "/");
                                                  network_prefix = parts[1];
                                                  split(network_prefix, octets, ".");
                                                  base = octets[1] "." octets[2] "." octets[3];
                                                }
                                                
                                                # Parse dnsmasq lease file format: <expiry-time> <MAC> <IP> <hostname> <client-id>
                                                {
                                                  if (NF >= 4) {
                                                    expiry = $1;
                                                    mac = $2;
                                                    ip = $3;
                                                    hostname = $4;
                                                    
                                                    # Check if IP is in our subnet
                                                    if (index(ip, base) == 1) {
                                                      # If hostname is "*" or empty, generate one from IP
                                                      if (hostname == "*" || hostname == "") {
                                                        split(ip, ip_parts, ".");
                                                        last_octet = ip_parts[4];
                                                        hostname = "dhcp-" last_octet;
                                                      }
                                                      
                                                      print "host-record=" hostname "." domain "," ip "  # Dynamic DHCP";
                                                    }
                                                  }
                                                }
                                              ' /var/lib/dnsmasq/net-${key}/dhcp.leases >> /var/lib/dnsmasq/net-${key}/dynamic-dns.conf
                                              
                                              DYNAMIC_COUNT=$(wc -l < /var/lib/dnsmasq/net-${key}/dynamic-dns.conf)
                                              echo "NET-${toUpper key}: $DYNAMIC_COUNT dynamic DNS entries"
                                            else
                                              echo "No DHCP leases found for NET-${toUpper key}"
                                            fi
                                        ''
                                    else
                                        ''
                                            echo "Dynamic DNS disabled for NET-${toUpper key}"
                                        ''
                                }

                                # Generate dnsmasq config
                                cat > /var/lib/dnsmasq/net-${key}/dnsmasq.conf << 'EOF'
                                # Listen on specific IP address
                                listen-address=${network.ipv4.gateway}
                                bind-interfaces

                                # Port
                                port=53

                                # Upstream DNS servers
                                ${concatMapStringsSep "\n" (s: "server=${parseUpstreamServer s}") (
                                    routerConfig.dns.upstreamServers or [
                                        "1.1.1.1"
                                        "9.9.9.9"
                                    ]
                                )}

                                # Local domain (only set domain= in fully hosted mode)
                                ${
                                    if primaryDomains.${key} != "local" && !dnsForwardUnlisted.${key} then
                                        ''
                                            domain=${primaryDomains.${key}}
                                        ''
                                    else
                                        ""
                                }
                                # Only use local= if we don't have wildcards (address= handles wildcards and local resolution)
                                # AND if forward_unlisted is false (fully hosted mode)
                                ${
                                    if primaryDomains.${key} != "local" && dnsWildcards.${key} == [ ] && !dnsForwardUnlisted.${key} then
                                        "local=/${primaryDomains.${key}}/"
                                    else
                                        ""
                                }

                                # Wildcard domains (from CNAME records)
                                # address=/domain/IP makes all subdomains resolve to that IP
                                # This also marks the domain as local, so we don't need local= when wildcards exist
                                ${concatStringsSep "\n" (
                                    map (
                                        wildcard:
                                        "address=/${wildcard.domain}/${wildcard.ip}${
                                            if (wildcard.comment or "") != "" && wildcard.comment != null then "  # ${wildcard.comment}" else ""
                                        }"
                                    ) dnsWildcards.${key}
                                )}

                                # Specific host records (override wildcards)
                                ${concatStringsSep "\n" (
                                    map (
                                        record:
                                        "host-record=${record.hostname},${record.ip}${
                                            if (record.comment or "") != "" && record.comment != null then "  # ${record.comment}" else ""
                                        }"
                                    ) allHostRecords.${key}
                                )}

                                # Whitelist - domains that should never be blocked
                                ${concatMapStringsSep "\n" (domain: "server=/${domain}/  # Whitelisted") (
                                    dns.${key}.whitelist or [ ]
                                )}

                                # Include blocklists and dynamic DNS
                                conf-file=/var/lib/dnsmasq/net-${key}/blocklist.conf
                                conf-file=/var/lib/dnsmasq/net-${key}/dynamic-dns.conf

                                # WebUI-managed configurations (may not exist if WebUI hasn't written them yet)
                                conf-file=/var/lib/dnsmasq/net-${key}/webui-dns.conf
                                ${if dhcpEnabled.${key} then "conf-file=/var/lib/dnsmasq/net-${key}/webui-dhcp.conf" else ""}

                                # DHCP Configuration (static reservations come from webui-dhcp.conf only to avoid duplicate "multiple names" errors)
                                ${
                                    if dhcpEnabled.${key} then
                                        ''
                                            dhcp-range=${bridgeNames.${key}},${network.dhcp.start},${network.dhcp.end},${network.dhcp.leaseTime}
                                            dhcp-option=${bridgeNames.${key}},3,${network.ipv4.gateway}
                                            dhcp-option=${bridgeNames.${key}},6${
                                                concatMapStringsSep "," (s: ",${s}") (network.dhcp.dnsServers or [ network.ipv4.gateway ])
                                            }
                                            ${lib.optionalString (
                                                dhcpOption15.${key} != null
                                            ) "dhcp-option=${bridgeNames.${key}},15,${dhcpOption15.${key}}"}
                                            dhcp-authoritative
                                            dhcp-leasefile=/var/lib/dnsmasq/net-${key}/dhcp.leases
                                        ''
                                    else
                                        ""
                                }

                                # Performance optimizations
                                cache-size=10000
                                no-negcache
                                no-resolv
                                no-poll
                                query-port=0

                                # Logging (disabled for performance - enable only for debugging)
                                # log-queries
                                # log-facility=/var/lib/dnsmasq/net-${key}/dnsmasq.log
                                EOF

                                # Generate initial WebUI DNS config from router-config.nix (if file doesn't exist)
                                # This ensures dnsmasq can start even before WebUI has written configs
                                if [ ! -f /var/lib/dnsmasq/net-${key}/webui-dns.conf ]; then
                                  cat > /var/lib/dnsmasq/net-${key}/webui-dns.conf << WEBUI_DNS_EOF
                                # WebUI-managed DNS configuration
                                # Generated automatically from router-config.nix - do not edit manually

                                ${
                                    if primaryDomains.${key} != "local" && dnsWildcards.${key} == [ ] && !dnsForwardUnlisted.${key} then
                                        "local=/${primaryDomains.${key}}/"
                                    else
                                        ""
                                }
                                ${concatStringsSep "\n" (
                                    map (
                                        wildcard:
                                        "address=/${wildcard.domain}/${wildcard.ip}${
                                            if (wildcard.comment or "") != "" && wildcard.comment != null then "  # ${wildcard.comment}" else ""
                                        }"
                                    ) dnsWildcards.${key}
                                )}
                                ${concatStringsSep "\n" (
                                    map (
                                        record:
                                        "host-record=${record.hostname},${record.ip}${
                                            if (record.comment or "") != "" && record.comment != null then "  # ${record.comment}" else ""
                                        }"
                                    ) allHostRecords.${key}
                                )}
                                WEBUI_DNS_EOF
                                fi

                                # Generate initial WebUI DHCP config from router-config.nix (if file doesn't exist and DHCP is enabled)
                                if [ ! -f /var/lib/dnsmasq/net-${key}/webui-dhcp.conf ] && [ "${
                                    if dhcpEnabled.${key} then "1" else "0"
                                }" = "1" ]; then
                                  cat > /var/lib/dnsmasq/net-${key}/webui-dhcp.conf << WEBUI_DHCP_EOF
                                # WebUI-managed DHCP configuration
                                # Generated automatically from router-config.nix - do not edit manually

                                ${concatStringsSep "\n" (
                                    map (res: "dhcp-host=${res.hwAddress},${res.hostname},${res.ipAddress}  # Static reservation") (
                                        dhcp.${key}.reservations or [ ]
                                    )
                                )}
                                WEBUI_DHCP_EOF
                                fi

                                # Set proper ownership
                                chown dnsmasq:dnsmasq /var/lib/dnsmasq/net-${key}/webui-dns.conf /var/lib/dnsmasq/net-${key}/webui-dhcp.conf 2>/dev/null || true
                            '';

                            serviceConfig = {
                                Type = "simple";
                                ExecStart = "${pkgs.dnsmasq}/bin/dnsmasq --no-daemon --conf-file=/var/lib/dnsmasq/net-${key}/dnsmasq.conf";
                                Restart = "on-failure";
                                RestartSec = "5s";

                                # Automatically create /var/lib/dnsmasq/net-${key} with proper permissions
                                StateDirectory = "dnsmasq/net-${key}";

                                # Run as dedicated user (not root)
                                User = "dnsmasq";
                                Group = "dnsmasq";

                                # Allow binding to privileged port 53 and DHCP configuration
                                # CAP_NET_BIND_SERVICE: bind to port 53 (DNS)
                                # CAP_NET_ADMIN: configure network interfaces for DHCP
                                # CAP_NET_RAW: send raw packets for DHCP
                                AmbientCapabilities = [
                                    "CAP_NET_BIND_SERVICE"
                                    "CAP_NET_ADMIN"
                                    "CAP_NET_RAW"
                                ];

                                # Security hardening
                                NoNewPrivileges = true;
                                PrivateTmp = true;
                                ProtectSystem = "strict";
                                ProtectHome = true;
                            };
                        };
                    };
                }) routerConfig.lan.networks
            ))
            ++ (attrValues (
                mapAttrs' (key: network: {
                    name = "dnsmasq-blocklist-update-net-${key}";
                    value = {
                        "dnsmasq-blocklist-update-net-${key}" = (
                            mkIf dnsEnabled.${key} {
                                description = "Update dnsmasq Blocklists for NET-${toUpper key}";
                                serviceConfig = {
                                    Type = "oneshot";
                                    StateDirectory = "dnsmasq/net-${key}";
                                    User = "dnsmasq";
                                    Group = "dnsmasq";
                                    ExecStart = "${pkgs.writeShellScript "update-blocklists-net-${key}" ''
                                        #!/usr/bin/env bash
                                        set -e

                                        echo "=== Updating NET-${toUpper key} Blocklists ==="
                                        > /tmp/blocklist-net-${key}-combined.txt

                                        ${concatMapStringsSep "\n" (url: ''
                                            echo "  - Downloading: ${url}"
                                            ${pkgs.curl}/bin/curl -s -f -L "${url}" >> /tmp/blocklist-net-${key}-combined.txt || echo "Warning: Failed to download ${url}"
                                        '') blocklistUrls.${key}}

                                        if [ -s /tmp/blocklist-net-${key}-combined.txt ]; then
                                          echo "Processing blocklists..."
                                          ${pkgs.gawk}/bin/awk '/^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]/ {
                                            if ($2 !~ /^(localhost|local|broadcasthost|ip6-)/) {
                                              print "address=/" $2 "/"
                                            }
                                          }' /tmp/blocklist-net-${key}-combined.txt | sort -u > /var/lib/dnsmasq/net-${key}/blocklist.conf.new
                                          
                                          BLOCKED_COUNT=$(wc -l < /var/lib/dnsmasq/net-${key}/blocklist.conf.new)
                                          echo "NET-${toUpper key}: Now blocking $BLOCKED_COUNT domains"
                                          
                                          mv /var/lib/dnsmasq/net-${key}/blocklist.conf.new /var/lib/dnsmasq/net-${key}/blocklist.conf
                                          rm /tmp/blocklist-net-${key}-combined.txt
                                          systemctl reload-or-restart dnsmasq-net-${key} || true
                                        else
                                          echo "No blocklists downloaded for NET-${toUpper key}"
                                        fi

                                        echo "=== NET-${toUpper key} blocklist update completed ==="
                                    ''}";
                                };
                            }
                        );
                    };
                }) routerConfig.lan.networks
            ))
            ++ (attrValues (
                mapAttrs' (key: network: {
                    name = "dnsmasq-dynamic-dns-net-${key}";
                    value = {
                        "dnsmasq-dynamic-dns-net-${key}" = (
                            mkIf dnsEnabled.${key} {
                                description = "Update dnsmasq Dynamic DNS for NET-${toUpper key}";
                                serviceConfig = {
                                    Type = "oneshot";
                                    # Run as root so systemctl reload-or-restart can run; chown output file to dnsmasq
                                };
                                script = ''
                                    echo "Updating dynamic DNS for NET-${toUpper key}..."

                                    # Regenerate dynamic DNS entries
                                    > /var/lib/dnsmasq/net-${key}/dynamic-dns.conf

                                    ${
                                        if (network.dhcp.dynamicDomain or "") != "" then
                                            ''
                                                if [ -f /var/lib/dnsmasq/net-${key}/dhcp.leases ]; then
                                                  ${pkgs.gawk}/bin/awk -v domain="${network.dhcp.dynamicDomain}" -v subnet="${network.ipv4.subnet}" '
                                                    BEGIN {
                                                      split(subnet, parts, "/");
                                                      network_prefix = parts[1];
                                                      split(network_prefix, octets, ".");
                                                      base = octets[1] "." octets[2] "." octets[3];
                                                    }
                                                    
                                                    # Parse dnsmasq lease file format: <expiry-time> <MAC> <IP> <hostname> <client-id>
                                                    {
                                                      if (NF >= 4) {
                                                        expiry = $1;
                                                        mac = $2;
                                                        ip = $3;
                                                        hostname = $4;
                                                        
                                                        # Check if IP is in our subnet
                                                        if (index(ip, base) == 1) {
                                                          # If hostname is "*" or empty, generate one from IP
                                                          if (hostname == "*" || hostname == "") {
                                                            split(ip, ip_parts, ".");
                                                            last_octet = ip_parts[4];
                                                            hostname = "dhcp-" last_octet;
                                                          }
                                                          
                                                          print "host-record=" hostname "." domain "," ip "  # Dynamic DHCP";
                                                        }
                                                      }
                                                    }
                                                  ' /var/lib/dnsmasq/net-${key}/dhcp.leases > /var/lib/dnsmasq/net-${key}/dynamic-dns.conf
                                                  
                                                  chown dnsmasq:dnsmasq /var/lib/dnsmasq/net-${key}/dynamic-dns.conf
                                                  systemctl reload-or-restart dnsmasq-net-${key} || true
                                                  
                                                  DYNAMIC_COUNT=$(wc -l < /var/lib/dnsmasq/net-${key}/dynamic-dns.conf)
                                                  echo "NET-${toUpper key}: $DYNAMIC_COUNT dynamic DNS entries"
                                                fi
                                            ''
                                        else
                                            ""
                                    }
                                '';
                            }
                        );
                    };
                }) routerConfig.lan.networks
            ))
        );

        systemd.timers = mkMerge (
            [ ]
            ++ (attrValues (
                mapAttrs' (key: network: {
                    name = "dnsmasq-blocklist-update-net-${key}";
                    value = {
                        "dnsmasq-blocklist-update-net-${key}" = (
                            mkIf (dnsEnabled.${key} && blocklistsEnabled.${key}) {
                                description = "Update dnsmasq Blocklists for NET-${toUpper key}";
                                wantedBy = [ "timers.target" ];
                                timerConfig = {
                                    OnBootSec = "5min";
                                    OnUnitActiveSec = "24h"; # TODO: Use minimum of all blocklist intervals
                                    Persistent = true;
                                };
                            }
                        );
                    };
                }) routerConfig.lan.networks
            ))
            ++ (attrValues (
                mapAttrs' (key: network: {
                    name = "dnsmasq-dynamic-dns-net-${key}";
                    value = {
                        "dnsmasq-dynamic-dns-net-${key}" = (
                            mkIf (dnsEnabled.${key} && ((network.dhcp.dynamicDomain or "") != "")) {
                                description = "Periodically update dnsmasq Dynamic DNS for NET-${toUpper key}";
                                wantedBy = [ "timers.target" ];
                                timerConfig = {
                                    OnBootSec = "1m";
                                    OnUnitActiveSec = "5m"; # Update every 5 minutes
                                };
                            }
                        );
                    };
                }) routerConfig.lan.networks
            ))
        );

        systemd.paths = mkMerge (
            [ ]
            ++ (attrValues (
                mapAttrs' (key: network: {
                    name = "dnsmasq-dynamic-dns-net-${key}";
                    value = {
                        "dnsmasq-dynamic-dns-net-${key}" = (
                            mkIf (dnsEnabled.${key} && ((network.dhcp.dynamicDomain or "") != "")) {
                                description = "Watch DHCP leases for NET-${toUpper key} Dynamic DNS updates";
                                wantedBy = [ "multi-user.target" ];
                                pathConfig = {
                                    PathModified = "/var/lib/dnsmasq/net-${key}/dhcp.leases";
                                };
                            }
                        );
                    };
                }) routerConfig.lan.networks
            ))
        );

        # Create dnsmasq user and group
        users.users.dnsmasq = {
            isSystemUser = true;
            group = "dnsmasq";
            description = "dnsmasq DNS server user";
        };

        users.groups.dnsmasq = { };

        # Install dnsmasq package
        environment.systemPackages = with pkgs; [
            dnsmasq
        ];

        networking.firewall.interfaces = (
            mapAttrs' (key: network: {
                name = network.bridge.name;
                value = {
                    allowedUDPPorts = [ 53 ] ++ (if dhcpEnabled.${key} then [ 67 ] else [ ]);
                    allowedTCPPorts = [ 53 ];
                };
            }) routerConfig.lan.networks
        );
    };
}
