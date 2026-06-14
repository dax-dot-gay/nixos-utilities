{ pkgs, ... }:

{
    packages = [
        pkgs.git
        pkgs.gnused
    ];
    languages.python = {
        enable = true;
        venv = {
            enable = true;
            requirements = ''
                proxctl
            '';
        };
    };
    scripts = {
        generate-docs.exec = '' # bash
            cd $(git rev-parse --show-toplevel)
            mkdir -p doc
            nix run ".#generate-module-options"
            rm -rf result
            sed -i 's/ - \[\/nix\/store\/[^\/]*\/modules/ - [modules/g' doc/generated-module-options.md
            sed -i 's/\](file:\/\/\/nix\/store\/[^\/]*\/modules/\]\(..\/modules/g' doc/generated-module-options.md
        '';
    };
}
