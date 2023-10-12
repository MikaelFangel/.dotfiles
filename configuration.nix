{ config, lib, pkgs, inputs, nur, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./network-configuration.nix
      ./power-configuration.nix
      ./specilisations.nix
      ./package-configuration.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
    tmp.useTmpfs = true;
  };

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

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Enable the KDE Plasma Desktop Environment.
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;

      # Configure keymap in X11
      layout = "eu";
      xkbVariant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
    
    # Enable tocuhpad gestures
    touchegg.enable = true;

    # Periodically trim the sdd
    fstrim.enable = true;
  };

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

  nix = { 
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
    
    settings = { 
      experimental-features = [ "nix-command" "flakes" ];

      # Define who can access the Nix package manager
      allowed-users = [ "@wheel" ];

      # Auto optimise storage used by the system
      auto-optimise-store = true;
    }; 

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "-d";
    };
  };

  # Auto upgrade the system
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [ 
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
      "-L"
    ]; 
    persistent = true;
    dates = "daily";
  };

  # Fine to be left as is. Don't change if you haven't read documentation fist.
  system.stateVersion = "22.11"; # Did you read the comment?
}
