{
  description = "GitButler desktop app packaged from the official .deb";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "0.19.7";
      buildNumber = "2956";

      src = pkgs.fetchurl {
        url = "https://releases.gitbutler.com/releases/release/${version}-${buildNumber}/linux/x86_64/GitButler_${version}_amd64.deb";
        hash = "sha256-/CVTeOl75rdZGHIfZUpxZqhl4sIaGevhG54OcAUHe9c=";
      };

      gitbutler = pkgs.stdenv.mkDerivation {
        pname = "gitbutler";
        inherit version src;

        nativeBuildInputs = with pkgs; [
          dpkg
          autoPatchelfHook
          wrapGAppsHook3
          gobject-introspection
        ];

        buildInputs = with pkgs; [
          gtk3
          gdk-pixbuf
          cairo
          glib
          webkitgtk_4_1
          libsoup_3
          dbus
          zlib
          openssl
        ];

        runtimeDependencies = with pkgs; [
          gtk3
          webkitgtk_4_1
          libsoup_3
        ];

        unpackPhase = ''
          dpkg-deb -x $src .
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          cp usr/bin/gitbutler-tauri $out/bin/gitbutler-tauri
          ln -s gitbutler-tauri $out/bin/gitbutler
          cp usr/bin/gitbutler-git-askpass $out/bin/

          mkdir -p $out/share
          cp -r usr/share/icons $out/share/
          cp -r usr/share/applications $out/share/
          cp -r usr/share/metainfo $out/share/

          substituteInPlace $out/share/applications/GitButler.desktop \
            --replace-fail "Exec=gitbutler-tauri" "Exec=$out/bin/gitbutler-tauri"

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Git branch management tool";
          homepage = "https://gitbutler.com";
          license = licenses.free;
          platforms = [ "x86_64-linux" ];
          mainProgram = "gitbutler";
        };
      };
    in
    {
      packages.${system} = {
        default = gitbutler;
        inherit gitbutler;
      };

      apps.${system}.default = {
        type = "app";
        program = "${gitbutler}/bin/gitbutler";
      };
    };
}
