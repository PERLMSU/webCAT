with import (fetchTarball { url = "channel:nixos-19.09"; }) { };
let
  unstable = import (fetchTarball { url = "channel:nixpkgs-unstable"; }) { };
in unstable.poetry2nix.mkPoetryApplication {
  src = lib.cleanSource ./.;
  pyproject = ./pyproject.toml;
  poetrylock = ./poetry.lock;
  python = python38;
  overrides = [ (import ./overrides.nix { inherit lib pkgs; }) ];
}
