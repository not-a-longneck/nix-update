{ config, pkgs, ... }:

let
  kde-reimage = pkgs.stdenv.mkDerivation {
    pname = "kde-service-menu-reimage";
    version = "latest";

    src = builtins.fetchGit {
      url = "https://github.com/giuseppebenigno/kde-service-menu-reimage";
      ref = "main";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share/kio/servicemenus
      cp bin/* $out/bin/
      cp servicemenus/*.desktop $out/share/kio/servicemenus/
      chmod +x $out/bin/* $out/share/kio/servicemenus/*.desktop
      sed -i "s|~/.local/bin/|$out/bin/|g" $out/share/kio/servicemenus/*.desktop
      runHook postInstall
    '';

    postFixup = ''
      for f in $out/bin/*; do
        wrapProgram "$f" --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [
          imagemagick jhead exiftool kdePackages.kdialog
        ])}
      done
    '';
  };
in
{
  environment.systemPackages = [ kde-reimage ];
}
