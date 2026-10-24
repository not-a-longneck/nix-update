{ config, pkgs, ... }:

let
  kde-reimage = pkgs.stdenv.mkDerivation {
    pname = "kde-service-menu-reimage";
    version = "latest";

    src = builtins.fetchGit {
          url = "https://github.com/giuseppebenigno/kde-service-menu-reimage.git";
          ref = "master";
        };

    propagatedBuildInputs = with pkgs; [
      imagemagick
      jhead
      exiftool
      kdePackages.kdialog
    ];

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/kio/servicemenus

      cp bin/* $out/bin/
      cp servicemenus/*.desktop $out/share/kio/servicemenus/

      chmod +x $out/bin/*
      sed -i 's|~/.local/bin/||g' $out/share/kio/servicemenus/*.desktop
    '';
  };
in
{
  # This makes it a valid NixOS module
  environment.systemPackages = [ kde-reimage ];
}
