{ config, pkgs, inputs, nur, ... }:
let
  lockscreen = pkgs.writeShellScriptBin "lockscreen" ''
    path=/tmp/tmpbg.png
    pathout=/tmp/tmpbgblur.png

    # Take screenshot
    grim "$path"

    # Use gaussion blur
    ffmpeg -i "$path" -filter:v "gblur=sigma=40" -frames:v 1 "$pathout" > /dev/null 2>&1

    # Lock the screen
    swaylock -c '1b2021' -i "$pathout"

    # Remove temp bgs
    rm -f "$path" "$pathout"
  '';
in {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Remove unwanted programs
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [ elisa konsole ];

  services.xserver.excludePackages = with pkgs; [ xterm ];

  # Enable programs system wide
  virtualisation.libvirtd.enable = true;
  programs = {
    steam.enable = true;
    wireshark.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "curses";
    };

    # Set the system default shell
    zsh.enable = true;

    # hyprland default enables [ dconf xdg-desktop-portal-hyprland polkit opengl xwayland ]
    hyprland = {
      enable = true;
      enableNvidiaPatches = true;
    };
  };

  users.defaultUserShell = pkgs.zsh;
  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      gnupg
      kitty
      nftables
      pinentry-curses

      # flakes
      inputs.nixvim.packages."x86_64-linux".default

      # Utilities
      ffmpeg
      openrazer-daemon
      polychromatic
      spice-vdagent
      unzip
      virt-manager
      wineWowPackages.full
      zip

      # Security
      vulnix

      # Programming languages
      go

      # Wayland 
      brightnessctl
      eww-wayland
      firefox-wayland
      grim
      lockscreen
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      swaylock
      swayidle
      tofi
      wlr-randr

      # hypr 
      dunst
      hyprland-protocols
      hyprpaper
      hyprpicker
      jq
      libnotify
      python3
      socat
      # libsForQt5.qtstyleplugin-kvantum
    ];
  };

  # Allow swaylock to unlock the device
  security.pam.services.swaylock = { };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikael = {
    isNormalUser = true;
    description = "mikael";
    extraGroups =
      [ "networkmanager" "wheel" "libvirtd" "openrazer" "wireshark" ];
    packages = with pkgs; [
      config.nur.repos.mikaelfangel-nur.battery-wallpaper
      config.nur.repos.mikaelfangel-nur.clx
      config.nur.repos.mikaelfangel-nur.gitpolite
      config.nur.repos.mikaelfangel-nur.quiet
      config.nur.repos.mikaelfangel-nur.rmosxf
      config.nur.repos.mikaelfangel-nur.spacedrive

      # firefox
      android-studio
      element-desktop
      gh # GitHub client
      git
      jetbrains.goland
      jetbrains.idea-community
      libreoffice-fresh
      nerdfonts
      nextcloud-client
      pipr
      protonmail-bridge
      ripgrep # telescope depend
      signal-desktop
      thunderbird
      ugrep
      ungoogled-chromium # Used for MS Teams
      wireshark

      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          ms-dotnettools.csharp # Ionide dependency
          ionide.ionide-fsharp
          asvetliakov.vscode-neovim

          dracula-theme.theme-dracula
          mkhl.direnv
        ];
      })
    ];
  };

  # home-manager setup 
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.mikael = { pkgs, ... }: {
      home.stateVersion = "23.05";
      programs = {
        zsh = {
          enable = true;
          autocd = true;
          enableAutosuggestions = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          shellAliases = {
            icat = "kitty +kitten icat";
            clip = "kitty +kitten clipboard";
            ls = "ls --color=auto";
            ip = "ip -c";
            clx = "clx -n";
            uq = "ug -Q";
            ux = "ug -UX";
            uz = "ug -z";
            ugit = "ug -R --ignore-files";
            grep = "ugrep -G";
            egrep = "ugrep -E";
            fgrep = "ugrep -F";
            pgrep = "upgrep -P";
            xgrep = "ugrep -W";
            zgrep = "ugrep -zG";
            zegrep = "ugrep -zE";
            zfgrep = "ugrep -zF";
            zpgrep = "ugrep -zP";
            zxgrep = "ugrep -zW";
          };
          history = { size = 10000; };
          initExtra = ''
            autoload -U colors && colors
            export PATH="$PATH:$(go env GOPATH)/bin"
          '';
        };
        kitty = {
          enable = true;
          theme = "Monokai Soda";
          settings = { background_opacity = "0.90"; };
        };
        starship = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            format = ''
              $character$username$directory$git_branch$cmd_duration
              [❯ ](bold #e7b077)
            '';

            git_branch = {
              format =
                "[$symbol $branch(:$remote_branch) ](bold #e7b077)";
              symbol = "";
            };

            directory = {
              format = "󰉋 $path ";
              truncation_length = 3;
              truncate_to_repo = false;
            };

            character = {
              success_symbol = "";
              error_symbol = "[](bold #FF0000)";
            };

            hostname = {
              ssh_only = false;
              ssh_symbol = "🌐";
              format = "[$ssh_symbol$hostame](bold #FF0000)";
            };

            username = {
              style_root = "bold #800080";
              style_user = "bold #e7b077";
              format = "[$user ](bold #e7b077)";
              show_always = true;
            };

            cmd_duration = {
              min_time = 1;
              format =
                "[[ ](fg: bold)$duration](fg: #BBC3DF)";
              disabled = false;
            };
          };
        };
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };
        git = {
          enable = true;
          userName = "Mikael Fangel";
          userEmail = "34864484+MikaelFangel@users.noreply.github.com";

          extraConfig = {
            commit.gpgsign = true;
            user.signingkey = "306DE4426F0B77C3";
          };
        };
      };

      # Virtmanager config
      dconf.settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };
      };

      home.file = {
        ".gitconfig".text = ''
          [pull]
           rebase = false
        '';

        ".config/ca_eduroam.pem".text = builtins.readFile ./ca_eduroam.pem;
      };
      gtk = {
        enable = true;
        theme.package = pkgs.qogir-theme;
        theme.name = "Qogir-Dark";
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-xft-antialias = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "hintfull";
          gtk-xft-rgba = "rgb";
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-xft-antialias = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "hintfull";
          gtk-xft-rgba = "rgb";
        };
      };
      qt = {
        enable = true;
        platformTheme = "kde";
        style.package = pkgs.qogir-kde;
        style.name = "Qogir-Dark";
      };
    };
  };
}
