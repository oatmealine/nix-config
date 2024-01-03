{
  #security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [
      { users = [ "oatmealine" ]; noPass = true; persist = false; keepEnv = true; }
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}