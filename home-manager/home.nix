{ inputs, outputs, pkgs, lib, config, ... }:

{
  imports = [
  	inputs.nix-colors.homeManagerModules.default
    outputs.homeManagerModules.alacritty
    outputs.homeManagerModules.opinions
    outputs.homeManagerModules.gtkConfig
    outputs.homeManagerModules.shellColors
    outputs.homeManagerModules.microColors
    outputs.homeManagerModules.gnomeBindings
    outputs.homeManagerModules.disableNews
  ];

  home.username = "oatmealine";
  home.homeDirectory = "/home/oatmealine";
  
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.unstable-packages
    inputs.catppuccin-vsc.overlays.default
  ];

  nixpkgs.config.allowUnfree = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; let
    discord = unstable.discord-canary.override {
      withOpenASAR = true;
      withVencord = true;	
    };
  in [
    # archives
    zip xz unzip p7zip
    # utils
    ripgrep jq
    # nix
    nix-output-monitor
    # dev
    sqlitebrowser sqlite-interactive
    # system
    btop sysstat lm_sensors ethtool pciutils usbutils powertop killall
    # debug
    strace ltrace lsof
    # apps
    vivaldi telegram-desktop onlyoffice-bin gnome.gnome-tweaks discord mpv
    # compatilibility
    wine
    # misc
    cowsay file which tree gnused grc
    # um
    doas-sudo-shim gnome.dconf-editor rbw
  ];

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;

  opinions = {
    fonts = {
      regular = {
        package = pkgs.atkinson-hyperlegible;
        family = "Atkinson Hyperlegible";
        size = 11;
      };
      monospace = {
        package = pkgs.cozette;
        family = "CozetteVector";
        size = 10;
      };
      monospaceBitmap = {
        package = pkgs.cozette;
        family = "Cozette";
        size = 10;
      };
    };

    lowercaseXdgDirs = true;
  };

  programs.git = {
    enable = true;
    userName = ''Jill "oatmealine" Monoids'';
    userEmail = "oatmealine@disroot.org";

    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  alacritty.enable = true;
  
  gtkConfig = {
    enable = true;
    preferDark = true;
    cursor = {
      package = pkgs.graphite-cursors;
      name = "graphite-dark";
    };
    icon = {
      package = pkgs.papirus-nord;
      name = "Papirus-Dark";
    };
  };

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

  shellColors.enable = true;
  programs.fish.enable = true;
  programs.fish.plugins = [ { name = "grc"; src = pkgs.fishPlugins.grc.src; } ];
  
  programs.micro = {
    enable = true;
    settings = {
      autosu = true;
      clipboard = "terminal";
      colorscheme = "generated";
      savecursor = true;
      scrollbar = true;
      tabsize = 2;
      tabstospaces = true;
    };
  };
  microColors.enable = true;

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  gnomeBindings.enable = true;
  gnomeBindings.shell = {
    # disable defaults
    "screenshot" = [];
    "screenshot-window" = [];
    "show-screenshot-ui" = [];
  };
  gnomeBindings.wm = {
    #"panel-run-dialog" = [ "Launch1" ];
  };
  gnomeBindings.custom = {
    "take-screenshot" = {
      binding = "Print";
      command = "${lib.getExe pkgs.flameshot} gui";
    };
    "take-screen-recording" = {
      binding = "<Shift>Print";
      command = "${lib.getExe pkgs.peek}";
    };
    "grab-password" = let
      grabScript = pkgs.writeScript "grab-password" ''
        ${lib.getExe pkgs.rbw} get $(${lib.getExe pkgs.gnome.zenity} --entry --text="" --title="") | ${lib.getExe pkgs.xclip} -selection clipboard
      '';
    in {
      binding = "Launch1";
      command = ''${grabScript}'';
    };
  };
  # usually you don't need to do this, but this is a workaround for https://github.com/flameshot-org/flameshot/issues/3328
  services.flameshot.enable = true;

  programs.rbw = {
    enable = true;
    settings.base_url = "https://bitwarden.lavatech.top";
    settings.email = "oatmealine@disroot.org";
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
