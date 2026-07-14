# ╭──────────────────────────────────────────────────────────╮
# │ NixOS WSL Configuration                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (config) meta;
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./sops.nix

    self.nixosModules.base
    self.nixosModules.interactive-only
  ];
  wsl = {
    enable = true;
    defaultUser = meta.username;
    docker-desktop.enable = true;
    # NOTE: with a Docker Desktop update, this suddenly must be set
    extraBin = [
      { src = "${pkgs.coreutils}/bin/mv"; }
    ];
    ssh-agent.enable = true;
    startMenuLaunchers = true;
    useWindowsDriver = true;
    wslConf.network.hostname = "wslstation";
    # Don't inject Windows' PATH into WSL. The ~105 /mnt/c entries live on
    # slow drvfs, and Nushell's external completer scans PATH as you type,
    # which caused noticeable keystroke latency. Interop stays enabled, so
    # Windows exes still run via full path (e.g. explorer.exe).
    wslConf.interop.appendWindowsPath = false;
  };

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [
      (self + /configurations/home/wsl.nix)
    ];
  };

  # Configuration
  nixpkgs.hostPlatform = "x86_64-linux";
}
