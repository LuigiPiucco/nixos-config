{ device, inputs, ... }: {
  nix.channel.enable = false;
  nix.daemonIOSchedClass = "best-effort";
  nix.daemonIOSchedPriority = 2;
  nix.daemonCPUSchedPolicy = "other";
  nix.settings = {
    allowed-users = [ "@users" ];
    extra-platforms = [ "aarch64-linux" ];
    extra-allowed-uris = [ "file:/" ];
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    auto-optimise-store = true;
    cores = {
      "laptop" = 8;
      "desktop" = 16;
      "wsl" = 4;
      "rpi" = 4;
    }.${device};
    extra-experimental-features = [
      "ca-derivations"
      "flakes"
      "nix-command"
      "no-url-literals"
    ];
    keep-derivations = false;
    keep-outputs = true;
    keep-failed = false;
    max-jobs = {
      "laptop" = 6;
      "desktop" = 12;
      "wsl" = 4;
      "rpi" = 2;
    }.${device};
    print-missing = true;
    sandbox = true;
    trusted-users = [ "root" "@wheel" ];
    use-xdg-base-directories = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
    persistent = true;
  };
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };

  nixpkgs.overlays = [inputs.emacs-overlay.overlays.default];
}
