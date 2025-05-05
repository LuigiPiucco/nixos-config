{ inputs, pkgs, lib, device, ... }: {
  users.users.luigi = {
    hashedPassword =
      "$6$AuFJcsrir3QGAuqD$XavJkb/EsihqfAZLX86USxjX/i9mxRNiDi.e36vNSwKIsSjY9XbyBrVwwgR37X2uSrbpeWSbmBvOcnv2podCM/";
    description = "Luigi Sartor Piucco";
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
      "adbusers"
      "gamemode"
    ] ++ lib.optionals (device == "desktop") [
      "iwd"
      "sev"
      "sev-guest"
    ];
    uid = 1000;
    group = "users";
    shell = pkgs.fish;
    createHome = false;
  };

  home-manager.users.luigi = { config, osConfig, pkgs, lib, ... }: {
    imports = [
      inputs.hyprland.homeManagerModules.default
    ];

    editorconfig = {
      enable = true;
      settings = {
        "*" = {
          end_of_line = "lf";
          insert_final_newline = true;
        };
        "*.*" = {
          indent_style = "space";
          indent_size = 4;
        };
        "*.{js,ts,jsx,tsx}".indent_size = 2;
        "*.{json,yaml,yml}".indent_size = 2;
        "*.el".indent_size = 2;
        "*.nix".indent_size = 2;
      };
    };

    home = {
      preferXdgDirectories = true;
      enableNixpkgsReleaseCheck = true;
      stateVersion = "25.05";
    };
    home.sessionVariables = {
      EMAIL = "luigipiucco@gmail.com";
      STACK_XDG = "1";
      JULIA_DEPOT_PATH = "${config.xdg.dataHome}/julia:${config.xdg.configHome}/julia";
      JULIAUP_DEPOT_PATH = "${config.xdg.dataHome}/julia";
      RENPY_PATH_TO_SAVES = "${config.xdg.dataHome}/renpy";
    };
    home.pointerCursor = {
      name = "Breeze_Hacked";
      package = pkgs.breeze-hacked-cursor-theme;
      hyprcursor.enable = true;
    };

    programs.eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
    };


    systemd.user.services.gpg-agent.Service.ExecStartPost = "/bin/sh -c 'systemctl --user set-environment SSH_AUTH_SOCK=$$(gpgconf --list-dirs agent-ssh-socket)'";
    systemd.user.services.keepassxc = {
      Unit = {
        Description = "KeepassXC Password Manager";
        After = ["gpg-agent.service" "graphical-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "/run/current-system/sw/bin/keepassxc --minimized %h/Secrets/OldPasswords.kdbx";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    programs.bat.enable = true;
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        function vterm_printf
            printf "\e]%s\e\\" "$argv"
        end

        if [ "$INSIDE_EMACS" = 'vterm' ]
          function clear
            vterm_printf "51;Evterm-clear-scrollback";
            tput clear;
          end
          function fish_title
            hostname
            echo ":"
            prompt_pwd
          end
        end

        function vterm_cmd --description 'Run an Emacs command among the ones been defined in vterm-eval-cmds.'
          set -l vterm_elisp ()
          for arg in $argv
            set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
          end
          vterm_printf '51;E'(string join "" $vterm_elisp)
        end

        function vterm_prompt_end;
          vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
        end
        functions --copy fish_prompt vterm_old_fish_prompt
        function fish_prompt --description 'Write out the prompt; do not replace this; Instead, put this at end of your file.'
          vterm_old_fish_prompt
          vterm_prompt_end
        end
      '';
    };
    programs.less.enable = true;
    programs.ripgrep.enable = true;
    programs.zoxide.enable = true;
    programs.starship = {
      enable = true;
      settings = {
        cmd_duration = {
          show_milliseconds = true;
          min_time = 8000;
        };
        directory = {
          style = "cyan";
          before_repo_root_style = "light grey";
          repo_root_style = "bold cyan";
          truncation_symbol = "(etc.)/";
        };
        direnv = {
          disabled = true;
          detect_files = [ ".envrc" ".env" ];
          detect_folders = [ ".direnv" ];
        };
      };
    };

    programs.git = {
      enable = true;

      ignores = [ ".direnv/" ".cache/" "*~" "*.bak" ];

      lfs.enable = true;

      signing = {
        key = "5EC80D9E33C0BFDC1F5543546FF1A01853A47A66";
        signByDefault = true;
      };

      userEmail = "luigipiucco@gmail.com";
      userName = "Luigi Sartor Piucco";

      extraConfig = {
        pull.rebase = false;
        credential.credentialStore = "secretservice";
        init.defaultBranch = "main";
        github.user = "LuigiPiucco";
        forge.autoPull = true;
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
    nix = {
      enable = true;
      inherit (osConfig.nix) settings;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      settings = let
        borderColorStart = "af0010";
        borderColorEnd = "1000af";
        borderAngle = "45";
      in {
        general = {
          border_size = 2;
          gaps_in = 4;
          gaps_out = 8;
          "col.inactive_border" = "rgba(${borderColorStart}af) rgba(${borderColorEnd}af) ${borderAngle}deg";
          "col.active_border" = "rgba(${borderColorStart}ff) rgba(${borderColorEnd}ff) -${borderAngle}deg";
          layout = "master";
          resize_on_border = true;
          extend_border_grab_area = 16;
          allow_tearing = true;
          snap = {
            enabled = true;
            window_gap = 2;
            monitor_gap = 4;
          };
        };
        decoration = {
          dim_inactive = true;
          blur = {
            enabled = true;
            size = 16;
            passes = 2;
          };
          shadow = {
            enabled = true;
            range = 8;
            ignore_window = false;
          };
        };
        input = {
          kb_layout = "us";
          kb_variant = "intl";
        };
        misc = {
          vrr = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          animate_manual_resizes = true;
          focus_on_activate = true;
        };
        render = {
          direct_scanout = true;
        };
        cursor = {
          hide_on_key_press = true;
        };
        workspace = [
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
        ];
        exec-once = [
          "walker --gapplication-service"
          "clipse --listen"
          "waybar"
          "mpvpaper -o 'no-audio loop' '*' ${../data}/hyprland/wallpaper.mp4"
          "dunst"
          "udiskie"
        ];
        windowrulev2 = [
          "bordersize 0, floating:0, onworkspace:w[tv1]"
          "rounding 0, floating:0, onworkspace:w[tv1]"
          "bordersize 0, floating:0, onworkspace:f[1]"
          "rounding 0, floating:0, onworkspace:f[1]"
          "float, class:(clipse)"
          "size 622 652, class:(clipse)"
          "suppressevent maximize, class:.*"
          "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"
          "workspace 10, class:^xwaylandvideobridge$"
        ];
      };
      extraConfig = let
        modifier = "SUPER";
        bindAction = flags: mod: dispatcher: l:
          lib.concatMapStringsSep
            "\n"
            ({ key, param }: "bind${flags} = ${mod}, ${key}, ${dispatcher}, ${param}")
            l;

        numericDirections = [ "10 0" "-10 0" "0 -10" "0 10" ];
        symbolicDirections = [ "r" "l" "u" "d" ];
        programs = [
          "alacritty --class clipse -e clipse"
          "walker"
        ];
        audioCalls = [
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];
        brightnessCalls = [
          "brightnessctl s 10%+"
          "brightnessctl s 10%-"
        ];
        playerCalls = [
          "playerctl next"
          "playerctl play-pause"
          "playerctl play-pause"
          "playerctl previous"
        ];
        workspaces = [
          "name:code"
          "name:web"
          "name:work"
          "name:games"
        ];

        directionMovements = [ "right" "left" "up" "down" ];
        viMovements = [ "h" "l" "k" "j" ];
        gameMovements = [ "a" "d" "w" "s" ];
        shortcuts = ["V" "space"];
        audioKeys = [
          "XF86AudioRaiseVolume"
          "XF86AudioLowerVolume"
          "XF86AudioMute"
          "XF86AudioMicMute"
        ];
        brightnessKeys = [
          "XF86MonBrightnessUp"
          "XF86MonBrightnessDown"
        ];
        playerKeys = [
          "XF86AudioNext"
          "XF86AudioPause"
          "XF86AudioPlay"
          "XF86AudioPrev"
        ];
        workspaceKeys = [ "1" "2" "3" "4" ];

        pairKeyParamLists = lib.zipListsWith (key: param: { inherit key param; });
        mkMovementBinds = movements: ''
          ${bindAction "" "" "movefocus" (pairKeyParamLists movements symbolicDirections)}
          ${bindAction "" "CTRL" "movewindow" (pairKeyParamLists movements symbolicDirections)}
          ${bindAction "e" "SHIFT" "resizeactive" (pairKeyParamLists movements numericDirections)}
        '';
        mkSubmap = name: key: binds: ''
          bind = ${modifier}, ${key}, submap, ${name}
          submap = ${name}
          bind = , escape, submap, reset
          ${binds}
          submap = reset
        '';
        windowSubmap = mkSubmap "windows" "W" ''
          ${mkMovementBinds directionMovements}
          ${mkMovementBinds viMovements}
          ${mkMovementBinds gameMovements}
          ${bindAction "" "" "workspace" (pairKeyParamLists workspaceKeys workspaces)}
          ${bindAction "" "SHIFT" "movetoworkspacesilent" (pairKeyParamLists workspaceKeys workspaces)}
          bind = SHIFT, 0, togglespecialworkspace, special
        '';

        windowMap = bindAction "" modifier "movefocus" (pairKeyParamLists viMovements symbolicDirections);
        execMap = bindAction "" modifier "exec" (pairKeyParamLists shortcuts programs);
        repeatableMediaMap = bindAction "el" modifier "exec" (pairKeyParamLists (audioKeys ++ brightnessKeys) (audioCalls ++ brightnessCalls));
        mediaMap = bindAction "l" modifier "exec" (pairKeyParamLists playerKeys playerCalls);
      in ''
        ${windowSubmap}
        ${windowMap}
        ${execMap}
        ${repeatableMediaMap}
        ${mediaMap}
        bindm = ${modifier}, mouse:272, movewindow
        bind = ${modifier}, backspace, killactive,
        bind = ${modifier}, Q, togglefloating,
        bind = ${modifier}, F, fullscreen, 0
        ${bindAction "" modifier "workspace" (pairKeyParamLists workspaceKeys workspaces)}
        bind = ${modifier}, 0, togglespecialworkspace, special
      '';
    };
    programs.hyprlock = {
      enable = true;
    };
    services.hypridle = {
      enable = true;
    };

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
    services.gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      enableSshSupport = true;
      enableFishIntegration = true;
      sshKeys = [ "87AF23A921179C8FF040FE3359B201DC3EF61234" ];
      pinentryPackage = pkgs.pinentry-qt;
    };
    programs.ssh.userKnownHostsFile = "${config.xdg.dataHome}/ssh/known_hosts";
  };
}
