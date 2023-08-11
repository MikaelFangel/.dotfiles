{ config, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];

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
  programs.steam.enable = true;

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

    # Programming languages
    go
    jdk
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikael = {
    isNormalUser = true;
    description = "mikael";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      git
      gh # GitHub client
      signal-desktop
      jetbrains.idea-community
      jetbrains.goland
      android-studio
      nextcloud-client
      libreoffice-fresh
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
    programs.kitty = {
      enable = true;
      theme = "Monokai Soda";
      settings = {
        background_opacity = "0.90";
      };
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
  };
}
