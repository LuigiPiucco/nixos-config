{ config, pkgs, ... }: {
  wsl.defaultUser = "pietro";

  users.users.root.hashedPassword =
    "$6$8tFm9JADE9l04cQq$M.iDOvqlNWup.h2XSBlWdgF5RDy/T4wJ0HmzNoMSz8mCYoxqjxdbTmYWZRAEqJtoTyu9NJpQ0XHqiQS.GL.y5/";
  users.users.luigi = {
    hashedPassword =
      "$6$8tFm9JADE9l04cQq$M.iDOvqlNWup.h2XSBlWdgF5RDy/T4wJ0HmzNoMSz8mCYoxqjxdbTmYWZRAEqJtoTyu9NJpQ0XHqiQS.GL.y5/";
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
    ];
    uid = 1000;
    group = "users";
    shell = pkgs.fish;
  };

  home-manager.users.pietro = let inherit (config.services) emacs;
  in { config, pkgs, ... }: {
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
      };
    };

    home = {
      enableNixpkgsReleaseCheck = true;
      pointerCursor = {
        package = pkgs.libsForQt5.breeze-gtk;
        name = "Breeze_cursors";
        size = 24;

        gtk.enable = true;
      };
      stateVersion = "24.05";
      sessionVariables = { EMAIL = "pietropiucco@gmail.com"; };
    };

    programs.eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.bat.enable = true;
    programs.fish = {
      enable = true;
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
    programs.less.enable = true;
    programs.ripgrep.enable = true;
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
