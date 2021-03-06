{config, pkgs, ...}:
{
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.overcommit_memory" = 2;
    "vm.overcommit_ratio" = 100;
    "vm.swappiness" = 50;
    "vm.vfs_cache_pressure" = 30;
    "net.ipv4.tcp_keepalive_time" = 120;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 3;
    "net.ipv4.tcp_syn_retries" = 4;
    "net.ipv4.tcp_retries2" = 6;
  };
}
