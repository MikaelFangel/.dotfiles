{ config, pkgs, ... }:

{
  imports = 
  [
    ./wireguard-configuration.nix
  ];

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
      allowedUDPPorts = [ 51820 ]; # Wireguard
    };
  };
}
