{
  description = "λ simple and configureable Nix-Flake repository!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";

    catppuccin-vsc.url = "github:catppuccin/vscode/catppuccin-vsc-v3.14.0";

    crystal-flake.url = "github:manveru/crystal-flake";
    
    waybar.url = "github:Alexays/Waybar";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprlock.url = "github:hyprwm/hyprlock";
    hypridle.url = "github:hyprwm/hypridle";
    hyprpaper.url = "github:hyprwm/hyprpaper";

    waybar-catppuccin.url = "github:catppuccin/waybar";
    waybar-catppuccin.flake = false;
    hyprland-catppuccin.url = "github:catppuccin/hyprland";
    hyprland-catppuccin.flake = false;
    fuzzel-catppuccin.url = "github:catppuccin/fuzzel";
    fuzzel-catppuccin.flake = false;

    lix = {
      url = "git+https://git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    pkgs = mkPkgs nixpkgs [ self.overlays.default inputs.catppuccin-vsc.overlays.default ];
    pkgs-unstable = mkPkgs nixpkgs-unstable [];

    lib = nixpkgs.lib.extend (final: prev: {
      my = import ./lib {
        inherit pkgs inputs;
        lib = final;
      };
    });
  in {
    lib = lib.my;

    overlays =
      (mapModules ./overlays import)
      // {
        default = final: prev: {
          unstable = pkgs-unstable;
          my = self.packages.${system};
        };
      };

    packages."${system}" = mapModules ./packages (p: pkgs.callPackage p {});

    nixosModules = mapModulesRec ./modules import;

    nixosConfigurations = mapHosts ./hosts {};
  };
}
