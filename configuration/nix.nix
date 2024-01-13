{
  nix.channel.enable = false;
  nix.daemonIOSchedClass = "best-effort";
  nix.daemonIOSchedPriority = 2;
  nix.daemonCPUSchedPolicy = "other";
  nix.settings = {
    allowed-users = ["@users"];
    auto-optimise-store = true;
    cores = 8;
    extra-experimental-features = [
      "ca-derivations"
      "flakes"
      "nix-command"
      "no-url-literals"
      "repl-flake"
    ];
    keep-derivations = false;
    keep-outputs = false;
    max-jobs = 8;
    print-missing = true;
    pure-eval = true;
    restrict-eval = true;
    sandbox = true;
    trusted-users = ["root" "@wheel"];
    use-xdg-base-directories = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 2d";
    persistent = true;
  };
  nix.optimise = {
    automatic = true;
    dates = ["daily"];
  };
}
