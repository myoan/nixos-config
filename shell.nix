{ pkgs ? import <nixpkgs> {}
}:
pkgs.mkShell {
	name = "nixos-config";
	buildInputs = [
		pkgs.gnumake
	];
}
