{
  inputs = {
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    systems,
    nixpkgs,
    ...
  } @ inputs: let
    eachSystem = f:
      nixpkgs.lib.genAttrs (import systems) (
        system:
          f nixpkgs.legacyPackages.${system}
      );
  in {
    packages = eachSystem (pkgs: {
      hello = pkgs.hello;
    });

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.opam
          pkgs.gcc
          pkgs.pkg-config
          pkgs.libev
          pkgs.libevdev
          pkgs.curl
          pkgs.gmp
        ];
      };
    });
  };
}
