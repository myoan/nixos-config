deploy:
	cp nixos/*.nix /etc/nixos/

install: deploy
	nixos-rebuild switch
