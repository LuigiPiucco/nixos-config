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
      "sev"
      "sev-guest"
    ] ++ lib.optionals (device == "rpi") [
      "i2c"
      "spi"
      "gpio"
    ] ++ lib.optional (device == "desktop" || device == "rpi") "iwd";
    uid = 1000;
    group = "users";
    shell = pkgs.fish;
    createHome = device == "rpi";
  };

  home-manager.users.luigi = { config, osConfig, pkgs, lib, ... }: {
    imports = [
      inputs.hyprland.homeManagerModules.default
      inputs.walker.homeManagerModules.default
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
        "*.typ".indent_size = 2;
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
      name = "Breeze";
      package = pkgs.kdePackages.breeze;
      hyprcursor.enable = osConfig.programs.hyprland.enable;
    };

    programs.eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
    };

    systemd.user.services.gpg-agent.Service.ExecStartPost =
      "/bin/sh -c 'systemctl --user set-environment SSH_AUTH_SOCK=$$(gpgconf --list-dirs agent-ssh-socket)'";

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

      lfs.enable = device != "rpi";

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

    services.hyprpaper = {
      enable = osConfig.programs.hyprland.enable;
      settings = {
        ipc = "on";
        preload = ["${inputs.self}/data/hyprland/wallpaper.jpg"];
        wallpaper = [",${inputs.self}/data/hyprland/wallpaper.jpg"];
      };
    };
    programs.walker = {
      enable = osConfig.programs.hyprland.enable;
      runAsService = osConfig.programs.hyprland.enable;

      config = {
        ui.fullscreen = true;
        list.height = 200;
        websearch.prefix = "?";
        switcher.prefix = "/";
      };
    };
    programs.waybar = {
      enable = osConfig.programs.hyprland.enable;
      systemd.enable = osConfig.programs.hyprland.enable;
      style = ''
        @define-color bg_main rgba(25, 25, 25, 0.65);
        @define-color bg_main_tooltip rgba(0, 0, 0, 0.7);

        @define-color bg_hover rgba(200, 200, 200, 0.3);
        @define-color bg_active rgba(100, 100, 100, 0.5);

        @define-color border_main rgba(255, 255, 255, 0.2);

        @define-color content_main white;
        @define-color content_inactive rgba(255, 255, 255, 0.25);

        * {
          text-shadow: none;
          box-shadow: none;
          border: none;
          border-radius: 0;
          font-family: "Iosevka Etoile", "Fira Code Nerd Font";
          font-weight: 600;
          font-size: 12.7px;
        }

        window#waybar {
          background:  @bg_main;
          border-top: 1px solid @border_main;
          color: @content_main;
        }

        tooltip {
          background: @bg_main_tooltip;
          border-radius: 5px;
          border-width: 1px;
          border-style: solid;
          border-color: @border_main;
        }
        tooltip label{
          color: @content_main;
        }

        #custom-os_button {
          font-family: "Fira Code Nerd Font";
          font-size: 24px;
          padding-left: 12px;
          padding-right: 20px;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }
        #custom-os_button:hover {
          background: @bg_hover;
          color: @content_main;
        }

        #workspaces {
          color: transparent;
          margin-right: 1.5px;
          margin-left: 1.5px;
        }
        #workspaces button {
          padding: 3px;
          color: @content_inactive;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }
        #workspaces button.active {
          color: @content_main;
          border-bottom: 3px solid white;
        }
        #workspaces button.focused {
          color: @bg_active;
        }
        #workspaces button.urgent {
          background:  rgba(255, 200, 0, 0.35);
          border-bottom: 3px dashed @warning_color;
          color: @warning_color;
        }
        #workspaces button:hover {
          background: @bg_hover;
          color: @content_main;
        }

        #taskbar {
        }

        #taskbar button {
          min-width: 130px;
          border-bottom: 3px solid rgba(255, 255, 255, 0.3);
          margin-left: 2px;
          margin-right: 2px;
          padding-left: 8px;
          padding-right: 8px;
          color: white;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }

        #taskbar button.active {
          border-bottom: 3px solid white;
          background: @bg_active;
        }

        #taskbar button:hover {
          border-bottom: 3px solid white;
          background: @bg_hover;
          color: @content_main;
        }

        #cpu, #disk, #memory {
          padding:3px;
        }

        #temperature {
          color: transparent;
          font-size: 0px;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }
        #temperature.critical {
          padding-right: 3px;
          color: @warning_color;
          font-size: initial;
          border-bottom: 3px dashed @warning_color;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }

        #window {
          border-radius: 10px;
          margin-left: 20px;
          margin-right: 20px;
        }

        #tray{
          margin-left: 5px;
          margin-right: 5px;
        }
        #tray > .passive {
          border-bottom: none;
        }
        #tray > .active {
          border-bottom: 3px solid white;
        }
        #tray > .needs-attention {
          border-bottom: 3px solid @warning_color;
        }
        #tray > widget {
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }
        #tray > widget:hover {
          background: @bg_hover;
        }

        #pulseaudio {
          font-family: "JetBrainsMono Nerd Font";
          padding-left: 3px;
          padding-right: 3px;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }
        #pulseaudio:hover {
          background: @bg_hover;
        }

        #network {
          padding-left: 3px;
          padding-right: 3px;
        }

        #language {
          padding-left: 5px;
          padding-right: 5px;
        }

        #clock {
          padding-right: 5px;
          padding-left: 5px;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }
        #clock:hover {
          background: @bg_hover;
        }
      '';
      settings.main = {
        layer = "bottom";
        position = "top";
        mod = "dock";
        exclusive = true;
        gtk-layer-shell = true;
        passthrough = false;
        height = 42;
        modules-left = [
          "custom/os-button"
          "hyprland/workspaces"
          "wlr/taskbar"
        ];
        modules-right = [
          "cpu"
          "temperature"
          "memory"
          "disk"
          "tray"
          "pulseaudio"
          "network"
          "hyprland/language"
          "clock"
        ];
        spacing = 4;
        "hyprland/language" = {
          format = "{}";
          format-en = "en-us";
          format-br = "pt-br";
        };
        "hyprland/workspaces" = {
          icon-size = 32;
          spacing = 16;
          on-scroll-up = "hyprctl dispatch workspace r+1";
          on-scroll-down = "hyprctl dispatch workspace r-1";
        };
        "custom/os_button" = {
            format = "";
            on-click = "walker";
            tooltip = false;
        };
        cpu = {
            "interval" = 5;
            "format" = "  {usage}%";
            "max-length" = 10;
        };
        temperature = {
            hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
            input-filename = "temp2_input";
            critical-threshold = 75;
            tooltip = false;
            format-critical = "({temperatureC}°C)";
            format = "({temperatureC}°C)";
        };
        disk = {
            interval = 30;
            format = "󰋊 {percentage_used}%";
            path = "/";
            tooltip = true;
            unit = "GiB";
            tooltip-format = "Available {free} of {total}";
        };
        memory = {
            interval = 10;
            format = "  {percentage}%";
            max-length = 10;
            tooltip = true;
            tooltip-format = "RAM - {used:0.1f}GiB used";
        };
        "wlr/taskbar" = {
            format = "{icon} {title:.17}";
            icon-size = 28;
            spacing = 3;
            on-click-middle = "close";
            tooltip-format = "{title}";
            ignore-list = [];
            on-click = "activate";
        };
        tray = {
            icon-size = 18;
            spacing = 3;
        };
        clock = {
            format = "      {:%R\n %d.%m.%Y}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
                mode = "year";
                mode-mon-col = 3;
                weeks-pos = "right";
                on-scroll = 1;
                on-click-right = "mode";
                format = {
                    months = "<span color='#ffead3'><b>{}</b></span>";
                    days = "<span color='#ecc6d9'><b>{}</b></span>";
                    weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                    weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                    today = "<span color='#ff6699'><b><u>{}</u></b></span>";
                };
            };
            actions = {
                on-click-right = "mode";
                on-click-forward = "tz_up";
                on-click-backward = "tz_down";
                on-scroll-up = "shift_up";
                on-scroll-down = "shift_down";
            };
        };
        network = {
            format-wifi = " {icon}";
            format-ethernet = "  ";
            format-disconnected = " 󰌙 ";
            format-icons = [
                "󰤯 "
                "󰤟 "
                "󰤢 "
                "󰤢 "
                "󰤨 "
            ];
        };
        pulseaudio = {
            max-volume = 150;
            scroll-step = 10;
            format = "{icon}";
            tooltip-format = "{volume}%";
            format-muted = " ";
            format-icons = {
                default = [
                    " "
                    " "
                    " "
                ];
            };
            on-click = "pwvucontrol";
        };
      };
    };
    services.dunst.enable = osConfig.programs.hyprland.enable;
    services.udiskie.enable = osConfig.programs.hyprland.enable;
    services.clipse.enable = osConfig.programs.hyprland.enable;
    wayland.systemd.target = "hyprland-session.target";
    wayland.windowManager.hyprland = {
      enable = osConfig.programs.hyprland.enable;
      systemd.enable = osConfig.programs.hyprland.enable;
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
          dim_inactive = device == "desktop";
          blur = {
            enabled = device == "desktop";
            size = 16;
            passes = 2;
          };
          shadow = {
            enabled = device == "desktop";
            range = 8;
            ignore_window = false;
          };
        };
        input = {
          kb_layout = {"desktop" = "us"; "rpi" = "br,us";}.${device};
          kb_variant = {"desktop" = "intl"; "rpi" = "abnt2,intl";}.${device};
          kb_options = "grp:alt_shift_toggle";
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
        exec-once = lib.optional (device == "desktop") "mpvpaper -o 'no-audio --loop' ALL ${inputs.self}/data/hyprland/wallpaper-4k.mp4";
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
          "walker"
          "alacritty --class clipse -e clipse"
          "iwmenu --launcher walker --icon xdg"
          "bzmenu --launcher walker --icon xdg"
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
        shortcuts = ["space" "v" "n" "b"];
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
        bind = ${modifier}, q, togglefloating,
        bind = ${modifier}, f, fullscreen, 0
        ${bindAction "" modifier "workspace" (pairKeyParamLists workspaceKeys workspaces)}
        bind = ${modifier}, 0, togglespecialworkspace, special
      '';
    };
    programs.hyprlock = {
      enable = osConfig.programs.hyprland.enable;
    };
    services.hypridle = {
      enable = osConfig.programs.hyprland.enable;
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
      pinentry.package = pkgs.pinentry-qt;
    };
    programs.ssh.userKnownHostsFile = "${config.xdg.dataHome}/ssh/known_hosts";

    systemd.user.services.keepassxc = {
      Unit = {
        Description = "KeepassXC Password Manager";
        After = ["gpg-agent.service" "graphical-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "/run/current-system/sw/bin/keepassxc --minimized %h/Secrets/Passwords.kdbx";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
