{
  description = "";

  outputs = _: {
    nixosModules = {
      applications = {
        dev = {
          vmware-workstation = import ./modules/applications/dev/vmware-workstation.nix;
          vscodium = import ./modules/applications/dev/vscodium.nix;
        };

        gaming = {
          steam = import ./modules/applications/gaming/steam.nix;
        };

        hardware = {
          uhk = import ./modules/applications/hardware/uhk.nix;
        };
      };

      hardware = {
        argoneon = import ./modules/hardware/argoneon;
      };

      configuration = {
        cross-aarch64-linux = import ./modules/configuration/cross-aarch64-linux.nix;
        common = import ./modules/configuration/common.nix;
      };
      
      desktop = {
        kde = import ./modules/desktop/kde.nix;
      };

      services = {
        avahi = import ./modules/services/avahi.nix;
        clamav = import ./modules/services/clamav.nix;
        globalprotect = import ./modules/services/globalprotect.nix;
        gpg-agent = import ./modules/services/gpg-agent.nix;
        home-assistant = import ./modules/services/home-assistant.nix;
        printing = import ./modules/services/printing.nix;
        pihole = import ./modules/services/pihole.nix;
      };
    };

    packages.x86_64-linux = {};

    packages.aarch64-linux = {
      argon-eon = import ./packages/argoneon;
    };
  };
}
