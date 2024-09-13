{
  description = "";

  inputs = {
    # System
    nixpkgs.follows = "stable";

    # Extra channels
    stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # Private common modules
    common.url = "../common";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    argon-eon.url = "git+ssh://git@github.com/simonkampe/argon-eon";
    rpi-pwm-fan.url = "github:simonkampe/raspberry-pi-pwm-fan-2/nixify";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    common,
    nixos-hardware,
    disko,
    argon-eon,
    rpi-pwm-fan,
    ...
  }:
  {
    overlays = [
      (final: prev: {
        stable = import inputs.stable {
          system = final.system;
          config.allowUnfree = true;
        };

        unstable = import inputs.unstable {
          system = final.system;
          config.allowUnfree = true;
        };

        master = import inputs.master {
          system = final.system;
          config.allowUnfree = true;
        };

        raspberry-pi-pwm-fan2 = rpi-pwm-fan.packages.${final.system}.raspberry-pi-pwm-fan-2;
        argon = argon-eon.packages.${final.system}.argon-eon;
      })
    ];

    defaultPackage."x86_64-linux" = self.nixosConfigurations.zeus.config.system.build.sdImage;

    nixosConfigurations = {
      zeus = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        pkgs = (import nixpkgs) {
          system = "aarch64-linux";

          config = {
            allowUnfree = true;
          };

          overlays = self.overlays;
        } // { outPath = nixpkgs.outPath; };
        
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4

          ./host.nix
          ./rpi4.nix
          ./sd-image.nix

          #common.nixosModules.hardware.argoneon

          common.nixosModules.configuration.common

          common.nixosModules.services.home-assistant
          #common.nixosModules.services.pihole
          common.nixosModules.services.clamav
          common.nixosModules.services.avahi

          ({ pkgs, ... }:
          {
            # Enable PWM for pwm-fan
            hardware.raspberry-pi."4".pwm0.enable = true;

            #services.argoneon = {
            #  enable = true;
            #  package = pkgs.argon;
            #  withFanControl = false;
            #  withOledDisplay = true;
            #  withPowerButton = true;
            #};
          
            services.tailscale.enable = true;

            services.jellyfin = {
              enable = true;
              openFirewall = true;
            };

            #systemd.services."rpi-pwm-fan" = {
            #  wantedBy = [ "multi-user.target" ];
            #  after = [ "sysinit.target" ];

            #  environment = {
            #    PWM_FAN_BCM_GPIO_PIN_PWM = "18";
            #    PWM_FAN_PWM_FREQ_HZ = "2500";
            #    PWM_FAN_MIN_DUTY_CYCLE = "20";
            #    PWM_FAN_MAX_DUTY_CYCLE = "100";
            #    PWM_FAN_MIN_OFF_TEMP_C = "38";
            #    PWM_FAN_MIN_ON_TEMP_C = "40";
            #    PWM_FAN_MAX_TEMP_C = "46";
            #    PWM_FAN_FAN_OFF_GRACE_MS = "60000";
            #    PWM_FAN_SLEEP_MS = "250";
            #  };

            #  serviceConfig = {
            #    ExecStart = "${pkgs.raspberry-pi-pwm-fan2}/bin/raspberry-pi-pwm-fan2";
            #    Restart = "always";
            #    Type = "simple";
            #  };
            #};
            
            environment.systemPackages = with pkgs; [
              jellyfin
              jellyfin-web
              jellyfin-ffmpeg

              raspberry-pi-pwm-fan2
            ];
          })
        ];
      };
    };
  };
}
