{ lib, pkgs, inputs, config, system, ... }:
let
  nixpkgs = inputs.nixpkgs;
in {
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    inputs.nix-alien.packages.${system}.nix-alien
  ];

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

  systemd.tmpfiles.rules = [
    "d   /root/.nix-defexpr        0755  root  root  -  -"
    "L+  /root/.nix-defexpr/nixos     -     -        -  -  ${nixpkgs}"
    "L+  /root/.nix-defexpr/nixpkgs   -     -        -  -  ${nixpkgs}"
  ];

  # Provide compatibility layer for non-flake utils
  environment.etc."nixos/compat/default.nix".text = ''
    { ... }:

    let
      nixpkgs = import ${nixpkgs} {};
    in
    nixpkgs
  '';

  environment.etc."nixos/compat/nixos/default.nix".text = ''
    { ... }:

    let
      current = import ${inputs.self};
    in
    current.nixosConfigurations."${config.networking.hostName}"
  '';

  environment.etc."nixos/configuration.nix".text = ''
    nix = {
      nixPath = [ "nixpkgs=${nixpkgs}" ];
    };

    system.name = "${config.networking.hostName}";
    system.stateVersion = "${config.system.stateVersion}";
  '';

  environment.etc."nixos/current".source = inputs.self;
  environment.etc."nixos/nixpkgs".source = nixpkgs;
  environment.etc."nixos/options.json".source =
    if config.documentation.nixos.enable
    then "${config.system.build.manual.optionsJSON}/share/doc/nixos/options.json"
    else
      pkgs.writeTextFile {
        name = "options.json";
        text = "{}";
      };

  environment.etc."nixos/system-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sorted = builtins.sort (a: b: lib.toLower a < lib.toLower b) (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sorted;
    in
    formatted;

  environment.extraInit = ''
    export NIX_PATH="nixpkgs=${nixpkgs}"
  '';

  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

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