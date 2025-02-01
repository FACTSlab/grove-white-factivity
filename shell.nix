let nixpkgs_source = (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz);
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
      # It may be necessary to adjust these to get the latest version:
      rev = "ce589817907ec450e74a6b31b4bd59d4ed6ccc31";
      sha256 = "0qz3qm0jbg4nbnik1fbfrfqzaqjj0prhi8hk68bpn2crdm498zq3";
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
      brms
      cmdstanr
      loo
      rstan
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
