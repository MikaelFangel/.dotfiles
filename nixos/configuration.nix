{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Specilisations
  specialisation = {
    nvidia.configuration = {
      # Nvidia Configuration
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.opengl.enable = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

      # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
      hardware.nvidia.modesetting.enable = true;

      hardware.nvidia.prime = {
        sync.enable = true;

        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = "PCI:1:0:0";

        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = "PCI:0:2:0";
      };

      # Fix for screen tearing
      hardware.nvidia.forceFullCompositionPipeline = true; 
    };
  };


  # Thermal control
  services.thermald.enable = true; 

  # Power management
  powerManagement.enable = true;
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  boot.blacklistedKernelModules = [
    "nouveau"
  ];
  services.upower.enable = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

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
      nextcloud-client
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;

  # List packages installed in system profile. 
  environment.systemPackages = with pkgs; [
    vim 
    gnupg
    pinentry-curses
    nftables
    kitty

    # Programming languages
    go
    jdk
    protobuf

    # Used for fixing broken binaries
    patchelf
  ];

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

  # Firewall settings
  networking.firewall = {
    enable = true;
  };

  # Fine to be left as is. Don't change if you haven't read documentation fist.
  system.stateVersion = "22.11"; # Did you read the comment?

}
