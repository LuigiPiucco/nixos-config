{ lib, pkgs, ... }:
{
  services.dbus.apparmor = "enabled";
  security.apparmor.enable = true;
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = true;
  security.wrappers.pkexec.permissions = "a+rx,u+w";
  security.wrappers.polkit-agent-helper-1.permissions = "a+rx,u+w";

  environment = {
    systemPackages = with pkgs; [
      config.services.emacs.package
      binutils
      coreutils
      curl
      dnsutils
      bottom
      manix
      whois
      bat
      eza
      procs
      usbutils
      epdfview
      (nix-direnv.override {enableFlakes = true;})
      starship
      direnv
      fd
      git
      jq
      ripgrep
      python3
      libtool
      bat
      git-lfs
      zoxide
      man-pages
      stdmanpages
      tio
      git-filter-repo
      socat
      dconf
      egl-wayland
      freetype
      glib
      gsettings-desktop-schemas
      libsForQt5.breeze-gtk
      libsForQt5.breeze-icons
      libsForQt5.breeze-qt5
      libsForQt5.kdialog
      libsForQt5.kiconthemes
      libsForQt5.kirigami2
      libsForQt5.polkit-kde-agent
      libsForQt5.qt5.qtbase
      libsForQt5.qt5.qtdeclarative
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtquickcontrols
      libsForQt5.qt5.qtwayland
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugins
      p7zip
      papirus-icon-theme
      qt6.qtbase
      qt6.qtwayland
      unrar
      xdg-dbus-proxy
      keepassxc
      libsecret
      polkit-kde-agent
    ];

    sessionVariables = {
      EDITOR = "emacsclient -a ''";
      VISUAL = "emacsclient -a ''";
      PAGER = "less";
      STARSHIP_CONFIG = ../data/starship.toml;
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "gtk";
      GDK_BACKEND = "wayland,xcb";
      CLUTTER_BACKEND = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      GTK_THEME = "Breeze-Dark";
      GTK_USE_PORTAL = "0";
      GDK_SCALE = "1";
      XCURSOR_THEME = "Breeze_cursors";
      XCURSOR_SIZE = "24";
    };

    shellAliases = {
      top = "btm";
      nrb = "nixos-rebuild --use-remote-sudo";
      ctl = "systemctl";
      stl = "sudo systemctl";
      utl = "systemctl --user";
      jtl = "journalctl";
      ls = "eza";
      l = "ls -lhg --git";
      la = "l -a";
      t = "l -T";
      ta = "la -T";

      less = "bat --paging=auto --color=always --italic-text=always --wrap=never --style=auto";

      ps = "procs";
    };
  };

  programs.command-not-found.enable = false;

  programs.fish = {
    enable = true;
    shellInit = ''
      echo "$(${pkgs.zoxide}/bin/zoxide init fish)" | source
    '';
    interactiveShellInit = ''
      function vterm_printf
          printf "\e]%s\e\\" "$1"
      end

      if [ "$INSIDE_EMACS" = 'vterm' ]
        function clear
          vterm_printf "51;Evterm-clear-scrollback";
          tput clear;
        end
      end

      function fish_title
        hostname
        echo ":"
        prompt_pwd
      end

      function vterm_cmd --description 'Run an Emacs command among the ones been defined in vterm-eval-cmds.'
        set -l vterm_elisp ()
        for arg in $argv
          set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
        end
        vterm_printf '51;E'(string join "" $vterm_elisp)
      end

      echo "$(${pkgs.direnv}/bin/direnv hook fish)" | source
    '';
    promptInit = ''
      echo "$(${pkgs.starship}/bin/starship init fish)" | source
      function vterm_prompt_end;
        vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
      end
      functions --copy fish_prompt vterm_old_fish_prompt
      function fish_prompt --description 'Write out the prompt; do not replace this; Instead, put this at end of your file.'
        printf "%b" (string join "\n" (vterm_old_fish_prompt))
        vterm_prompt_end
      end
    '';
  };

  documentation = let
    enableAttr = { enable = true; };
  in enableAttr // {
    dev = enableAttr;
    man = enableAttr;
    doc = enableAttr;
    info = enableAttr;
  };

  services.emacs = {
    defaultEditor = true;
    package = pkgs.emacs-git.pkgs.withPackages (epkgs:
      with builtins;
      with epkgs; [
        vterm
      ]
    );
  };

  fonts = {
    enableDefaultPackages = true;

    fontconfig.enable = true;
    fontconfig.allowBitmaps = true;
    fontconfig.useEmbeddedBitmaps = true;
    fontconfig.antialias = true;
    fontconfig.includeUserConf = true;
    fontconfig.subpixel.rgba = "rgb";
    fontconfig.subpixel.lcdfilter = "light";
    fontconfig.hinting.enable = true;
    fontconfig.defaultFonts.monospace = ["Iosevka"];
    fontconfig.defaultFonts.serif = ["Iosevka Etoile"];
    fontconfig.defaultFonts.sansSerif = ["Iosevka"];
    fontconfig.defaultFonts.emoji = ["Noto Color Emoji" "Noto Sans Nerd Font"];

    packages = with pkgs; let
      iosevkas = map (variant: iosevka-bin.override {inherit variant;}) [
        ""
        "curly"
        "etoile"
      ];
    in
      iosevkas
      ++ [
        unicode-emoji
        nerdfonts
      ];
  };

  gtk.iconCache.enable = true;

  services.xserver = {
    enable = true;
    updateDbusEnvironment = true;

    desktopManager = {
      runXdgAutostartIfNone = true;
      gnome.enable = false;
      plasma5.enable = false;
    };

    displayManager = {
      lightdm.enable = false;
      gdm.enable = lib.mkDefault false;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-kde];
    xdgOpenUsePortal = true;
  };

  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "ja_JP.EUC-JP/EUC-JP"
    ];
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us-acentos";
  };

  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = true;
  };
}
