# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos";
  networking.interfaces.enp0s5.useDHCP = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    dpi = 220;

    desktopManager = {
      xterm.enable = false;
    };
    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;

      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 250 40
      '';
    };
    windowManager.i3.enable = true;
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "Hack" ]; })
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.initialPassword = "root";
  users.users.yoan = {
    isNormalUser = true;
    home = "/home/yoan";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [];
  };

  home-manager.users.yoan = { pkgs, ... }: {
    xdg.enable = true;
    home.packages = [
      pkgs.bat
      pkgs.exa
      pkgs.jq
      pkgs.ripgrep
      pkgs.tree
      pkgs.rofi
      pkgs.gcc
      pkgs.gh
      pkgs.peco
      pkgs.ghq
      pkgs.gnupg
      pkgs.direnv
      pkgs.nix-direnv
      pkgs.feh

      pkgs.go
      pkgs.gopls
    ];

    xdg.configFile."i3/config".text = builtins.readFile /home/yoan/nixos-config/i3;

    programs.alacritty = {
      enable = true;
      settings = {
      	window.decorations = "Full";
      	env.TERM = "xterm-256color";
      	font = {
	  size = 11;
	  normal.family = "Hack Nerd Font";
	  stye = "Regular";
	};
	dynamicTitle = true;
	cusor = "Block";
      };
    };

    programs.zsh = {
      enable = true;
      initExtra = builtins.readFile /home/yoan/nixos-config/zshrc;
      shellAliases = {
        vim = "nvim";
	ls = "exa";
      };
    };

    programs.git = {
      enable = true;
      userName = "myoan";
      userEmail = "motoki.yoan@gmail.com";
      signing = {
        key = "B1CADB53D7E4E63A";
	signByDefault = true;
      };
      aliases = {
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creeset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
        ci = "commit";
	co = "checkout";
	st = "status";
	br = "branch";
	sw = "switch";
	rs = "restore";

      };
      extraConfig = {
        branch.autosetuprebase = "always";
        core.editor = "nvim";
        core.askPass = "";
        color.ui = true;
        ghq.vcs = "git";
        ghq.root = "~/dev/src";
        github.user = "myoan";
        init.defaultBranch = "main";
        push.default = "upstream";
	credential."https://github.com".helper = "!gh auth git-credential";
      };
    };

    programs.neovim = {
      enable = true;
      extraConfig = builtins.readFile /home/yoan/nixos-config/init.lua;
      # extraConfig = (import /home/yoan/nix-config/nvim)
      plugins = with pkgs; [
        vimPlugins.vim-airline
        vimPlugins.vim-airline-themes
        vimPlugins.vim-eunuch
        vimPlugins.nord-vim
        vimPlugins.tokyonight-nvim
        vimPlugins.telescope-nvim
        vimPlugins.nvim-comment
        vimPlugins.nvim-lspconfig
        vimPlugins.cmp-nvim-lsp
        vimPlugins.nvim-cmp
        vimPlugins.nvim-treesitter.withAllGrammars
        vimPlugins.nvim-tree-lua
        vimPlugins.nvim-web-devicons
        vimPlugins.neogit
        vimPlugins.lexima-vim
      ];
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "tty";

      defaultCacheTtl = 31536000;
      maxCacheTtl = 31536000;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    zsh
    alacritty
    # xbanish

    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  ];
  environment.sessionVariables = rec {
    GOPATH = "\${HOME}/go";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

