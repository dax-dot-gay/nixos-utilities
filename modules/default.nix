{ inputs, ... }:
{ lib, ... }:
{
    imports = [
        (lib.modules.importApply ./router { inputs = inputs; })
        (lib.modules.importApply ./autoUpgrade { inputs = inputs; })
    ];
}
