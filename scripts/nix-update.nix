{ ... }:

let
  baseUrl = "https://raw.githubusercontent.com/not-a-longneck/NixOS-VCVM/main";
  configDir = "/etc/nixos";
  
  # Add any new files you want to track here (relative to /etc/nixos/)
  filesToSync = [
    "configuration.nix"
    "scripts/nix-update.nix"
  ];
in
{
  environment.interactiveShellInit = ''
    nix-update() {
      echo "📦 Step 1: Creating backups..."
      for file in ${builtins.concatStringsSep " " filesToSync}; do
        if [ -f "${configDir}/$file" ]; then
          sudo mkdir -p "$(dirname "${configDir}/$file.bak")"
          sudo cp "${configDir}/$file" "${configDir}/$file.bak"
        fi
      done

      echo "🔄 Step 2: Downloading files from GitHub..."
      local download_failed=0
      for file in ${builtins.concatStringsSep " " filesToSync}; do
        # Ensure target subdirectories exist (e.g., scripts/)
        sudo mkdir -p "$(dirname "${configDir}/$file")"
        
        if ! sudo curl -sSL -o "${configDir}/$file" "${baseUrl}/$file"; then
          echo "❌ Failed to download $file"
          download_failed=1
          break
        fi
      done

      if [ $download_failed -eq 0 ]; then
        echo "❄️ Step 3: Rebuilding NixOS..."
        if sudo nixos-rebuild switch; then
          gen_num=$(readlink /nix/var/nix/profiles/system | cut -d- -f2)
          echo "✨ Success! Updated to Generation $gen_num!"
          return 0
        fi
      fi

      echo "❌ Update failed! Restoring backups..."
      for file in ${builtins.concatStringsSep " " filesToSync}; do
        if [ -f "${configDir}/$file.bak" ]; then
          sudo cp "${configDir}/$file.bak" "${configDir}/$file"
        fi
      done
      return 1
    }
  '';
}
