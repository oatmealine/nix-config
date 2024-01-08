{ ... }:
{
  /*
  networking.firewall.checkReversePath = false; 
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.6/32" ];
    privateKeyFile = "/home/oatmealine/wireguard-keys/private";

    listenPort = 51820;

    peers = [
      {
        publicKey = "fOb9kJS1992n5dHu0YvzEMEHkSdc1tDzfRFILQLj6W8=";
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "46.4.96.113:51820";
        # ensure connection is stable under NATs
        persistentKeepalive = 25;
      }
    ];
  };
  */
}