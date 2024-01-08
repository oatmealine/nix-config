{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) toString;
  inherit (lib.modules) mkAliasOptionModule mkDefault mkIf;
  inherit (lib.my) mapModulesRec';
in {
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
  	  inputs.nix-colors.homeManagerModules.default
      (mkAliasOptionModule ["hm"] ["home-manager" "users" config.user.name])
    ]
    ++ (mapModulesRec' (toString ./modules) import);

  # Common config for all nixos machines;
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  nix = {
    package = pkgs.nixVersions.stable;

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry.nixpkgs.flake = inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  system = {
    stateVersion = "23.11";
    configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  };
  hm.home.stateVersion = config.system.stateVersion;

  boot = {
    kernelPackages = mkDefault pkgs.unstable.linuxPackages_latest;
    kernelParams = ["pcie_aspm.policy=performance"];
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "workman";
  };
  console = {
    useXkbConfig = mkDefault true;
  };

  time.timeZone = mkDefault "Europe/Moscow";

  i18n.defaultLocale = mkDefault "en_GB.UTF-8";

  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    unrar unzip
  	micro
  	curl wget
    desktop-file-utils
    shared-mime-info
    xdg-user-dirs
    xdg-utils  
  ];
}
