{
  inputs = {
    nixpkgs.url = "tarball+https://git.tatikoma.dev/corpix/nixpkgs/archive/v2024-05-29.632320.tar.gz";
    gerbil.url = "tarball+https://git.tatikoma.dev/corpix/gerbil-nix/archive/v2024-05-31.21.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, gerbil }:
    flake-utils.lib.eachDefaultSystem
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
            pkgs.gcc
            pkgs.glibc #.static;
            pkgs.zlib.static
            (pkgs.openssl.override { static = true; })
            (pkgs.sqlite.overrideAttrs (super: { configureFlags = super.configureFlags ++ ["--enable-static" "--disable-shared"]; }))
            gerbil.packages.${arch}.static
            mosquitto

            self.packages.${arch}.default
          ];

        in {
          packages.default = gerbil.stdenv.${arch}.static.mkGerbilPackage {
            name = "gerbil-mosquitto";
            src = ./.;
            propagatedNativeBuildInputs = [
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
