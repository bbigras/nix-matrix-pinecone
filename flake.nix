{
  description = "dendrite-demo-pinecone";
  nixConfig.substituters = [
    "https://cache.nixos.org"
    "https://dendrite-demo-pinecone.cachix.org"
  ];
  nixConfig.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "dendrite-demo-pinecone.cachix.org-1:qgybhOM1X0JikTrvpYo1HwtsXT2ee+6ajbmCjCns4yI="
  ];

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    dendrite = {
      url = "github:matrix-org/dendrite";
      flake = false;
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, pre-commit-hooks, dendrite, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    perSystem = { system, ... }:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages.default = (import ./build.nix { inherit pkgs dendrite; }).main;
        packages.dendrite = (import ./build.nix { inherit pkgs dendrite; }).main;
        packages.dockerImage = import ./image.nix { inherit pkgs dendrite; };
        devShells.default = import ./shell.nix { inherit pkgs pre-commit-hooks system; };
      };
  };
}
