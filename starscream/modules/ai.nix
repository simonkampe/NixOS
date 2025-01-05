{ config, pkgs, ... } :

{
  services = {
    # AI
    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    # Ollama GUI
    open-webui.enable = true;
  };

  boot.extraModulePackages = with pkgs; [
    intel-npu-driver
  ];

  hardware.firmware = with pkgs; [
    intel-npu-driver.firmware
  ];
}