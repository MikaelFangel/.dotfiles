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
  services.pcscd.enable = true;

  # Enable programs system wide
  virtualisation.libvirtd.enable = true;
  programs = {
    steam.enable = true;
    wireshark.enable = true;

    ## neovim = {
    ##   enable = true;
    ##   defaultEditor = true;
    ##   viAlias = true;
    ##   vimAlias = true;
    ## };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    # Set the system default shell
    zsh.enable = true;

    # hyprland default enables [ dconf xdg-desktop-portal-hyprland polkit opengl xwayland ]
    hyprland.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      gnupg
      kitty
      nftables
      pinentry-curses

      # Utilities
      ffmpeg
      openrazer-daemon
      polychromatic
      spice-vdagent
      unzip
      virt-manager
      wineWowPackages.full
      zip
      yubikey-manager

      # Security
      vulnix

      # flakes
      inputs.nixvim.packages.${system}.default

      # Wayland 
      brightnessctl
      eww
      firefox-wayland
      grim
      slurp
      lockscreen
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      swaylock
      swayidle
      tofi
      wlr-randr
      xdg-utils

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
      config.nur.repos.mikaelfangel-nur.gitpolite
      config.nur.repos.mikaelfangel-nur.quiet
      config.nur.repos.mikaelfangel-nur.rmosxf

      spacedrive

      # firefox
      android-studio
      element-desktop
      gh # GitHub client
      git
      isabelle
      jetbrains.goland
      jetbrains.idea-ultimate
      libreoffice-fresh
      livebook
      nerdfonts
      nextcloud-client
      pipr
      protonmail-bridge
      ripgrep # telescope depend
      signal-desktop
      thunderbird
      ugrep
      ugrep-indexer
      # ungoogled-chromium # Used for MS Teams
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
          autosuggestion.enable = true;
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
          '';
        };
        kitty = {
          enable = true;
          theme = "Monokai Soda";
          settings = {
            background_opacity = "0.90";
            enable_audio_bell = "no";
          };
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
              format = "[$symbol $branch(:$remote_branch) ](bold #e7b077)";
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
              format = "[[ ](fg: bold)$duration](fg: #BBC3DF)";
              disabled = false;
            };
          };
        };
        firefox = {
          enable = true;
          package = pkgs.firefox-wayland;
          profiles.default = {
            isDefault = true;
            path = "08j2lb87.default";
            userChrome = ''
              /* Disable list all tabs */
              #alltabs-button { display: none !important;}

              /* 
                This stylesheet is based on:
                  - https://github.com/khuedoan/one-line-firefox
                  - https://github.com/MrOtherGuy/firefox-csshacks
              */

              /* Title bar */
              .titlebar-buttonbox {
                display: none !important;
              }

              .titlebar-spacer {
                display: none !important;
              }

              /* Tab bar */
              #navigator-toolbox {
                border: 0px !important;
                padding-bottom: 1px !important; /* symmetry */
              }

              #TabsToolbar {
                margin-left: 40vw !important; /* offset for url bar and icons */
              }

              #tabbrowser-tabs {
                --tab-min-height: 29px !important;
                border: none !important;
                box-shadow: none !important;
              }

              /* Nav bar */
              #nav-bar {
                background: transparent !important;
                margin-top: -36px !important;
                margin-right: 60vw !important; /* offset for tab bar */
                padding-bottom: 1px !important; /* symmetry */
              }

              /* URL bar elements - uncomment selectors to _hide_ them */

              /* #back-button {
                display: none !important;
              } */

              /* #forward-button {
                display: none !important;
              } */

              /* #tracking-protection-icon-container {
                display: none !important;
              } */
              #home-button { display: none !important; }

              #urlbar-container {
                min-width: 175px !important;
              }

              #urlbar-background {
                animation: none !important;
              }

              #urlbar {
                background: transparent !important;
                border: none !important;
                box-shadow: none !important;
              }

              #page-action-buttons {
                display: none !important;
              }

              #PanelUI-button {
                display: none !important;
              }

              /* properly display url bar pop up (history, search suggestions,...) */

              :root{
                --toolbar-field-background-color: var(--toolbar-field-non-lwt-bgcolor);
                --toolbar-field-focus-background-color: var(--lwt-toolbar-field-focus,Field);
              }
              :root:-moz-lwtheme{
                --toolbar-field-background-color: var(--lwt-toolbar-field-background-color);
              }

              .urlbarView-row-inner{
                 /* This sets how far the dropdown-items are from the window edge */
                padding-inline-start: 6px !important;
              }

              #urlbar-container,
              #urlbar {
                position: static !important;
                display: -moz-box !important;
              }

              #urlbar {
                height: auto !important;
                width: auto !important;
                box-shadow: inset 0 0 0 1px var(--toolbar-field-border-color, hsla(240,5%,5%,.25));
                background-color: var(--toolbar-field-background-color, hsla(0,0%,100%,.8));
                border-radius: var(--toolbarbutton-border-radius);
                --uc-urlbar-min-width: none; /* navbar_tabs_oneliner.css compatibility */
              }

              #urlbar[focused] {
                box-shadow: inset 0 0 0 1px var(--toolbar-field-focus-border-color, highlight);
              }

              .urlbarView {
                position: absolute !important;
                margin: 0 !important;
                left: 0 !important;
                width: 40vw !important; /* width of the urlbar pop up; set to 100vw to make it as wide as the browser window */
                border-width: 1px 0;
                top: calc(var(--urlbar-toolbar-height) + 1px); /* symmetry */
                background-color: var(--toolbar-field-focus-background-color, inherit);
                z-index: 4;
                box-shadow: 0 1px 4px rgba(0,0,0,.05);
              }

              #urlbar > #urlbar-input-container {
                padding: 0px !important;
                width: auto !important;
                height: auto !important;
              }

              #urlbar > #urlbar-background {
                display: none !important;
              }

              /* This may seem pretty weird, but it gets around an issue where the height of urlbar may suddenly change when one starts typing into it */
              /* If you are otherwise modifying the urlbar height then you might need to modify the height of this too */
              #urlbar > #urlbar-input-container::before {
                content: "";
                display: -moz-box;
                height: 24px;
              }
            '';
            settings = {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.compactmode.show" = true;

              # Mullvad privacy settings 
              "privacy.resistFingerprinting" = true;
              "privacy.resistFingerprinting.block_mozAddonManager" = true;
              "privacy.resistFingerprinting.letterboxing" = true;

              # Other privacy settings 
              "network.http.referer.spoofSource" = true;
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
            pull.rebase = true;
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
            help.autocorrect = 50;
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

      home.file.".config/ca_eduroam.pem".text =
        builtins.readFile ./ca_eduroam.pem;
      gtk = {
        enable = true;
        theme.package = pkgs.qogir-theme;
        theme.name = "Qogir-Dark";
        iconTheme.package = pkgs.qogir-icon-theme;
        iconTheme.name = "Qogir-dark";
        cursorTheme.package = pkgs.nordzy-cursor-theme;
        cursorTheme.name = "Nordzy-cursors";
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
        platformTheme.name = "kde";
        style.package = pkgs.libsForQt5.breeze-qt5;
        style.name = "Breeze";
      };
    };
  };
}
