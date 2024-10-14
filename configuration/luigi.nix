{ pkgs, wsl, ... }: {
  users.users.root.hashedPassword =
    "$6$AuFJcsrir3QGAuqD$XavJkb/EsihqfAZLX86USxjX/i9mxRNiDi.e36vNSwKIsSjY9XbyBrVwwgR37X2uSrbpeWSbmBvOcnv2podCM/";
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
    ];
    uid = 1000;
    group = "users";
    shell = pkgs.fish;
    createHome = false;
  };

  home-manager.users.luigi = { config, osConfig, pkgs, ... }: {
    imports = [
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
      stateVersion = "24.05";
    };
    home.sessionVariables = {
      EMAIL = "luigipiucco@gmail.com";
      STACK_XDG = "1";
      JULIA_DEPOT_PATH = "${config.xdg.dataHome}/julia:${config.xdg.configHome}/julia";
      JULIAUP_DEPOT_PATH = "${config.xdg.dataHome}/julia";
    };

    programs.eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = true;
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
        init.defaultBranch = "master";
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
