let
  defaultPkgs = import <nixpkgs> {};
  pinnedPkgs = import (defaultPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "94500c93dc239761bd144128a1684abcd08df6b7"; # 15 Oct 2019
    sha256 = "0p6bd16mb1k5c3zihl1c3d62m419rii102xfb340pccgbd8j34bc";
  }) {};

in

{ nixpkgs ? pinnedPkgs }:

let
  pkgs = if nixpkgs == null then defaultPkgs else pinnedPkgs;
  devEnv = with pkgs; buildEnv {
    name = "devEnv";
    paths = [
      maven3
      doxygen
      graphviz
      openjdk8
      travis
      postgresql
      awscli
      docker-compose
    ];
  };
in
  pkgs.runCommand "dummy" {
    buildInputs = [
      devEnv
    ];
  } ""
