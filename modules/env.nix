{ lib, config, ... }:

with lib;
{
  options = {
    env = mkOption {
      type = with types; attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (n: v:
        if isList v
        then concatMapStringsSep ":" (x: toString x) v
        else (toString v));
      default = {};
      description = "Provides easy-access to `environment.extraInit`";
    };
  };

  config = {
    environment.extraInit =
      concatStringsSep "\n"
      (mapAttrsToList (n: v: ''export ${n}="${v}"'') config.env);
  };
}