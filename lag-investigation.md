Resume this session with:
claude --resume 0c330359-0325-4013-bf6d-1cb300644835


# Lag investigation — 2026-08-22

## Symptom

System felt laggy from time to time. First check showed:

- IO pressure (`/proc/pressure/io`) sustained at ~78% avg10 / ~49% avg300
- 6.6 GB of swap in use on the LUKS disk swap partition
- Only 3.3 GB of 15 GB RAM available
- CPU load and memory pressure both normal

## Config issues found and fixed (base.nix)

1. **Duplicate swap** — `hardware-configuration.nix` already declared a 16.5 GB LUKS swap partition, but `base.nix` also created an unencrypted 8 GB swapfile at `/var/lib/swapfile`. Both were active. The swapfile also bypassed LUKS encryption. Removed from config; file was manually deleted with `sudo rm /var/lib/swapfile`.
2. **No zram** — added `zramSwap.enable = true; memoryPercent = 50; algorithm = "zstd";`. Compressed RAM swap absorbs pressure before hitting disk. After change, ~3 GB routinely lives in zram that used to hit the encrypted disk swap.
3. **swappiness = 60 (default)** — too aggressive for a desktop with 15 GB RAM. Lowered via `boot.kernel.sysctl."vm.swappiness" = 10;`.
4. **User + home-manager generations never pruned** — the existing `pruneSystemGenerations` script only touched the system profile, so `nix-gc` couldn't reclaim old home-manager store paths. Added a weekly `nix-prune-user-generations-weekly` systemd timer + `nix.optimise.automatic = true`.
5. Added `services.fwupd.enable = true` (so BIOS + firmware updates are checkable with `fwupdmgr`) and `services.thermald.enable = true`.

## Actual root cause of the current lag (not a config issue)

The config issues above were real, but the *acute* lag came from kernel state, not configuration.

On **2026-08-19 at 23:08:40**, immediately after resuming from suspend, the kernel logged a WARNING while ext4 was writing back dirty pages:

```
prepare_slab_obj_exts_hook, biovec-max: Failed to create slab extension vector!
WARNING: CPU: 6 PID: 410060 at mm/slub.c:2112 alloc_tagging_slab_alloc_hook+0x18c/0x1b0
Workqueue: writeback wb_workfn (flush-254:0)
Call Trace:
  bvec_alloc → bio_alloc_bioset → ext4_bio_write_folio → ext4_writepages
  → wb_workfn → process_one_work → worker_thread
```

This is a known allocator-tagging bug in kernel 6.12 (`CONFIG_MEM_ALLOC_PROFILING`). The system did not crash but the writeback path was left in a degraded state. From then on:

- `vmstat 1` showed `b=6` constantly — six kernel threads permanently blocked
- `wa` (IO wait CPU) was 40–60% with **almost zero real disk throughput** (`bi`/`bo` near 0, and per-process `/proc/*/io` deltas near zero)
- A `kworker/N:M+pm` thread was visible in D state at least once
- PSI IO stayed pinned near 90–95% even at idle

That is: the kernel was reporting massive IO wait for writeback that would never make progress. Every process touching the filesystem paid a stall tax, which felt like lag.

## What to do if it happens again

1. **Check for the tell-tale pattern first:**

   ```
   vmstat 1 3               # look for b=high with wa=high but bi/bo≈0
   cat /proc/pressure/io    # if avg300 stays >50% while system is idle
   journalctl -k -b | grep -iE "WARNING|prepare_slab_obj_exts|alloc_tagging"
   ```

   If you see the WARNING and vmstat looks like above → it's the same issue.

2. **Reboot** — clears kernel state, resumes normal operation immediately.

3. **Longer-term mitigations to consider** (not applied yet):
   - Switch kernel to newer mainline: `boot.kernelPackages = pkgs.linuxPackages_latest;` — likely has the alloc-tagging fix. Not applied because LTS is more stable and BIOS/firmware might fix suspend behavior.
   - Check for BIOS updates: `sudo fwupdmgr refresh && fwupdmgr get-updates` (needs `services.fwupd.enable = true`, which is now on). Current BIOS at time of investigation: **1.46.1, dated 2025-04-23** on Dell Latitude 5420.
   - If suspend continues to break the kernel, try `boot.kernelParams = [ "mem_sleep_default=deep" ];` to force S3 instead of s2idle. Some Dell Tigerlake platforms are unstable on s2idle.

## Useful diagnostics used

```
# Memory + swap layout
free -h
swapon --show

# Kernel pressure info (Linux 4.20+)
cat /proc/pressure/{io,memory,cpu}

# Real disk activity (vs. reported iowait)
vmstat 1 5

# Blocked threads
ps -eLo pid,tid,stat,wchan,comm --no-headers | awk '$3 ~ /D/'

# Per-process IO totals
for pid in $(ps -eo pid=); do
  r=$(awk '/^read_bytes:/{print $2}' /proc/$pid/io 2>/dev/null)
  w=$(awk '/^write_bytes:/{print $2}' /proc/$pid/io 2>/dev/null)
  [ -z "$r" ] || printf "%s %s %s %s\n" "$pid" "$r" "$w" "$(cat /proc/$pid/comm)"
done | sort -k3 -n -r | head

# Kernel warnings / oopses this boot
journalctl -k -b -p warning --no-pager
```

## System context at time of investigation

- Dell Latitude 5420 (Intel Tigerlake), BIOS 1.46.1 (2025-04-23)
- Kernel 6.12.93 (NixOS 25.11 LTS default)
- 15 GB RAM, 8 cores, NVMe SSD, LUKS-encrypted root + swap
- Uptime at investigation: 14 days 15 h
