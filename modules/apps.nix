{ config, pkgs, ... }:
{  
  environment.systemPackages = with pkgs; [
    ### GUI Apps
    fluent-reader
    mediawriter

    ### CLI / Utilities
    libnotify
    git
    github-cli
    usbutils
    wget
    curl
    htop
    btop
    nvtopPackages.full
    fastfetch
    ripgrep
    eza
    bat
    nh
    nix-output-monitor
    parted
    gparted
    cryptsetup
    whois        # includes mkpasswd
    chafa        # terminal image previews
    nodejs
    python3
    python3Packages.pip
    yt-dlp 
    imagemagick
    openssl 
  
    ### System / Runtimes / Libraries
    cifs-utils   # Unraid/SMB shares
    libvlc
    ffmpeg-full
    swtpm
    virt-viewer
  
    ### Formatters
    prettier
    black
    nixpkgs-fmt
  
    # Custom scripts
    # (writeShellScriptBin "obs-convert" (builtins.readFile ./scripts/obs-convert.sh))
  
    # ---------------------------------------------------------
    # KDE PACKAGES  (active)
    # ---------------------------------------------------------
    kdePackages.kdegraphics-thumbnailers # For images and PDFs
    kdePackages.ffmpegthumbs             # For video thumbnails
    kdePackages.taglib                   # For audio files
    
    # ---------------------------------------------------------
    # GNOME PACKAGES  (commented out — uncomment to enable)
    # ---------------------------------------------------------
    # gnome-tweaks
    # gnome-extension-manager
    # gnome-shell-extensions
  
  ];
}
