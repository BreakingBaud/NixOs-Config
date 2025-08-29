{ stdenv, fetchFromGitHub, raylib, makeWrapper, pkgs }:

stdenv.mkDerivation {
  pname = "hellpaper";
  version = "unstable-2025-08-23"; # Or the latest commit date
  
  src = fetchFromGitHub {
    owner = "danihek";
    repo = "hellpaper";
    rev = "ada764578b146b5215e3a2ce334fa95bd609f88d"; # Replace with the latest commit hash
    sha256 = "sha256-RQuvEZEi1IX9yop+rKc+rxq+qM2mivL8FTZH6KUwPgw="; # You will need to get this later
  };

  buildInputs = [ raylib makeWrapper ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp hellpaper $out/bin/hellpaper
  '';
postInstall = ''
wrapProgram $out/bin/hellpaper \
--prefix PATH : "${pkgs.swww}/bin"
'';
}
