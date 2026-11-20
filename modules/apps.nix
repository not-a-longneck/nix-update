{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ### GUI Apps
    fluent-reader
    mediawriter

    ### CLI / Utilities
    bat
    btop
    chafa          # terminal image previews
    cryptsetup
    curl
    eza
    fastfetch
    git
    github-cli
    gparted
    htop
    imagemagick
    libnotify
    nh
    nix-output-monitor
    nodejs
    nvtopPackages.full
    openssl
    parted
    python3
    python3Packages.pip
    ripgrep
    rsync
    tldr
    usbutils
    wget
    whois          # includes mkpasswd
    yt-dlp

    ### System / Runtimes / Libraries
    cifs-utils     # Unraid/SMB shares
    ffmpeg-full
    libvlc
    swtpm
    virt-viewer

    ### Formatters
    black
    nixpkgs-fmt
    prettier

    ### KDE
    kdePackages.ffmpegthumbs             # video thumbnails
    kdePackages.kdegraphics-thumbnailers # image and PDF thumbnails
    kdePackages.taglib                   # audio file metadata

    ### Custom scripts
    # (writeShellScriptBin "obs-convert" (builtins.readFile ./scripts/obs-convert.sh))

    ### GNOME (commented out, uncomment to enable)
    # gnome-extension-manager
    # gnome-shell-extensions
    # gnome-tweaks
  ];
}
