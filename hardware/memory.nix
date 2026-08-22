{ config, pkgs, ... }:

{
  # Compressed RAM swap — cuts disk thrashing under memory pressure.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # Prefer keeping working set in RAM over swapping; zram makes cheap swap available anyway.
  boot.kernel.sysctl."vm.swappiness" = 10;
}
