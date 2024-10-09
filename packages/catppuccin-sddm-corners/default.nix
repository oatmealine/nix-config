{ lib
, stdenvNoCC
, fetchFromGitHub
, writeText
, config ? {}
}:

let
  defaultConfig = {
    General = {
      ### GENERAL

      # path to the wallpaper. you can drop files in backgrounds/ to use a relative path, or you can just use an absolute path.
      Background="backgrounds/flatppuccin_macchiato.png";

      # the font to use throughout the theme. use the name of the font family.
      Font="Liga SFMono Nerd Font";

      # the distance that stuff should be from the screen edge.
      Padding="50";

      # specify how round corners should be, or set to 0 to disable rounded corners.
      CornerRadius="5";

      # the font size used for everything excluding the date and time.
      GeneralFontSize="9";

      # this allows you to adjust the relative scale of UI elements. you should probably keep the value below 1.
      LoginScale="0.175";

      ### USER PICTURE

      # the width of the outline around the user avatar. set to 0 to disable.
      UserPictureBorderWidth="5";

      # the color of the outline around the user avatar.
      UserPictureBorderColor="#c0caf5";

      # the color of the default, blank avatar. note that this isonly visible when you don't have a custom picture set.
      UserPictureColor="#414868";

      ### TEXT FIELD (USER AND PASSWORD)

      # the color of the text field background for the user and password fields.
      TextFieldColor="#414868";

      # the color of the text inside the user and password fields.
      TextFieldTextColor="#c0caf5";

      # the color of the border around the currently selected text field.
      TextFieldHighlightColor="#c0caf5";

      # the border width of the currently selected text field. set to 0 to disable the border.
      TextFieldHighlightWidth="3";

      # the placeholder text shown in the user field when nothing is typed.
      UserFieldBgText="User";

      # the placeholder text shown in the password field when nothing is typed.
      PasswordFieldBgText="Password";

      ### LOGIN BUTTON

      # the color of the login button text.
      LoginButtonTextColor="#414868";

      # the color of the login button background.
      LoginButtonBgColor="#c0caf5";

      # the text to be displayed on the login button.
      LoginButtonText="Login";

      ### POPUP (POWER, SESSION, AND USER)

      # the background color of the popup. this applies to the power panel, session panel, and user panel.
      PopupBgColor="#c0caf5";

      # the color of the currently selected entry in the popup. this applies to the power panel, session panel, and user panel.
      PopupHighlightColor="#414868";

      # the color of the text for the currently selectedoption. only applies to session and user popups.
      PopupHighlightedTextColor="#c0caf5";

      ### SESSION BUTTON

      # the color of the session button background.
      SessionButtonColor="#c0caf5";

      # the color of the icon inside the session button.
      SessionIconColor="#414868";

      ### POWER BUTTON

      # the color of the power button background.
      PowerButtonColor="#c0caf5";

      # the color of the power button background.
      PowerIconColor="#414868";

      ### DATE

      # the text color of the date.
      DateColor="#c0caf5";

      # the font size of the date.
      DateSize="36";

      # whether the date is bolded. accepts either `true` or `false`.
      DateIsBold="false";

      # whether the date is bolded. accepts either `true` or `false`.
      DateOpacity="0.8";

      # specify the formatting of the date.
      DateFormat="dddd, MMMM d";

      ### TIME

      # the text color of the time.
      TimeColor="#c0caf5";

      # the font size of the time.
      TimeSize="48";

      # whether the time is bolded. accepts either `true` or `false`.
      TimeIsBold="true";

      # the opacity of the time text. set to 1 to disable transparency.
      TimeOpacity="0.8";

      # specify the formatting of the time.
      TimeFormat="hh:mm AP";
    };
  };
  mergedConfig = lib.attrsets.recursiveUpdate defaultConfig config;
in stdenvNoCC.mkDerivation {
  pname = "catppuccin-sddm-corners";
  version = "unstable-2023-02-17";

  src = fetchFromGitHub {
    owner = "khaneliman";
    repo = "catppuccin-sddm-corners";
    rev = "7b7a86ee9a5a2905e7e6623d2af5922ce890ef79";
    hash = "sha256-sTnt8RarNXz3RmYfmx4rD+nMlY8rr2n0EN3ntPzOurw=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = let
    configFile = writeText "catppuccin-sddm-corners-theme-conf" (lib.generators.toINI {
      # specifies how to format a key/value pair
      mkKeyValue = lib.generators.mkKeyValueDefault {
        mkValueString = v: ''"${builtins.toString v}"'';
      } " = ";
    } mergedConfig);
  in ''
    runHook preInstall

    cp ${configFile} catppuccin/theme.conf

    mkdir -p "$out/share/sddm/themes/"
    cp -r catppuccin/ "$out/share/sddm/themes/catppuccin-sddm-corners"

    runHook postInstall
  '';

  meta = {
    description = "Soothing pastel theme for SDDM based on corners theme.";
    homepage = "https://github.com/khaneliman/sddm-catppuccin-corners";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ khaneliman ];
    platforms = lib.platforms.linux;
  };
}
