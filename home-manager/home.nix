{ inputs, outputs, config, pkgs, ... }:

let
  nix-colors-lib = inputs.nix-colors.lib.contrib { inherit pkgs; };
in {
  imports = [
  	inputs.nix-colors.homeManagerModules.default
    outputs.homeManagerModules.alacritty
    outputs.homeManagerModules.opinions
    outputs.homeManagerModules.gtkConfig
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "oatmealine";
  home.homeDirectory = "/home/oatmealine";

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
  };

  dconf = {
    enable = true;
    #settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    nil

    # misc
    cowsay
    file
    which
    tree
    gnused
    grc

    nix-output-monitor

    btop  # replacement of htop/nmon

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    powertop

    vivaldi
    (discord.override {
      withOpenASAR = true;
      withVencord = true;	
    })
    telegram-desktop

    doas-sudo-shim

    gnome.gnome-tweaks

    onlyoffice-bin
  ];

  alacritty.enable = true;
  
  gtkConfig = {
    enable = true;
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
      bbenoist.nix
    ];
  };

  programs.fish = let
    colorScript = nix-colors-lib.shellThemeFromScheme { scheme = config.colorScheme; };
  in {
    enable = true;
  	interactiveShellInit = ''
      sh ${colorScript}
  	'';
    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      #{ name = "tide"; src = pkgs.fishPlugins.tide.src; }
    ];
  };

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
  home.file."micro-generated-colorscheme" = {
    enable = true;
    target = ".config/micro/colorschemes/generated.micro";
    text = with config.colorScheme.colors; ''
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

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "Print";
      command = "${pkgs.lib.getExe pkgs.flameshot} gui";
      name = "take-screenshot";
    };
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
