{config, pkgs, ...}:
{
  boot.kernel.sysctl = {
    "vm.dirty_background_bytes" = 2*4194304;
    "vm.dirty_bytes" = 5*4194304;
    "vm.dirty_ratio" = 4;
    "vm.dirty_background_ratio" = 3;
    "vm.overcommit_memory" = 2;
    "vm.overcommit_ratio" = 100;
    "vm.swappiness" = 80;
  };
}
