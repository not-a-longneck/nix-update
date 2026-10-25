{ ... }:

let
  tarballUrl = "https://github.com/not-a-longneck/nix-update/archive/refs/heads/main.tar.gz";
  configDir  = "/etc/nixos";
  backupDir  = "/etc/nixos.bak";

  # Files that should never be overwritten by the sync
  # (patterns are matched by tar, relative to the repo root)
  excludes = [
    "hardware-configuration.nix"
    ".git*"
    "README*"
  ];

  excludeFlags = builtins.concatStringsSep " "
    (map (e: "--exclude='${e}'") excludes);
in
{
  environment.interactiveShellInit = ''
    nix-update() {
      local tmp ok=0
      tmp=$(mktemp -d)

      echo "📦 Step 1: Creating backup..."
      sudo rm -rf "${backupDir}"
      sudo cp -a "${configDir}" "${backupDir}"

      echo "🔄 Step 2: Downloading repo from GitHub..."
      if curl -sSLf -o "$tmp/repo.tar.gz" "${tarballUrl}" \
         && mkdir "$tmp/src" \
         && tar -xzf "$tmp/repo.tar.gz" -C "$tmp/src" --strip-components=1 ${excludeFlags} \
         && sudo cp -a "$tmp/src/." "${configDir}/"; then

        echo "❄️ Step 3: Rebuilding NixOS..."
        if sudo nixos-rebuild switch; then
          gen_num=$(readlink /nix/var/nix/profiles/system | cut -d- -f2)
          echo "✨ Success! Updated to Generation $gen_num!"
          ok=1
        fi
      else
        echo "❌ Failed to download or extract the repo"
      fi

      rm -rf "$tmp"
      [ $ok -eq 1 ] && return 0

      echo "❌ Update failed! Restoring backup..."
      sudo cp -a "${backupDir}/." "${configDir}/"
      return 1
    }
  '';
}
