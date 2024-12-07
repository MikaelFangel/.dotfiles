{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
      ethernet.macAddress = "random";
    };

    # Firewall settings
    firewall = {
      enable = true;
      allowPing = false;
    };
  };
}
