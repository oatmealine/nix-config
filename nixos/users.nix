{ pkgs, ... }:

{
  users.users.oatmealine = {
    isNormalUser = true;
    description = "jill";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.users.root = {
    packages = [ pkgs.shadow ];
    shell = pkgs.shadow;
    hashedPassword = "!";
  };
}