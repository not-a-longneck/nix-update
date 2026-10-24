{ stdenv, fetchFromGitHub, lib, imagemagick, jhead, exiftool, kdePackages }:

stdenv.mkDerivation {
  pname = "kde-service-menu-reimage";
  version = "latest";

  src = fetchFromGitHub {
    owner = "giuseppebenigno";
    repo = "kde-service-menu-reimage";
    rev = "master"; 
    hash = lib.fakeHash; # Replace with the actual hash after the first run
  };

  propagatedBuildInputs = [
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
}
