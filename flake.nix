{
  inputs = {
    nixpkgs.url = "tarball+https://github.com/corpix/nixpkgs/archive/v2024-07-23.655030.tar.gz";
    gerbil.url = "tarball+https://github.com/corpix/gerbil-nix/archive/v2024-07-23.54.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, gerbil }: let
    eachSystem = flake-utils.lib.eachSystem flake-utils.lib.allSystems;
  in
    eachSystem
      (arch:
        let
          pkgs = nixpkgs.legacyPackages.${arch}.pkgs;

          inherit (builtins)
            removeAttrs
          ;

          inherit (pkgs)
            writeText
            writeScript
            stdenv
          ;
          inherit (pkgs.lib)
            attrValues
            filter
          ;

          mosquitto = pkgs.mosquitto.overrideAttrs (super: {
            cmakeFlags = super.cmakeFlags ++ ["-DWITH_STATIC_LIBRARIES=ON"];
          });

          packages = [
            pkgs.coreutils
            pkgs.gnumake
            pkgs.git
            pkgs.gcc
            pkgs.glibc.static
            (pkgs.zlib.override { shared = false; static = true; })
            (pkgs.openssl.override { static = true; })
            (pkgs.sqlite.overrideAttrs (super: { configureFlags = super.configureFlags ++ ["--enable-static" "--disable-shared"]; }))
            gerbil.packages.${arch}.gerbil-static
            mosquitto
          ];

        in {
          packages.default = gerbil.stdenv.${arch}.static.mkGerbilPackage {
            name = "gerbil-mosquitto";
            src = ./.;
            propagatedNativeBuildInputs = [
              pkgs.git
              mosquitto
            ];
            buildPhase = ''
              make
            '';
            installPhase = ''
              mkdir -p $out/gerbil
              mv .gerbil/lib $out/gerbil
            '';
          };

          devShells.default = pkgs.mkShell {
            name = "gerbil-mosquitto";
            packages = packages;
          };
        });
}
