{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  # environment.pathsToLink = [ "/share/fish" ];

  users.users.yoan = {
    isNormalUser = true;
    home = "/home/yoan";
    extraGroups = [ "docker" "wheel" ];
    # shell = pkgs.fish;
    # TODO: change password using passwd
    initialPassword = "password";
    # hashedPassword = "$6$p5nPhz3G6k$6yCK0m3Oglcj4ZkUXwbjrG403LBZkfNwlhgrQAqOospGJXJZ27dI84CbIYBNsTgsoH650C1EBsbCKesSVPSpB1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkLxRY5b1UBv4uKddeZyFhMNe9Lsf2E513FYwthoQII yoan@antelope.local"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
