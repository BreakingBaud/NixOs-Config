{ config, pkgs, lib, unstablePkgs, ... }:
let
  hellpaper = pkgs.callPackage ./hellpaper.nix { pkgs = pkgs; };
  in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ========================================
  # BOOT CONFIGURATION
  # ========================================
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # ========================================
  # NETWORKING
  # ========================================
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # ========================================
  # LOCALIZATION
  # ========================================
  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # ========================================
  # DISPLAY & DESKTOP
  # ========================================
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Display Manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
    ];
  };

  # # Only enable NVIDIA on machines that have it
  # hardware.nvidia = lib.mkIf (builtins.pathExists /sys/class/drm/card0) {
  #   modesetting.enable = true;
  #   open = true;
  #   nvidiaSettings = true;
  # };
  
  # services.xserver.videoDrivers = lib.mkIf (builtins.pathExists /sys/class/drm/card0) [ "nvidia" ];

  # ========================================
  # USERS
  # ========================================
  users = {
    defaultUserShell = pkgs.fish;
    users.smg = {
      isNormalUser = true;
      description = "Sean";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
    };
  };

  # ========================================
  # FONTS
  # ========================================
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      # (nerd-fonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

   # Enable the sunshine service
  systemd.user.services.sunshine = {
    description = "Sunshine streaming server";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Restart = "on-failure";
    };
  };

  # Required for Wayland screen capture
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Firewall configuration
  networking.firewall = {
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
    ];
  };

  # Enable avahi for discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };


  # ========================================
  # NIX CONFIGURATION
  # ========================================
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ========================================
  # SYSTEM PACKAGES
  # ========================================
  environment.systemPackages = with pkgs; [
    # SDDM Theme
    (pkgs.callPackage ./sddm-astronaut-theme.nix {
      theme = "jake_the_dog";
      themeConfig = {
        General = {
          HeaderText = "Hi";
          Background = "/run/current-system/sw/share/sddm/themes/sddm-astronaut-theme/Backgrounds/jake_the_dog.mp4";
          FontSize = "10.0";
        };
      };
    })

    #Python with packages
    (python3.withPackages (ps: [
      ps.requests
    ]))

    # Desktop Applications
    kitty
    firefox
    nemo
    nemo-fileroller
    vesktop
    obsidian
    spotify
    steam
    gamescope
    sunshine

    # Development Tools
    helix
    qt6.full
    qt6.qtbase
    qt6.qttools
    pkg-config
    cmake

    # LSP
    nil
    nixfmt-rfc-style
    ruff
    bash-language-server
    yaml-language-server
    nodePackages.vscode-json-languageserver
    vscode-extensions.ecmel.vscode-html-css
    taplo

    # System Monitoring & Info
    fastfetch
    btop                    # replacement of htop/nmon
    iotop                   # io monitoring
    iftop                   # network monitoring
    sysstat
    lm_sensors              # for sensors command

    # System Tools & Hardware
    ethtool
    pciutils                # lspci
    usbutils                # lsusb

    # System Call Monitoring & Debugging
    strace                  # system call monitoring
    ltrace                  # library call monitoring
    lsof                    # list open files

    # Media & Audio
    ffmpeg
    pulsemixer
    spicetify-cli

    # Wayland/Desktop Environment
    rofi-wayland
    swaylock-effects
    swaylock
    swaybg
    swww
    eww
    waybar
    wl-clip-persist
    cliphist

    # Get rid of on Niri ????
    xdg-desktop-portal-hyprland

    # Archive & Compression
    zip
    xz
    unzip
    p7zip

    # CLI Utilities & Tools
    brightnessctl
    psmisc
    imagemagick
    hellpaper
    ripgrep                 # recursively searches directories for a regex pattern
    jq                      # A lightweight and flexible command-line JSON processor
    yq-go                   # yaml processor
    eza                     # A modern replacement for 'ls'
    fzf                     # A command-line fuzzy finder
    tree
    file
    which
    gnused
    gnutar
    gawk
    zstd
    gnupg
    ugrep

    # Networking Tools
    mtr                     # A network diagnostic tool
    iperf3
    dnsutils                # dig + nslookup
    ldns                    # replacement of dig, provides the command drill
    aria2                   # A lightweight multi-protocol & multi-source command-line download utility
    socat                   # replacement of openbsd-netcat
    nmap                    # A utility for network discovery and security auditing
    ipcalc                  # calculator for IPv4/v6 addresses

    # Documentation & Text Processing
    hugo                    # static site generator
    glow                    # markdown previewer in terminal

    # Build & Development Utilities
    nix-output-monitor

    # Misc/Fun
    cowsay
    hellwal                 # colorscheme tool
  ];

  # ========================================
  # PROGRAMS
  # ========================================
  programs = {
    # Desktop Environment
    niri.enable = true;

    # Shell & Prompt
    fish.enable = true;
    starship.enable = true;

    # Steam
    steam = {
      enable = true;
      extraCompatPackages = [
      pkgs.proton-ge-bin ];
    };

    # Development
    git.enable = true;
  };

  # ========================================
  # SYSTEM VERSION
  # ========================================
  system.stateVersion = "25.05"; # Did you read the comment?
}
