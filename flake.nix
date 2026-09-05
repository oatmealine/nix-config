{
  description = "pornussy";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";

    catppuccin-vsc.url = "github:catppuccin/vscode/catppuccin-vsc-v3.14.0";

    crystal-flake.url = "github:manveru/crystal-flake";
    
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprlock.url = "github:hyprwm/hyprlock";
    hypridle.url = "github:hyprwm/hypridle";
    #hyprpaper.url = "github:hyprwm/hyprpaper";

    niri.url = "github:sodiboo/niri-flake/very-refactor";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    niri-pkgs.url = "github:sodiboo/niri-flake";
    niri-pkgs.inputs.nixpkgs.follows = "nixpkgs";

    waybar-catppuccin.url = "github:catppuccin/waybar";
    waybar-catppuccin.flake = false;
    hyprland-catppuccin.url = "github:catppuccin/hyprland";
    hyprland-catppuccin.flake = false;
    fuzzel-catppuccin.url = "github:catppuccin/fuzzel";
    fuzzel-catppuccin.flake = false;

    mdrop.url = "github:frahz/mdrop/7b2eb5c385ec3e1dc3b1d48b1e75137b8a4e125b";
    mdrop.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nix-index-database.follows = "nix-index-database";

    stackpkgs.url = "git+https://code.thishorsie.rocks/ryze/stackpkgs";

    millennium.url = "github:Trivaris/Millennium?dir=packages/nix";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    vicinae.url = "github:vicinaehq/vicinae";

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    system76-scheduler-niri.url = "github:Kirottu/system76-scheduler-niri";
    system76-scheduler-niri.inputs.nixpkgs.follows = "nixpkgs";

    pond.url = "gitlab:Morgenkaff/flake-for-pond";
    pond.inputs.nixpkgs.follows = "nixpkgs";
    
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    ryubing.url = "github:h4rldev/ryubing-flake";
    ryubing.inputs.nixpkgs.follows = "nixpkgs";

    # https://github.com/NixOS/nixpkgs/pull/542467
    vivaldi.url = "github:wineee/nixpkgs/vivaldi";

    bitwig.url = "nixpkgs/655e3354167d63919a7f376897aa762d45d595e9";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: let
    inherit (lib.my) mapModules mapModulesRec mapHosts;
    system = "x86_64-linux";

    mkPkgs = pkgs: extraOverlays:
      import pkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowAliases = false;
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
    pkgs = mkPkgs nixpkgs [
      self.overlays.default
      inputs.catppuccin-vsc.overlays.default
      inputs.nix-cachyos-kernel.overlays.pinned
      inputs.fenix.overlays.default
    ];
    pkgs-unstable = mkPkgs nixpkgs-unstable [];

    lib = nixpkgs.lib.extend (final: prev: {
      my = import ./lib {
        inherit pkgs inputs;
        lib = final;
      };
    });
  in rec {
    lib = lib.my;

    overlays =
      (mapModules ./overlays import)
      // {
        default = final: prev: {
          unstable = pkgs-unstable;
          my = self.packages.${system};
        };
      };

    packages."${system}" = mapModules ./packages (p: pkgs.callPackage p { });

    nixosModules = mapModulesRec ./modules import;

    nixosConfigurations = mapHosts ./hosts {};
  };
}
