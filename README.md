# nixos-utilities
A flake containing a number of utilities for my nixos configurations

This is unlikely to be super useful outside of my context, but some basic documentation follows:

## Option Reference:

[generated-module-options.md](./doc/generated-module-options.md)

## Provided Modules:

### `nixos-utilities.systems.router`
*Options and configs for defining a NixOS router*

This module creates a declarative router for small, wired networks. Configuration is heavily based on [NixRTR/nixos-router](https://github.com/NixRTR/nixos-router), adapted for use in a larger system configuration and with the limitations on network count and naming removed.

**Feature Set:**

- Multi-network support (isolated LAN segments)<br>
  *support cloned from [NixRTR/nixos-router](https://github.com/NixRTR/nixos-router)*
- DHCP & DNS server (`dnsmasq` w/ adblocking)<br>
  *support cloned from [NixRTR/nixos-router](https://github.com/NixRTR/nixos-router)*
- Dynamic DNS support (simplified config for `ddns-updater`)
- Firewall & NAT<br>
  *support cloned from [NixRTR/nixos-router](https://github.com/NixRTR/nixos-router)*
- Optional `sops-nix` secret management

**Status:** Basically functional, though some features have yet to be tested

### `nixos-utilities.services.autoUpgrade`
*Options and configs for a more complete auto-upgrade process*

This module builds on [nlewo/comin](https://github.com/nlewo/comin) and provides opinionated defaults, better desktop notifications, and in-depth event hooks.

**Feature Set:**

- Support for most of [nlewo/comin](https://github.com/nlewo/comin)'s features, except prometheus and non-flake configurations because I don't need those right now
- Per-event hooks for [nlewo/comin](https://github.com/nlewo/comin) events. Currently relies on the executed commands to fetch their own context information, due to comin's event stream being non-trivial to parse (I mean. It *is* trivial. I just couldn't really be bothered)
- More configurable desktop notifications with `libnotify`
- Required reboot monitoring with time-based reboots and desktop notifications

**Status:** Completely and totally untested. Might explode.

---

## References & Sources

Most of this functionality is building on work from other developers. Of those, the most relevant are:

- [NixRTR/nixos-router](https://github.com/NixRTR/nixos-router) - Advanced router configs
- [nlewo/comin](https://github.com/nlewo/comin) - GitOps functionality
- [NixOS/nixpkgs: `system.autoUpgrade`](https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/tasks/auto-upgrade.nix) - Reboot window script


