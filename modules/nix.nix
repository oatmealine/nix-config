{ lib, pkgs, inputs, config, system, ... }:
let
  nixpkgs = inputs.nixpkgs;
in {
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    inputs.nix-alien.packages.${system}.nix-alien
  ];

  /*
  nix.registry.nixpkgs = {
    from = {
      id = "nixpkgs";
      type = "indirect";
    };
    to = lib.mkForce {
      path = "${nixpkgs}";
      type = "path";
    };
  };
  */

  nix.registry = let
    flakes = lib.filterAttrs (name: value: value ? outputs) inputs;
  in builtins.mapAttrs
    (name: v: { flake = v; })
    flakes;

  systemd.tmpfiles.rules = [
    "d   /root/.nix-defexpr        0755  root  root  -  -"
    "L+  /root/.nix-defexpr/nixos     -     -        -  -  ${nixpkgs}"
    "L+  /root/.nix-defexpr/nixpkgs   -     -        -  -  ${nixpkgs}"
  ];

  environment.etc = (lib.mapAttrs'
    (name: value: { name = "nix/inputs/${name}"; value = { source = value.outPath; }; })
    inputs);

  nix.nixPath = [ "/etc/nix/inputs" ];

  environment.extraInit = ''
    export NIX_PATH="nixpkgs=${nixpkgs}"
  '';

  programs.command-not-found.enable = false;
  /*programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };*/
  hm.programs.nix-index.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}