# nix-config

hello!! welcome to my little nix cave, home to `five-pebbles` and `seven-red-suns`

this is a nix flake managing my nixos systems. it isn't (and won't ever be) ready for other peoples' use, but you are free to look around.

a lot of the base flake and module design was taken from [Icy-Thought's snowflake](https://github.com/Icy-Thought/snowflake) repo. thank you very much!!

## users

this flake assumes a single-user system for all hosts, enforced by `modules/user.nix`. this makes it much simpler to write modules that use both NixOS and `home-manager`, but also means that, well, you can't have more than one "main" user on the system. thus, it's not really suitable for larger servers.

## themes

different color schemes, icons and flavors are grouped into "themes", which you can look at in [`modules/desktop/themes/`](./modules/desktop/themes/). these are independent of desktop environments and display protocols and offer a nice abstraction over desktop customization in general

## screenshots

these are sorted by `theme - de`. credit for wallpapers and other assets can be seen in [assets/readme.txt](./assets/readme.txt)

### Catppuccin - Gnome

![](./docs/assets/2024-01-08_14-24.png)

### Catppuccin - Hyprland

![](./docs/assets/2024-07-25_23-36.png)

### Catppuccin - Niri

![](./docs/assets/2024-12-14_04-51.png)