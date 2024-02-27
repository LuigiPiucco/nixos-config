{ lib, config, pkgs, inputs, wsl, ... }:
{
  qt.enable = true;
  programs.dconf.enable = true;
  programs.nm-applet.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-lua
        fcitx5-gtk
        fcitx5-mozc
        fcitx5-m17n
        fcitx5-material-color
        libsForQt5.fcitx5-qt
      ];
      waylandFrontend = true;
    };
  };

  programs.steam.enable = true;

  environment = {
    systemPackages = with pkgs; [
      config.services.emacs.package
      lutris
      protonup-qt
      fcitx5-configtool
      epdfview
      egl-wayland
      freetype
      glib
      gsettings-desktop-schemas
      papirus-icon-theme
      qt6.qtbase
      qt6.qtwayland
      keepassxc
      polkit-kde-agent
      alacritty
      firefox
      libsForQt5.dolphin-plugins
      nyxt
      steam
      steam-run
      typst
      typstfmt
      typst-lsp
      discord
    ];

    variables = {
      EDITOR = "emacsclient -a 'emacs'";
      VISUAL = "emacsclient -a 'emacs'";
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
        slime
        slime-repl-ansi-color
        treesit-grammars.with-all-grammars
      ]
    );
  };

  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;

    fontconfig.enable = true;
    fontconfig.allowBitmaps = true;
    fontconfig.useEmbeddedBitmaps = true;
    fontconfig.antialias = true;
    fontconfig.includeUserConf = true;
    fontconfig.subpixel.rgba = "rgb";
    fontconfig.subpixel.lcdfilter = "light";
    fontconfig.hinting.enable = true;
    fontconfig.defaultFonts.monospace = ["Iosevka" "Fira Code"];
    fontconfig.defaultFonts.serif = ["Iosevka Etoile"];
    fontconfig.defaultFonts.sansSerif = ["Iosevka Curly"];
    fontconfig.defaultFonts.emoji = ["Fira Code Symbol" "FiraCode Nerd Font"];

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
        liberation_ttf
        helvetica-neue-lt-std
      ];
  };

  gtk.iconCache.enable = true;

  services.xserver = {
    enable = true;
    autorun = !wsl;
    updateDbusEnvironment = true;
    excludePackages = with pkgs; [xterm libsForQt5.plasma-nm];

    desktopManager = {
      runXdgAutostartIfNone = true;
      gnome.enable = false;
      plasma5 = {
        enable = true;
        useQtScaling = true;
      };
    };

    xkb.layout = "us,br";
    xkb.variant = "intl,abnt2";

    displayManager.sddm = {
      enable = !wsl;
      wayland.enable = true;
    };
  } // lib.optionalAttrs (!wsl) {
    videoDrivers = ["nvidia"];

    libinput = {
      touchpad = {
        tappingButtonMap = "lrm";
        sendEventsMode = "disabled-on-external-mouse";
        disableWhileTyping = true;
      };
    };
  };

  xdg.portal = {
    enable = true;
    config.common.default = ["kde" "gtk"];
    extraPortals = with pkgs; [xdg-desktop-portal-kde xdg-desktop-portal-gtk];
    xdgOpenUsePortal = true;
  };

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };
}
