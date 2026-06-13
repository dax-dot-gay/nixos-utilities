{
    config,
    pkgs,
    lib,
    inputs,
    ...
}:
{
    imports = [
        ./hardware-configuration.nix
    ];

    flake.nixos-utilities.systems.router = {
        enable = true;
        config = {
            domain = "nixos-utilities.local";
            nameservers = [ "1.1.1.1" "9.9.9.9" ];
            wan = {
                type = "dhcp";
                interface = "ens18";
            };
            lan = {
                isolation.enable = true;
                networks = {
                    main = {
                        ipv4 = {
                            gateway = "192.168.24.1";
                            subnet = "192.168.24.0/24";
                            prefixLength = 24;
                        };
                        ipv6.enable = false;
                        bridge = {
                            name = "br0";
                            interfaces = [
                                "ens19"
                            ];
                        };
                        dhcp = {
                            enable = true;
                            start = "192.168.24.100";
                            end = "192.168.24.200";
                            dynamicDomain = "nixos-utilities.local";
                        };
                        dns = {
                            enable = true;
                            forwardUnlisted = true;

                        };
                    };
                };
                primaryNetwork = "main";
            };
            nat = {
                enable = true;
            };
            dns = {
                enable = true;
            };
        };
        secrets = {
            sops.enable = false;
            paths = {
                pppoe-username = "blank";
                pppoe-password = "blank";
                pppoe-config = "blank";
                dyndns-config = "blank";
            };
        };
    };
    system.stateVersion = "26.05";
    proxmox = {
        qemuConf = {
            bios = "ovmf";
            cores = 4;
            memory = 2048;
            net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=0";
        };
        qemuExtraConf = {
            cpu = "host";
            net1 = "virtio=00:00:00:00:00:00,bridge=vmbr3,firewall=0";
        };
    };
    virtualisation.diskSize = 20480;
    networking.hostName = "nixos-utilities-vms-router";
    time.timeZone = "America/New_York";
    users.users.nixos-utilities = {
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        password = "nixos-utilities";
    };
    services.openssh = {
        enable = true;
        openFirewall = true;
    };
    environment.systemPackages = [
        pkgs.neovim
        pkgs.ghostty.terminfo
        pkgs.git
    ];
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
