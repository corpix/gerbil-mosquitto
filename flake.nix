{
  inputs = {
    nixpkgs.url = "tarball+https://git.tatikoma.dev/corpix/nixpkgs/archive/v2024-05-09.609610.tar.gz";
    gerbil.url = "tarball+https://git.tatikoma.dev/corpix/gerbil-nix/archive/v2024-05-12.9.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, gerbil }:
    flake-utils.lib.eachDefaultSystem
      (arch:
        let
          pkgs = nixpkgs.legacyPackages.${arch}.pkgs;

          inherit (pkgs)
            writeScript
            stdenv
          ;
          inherit (pkgs.lib)
            attrValues
            filter
          ;

          packages = attrValues {
            inherit (pkgs)
              coreutils
              gnumake
              gcc
            ;
            glibc = pkgs.glibc; #.static;
            zlib = pkgs.zlib.static;
            openssl = pkgs.openssl.override { static = true; };
            sqlite = pkgs.sqlite.overrideAttrs (super: { configureFlags = super.configureFlags ++ ["--enable-static" "--disable-shared"]; });
            gerbil = gerbil.packages.${arch}.static;
            #inherit (pkgs) mosquitto;
            mosquitto = pkgs.mosquitto.overrideAttrs (super: { cmakeFlags = super.cmakeFlags ++ ["-DWITH_STATIC_LIBRARIES=ON"]; });
          };
        in {
          devShells.default = pkgs.mkShell {
            name = "gerbil-mosquitto";
            packages = packages;
          };
        });
}
