let nixpkgs_source = (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz);
in
{ pkgs ? import nixpkgs_source {
    inherit system;
  }
, system ? builtins.currentSystem
}:
let
  rlang = pkgs.rPackages.buildRPackage {
    name = "rlang";
    src = fetchTarball "https://cran.r-project.org/src/contrib/rlang_4.5.0.tar.gz";
    propagatedBuildInputs = [ ];
    nativeBuildInputs = [ ];
  };
  cmdstanr = pkgs.rPackages.buildRPackage {
    name = "cmdstanr";
    src = pkgs.fetchFromGitHub {
      owner = "stan-dev";
      repo = "cmdstanr";
      rev = "ced35d1cb02768f47fa215e40c1bc9a2ebcf4b70";
      sha256 = "0qcqnb80wif0j1b0lvhqfxr5wflmqccgl3i0h8d07pz18wl5h09n";
    };
    propagatedBuildInputs = [
      pkgs.rPackages.checkmate
      pkgs.rPackages.data_table
      pkgs.rPackages.jsonlite
      pkgs.rPackages.posterior
      pkgs.rPackages.processx
      pkgs.rPackages.R6
      pkgs.rPackages.vroom
    ];
    nativeBuildInputs = [ ];
  };
  R-stuff = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      cmdstanr
      loo
    ];
  };
in
pkgs.stdenv.mkDerivation
{
  name = "my-env-0";
  buildInputs = [
    pkgs.cmdstan
    R-stuff
  ];
  shellHook = ''
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
    # export LANG=en_US.UTF-8
    # export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    eval $(egrep ^export ${R-stuff}/bin/R)
  '';
}
