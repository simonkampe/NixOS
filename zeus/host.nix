{ pkgs, lib, config, inputs, ... }:
{
  system.stateVersion = "23.11";

  programs.fish.enable = true;

 
  networking = {
    hostName = "zeus";
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  services.sshd.enable = true;

  powerManagement.cpuFreqGovernor = "powersave";

  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
  ];

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/3ba6e17c-1b93-4a33-b62c-1b99b8c93c5b";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8181c435-a004-4ed6-81e8-885af0dc3e83";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/d232e278-f2d2-4a97-853a-595480b22bfa"; }
  ];

  boot.swraid.enable = true;

  nix.settings.trusted-users = [ "root" "@wheel" ];
  
  users.users.simon = {
    description = "Simon Kämpe";
    isNormalUser = true;
    home = "/home/simon";
    extraGroups = [ "wheel" "networkmanager" "samba" ];
    initialPassword = "changethis";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmuPGHvJG8J9fQJUOc2tbctKHrIOty3S2bDgfwiJ8qi" ];
  };

  users.users.petra = {
    isNormalUser = true;
    home = "/home/simon";
    description = "Petra Kämpe Schröder";
    extraGroups = [ "samba" ];
  };

  users.users.samba = {
    isSystemUser = true;
    group = "samba";
    description = "Samba user";
  };

  users.groups.samba = {};

  services.samba-wsdd = {
    # make shares visible for Windows clients
    enable = true;
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = Samba %v on %L
      netbios name = ZEUS
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 10.10.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      Share = {
        path = "/data/Share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "samba";
        "force group" = "samba";
      };
    };
  };
}

