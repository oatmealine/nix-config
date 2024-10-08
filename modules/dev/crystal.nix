{ system, inputs, config, pkgs, lib, ... }:
with lib;
let 
  cfg = config.modules.dev.crystal;
  crpkgs = inputs.crystal-flake.packages.${system};
in {
  options.modules.dev.crystal = {
    enable = mkEnableOption "Enable Crystal's development module, a Ruby-like compiled language";
  };
  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      shards
      ameba
      crystalline
    ] ++ (with crpkgs; [
      crystal
    ]);

    /*hm.programs.vscode.extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [ {
      name = "crystal-lang";
      publisher = "crystal-lang-tools";
      version = "0.8.4";
      sha256 = "sha256-hU6g4CqcCxXlhqSKL36vgzX2EJ7fIdbIuPCHbpRW/zE=";
    } ];*/

    /*hm.programs.vscode.userSettings = {
      "crystal-lang.completion" = true;
      "crystal-lang.hover" = true;
      "crystal-lang.implementations" = true;

      "crystal-lang.server" = getExe pkgs.crystalline;
      "crystal-lang.compiler" = getExe crpkgs.crystal;
      "crystal-lang.shards" = getExe pkgs.shards;
    };*/
  };
}