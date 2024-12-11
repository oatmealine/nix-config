{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.modules.software.editors.vscode;
in {
  options.modules.software.editors.vscode = {
    enable = mkEnableOption "Enable VSCode, Microsoft's GUI code editor";
  };

  config = mkIf cfg.enable {
    hm.programs.vscode = {
      enable = true;
      #extensions = with pkgs.vscode-extensions; [
      #  jnoortheen.nix-ide
      #  sumneko.lua
      #  ms-vsliveshare.vsliveshare
      #  svelte.svelte-vscode
      #  editorconfig.editorconfig
      #] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ {
      #  name = "luxe";
      #  publisher = "luxeengine";
      #  version = "0.0.64";
      #  sha256 = "sha256-yA8b/N7Ka0Vt154kKbLDZxdjuDffuFV916xxgxfkfsQ=";
      #} ];
      #mutableExtensionsDir = false;
      #enableExtensionUpdateCheck = false;
      #enableUpdateCheck = false;
      /*userSettings = with config.modules.desktop.fonts.fonts; {
        "editor.fontFamily" = "'${monospace.family}', monospace";
        "editor.fontSize" = monospace.size + 3; # no clue why i have to do this

        "terminal.integrated.fontFamily" = "\"${monospace.family}\"";
        "terminal.integrated.fontSize" = monospace.size + 3;

        "telemetry.enableTelemetry" = false;

        "editor.tabSize" = 2;
        "editor.cursorSmoothCaretAnimation" = "on";

        "window.dialogStyle" = "custom";
        "window.titleBarStyle" = "custom";

        "workbench.tips.enabled" = false;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${lib.getExe pkgs.nil}";

        "security.workspace.trust.untrustedFiles" = "open";

        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;

        "editor.bracketPairColorization.enabled" = false;
        "editor.smoothScrolling" = true;
        "editor.wordWrap" = "on";
        "editor.wrappingStrategy" = "advanced";
        "editor.fontWeight" = "normal";
        "editor.semanticHighlighting.enabled" = true;

        # prevent VSCode from modifying the terminal colors
        "terminal.integrated.minimumContrastRatio" = 1;

        "Lua.workspace.ignoreDir" = [ ".vscode" ".direnv" ];
      };*/
    };
  };
}
