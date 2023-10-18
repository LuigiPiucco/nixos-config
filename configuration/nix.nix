{
  nix.daemonIOSchedClass = "idle";
  nix.daemonCPUSchedPolicy = "idle";
  nix.settings = {
    sandbox = true;
    trusted-users = ["root" "@wheel"];
    max-jobs = 8;
    auto-optimise-store = true;
    system-features = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    extra-experimental-features = ["nix-command" "flakes" "repl-flake"];
    allowed-users = ["@wheel"];
  };
  nix.extraOptions = ''
    min-free = 536870912
    keep-outputs = true
    keep-derivations = true
    fallback = true
  '';
  nix.gc = {
    dates = "weekly";
    options = "--delete-older-than 2d";
    persistent = true;
  };
  nix.optimise = {
    automatic = true;
    dates = ["daily"];
  };
}
