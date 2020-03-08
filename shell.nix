{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  inherit (lib) optional optionals;
  unstable = import (fetchTarball { url = "channel:nixpkgs-unstable"; }) { };

  pythonEnv = unstable.poetry2nix.mkPoetryEnv {
    poetrylock = ./poetry.lock;
    python = python38;
    overrides = [ (import ./overrides.nix { inherit lib; pkgs = unstable; }) ];
  };

in mkShell {
  buildInputs = [ pythonEnv python3Packages.setuptools killall ];

  shellHook = ''
    # Add scripts to path
    export PATH="./bin/:$PATH"
  '';
}
