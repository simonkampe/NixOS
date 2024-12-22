{ config, ... } :

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
}