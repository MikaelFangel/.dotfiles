{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./network-configuration.nix
      ./power-configuration.nix
      ./specilisations.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Remove unwanted programs
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    konsole
  ];

  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "eu";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define who can access the Nix package manager
  nix.settings.allowed-users = [ "@wheel" ];

  # Auto optimise system
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "-d";
  };

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;

  # List packages installed in system profile. 
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-curses
    nftables
    kitty
    i7z

    # Programming languages
    go
    jdk

    # Used for fixing broken binaries
    patchelf
  ];

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

  # Fine to be left as is. Don't change if you haven't read documentation fist.
  system.stateVersion = "22.11"; # Did you read the comment?

}
