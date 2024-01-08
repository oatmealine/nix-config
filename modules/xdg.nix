{ ... }:
{
  config = {
    hm.xdg.enable = true;
    hm.xdg.userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "$HOME/desktop";
      documents = "$HOME/documents";
      download = "$HOME/downloads";
      music = "$HOME/music";
      pictures = "$HOME/pictures";
      publicShare = "$HOME/public";
      templates = "$HOME/templates";
      videos = "$HOME/videos";
    };
  };
}