{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.editors.micro;
  canUseOSC52 = config.modules.software.system.alacritty.enable;
in {
  options.modules.software.editors.micro = {
    enable = mkEnableOption "Enable micro, the simple command-line code editor";
  };

  config = let
    schemeName = "generated";
  in mkIf cfg.enable {
    environment.variables.EDITOR = "micro";

    hm.home.packages = mkIf (!canUseOSC52) (with pkgs; [
      (if (config.modules.desktop.envProto == "x11") then xclip else wl-clipboard-x11)
    ]);

    hm.programs.micro = {
      enable = true;
      settings = {
        autosu = true;
        clipboard = if canUseOSC52 then "terminal" else "external";
        savecursor = true;
        scrollbar = true;
        tabsize = 2;
        tabstospaces = true;

        colorScheme = schemeName;
      };
    };

    hm.home.file.".config/micro/colorschemes/${schemeName}.micro".text = with config.colorScheme.colors; ''
      color-link default "#${base05},#${base00}"
      color-link comment "#${base03},#${base00}"
      color-link identifier "#${base0D},#${base00}"
      color-link constant "#${base0E},#${base00}"
      color-link constant.string "#E6DB74,#${base00}"
      color-link constant.string.char "#BDE6AD,#${base00}"
      color-link statement "#${base08},#${base00}"
      color-link symbol.operator "#${base08},#${base00}"
      color-link preproc "#CB4B16,#${base00}"
      color-link type "#${base0D},#${base00}"
      color-link special "#${base0B},#${base00}"
      color-link underlined "#D33682,#${base00}"
      color-link error "bold #CB4B16,#${base00}"
      color-link todo "bold #D33682,#${base00}"
      color-link hlsearch "#${base00},#E6DB74"
      color-link statusline "#${base00},#${base05}"
      color-link tabbar "#${base00},#${base05}"
      color-link indent-char "#505050,#${base00}"
      color-link line-number "#AAAAAA,#${base01}"
      color-link current-line-number "#AAAAAA,#${base00}"
      color-link diff-added "#00AF00"
      color-link diff-modified "#FFAF00"
      color-link diff-deleted "#D70000"
      color-link gutter-error "#CB4B16,#${base00}"
      color-link gutter-warning "#E6DB74,#${base00}"
      color-link cursor-line "#${base01}"
      color-link color-column "#${base01}"
      #No extended types; Plain brackets.
      color-link type.extended "default"
      #color-link symbol.brackets "default"
      color-link symbol.tag "#${base0E},#${base00}"
    '';
  };
}
