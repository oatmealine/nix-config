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
  # disables Nixpkgs Hyprland module to avoid conflicts
  #disabledModules = [ "programs/hyprland.nix" ];
  
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      (mkAliasOptionModule ["hm"] ["home-manager" "users" config.user.name])
  	  inputs.nix-colors.homeManagerModules.default
      #inputs.hyprland.nixosModules.default
      #inputs.lix-module.nixosModules.default
    ]
    ++ (mapModulesRec' (toString ./modules) import);

  hm.imports = [
    inputs.nix-index-database.homeModules.nix-index
    #inputs.hyprland.homeManagerModules.default
    inputs.vicinae.homeManagerModules.default
  ];

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
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
      substituters = [
        "https://nix-community.cachix.org"
        #"https://nixpkgs-wayland.cachix.org"
        "https://hyprland.cachix.org"
        #"https://cache.lix.systems"
        #"https://oatmealine.cachix.org
        "https://vicinae.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        #"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        #"cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        #"oatmealine.cachix.org-1:Ee3e/VVuXZgcF3u8UxMoK9EVhRtwadNU8MxN3+61Ds0="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      ];
    };
  };

  system = {
    stateVersion = "23.11";
    configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  };
  hm.home.stateVersion = config.system.stateVersion;
  # Mods, release the spores into his body. thank you
  hm.home.enableNixpkgsReleaseCheck = false;

  boot = {
    kernelPackages = mkDefault pkgs.unstable.linuxPackages_latest;
    kernelParams = ["pcie_aspm.policy=performance"];
    
    # last cheched with https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamos-customizations-jupiter-20240219.1-2-any.pkg.tar.zst
    kernel.sysctl = {
      # 20-shed.conf
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      # 20-net-timeout.conf
      # This is required due to some games being unable to reuse their TCP ports
      # if they're killed and restarted quickly - the default timeout is too large.
      "net.ipv4.tcp_fin_timeout" = 5;
      # 30-vm.conf
      # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
      # see comment in include/linux/mm.h in the kernel tree.
      "vm.max_map_count" = 2147483642;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "workman";
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
    # fun fact! when using flakes not having
    # git available as a global package while operating
    # on a git repository makes nixos-rebuild break,
    # rendering your system unable to rebuild.
    # nix is really cool
    git  
  ];

  documentation.nixos.enable = false;
}
