{ config, pkgs, inputs, lib, device, install-cd, ... }: let
  iosevkas = map (variant: pkgs.iosevka-bin.override { inherit variant; }) [
    ""
    "Curly"
    "Etoile"
  ];
in lib.optionalAttrs (device != "wsl") {
  programs.dconf.enable = true;
  programs.nix-ld.dev.libraries = with pkgs; [
      xorg.libX11
      kdePackages.qtwayland
  ];

  programs.hyprland = {
    enable = device == "desktop" || device == "rpi";
    withUWSM = true;
    xwayland.enable = true;
  };
  programs.hyprlock.enable = config.programs.hyprland.enable;
  services.hypridle.enable = config.programs.hyprland.enable;
  programs.uwsm = {
    enable = config.programs.hyprland.enable;
    waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };
  };

  i18n.inputMethod = {
    enable = device != "rpi" && device != "wsl";
    type = if config.i18n.inputMethod.enable then "fcitx5" else null;
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-lua
        fcitx5-mozc
        fcitx5-m17n
        fcitx5-material-color
      ];
      waylandFrontend = true;
      plasma6Support = true;
    };
  };

  programs.steam = {
    enable = device == "desktop";
    gamescopeSession.enable = true;
    extest.enable = device == "desktop";
    package = pkgs.steam.override (old: {
      extraPkgs = pkgs: (old.extraPkgs or lib.const []) pkgs ++ lib.optionals (device == "laptop") (with pkgs; [
        nvidia-vaapi-driver
        config.hardware.nvidia.package
        config.hardware.nvidia.package.bin
      ]);
      extraLibraries = pkgs: (old.extraLibraries or lib.const []) pkgs ++ lib.optionals (device == "laptop") (with pkgs; [
        nvidia-vaapi-driver
        config.hardware.nvidia.package
        config.hardware.nvidia.package.out
        config.hardware.nvidia.package.lib32
      ]);
    });

    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  programs.gamescope = {
    enable = device == "desktop";
    capSysNice = true;
    env = lib.optionalAttrs (device == "laptop") {
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    } // lib.optionalAttrs (device == "desktop") {
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    };
  };
  programs.gamemode = {
    enable = device == "desktop";
    enableRenice = true;
    settings = {
      general.renice = 10;
    };
  };
  programs.partition-manager.enable = device != "rpi";
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [kdePackages.plasma-browser-integration];
  };

  environment = {
    systemPackages = with pkgs; [
      config.services.emacs.package
      freetype
      glib
      gsettings-desktop-schemas
      papirus-icon-theme
      kdePackages.qtwayland
      kdePackages.polkit-kde-agent-1
      alacritty
      playerctl
      brightnessctl
      libwebp
      hunspell
      hunspellDicts.en_US
      hunspellDicts.pt_BR
      enchant
    ] ++ lib.optionals (device == "laptop" || device == "desktop") [
      kdePackages.dolphin-plugins
      ffmpeg
      stdenv.cc.libc
      stdenv.cc.cc
      stdenv.cc
      inkscape-with-extensions
      libreoffice-qt
      nuspell
      typst
      typstfmt
      tinymist
      nyxt
    ] ++ lib.optionals (device == "laptop") [
      egl-wayland
      nvidia-vaapi-driver
    ] ++ lib.optionals (device == "desktop") [
      mpvpaper
      kdePackages.krdc
      rustdesk
      vulkan-hdr-layer-kwin6
      udiskie
      rpcs3
      zulu
      zulu17
      lutris
      protontricks
      protonup-qt
      prismlauncher
      discord
      tor-browser
      piper
      wineWowPackages.stagingFull
      dxvk
      vkd3d
      vkd3d-proton
    ] ++ lib.optionals config.programs.hyprland.enable [
      inputs.iwmenu.packages.default
      inputs.bzmenu.packages.default
      hyprpaper
      hyprpolkitagent
      hyprpicker
      walker
      clipse
      pwvucontrol
    ] ++ lib.optionals (!install-cd || device != "rpi") [
      vlc
    ] ++ lib.optional (device != "wsl") keepassxc;

    sessionVariables = {
      EDITOR = "emacsclient -a 'emacs'";
      VISUAL = "emacsclient -a 'emacs'";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      GDK_BACKEND = "wayland,xcb";
      CLUTTER_BACKEND = "wayland";
      GTK_USE_PORTAL = "1";
      NIXOS_OZONE_WL = "1";
    };
  };
  services.ratbagd.enable = device != "rpi";

  services.emacs = {
    defaultEditor = true;
    package = let
      emacs-git = inputs.emacs-overlay.packages.emacs-git;
      emacs = emacs-git.pkgs;
    in emacs.withPackages (epkgs:
      with epkgs;
      with epkgs.manualPackages;
      with epkgs.elpaDevelPackages;
      with epkgs.nongnuPackages;
      with epkgs.elpaPackages;
      with epkgs.melpaPackages; [
        jinx
        pdf-tools
        vterm
      ] ++ lib.optional (device != "rpi") treesit-grammars.with-all-grammars);
  };

  fonts = {
    enableDefaultPackages = device != "rpi";
    enableGhostscriptFonts = device != "rpi";

    fontDir.enable = true;

    fontconfig.enable = true;
    fontconfig.allowBitmaps = true;
    fontconfig.useEmbeddedBitmaps = true;
    fontconfig.antialias = true;
    fontconfig.includeUserConf = true;
    fontconfig.hinting.enable = true;
    fontconfig.hinting.autohint = true;
    fontconfig.defaultFonts.monospace = [ "Iosevka" "Fira Code" ];
    fontconfig.defaultFonts.serif = [ "Iosevka Etoile" ];
    fontconfig.defaultFonts.sansSerif = [ "Iosevka Curly" ];
    fontconfig.defaultFonts.emoji = [ "Fira Code Symbol" "FiraCode Nerd Font" ];

    packages = with pkgs;
      iosevkas ++ [
        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
      ] ++ lib.optionals (device != "rpi") [
        liberation_ttf
        helvetica-neue-lt-std
        noto-fonts-cjk-sans
        sarasa-gothic
        unicode-emoji
        unicode-character-database
        ucs-fonts
        unifont
        noto-fonts
        noto-fonts-emoji
      ];
  };

  gtk.iconCache.enable = true;

  qt = {
    enable = true;
    platformTheme = "kde6";
    style = "breeze";
  };
  services.desktopManager.plasma6 = {
    enable = device != "rpi";
    enableQt5Integration = true;
  };
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    discover
    kwalletmanager
    konsole
    drkonqi
  ];
  programs.regreet = {
    enable = device != "rpi";
    cursorTheme = {
      name = "Breeze_Hacked";
      package = pkgs.breeze-hacked-cursor-theme;
    };
    font = {
      name = "Iosevka Etoile";
      size = 16;
      package = builtins.elemAt iosevkas 1;
    };
    iconTheme = {
      name = "candy-icons";
      package = pkgs.candy-icons;
    };
    theme = {
      name = "Sweet-Dark";
      package = pkgs.sweet;
    };
    settings = {
      background.path = "${inputs.self}/hyprland/wallpaper.jpg";
      GTK.application_prefer_dark_theme = true;
      "widget.clock" = {};
    };
  };
  services.greetd.enable = device != "rpi";
  services.xserver = {
    enable = true;
    autorun = true;
    updateDbusEnvironment = true;
    excludePackages = with pkgs; [ xterm mesa-demos ];

    desktopManager = {
      runXdgAutostartIfNone = true;
      gnome.enable = false;
    };

    xkb.layout = { "laptop" = "us,br"; "desktop" = "us"; "rpi" = "br,us"; }.${device};
    xkb.variant = { "laptop" = "intl,abnt2"; "desktop" = "intl"; "rpi" = "abnt2,intl"; }.${device};
  } // lib.optionalAttrs (device != "rpi") {
    videoDrivers = { "laptop" = [ "nvidia" ]; "desktop" = [ "amdgpu" ]; }.${device};
  };
  services.displayManager.sddm = {
    enable = device == "rpi";
    wayland = {
      enable = true;
      compositor = "kwin";
    };
  };

  services.libinput = {
    enable = device != "rpi" && device != "wsl";
    touchpad = {
      tappingButtonMap = "lrm";
      sendEventsMode = "disabled-on-external-mouse";
      disableWhileTyping = true;
    };
  };

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    config.common.default = [ "kde" "gtk" ] ++ lib.optional config.programs.hyprland.enable "hyprland";
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde xdg-desktop-portal-gtk ];
  };

  services.pipewire = {
    enable = device != "wsl";
    audio.enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };
}
