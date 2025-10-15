{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.thumbnailers;
in {
  options.modules.desktop.thumbnailers = {
    enable = mkEnableOption "Enable some thumbnailers for desktop envs";
  };

  config = mkIf cfg.enable {
    hm.home.packages = let
      mkThumbnailer = { name, mime, exec }: pkgs.writeTextFile {
        name = "${name}-thumbnailer";
        destination = "/share/thumbnailers/${name}.thumbnailer";
        text = ''
          [Thumbnailer Entry]
          Exec=${exec}
          MimeType=${mime}
        '';
      };
      mkMagickThumbnailer = { format, mime }: mkThumbnailer {
        name = format;
        inherit mime;
        exec = "${pkgs.imagemagick}/bin/magick ${format}:%i -flatten -thumbnail x%s png:%o";
      };
    in [
      # text files
      # heavily modified from https://github.com/LordMZTE/dotfiles/blob/c2dc8c2fc6b97e2525f2f3cff64c1cbfd6f4483a/nix/pkgs/thumbnailers.nix#L10
      # UNFORTUNATELY looks pretty ass due to the res & background checkerboard
      /*
      (let
        textthumb = pkgs.writeShellScript "textthumb" ''
          iFile=$(<"$1")
          tempFile=$(mktemp) && {
            echo "''${iFile:0:1600}" > "$tempFile"

            ${pkgs.imagemagick}/bin/magick \
              -size 210x290 \
              -background white \
              -pointsize 15 \
              -border 10x10 \
              -bordercolor "#CCC" \
              -font ${pkgs.dejavu_fonts.minimal}/share/fonts/truetype/DejaVuSans.ttf \
              caption:@"$tempFile" \
              "$2"

            rm "$tempFile"
          }

          iFile=$(<"$1")
          tempFile=$(mktemp) && {
            echo "''${iFile:0:1600}" > "$tempFile"

            ${pkgs.imagemagick}/bin/convert \
              -size 256x256 -background none \
              "${toString ./file-back.png}" \
              \( \
                \( \( \
                  -size 172x228 \
                  -pointsize 25 \
                  -define caption:split=true \
                  -font "${pkgs.recursive}/share/fonts/truetype/RecMonoLinear-Regular-1.085.ttf" \
                  caption:@"$tempFile" \
                \) -geometry +46+16 \) \
                \( "${toString ./file-mask.png}" -alpha Shape \) -compose Dst_In -gravity Center -composite \
              \) -compose Over +gravity -composite \
              "${toString ./file-front.png}" -compose Over -composite \
              "$2"

            rm "$tempFile"
          }
        '';
      in
        mkThumbnailer {
          name = "text";
          mime = "text/plain;text/x-log;text/html;text/css;";
          exec = "${textthumb} %i %o";
        }
      )
      */
      # videos
      pkgs.ffmpegthumbnailer
      # project files
      (mkThumbnailer {
        name = "kra";
        mime = "application/x-krita";
        exec = "sh -c \"${pkgs.unzip}/bin/unzip -p %i preview.png > %o\"";
      })
      # > note: apparently xcftools is unmaintained since 2019 and nixpkgs' version has multiple code-execution vulnerabilities, so let's not use xcf2png
      (mkMagickThumbnailer { format = "xcf"; mime = "image/x-xcf"; })
      # for embbedded cover art
      (mkThumbnailer {
        name = "audio";
        mime = "audio/mpeg;audio/flac;audio/wavpack;audio/webm;audio/mp4;audio/aac;audio/x-matroska;audio/x-opus+ogg";
        # this one does waveforms but idk if i fw that
        # https://github.com/saltedcoffii/ffmpeg-audio-thumbnailer/blob/main/src/ffmpeg-audio-thumbnailer.thumbnailer
        #exec = "${pkgs.ffmpeg}/bin/ffmpeg -y -i %i -lavfi 'compand,showwavespic=s=%sx%s:colors=white' -frames:v 1 -c:v png %o";
        exec = "${pkgs.ffmpeg} -y -i %i %o -fs %s";
      })
      # more obscure file formats
      (mkThumbnailer {
        name = "gdx-pixbuf";
        mime = "application/x-navi-animation;image/png;image/bmp;image/x-bmp;image/x-MS-bmp;image/gif;image/x-icon;image/x-ico;image/x-win-bitmap;image/vnd.microsoft.icon;application/ico;image/ico;image/icon;text/ico;image/jpeg;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/tiff;image/x-xpixmap;image/x-xbitmap;image/x-tga;image/x-icns;image/x-quicktime;image/qtif;image/x-webp;image/webp";
        exec = "${pkgs.gdk-pixbuf}/bin/gdk-pixbuf-thumbnailer -s %s %u %o";
      })
      (mkMagickThumbnailer { format = "dds"; mime = "image/x-dds"; })
      # REALLY obscure ones now
      # valve texture format
      (mkThumbnailer {
        name = "vtf";
        mime = "image/vnd.valve.source.texture;application/x-vtfedit";
        exec = "${pkgs.my.vtf2png}/bin/vtf2png %i %o";
      })
    ];
  };
}