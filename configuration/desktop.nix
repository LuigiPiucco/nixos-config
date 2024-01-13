{ lib, config, pkgs, inputs, utils, ... }:
{
  imports = lib.optional (config.home-manager.users ? "luigi") {
    home-manager.users.luigi = {
      gtk = {
        enable = true;
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
        platformTheme = "kde";
        style.name = "Breeze-Dark";
      };
    };
  } ++ lib.optional (config.home-manager.users ? "pietro" ) {
    home-manager.users.pietro = {
      gtk = {
        enable = true;
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
        platformTheme = "kde";
        style.name = "Breeze-Dark";
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      config.services.emacs.package
      epdfview
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
      libsForQt5.systemsettings
      libsForQt5.qt5.qtbase
      libsForQt5.qt5.qtdeclarative
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtquickcontrols
      libsForQt5.qt5.qtwayland
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugins
      papirus-icon-theme
      qt6.qtbase
      qt6.qtwayland
      keepassxc
      polkit-kde-agent
    ];

    sessionVariables = {
      EDITOR = "emacsclient -a ''";
      VISUAL = "emacsclient -a ''";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "gtk";
      GDK_BACKEND = "wayland,xcb";
      CLUTTER_BACKEND = "wayland";
      GTK_USE_PORTAL = "1";
    };
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
    package = let
      epackages = inputs.emacs-overlay.packages.x86_64-linux;
      elib = inputs.emacs-overlay.lib.x86_64-linux;
      epkgs = elib.emacsPackagesFor epackages.emacs-pgtk;
    in epkgs.emacsWithPackages (epkgs:
      with epkgs; [
        emacsql
        vterm
        pdf-tools
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
    fontconfig.defaultFonts.monospace = ["Iosevka" "Fira Code "];
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
        sarasa-gothic
        fira-code
        fira-code-symbols
        fira-code-nerdfont
        unicode-emoji
        unicode-character-database
        ucs-fonts
        unifont
      ];
  };

  gtk.iconCache.enable = true;

  services.xserver = {
    enable = false;
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
    config.prefered.default = ["kde"];
    extraPortals = with pkgs; [xdg-desktop-portal-kde];
    xdgOpenUsePortal = true;
  };
}
