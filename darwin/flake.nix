{
  description = "Cool nix-darwin system flake";

  inputs = {
    # Nixpkgs: collection of software packages for the Nix package manager
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # VSCode extensions
    # see https://davi.sh/blog/2024/11/nix-vscode/
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    # nix-darwin (MacOS)
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NUR
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    darwin,
    nixpkgs,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    home-manager,
    nix-vscode-extensions,
    nur,
    ...
  }:
  let
    configuration = { pkgs, config, ... }: {

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      nixpkgs.config.allowUnfree = true;

      nixpkgs.overlays = [
        nix-vscode-extensions.overlays.default
      ];

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment = {
        variables = {
          DOCKER_HOST = "unix:///var/folders/j4/pkqvd4dj1qj2tn6b0g9z763w0000gn/T/podman/podman-machine-default-api.sock";
        };
        systemPackages = with pkgs; [
          # beekeeper-studio // doesn't exist for aarch64-darwin
          bitwarden-desktop
          brave
          chezmoi
          corepack
          cowsay
          fortune
          fzf
          gh
          libreoffice-bin
          mkalias
          # neofetch
          nur
          oh-my-posh
          # signal-desktop // not working 06/05/2025
          slack
          zoom-us
          zsh
        ];
      };

      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.meslo-lg
      ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "podman"
          "podman-compose"
          "qrencode"
          "verapdf"
          "vips"
          "xpdf"
        ];
        casks = [
          "deepl"
          "figma"
          "firefox"
          "ghostty"
          "imageoptim"
          "podman-desktop"
          "signal"
          "spotify"
          "vlc"
          "whatsapp"
        ];
        onActivation.cleanup = "zap";
        onActivation.upgrade = true;
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      programs = {
        ssh = {
          knownHosts = {
            "github/ed25519" = {
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
              hostNames = [ "github.com" ];
            };
            "github/sha2" = {
              publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
              hostNames = [ "github.com" ];
            };
            "github/rsa" = {
              publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
              hostNames = [ "github.com" ];
            };
          };
        };
      };

      # Enable Touch ID with sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      system = {
        # Create aliases instead of symlinks for all installed applications
        # See https://gist.github.com/elliottminns/211ef645ebd484eb9a5228570bb60ec3
        activationScripts = {
          applications.text = let
            env = pkgs.buildEnv {
              name = "system-applications";
              paths = config.environment.systemPackages;
              pathsToLink = "/Applications";
            };
          in
            pkgs.lib.mkForce ''
            # Set up applications.
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
                '';

          postActivation.text = ''
            # Following line should allow us to avoid a logout/login cycle
            sudo /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
            '';
        };

        primaryUser = "yaaax";

        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # System (MacOS)
        defaults = {
          dock.autohide = true;
          finder = {
            FXPreferredViewStyle = "clmv";
          };
          spaces.spans-displays = true;

          CustomSystemPreferences = {
            NSGlobalDomain = {
              # Add a context menu item for showing the Web Inspector in web views
              WebKitDeveloperExtras = true;
              "com.apple.mouse.tapBehavior" = 1;
              "com.apple.swipescrolldirection" = true;
            };
          };
        };

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 6;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      modules = [
        configuration

        # Adds the NUR overlay
        nur.modules.darwin.default

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "yaaax";

            # Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            # Enable fully-declarative tap management
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }

        home-manager.darwinModules.home-manager
        {
          # Mandatory in order to make config build (even if repeated in home.nix)
          users = {
            users = {
              yaaax.home = "/Users/yaaax";
            };
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.yaaax = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          };
        }
      ];
    };
  };
}
