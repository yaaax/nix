{ config, pkgs, nur, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "yaaax";
    homeDirectory = "/Users/yaaax";

    file = {
      # Ghostty config
      ".config/ghostty/config".text = ''
        # Theme
        theme = "catppuccin-mocha"

        # UI
        macos-titlebar-style = "tabs"
        window-colorspace = "display-p3"

        # Keys
        keybind = global:cmd+grave_accent=toggle_quick_terminal

        # Functionnalities
        window-save-state = always

        scrollback-limit = 4294967295
      '';

      # Neovim config
      ## Configure git commit message highlighting
      ".config/nvim/after/ftplugin/gitcommit.vim".text = ''
        highlight gitcommitOverflow guifg=#bf616a ctermfg=202
      '';

      # SSH config
      ## Add identity file (private key) to access github.com to
      ".ssh/config".text = ''
        Host github.com
        UseKeychain yes
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_ed25519
      '';
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = true;
        file-style = "#efefef bold darkblue";
        file-decoration-style = "#efefef ul ol";
        minus-style = "red bold auto";
        plus-style = "green bold #114411";
      };
    };
    google-chrome = {
      enable = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # firefox = {
    #   enable = true;
    #   profiles = {
    #     default = {
    #       id = 0;
    #       name = "default";
    #       extensions = {
    #         packages = with pkgs.nur.repos.rycee.firefox-addons; [
    #           bitwarden
    #           headingsmap
    #           ublock-origin
    #           wappalyzer
    #           web-developer
    #         ];
    #       };
    #     };
    #   };
    # };

    git = {
      enable = true;
      settings = {
        alias = {
          co = "checkout";
          oops = "commit --amend --no-edit";
        };
        pull.ff = "only";
        stash.showPatch = true;
        user = {
          email = "yaacov@goodimpact.studio";
          userName = "Yaacov";
        };
      };
    };

    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    oh-my-posh = {
      enableZshIntegration = true;
    };

    # Spotify
    spotify-player = {
      enable = true;
    };

    # VS Codium
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles = {
        default = {
          userSettings = {
            "[json]" = {
              "editor.defaultFormatter" = "vscode.json-language-features";
            };
            "[jsonc]" = {
              "editor.defaultFormatter" = "vscode.json-language-features";
            };
            "[vue]" = {
              "editor.defaultFormatter" = "Vue.volar";
            };
            "containers.containerClient" = "com.microsoft.visualstudio.containers.podman";
            "editor.codeActionsOnSave" = {
              "source.fixAll" = "explicit";
            };
            "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
            "editor.minimap.enabled" = false;
            "editor.rulers" = [80];
            "files.associations" = {
              "*.json" = "jsonc";
            };
            "files.autoSave" = "off";
            "javascript.format.enable" = false;
            "task.allowAutomaticTasks" = "off";
            "terminal.integrated.fontFamily" = "MesloLGM Nerd Font";
            "typescript.preferences.importModuleSpecifier" = "relative";
            "typescript.tsserver.experimental.enableProjectDiagnostics" = true;
            "typescript.format.enable" = false;
          };
          extensions = with pkgs.vscode-marketplace; [
            bbenoist.nix
            dbaeumer.vscode-eslint
            dreamcatcher45.podmanager
            eamodio.gitlens
            esbenp.prettier-vscode
            firefox-devtools.vscode-firefox-debug
            github.vscode-github-actions
            ms-azuretools.vscode-containers
            prisma.prisma
            ritwickdey.liveserver
            tamasfe.even-better-toml
            possan.nbsp-vscode
          ] ++ [
            pkgs.vscode-extensions.vue.volar
          ];
        };
      };
    };

    zsh = {
      enable = true;
      syntaxHighlighting = {
        enable = true; # Amazing oneline!
      };
      shellAliases = {
        docker = "podman";

        l = "ls -al --color";

        g = "git";

        ga = "git add";

        gc = "git commit";

        gd = "git diff";

        gds = "git diff --staged";

        # Best default 'git log':
        gl = "glog --name-status";

        # Fancy 'git log --graph':
        glg = "glog --graph";

        # Fancy 'git log --graph --oneline':
        glgo = "git log -10 --graph --date=format:\"%d/%m/%y\" --pretty=format:\"%C(yellow)%h%Creset   %C(white)%ad%Creset%x09%C(bold)%s%x09%C(bold green)%D%Creset%n\"";

        # Fancy 'git log --graph --stat':
        glgs = "glog --graph --stat";

        # Fancy 'git log --oneline':
        glo = "git log -10 --date=format:\"%d/%m/%y\" --pretty=format:\"%C(yellow)%h%Creset   %C(white)%ad%Creset    %C(bold)%s     %C(bold green)%D%Creset\"";

        # Regular 'git log' in style:
        glog = "git log -10 --date=format:\"%A %B %d %Y at %H:%M\" --pretty=format:\"%C(yellow)%H%Creset%x09%C(bold green)%D%Creset%n%<|(40)%C(white)%ad%x09%an%Creset%n%n    %C(bold)%s%Creset%n%w(0,4,4)%+b\"";

        gp = "git push";

        gs = "git status -s";

        # Regular 'git show' in style:
        gsh = "git show --date=format:\"%A %B %d %Y at %H:%M\" --pretty=format:\"%C(yellow)%H%Creset%x09%C(bold green)%D%Creset%n%<|(40)%C(white)%ad%x09%an%Creset%n%n    %C(bold)%s%Creset%n%w(0,4,4)%+b%n\"";
      };
      initContent = ''
        # Oh My Posh initialization
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config $HOME/.config/oh-my-posh/zen.toml)"
      '';
    };
  };

  targets.darwin = {
    currentHostDefaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;

        InitialKeyRepeat = 14;
        KeyRepeat = 2;

        # Tap to click on mouse.
        # ⚠️ Disabled as Not working well…
        # "com.apple.mouse.tapBehavior" = 1;

        # Normal scrolling.
        # "com.apple.swipescrolldirection" = false;
      };
      "com.apple.controlcenter" = {
        BatteryShowPercentage = true;
      };
      "com.apple.Safari" = {
        AlwaysRestoreSessionAtLaunch = true;
        IncludeDevelopMenuPreferenceKey = true;
        IncludeInternalDebugMenu = true;
        ShowFullURLInSmartSearchField = true;
        ShowOverlayStatusBar = true;
        SuppressSearchSuggestions = true;
        UniversalSearchEnabled = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        "WebKitPreferences.tabFocusesLinks" = 1;
      };

      "com.apple.Safari.ContentPageGroupIdentifier" = {
        WebKit2DeveloperExtrasEnabled = true;
      };

      "com.apple.Safari.SandboxBroker" = {
        ShowDevelopMenu = true;
      };
    };
  };
}

# Some notes
# ==========
#
# Local Apache
# ------------
#
# J’ai suivi [How to Set Up a Local Web Server on macOS 15 Sequoia](https://sausheong.com/how-to-set-up-a-local-web-server-on-macos-15-sequoia-90a70293ce74)