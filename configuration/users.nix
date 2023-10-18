{ config, pkgs, ... }:

{
  users.extraGroups.plugdev = {};
  users.users.luigi = {
    hashedPassword = "$6$ZFbU3PKV$FDr8k0ZCSsowj94x65yLGL68BF2A0BUAIoWV94yQPaxNzYxa7Jxa0NRFk1v1is9Kllih/7Wghgk2NrtsGveRg1";
    description = "Luigi Sartor Piucco";
    isNormalUser = true;
    extraGroups = ["wheel" "network" "input" "video" "audio" "render" "plugdev" "uucp" "dialout"];
    uid = 1000;
    group = "users";
    shell = pkgs.fish;
  };
  users.users.root.hashedPassword = "$6$ZFbU3PKV$FDr8k0ZCSsowj94x65yLGL68BF2A0BUAIoWV94yQPaxNzYxa7Jxa0NRFk1v1is9Kllih/7Wghgk2NrtsGveRg1";
  users.defaultUserShell = pkgs.fish;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.luigi = {config, pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.git = {
      enable = true;

      extraConfig = {
        commit.gpgsign = true;
        pull.rebase = false;
        credential.credentialStore = "secretservice";
        init.defaultBranch = "master";
        user.name = "Luigi Sartor Piucco";
        user.email = "luigipiucco@gmail.com";
        github.user = "LuigiPiucco";
        forge.autoPull = true;
      };
    };

    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.libsForQt5.breeze-gtk;
        name = "Breeze_cursors";
        size = 24;
      };
      font = {
        package = pkgs.iosevka;
        name = "Iosevka Regular";
      };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style = {
        package = pkgs.libsForQt5.breeze-qt5;
        name = "Breeze";
      };
    };

    xdg.configFile."stack/config.yaml".text = ''
      templates:
        params:
          author-name: Luigi Sartor Piucco
          author-email: luigipiucco@gmail.com
          github-username: LuigiPiucco
      nix:
        enable: true
    '';
    home.sessionVariables = {
      EMAIL = "luigipiucco@gmail.com";
      STACK_XDG = "1";
    };
    programs.fish.enable = true;

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.configHome}/gnupg";
    };
    services.gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      enableSshSupport = true;
      enableFishIntegration = true;
      pinentryFlavor = null;
      sshKeys = [
        "87AF23A921179C8FF040FE3359B201DC3EF61234"
      ];
      extraConfig = ''
        pinentry-program /mnt/c/Program Files (x86)/Gpg4win/bin/pinentry.exe
      '';
    };
  };
}
