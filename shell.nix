let
  defaultPkgs = import <nixpkgs> {};
  pinnedPkgs = import (defaultPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "63cdd9bd317e15e4a4f42dde455c73383ded1b41"; # nixpkgs-19.09-darwin, 29 Oct 2019
    sha256 = "0svq9pim5pp43w749xg2rr5xpm4ibgm08fzfplxccmphd6yhajig";
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
