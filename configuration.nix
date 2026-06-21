# ============================================================
# NixOS Configuration
# ============================================================

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./scripts/nix-update.nix
    # <home-manager/nixos>
    "${(builtins.fetchTarball {
      url = "https://github.com/gmodena/nix-flatpak/archive/refs/tags/v0.6.0.tar.gz";
      sha256 = "sha256:0s3mpb28rcmma29vv884fi3as926bfszhn7v8n74bpnp5qg5a1c8";
    })}/modules/nixos.nix"
  ];


  # ============================================================
  # SYSTEM
  # ============================================================

  # NixOS version — do not change unless you know what you're doing
  system.stateVersion = "25.11";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";

  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT    = "da_DK.UTF-8";
    LC_MONETARY       = "da_DK.UTF-8";
    LC_NAME           = "da_DK.UTF-8";
    LC_NUMERIC        = "da_DK.UTF-8";
    LC_PAPER          = "da_DK.UTF-8";
    LC_TELEPHONE      = "da_DK.UTF-8";
    LC_TIME           = "da_DK.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;


  # ============================================================
  # BOOT
  # ============================================================

  boot.loader.systemd-boot.enable    = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;

  # kvm-amd: virtualization; nct6775: fan control via CoolerControl
  boot.kernelModules = [ "kvm-amd" "nct6775" ];

  boot.kernelParams = [
    "acpi_enforce_resources=lax"  # Required for nct6775 fan control
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];


  # ============================================================
  # SLEEP
  # ============================================================

  # Restart CoolerControl on system wake to fix crazy fans
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart coolercontrold.service
  '';

  # ============================================================
  # HARDWARE
  # ============================================================

  hardware.bluetooth = {
    enable       = true;
    powerOnBoot  = true;
    settings.General.Experimental = true;
  };

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  services.fwupd.enable = true;    # Firmware updates
  services.fstrim.enable = true;   # SSD TRIM


  # ============================================================
  # NVIDIA
  # ============================================================

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable    = true;
    powerManagement.enable = true;
    open    = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL          = "1";         # Hint Electron apps to use Wayland
    GBM_BACKEND             = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME       = "nvidia";
  };


  # ============================================================
  # DISPLAY / DESKTOP
  # ============================================================
  # Display manager is shared by both desktop environments below.
  # SDDM will show a session picker if more than one DE is enabled.

  services.displayManager.sddm.enable = true;

  # ---------------------------------------------------------
  # KDE PLASMA  (active)
  # ---------------------------------------------------------
  services.desktopManager.plasma6.enable = true;

  # ---------------------------------------------------------
  # GNOME  (commented out — uncomment block below to enable)
  # ---------------------------------------------------------
  # services.desktopManager.gnome.enable = true;
  #
  # environment.gnome.excludePackages = with pkgs; [
  #   gnome-tour
  #   gnome-connections
  #   epiphany
  #   geary
  #   gnome-maps
  #   gnome-weather
  #   gnome-contacts
  #   gnome-music
  #   gnome-photos
  #   gnome-software
  # ];

  # Shared keyboard / font settings (DE-agnostic)
  services.xserver.xkb = {
    layout  = "dk";
    variant = "";
  };

  fonts.fontDir.enable = true;


  # ============================================================
  # AUDIO (PipeWire)
  # ============================================================

  services.pipewire = {
    enable           = true;
    alsa.enable      = true;
    alsa.support32Bit = true;
    pulse.enable     = true;
  };

  # Reset USB mic on login (vendor: 0d8c, product: 016c)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0d8c", ATTR{idProduct}=="016c", MODE="0666", GROUP="audio"
  '';

  systemd.user.services.reset-usb-mic = {
    description = "Reset USB Microphone on login";
    wantedBy    = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/sleep 10; ${pkgs.usbutils}/bin/usbreset 0d8c:016c'";
      Type      = "oneshot";
    };
  };


  # ============================================================
  # USERS
  # ============================================================

  users.users.hjalte = {
    isNormalUser = true;
    description  = "Hjalte";
    shell        = pkgs.zsh;
    extraGroups  = [ "networkmanager" "wheel" "libvirtd" "storage" ];

    packages = with pkgs; [
      # ---------------- KDE (active) ----------------
      kdePackages.kate

      # ---------------- GNOME (commented out) --------
      # gnome-text-editor
    ];
  };

  # home-manager.users.hjalte = { pkgs, ... }: {
  #   imports = [ ./plasma.nix ];
  #   home.stateVersion = "25.11";
  # };


  # ============================================================
  # SHELL (ZSH)
  # ============================================================

  programs.zsh = {
    enable                  = true;
    autosuggestions.enable  = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme  = "robbyrussell";
    };
  };


  # ============================================================
  # SYSTEM PACKAGES
  # ============================================================

  environment.systemPackages = with pkgs; [
    # CLI / Utilities
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
    mediawriter

    # System / Runtimes / Libraries
    cifs-utils   # Unraid/SMB shares
    libvlc
    ffmpeg-full
    swtpm
    virt-viewer

    # Formatters
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

  # ============================================================
  # BROWSER
  # ============================================================

  programs.firefox.enable = true;

  # ============================================================
  # FLATPAK (Declarative via nix-flatpak)
  # ============================================================

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
  '';


  # ============================================================
  # SERVICES
  # ============================================================

  services.syncthing = {
    enable    = true;
    user      = "hjalte";
    dataDir   = "/home/hjalte/Documents";
    configDir = "/home/hjalte/.config/syncthing";
  };

  services.printing.enable = true;

  services.avahi = {
    enable     = true;
    nssmdns4   = true;
    openFirewall = true;
  };

  services.gvfs.enable    = true;   # Network browsing in file managers
  services.udisks2.enable = true;   # Drive mounting in KDE

  services.espanso = {
    enable  = true;
    package = pkgs.espanso-wayland;
  };

  programs.coolercontrol.enable = true;


  # ============================================================
  # VIRTUALISATION
  # ============================================================

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package            = pkgs.qemu_full;
      vhostUserPackages  = [ pkgs.virtiofsd ];
      runAsRoot          = true;
      swtpm.enable       = true;   # TPM support
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable    = true;
  services.spice-vdagentd.enable  = true;


  # ============================================================
  # STORAGE / MOUNTS
  # ============================================================

  fileSystems."/home" = {
    device  = "/dev/disk/by-uuid/709c8ea6-928a-4f88-a831-d969233a845e";
    fsType  = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/mnt/tower/main-share" = {
    device  = "//192.168.1.53/main-share";
    fsType  = "cifs";
    options = [
      "guest,uid=1000,gid=100,rw,iocharset=utf8"
      "file_mode=0777,dir_mode=0777,noperm"
      "_netdev,x-systemd.automount,x-systemd.idle-timeout=60"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/tower/main-share 0777 1000 users -"
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
           action.id == "org.freedesktop.udisks2.encrypted-unlock-system") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';


  # ============================================================
  # MAINTENANCE
  # ============================================================

  system.autoUpgrade = {
    enable      = true;
    allowReboot = false;
    dates       = "23:00";
  };

  # Notify the desktop user after autoUpgrade completes
  systemd.user.services.nixos-upgrade-notify = {
    description = "Notify user after NixOS auto-upgrade";
    after       = [ "nixos-upgrade.service" ];
    wantedBy    = [ "nixos-upgrade.service" ];
    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "${pkgs.libnotify}/bin/notify-send \"NixOS\" \"System updated. Reboot to apply any kernel changes.\" --icon=software-update-available";
    };
  };

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 14d";
  };
}