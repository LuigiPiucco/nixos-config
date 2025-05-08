{ config, pkgs, inputs, lib, device, ... }: let
  iosevkas = map (variant: pkgs.iosevka-bin.override { inherit variant; }) [
    ""
    "Curly"
    "Etoile"
  ];
in {
  programs.dconf.enable = true;

  programs.hyprland = {
    enable = (device == "desktop");
    withUWSM = true;
    xwayland.enable = true;
  };
  programs.hyprlock.enable = (device == "desktop");
  services.hypridle.enable = (device == "desktop");
  programs.uwsm = {
    enable = (device == "desktop");
    waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
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
    enable = (device == "desktop");
    gamescopeSession.enable = true;
    extest.enable = true;
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
    enable = (device == "desktop");
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
    enable = (device == "desktop");
    enableRenice = true;
    settings = {
      general.renice = 10;
    };
  };
  programs.partition-manager.enable = true;

  environment = {
    systemPackages = with pkgs; [
      config.services.emacs.package
      freetype
      glib
      gsettings-desktop-schemas
      papirus-icon-theme
      breeze-hacked-cursor-theme
      keepassxc
      kdePackages.polkit-kde-agent-1
      inkscape-with-extensions
      alacritty
      firefox
      libsForQt5.dolphin-plugins
      ffmpeg
      nyxt
      typst
      typstfmt
      tinymist
      libreoffice-qt
      vlc
      playerctl
      brightnessctl
      libwebp
      nuspell
      hunspell
      hunspellDicts.en_US
      hunspellDicts.pt_BR
      enchant
      stdenv.cc
    ] ++ lib.optionals (device == "laptop") [
      egl-wayland
      nvidia-vaapi-driver
    ] ++ lib.optionals (device == "desktop") [
      hyprpolkitagent
      hyprpicker
      dunst
      waybar
      mpvpaper
      walker
      clipse
      iwgtk
      blueberry
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
    ];

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
  services.ratbagd.enable = true;

  services.emacs = {
    defaultEditor = true;
    package = let
      inherit (inputs.emacs-overlay.packages.x86_64-linux) emacs-git;
      emacs = emacs-git.pkgs;
    in emacs.withPackages (epkgs:
      with epkgs;
      with epkgs.manualPackages;
      with epkgs.elpaDevelPackages;
      with epkgs.nongnuPackages;
      with epkgs.elpaPackages;
      with epkgs.melpaPackages; [
        jinx
      #   a
      #   ace-window
      #   aio
      #   android-mode
      #   annalist
      #   anzu
      #   apheleia
      #   async
      #   auto-minor-mode
      #   auto-yasnippet
      #   avy
      #   bash-completion
      #   better-jumper
      #   bind-key
      #   browse-at-remote
      #   bui
      #   buttercup
      #   cape
      #   ccls
      #   cfrs
      #   clipetty
      #   closql
      #   cmake-mode
      #   code-review
      #   compat
      #   consult
      #   consult-dir
      #   consult-flycheck
      #   consult-lsp
      #   corfu
      #   corfu-terminal
      #   csv-mode
      #   cuda-mode
      #   dap-mode
      #   dash
      #   dash-docs
      #   deferred
      #   demangle-mode
      #   diff-hl
      #   diredfl
      #   dired-git-info
      #   dired-rsync
      #   disaster
      #   docker
      #   dockerfile-mode
      #   doom-modeline
      #   # doom-snippets
      #   doom-themes
      #   drag-stuff
      #   dtrt-indent
      #   dumb-jump
      #   edit-indirect
      #   editorconfig
      #   eldoc
      #   elisp-def
      #   elisp-demos
      #   elisp-refs
      #   emacsql
      #   embark
      #   embark-consult
      #   embrace
      #   emmet-mode
      #   emojify
      #   envrc
      #   epl
      #   eros
      #   eshell-did-you-mean
      #   eshell-syntax-highlighting
      #   eshell-up
      #   eshell-z
      #   esh-help
      #   evil
      #   evil-anzu
      #   evil-args
      #   evil-collection
      #   evil-easymotion
      #   evil-embrace
      #   evil-escape
      #   evil-exchange
      #   evil-goggles
      #   evil-indent-plus
      #   evil-lion
      #   evil-markdown
      #   evil-mc
      #   evil-multiedit
      #   evil-nerd-commenter
      #   evil-numbers
      #   evil-org
      #   #evil-quick-diff
      #   evil-snipe
      #   evil-surround
      #   evil-terminal-cursor-changer
      #   evil-textobj-anyblock
      #   evil-textobj-tree-sitter
      #   evil-traces
      #   evil-visualstar
      #   exato
      #   expand-region
      #   #explain-pause-mode
      #   f
      #   fd-dired
      #   fish-completion
      #   fish-mode
      #   flycheck
      #   flycheck-cask
      #   flycheck-kotlin
      #   flycheck-package
      #   flycheck-popup-tip
      #   flycheck-posframe
      #   font-utils
      #   forge
      #   gcmh
      #   general
      #   ghub
      #   git-commit
      #   git-modes
      #   git-timemachine
      #   glsl-mode
      #   goto-chg
      #   grip-mode
      #   groovy-mode
      #   haml-mode
      #   haskell-mode
      #   helpful
      #   hide-mode-line
      #   highlight-indent-guides
      #   highlight-numbers
      #   highlight-quoted
      #   hl-todo
      #   ht
      #   htmlize
      #   hydra
      #   ibuffer-projectile
      #   ibuffer-vc
      #   iedit
      #   inheritenv
      #   jq-mode
      #   js2-mode
      #   js2-refactor
      #   json-mode
      #   json-snatcher
      #   julia-mode
      #   julia-repl
      #   julia-snail
      #   #melpaStablePackages.jupyter
      #   justl
      #   just-mode
      #   kotlin-mode
      #   kurecolor
      #   ligature
      #   link-hint
      #   list-utils
      #   load-relative
      #   loc-changes
      #   lsp-docker
      #   lsp-haskell
      #   lsp-java
      #   lsp-julia
      #   lsp-ltex
      #   lsp-mode
      #   lsp-treemacs
      #   lsp-ui
      #   lua-mode
      #   lv
      #   macrostep
      #   magit
      #   magit-section
      #   magit-todos
      #   marginalia
      #   markdown-mode
      #   markdown-toc
      #   modern-cpp-font-lock
      #   multiple-cursors
      #   nav-flash
      #   nerd-icons
      #   nerd-icons-completion
      #   nerd-icons-corfu
      #   nerd-icons-dired
      #   # nix3
      #   nix-mode
      #   nix-update
      #   nodejs-repl
      #   # nomake
      #   npm-mode
      #   ob-async
      #   ob-restclient
      #   opencl-mode
      #   orderless
      #   org
      #   org-appear
      #   org-cliplink
      #   org-contrib
      #   org-fancy-priorities
      #   orgit
      #   orgit-forge
      #   org-noter
      #   org-pdftools
      #   org-superstar
      #   #org-yt
      #   overseer
      #   ox-clip
      #   ox-pandoc
      #   package-lint
      #   parent-mode
      #   parinfer-rust-mode
      #   pcache
      #   pcre2el
      #   pdf-tools
      #   persistent-soft
      #   persp-mode
      #   pfuture
      #   pkg-info
      #   popon
      #   popup
      #   posframe
      #   project
      #   projectile
      #   promise
      #   pug-mode
      #   queue
      #   quickrun
      #   rainbow-delimiters
      #   rainbow-mode
      #   realgud
      #   realgud-trepan-ni
      #   request
      #   restart-emacs
      #   restclient
      #   restclient-jq
      #   rjsx-mode
      #   #rotate-text
      #   rustic
      #   rust-mode
      #   s
      #   sass-mode
      #   saveplace-pdf-view
      #   seq
      #   shrink-path
      #   simple-httpd
      #   skewer-mode
      #   slim-mode
      #   # smartparens
      #   solaire-mode
      #   spinner
      #   ssh-deploy
      #   # straight
      #   stylus-mode
      #   switch-window
      #   sws-mode
      #   tablist
      #   test-simple
      #   tide
      #   toc-org
      #   transient
      #   treemacs
      #   treemacs-evil
      #   treemacs-magit
      #   treemacs-nerd-icons
      #   treemacs-persp
      #   treemacs-projectile
      #   treepy
      #   tree-sitter
      #   tree-sitter-indent
      #   tree-sitter-langs
      #   tsc
      #   typescript-mode
      #   # typst-ts-mode
      #   ucs-utils
      #   undo-tree
      #   unicode-fonts
      #   use-package
      #   uuidgen
      #   vertico
      #   vertico-posframe
      #   vi-tilde-fringe
        vterm
      #   web-mode
      #   websocket
      #   wgrep
      #   which-key
      #   with-editor
      #   ws-butler
      #   xref
      #   xref-js2
      #   xterm-color
      #   yaml
      #   yaml-mode
      #   yasnippet
      #   yasnippet-capf
      #   zmq
        treesit-grammars.with-all-grammars
      ]);
  };

  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;

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
        sarasa-gothic
        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
        unicode-emoji
        unicode-character-database
        ucs-fonts
        unifont
        liberation_ttf
        helvetica-neue-lt-std
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
      ];
  };

  gtk.iconCache.enable = true;

  qt = {
    enable = true;
    platformTheme = "kde";
    style = "breeze";
  };
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };
  programs.regreet = {
    enable = true;
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
      background.path = "${../data}/greeter/wallpaper.webp";
      GTK.application_prefer_dark_theme = true;
      "widget.clock" = {};
    };
  };
  services.greetd = {
    enable = true;
    # settings = {
    #   default_session = {
    #     command = "Hyprland --config ${../data}/greeter/hyprland.conf";
    #     user = "greeter";
    #   };
    # };
  };
  services.xserver = {
    enable = true;
    autorun = true;
    updateDbusEnvironment = true;
    excludePackages = with pkgs; [ xterm ];

    desktopManager = {
      runXdgAutostartIfNone = true;
      gnome.enable = false;
    };

    xkb.layout = { "laptop" = "us,br"; "desktop" = "us"; }.${device};
    xkb.variant = { "laptop" = "intl,abnt2"; "desktop" = "intl"; }.${device};
    videoDrivers = { "laptop" = [ "nvidia" ]; "desktop" = [ "amdgpu" ]; }.${device};
  };

  services.libinput = {
    enable = true;
    touchpad = {
      tappingButtonMap = "lrm";
      sendEventsMode = "disabled-on-external-mouse";
      disableWhileTyping = true;
    };
  };

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    config.common.default = lib.optional (device == "desktop") "hyprland" ++ [ "kde" "gtk" ];
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
