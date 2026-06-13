{ pkgs, nix-options-doc, ... }:

{
  packages = [ pkgs.git nix-options-doc.packages.x86_64-linux.default ];
  languages.python = {
    enable = true;
    venv = {
      enable = true;
      requirements = ''
        proxctl
      '';
    };
  };
}
