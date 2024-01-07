{ pkgs, config, ... }:
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      sumneko.lua
      ms-vsliveshare.vsliveshare
      (catppuccin.catppuccin-vsc.override {
        accent = "pink";
        boldKeywords = false;
        italicComments = false;
        italicKeywords = false;
        extraBordersEnabled = false;
        workbenchMode = "flat";
        #bracketMode = "rainbow";
      })
    ];
    mutableExtensionsDir = false;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    userSettings = with config.opinions.font; {
      "telemetry.enableTelemetry" = false;

      "editor.tabSize" = 2;
      "editor.cursorSmoothCaretAnimation" = "on";

      "editor.fontFamily" = "'${monospace.family}', monospace";
      "editor.fontSize" = monospace.size;

      "terminal.integrated.fontFamily" = "\"${monospace.family}\"";
      "terminal.integrated.fontSize" = monospace.size;

      "window.dialogStyle" = "custom";
      "window.titleBarStyle" = "custom";

      "workbench.tips.enabled" = false;
      "workbench.colorTheme" = "Catppuccin Mocha";

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
    };
  };

  programs.micro = {
    enable = true;
    settings = {
      autosu = true;
      clipboard = "terminal";
      savecursor = true;
      scrollbar = true;
      tabsize = 2;
      tabstospaces = true;
    };
  };
  microColors.enable = true;
}