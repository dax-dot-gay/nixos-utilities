{ pkgs, nix-options-doc, ... }:

{
    packages = [
        pkgs.git
        nix-options-doc.packages.x86_64-linux.default
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
            nix-options-doc --path ./modules --out doc/generated-options.md
        '';
    };
}
