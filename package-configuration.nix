{ config, pkgs, inputs, nur, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Remove unwanted programs
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    konsole
  ];

  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable programs system wide
  virtualisation.libvirtd.enable = true;
  programs = {
    dconf.enable = true;

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
       pinentryFlavor="curses";
    };

    # Set the system default shell
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # List packages installed in system profile. 
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-curses
    nftables
    kitty

    # Utilities
    zip
    unzip
    virt-manager
    openrazer-daemon
    polychromatic
    wineWowPackages.full
    spice-vdagent

    # Security
    vulnix

    # Programming languages
    go
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.wazuh = {};
  users.users.mikael = {
    isNormalUser = true;
    description = "mikael";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "openrazer" "wireshark" ];
    packages = with pkgs; [
      config.nur.repos.mikaelfangel-nur.rmosxf
      config.nur.repos.mikaelfangel-nur.gitpolite
      config.nur.repos.mikaelfangel-nur.spacedrive
      config.nur.repos.mikaelfangel-nur.battery-wallpaper
      config.nur.repos.mikaelfangel-nur.quiet
      config.nur.repos.mikaelfangel-nur.clx

      firefox
      ungoogled-chromium # Used for MS Teams
      thunderbird
      protonmail-bridge
      git
      gh # GitHub client
      signal-desktop
      element-desktop
      jetbrains.idea-community
      jetbrains.goland
      android-studio
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
	  ms-dotnettools.csharp # Ionide dependency
	  ionide.ionide-fsharp
	  asvetliakov.vscode-neovim

	  dracula-theme.theme-dracula
	  mkhl.direnv
	];
      })
      nextcloud-client
      libreoffice-fresh
      nerdfonts
      ripgrep # telescope depend
      ugrep
      wireshark
    ];
  };

  # home-manager setup 
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.mikael = {pkgs, ... }: {
    home.stateVersion = "23.05";
    programs = {
      zsh = {
        enable = true;
        autocd = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          icat="kitty +kitten icat";
          clip="kitty +kitten clipboard";
          ls="ls --color=auto";
          ip="ip -c";
	  nixvim="nix run github:mikaelfangel/nixvim-config";
	  clx="clx -n";
	  uq="ug -Q";
	  ux="ug -UX";
	  uz="ug -z";
	  ugit="ug -R --ignore-files";
	  grep="ugrep -G";
	  egrep="ugrep -E";
	  fgrep="ugrep -F";
	  pgrep="upgrep -P";
	  xgrep="ugrep -W";
          zgrep="ugrep -zG";
          zegrep="ugrep -zE";
          zfgrep="ugrep -zF";
          zpgrep="ugrep -zP";
          zxgrep="ugrep -zW";
        };
        history = {
          size = 10000;
        };
        initExtra = ''
           autoload -U colors && colors
           export PATH="$PATH:$(go env GOPATH)/bin"
        '';
      };
      kitty = {
        enable = true;
        theme = "Monokai Soda";
        settings = {
          background_opacity = "0.90";
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
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
    
    home.file = {
      ".gitconfig".text = ''
           [pull]
            rebase = false
        '';

      ".config/ca_eduroam.pem".text = builtins.readFile ./ca_eduroam.pem; 
    };
  };
}
