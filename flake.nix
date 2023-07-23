{
  description = "Nix flake for development";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            go_1_19
          ];
        };

        packages.default = pkgs.buildGoModule rec {
          pname = "github_exporter";
          version = "unstable";
          src = ./.;

          ldflags =
            let
              t = "github.com/promhippie/github_exporter/pkg/version";
            in [
              "-s" "-w"
              "-X ${t}.String=${version}"
              "-X ${t}.Revision=HEAD"
              "-X ${t}.Date=unknown"
            ];

          vendorSha256 = "sha256-CdT4noTYbax+enN81AQTUDjlJ+M4pvoiPR6iUzYURMI=";
        };
      }
    );
}
