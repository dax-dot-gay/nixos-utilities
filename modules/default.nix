{ inputs, ... }:
{ lib, ... }:
{
    imports = [
        (lib.modules.importApply ./router { inputs = inputs; })
    ];
}
