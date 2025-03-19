{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Define your hostname.
    wireless.iwd.enable = true;

    # Firewall settings
    firewall = {
      enable = true;
      allowPing = false;
    };
  };
}
