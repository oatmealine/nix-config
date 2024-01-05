{
  alacritty = import ./alacritty.nix;
  opinions = import ./opinions.nix;
  gtkConfig = import ./gtk-config.nix;
  shellColors = import ./shell-colors.nix;
  microColors = import ./micro-colors.nix;
  gnomeBindings = import ./gnome-bindings.nix;
  disableNews = import ./disable-news.nix;
}
