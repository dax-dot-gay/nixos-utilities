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
        enable = false;
    };
    system.stateVersion = "26.05";
    proxmox = {
        qemuConf = {
            bios = "ovmf";
            cores = 4;
            memory = 2048;
            net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=0";
            diskSize = "20480";
        };
        qemuExtraConf = {
            cpu = "host";
            net0 = "virtio=00:00:00:00:00:00,bridge=vmbr3,firewall=0";
        };
        nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
    };
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
    ];
}
