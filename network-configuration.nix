{ config, pkgs, ... }:

{
  imports = 
  [
    ./wireguard-configuration.nix
  ];

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.ethernet.macAddress = "random";
  networking.networkmanager.firewallBackend = "nftables";

  # Firewall settings
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ]; # Wireguard
  };
}