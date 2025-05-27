{ pkgs, config, lib, ... }:

with lib;
let
  cfg = config.modules.software.dev.git;
in {
  options.modules.software.dev.git = {
    enable = mkEnableOption "Enable git. You know what git is";
  };

  config = mkIf cfg.enable {
    programs.ssh.askPassword = ""; # holy shit x11-ssh-askpass is UGLY
    hm.programs.git = {
      enable = true;
      package = pkgs.gitFull;

      userName = ''Jill "oatmealine" Monoids'';
      userEmail = "oatmealine@disroot.org";

      ignores = [
        # General:
        "*.bloop"
        "*.bsp"
        "*.metals"
        "*.metals.sbt"
        "*metals.sbt"
        "*.direnv"
        "*.envrc"
        "*hie.yaml"
        "*.mill-version"
        "*.jvmopts"

        # OS-related:
        ".DS_Store?"
        ".DS_Store"
        ".CFUserTextEncoding"
        ".Trash"
        ".Xauthority"
        "thumbs.db"
        "Thumbs.db"
        "Icon?"
      ];

      aliases = {
        # Data Analysis:
        ranked-authors = "!git authors | sort | uniq -c | sort -n";
        emails = ''
          !git log --format="%aE" | sort -u
        '';
        email-domains = ''
          !git log --format="%aE" | awk -F'@' '{print $2}' | sort -u
        '';
        graph = ''
          log --graph --color --pretty=format:"%C(yellow)%H%C(green)%d%C(reset)%n%x20%cd%n%x20%cn%x20(%ce)%n%x20%s%n"
        '';
      };
      
      extraConfig = {
        push.autoSetupRemote = true;
        pull.rebase = true;
        init.defaultBranch = "main";
        credential.helper = "libsecret";
      };
    };
    hm.programs.gh.enable = true;
  };
}