# Adding a new machine

This flake is structured so each machine lives in `hosts/<hostname>/` and picks which shared modules it needs. Shared modules live in top-level directories (`hardware/`, `system/`, `user/`, `desktop/`) and stay identical across machines.

## Prerequisites on the new machine

- NixOS is already installed via the standard installer.
- You have access to `/etc/nixos/` on the target machine.
- The target has network access to fetch flake inputs on first build.

## Step 1 — Get the flake onto the new machine

```
git clone <this-repo-url> /etc/nixos
```

If the repo isn't published, `scp` or `rsync` it from another host that has it. The `/etc/nixos` directory must be a checkout of this flake.

## Step 2 — Create the host directory

```
mkdir -p /etc/nixos/hosts/<new-hostname>
sudo nixos-generate-config --show-hardware-config \
    > /etc/nixos/hosts/<new-hostname>/hardware-configuration.nix
```

If a working `/etc/nixos/hardware-configuration.nix` already exists on the target from the installer, copy it in directly instead of regenerating.

## Step 3 — Write `identity.nix`

```nix
# hosts/<new-hostname>/identity.nix
{
  username = "vestigo";
  fullName = "Vestigo";
  hostname = "<new-hostname>";
}
```

## Step 4 — Write `default.nix`

Copy `hosts/nixos/default.nix` as a starting point and adjust the imports list to what the new machine needs. Rule of thumb: the imports list is a *menu* — comment out what doesn't apply, uncomment what does.

Example for a desktop:

```nix
{ vars, ... }:

{
  system.stateVersion = "25.11";

  imports = [
    ./hardware-configuration.nix
    ../../base.nix

    ../../system/network.nix
    ../../system/pruning.nix
    ../../system/security.nix

    ../../hardware/audio.nix
    ../../hardware/bluetooth.nix
    # ../../hardware/fingerprint.nix    # no fingerprint reader
    ../../hardware/input.nix
    # ../../hardware/memory.nix          # 32 GB — no swap tuning needed
    ../../hardware/power.nix
    ../../hardware/printing.nix
    ../../hardware/storage.nix

    ../../user/user.nix
    ../../user/shell.nix
    ../../user/home-manager.nix

    ../../desktop/gnome.nix              # or ../../desktop/xmonad.nix

    ../../apps.nix
    # ../../containers.nix                # enable if docker is needed
  ];
}
```

Any machine-specific `boot.kernelParams`, `boot.kernelModules`, or one-off tweaks also go inside this file.

## Step 5 — Register the host in `flake.nix`

```nix
nixosConfigurations = {
  nixos = mkHost "nixos";
  <new-hostname> = mkHost "<new-hostname>";
};
```

## Step 6 — First rebuild on the target

```
sudo nixos-rebuild switch --flake '/etc/nixos#<new-hostname>' \
    --extra-experimental-features 'nix-command flakes'
```

The `--extra-experimental-features` flag is needed only on the first rebuild. After that, `nix.settings.experimental-features` in `base.nix` keeps flakes enabled system-wide, and the `update` alias in `user/shell.nix` selects the right host automatically via `${vars.hostname}`.

## What typically varies between machines

| Concern | Where it lives |
|---|---|
| Hardware detection | `hosts/<name>/hardware-configuration.nix` |
| Hostname, username | `hosts/<name>/identity.nix` |
| Which shared modules apply | `hosts/<name>/default.nix` imports list |
| Machine-specific kernel params / boot options | inside `hosts/<name>/default.nix` |
| Desktop environment (Gnome vs xmonad vs i3) | pick one from `desktop/` in the imports |
| Docker, gaming, dev tools | pick which shared modules to enable |

Shared modules themselves (`hardware/`, `system/`, `user/`, `desktop/`, `base.nix`, `apps.nix`) don't change between machines — they're the menu items.

## Gotcha: the `myhome` input

`flake.nix` currently pins the home-manager config to a local path:

```nix
myhome.url = "git+file:///home/vestigo/.config/home-manager";
```

For this to work on the new machine, the same absolute path must exist there with a checkout of the home-manager repo. Options:

- **Simple:** `git clone <home-manager-repo> ~/.config/home-manager` on the new machine.
- **Better for multi-machine:** publish the home-manager repo to GitHub and change the input to `myhome.url = "github:vestigo/dotfiles";`. Then every machine picks up the same source with no local path assumption. Bump via `nix flake update myhome`.

If home-manager isn't needed on the new host at all, drop `../../user/home-manager.nix` from that host's imports.

## Practical tip

Before committing a new host, run `sudo nixos-rebuild build --flake '/etc/nixos#<newname>'` (no `switch`) on the target. It builds without activating — iterate on the imports list until the build succeeds, then `switch` to actually apply.
