{ config, pkgs, inputs, ... }:
let
   rmosxf = pkgs.callPackage ./custom-pkgs/rmosxf/default.nix {};
   gitpolite = pkgs.callPackage ./custom-pkgs/gitpolite/default.nix {};
in
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
  programs.dconf.enable = true;

  programs.steam.enable = true;
  programs.wireshark.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor="curses";
  };

  # Set the system default shell
  programs.zsh.enable = true;
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
    jdk
    # dotnet-sdk
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikael = {
    isNormalUser = true;
    description = "mikael";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "openrazer" "wireshark"];
    packages = with pkgs; [
      rmosxf
      gitpolite

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

	  dracula-theme.theme-dracula
	  mkhl.direnv
	];
      })
      nextcloud-client
      libreoffice-fresh
      nerdfonts # used by nvchad
      ripgrep
      wireshark
    ];
  };

  # home-manager setup 
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.mikael = {pkgs, ... }: {
    home.stateVersion = "23.05";
    programs.zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        icat="kitty +kitten icat";
        clip="kitty +kitten clipboard";
        ls="ls --color=auto";
        ip="ip -c";
      };
      history = {
        size = 10000;
      };
      initExtra = ''
         autoload -U colors && colors
         export PATH="$PATH:$(go env GOPATH)/bin"
      '';
    };
    
    # Virtmanager config
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
    programs.kitty = {
      enable = true;
      theme = "Monokai Soda";
      settings = {
        background_opacity = "0.90";
      };
    };
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    programs.git = {
      enable = true;
      userName = "Mikael Fangel";
      userEmail = "34864484+MikaelFangel@users.noreply.github.com";
      
      extraConfig = {
         commit.gpgsign = true; 
         user.signingkey = "306DE4426F0B77C3";
      };
    };
    home.file.".gitconfig" = {
      text = ''
         [pull]
	  rebase = false
      '';
    };
   home.file.".config/ca_eduroam.pem" = {
     text = builtins.readFile ./ca_eduroam.pem; 
   };

   # Nvchad config files
   home.file.".config/nvim/lua/custom/chadrc.lua".text = builtins.readFile ./nvchad/chadrc.lua;
   home.file.".config/nvim/lua/custom/configs/lspconfig.lua".text = builtins.readFile ./nvchad/lspconfig.lua;
   home.file.".config/nvim/lua/custom/configs/null-ls.lua".text = builtins.readFile ./nvchad/null-ls.lua;
   home.file.".config/nvim/lua/custom/configs/overrides.lua".text = builtins.readFile ./nvchad/overrides.lua;
  };
}
