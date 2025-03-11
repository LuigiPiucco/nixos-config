{ pkgs, ... }: {
  users.users.pietro = {
    description = "Pietro Sartor Piucco";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "network"
      "input"
      "video"
      "audio"
      "render"
      "plugdev"
      "uucp"
      "dialout"
      "uinput"
    ];
    uid = 1000;
    group = "users";
    shell = pkgs.fish;
    createHome = true;
    password = "nopassword";
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    cmake
    clang
    clang-tools
    gcc
  ];
}
