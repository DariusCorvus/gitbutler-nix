# gitbutler-nix

Nix flake that packages the [GitButler](https://gitbutler.com) desktop app from the official `.deb` release.

## Usage

### Run directly

```sh
nix run github:DariusCorvus/gitbutler-nix
```

### Add to a flake

```nix
{
  inputs.gitbutler.url = "github:DariusCorvus/gitbutler-nix";

  # then in your packages / home-manager config:
  # gitbutler.packages.x86_64-linux.default
}
```

### Install to profile

```sh
nix profile install github:DariusCorvus/gitbutler-nix
```

### Try in a shell

```sh
nix shell github:DariusCorvus/gitbutler-nix
gitbutler-tauri
```

## What it does

- Extracts the official GitButler `.deb` for `x86_64-linux`
- Patches the binary with `autoPatchelfHook` (GTK3, WebKitGTK 4.1, libsoup3, dbus, etc.)
- Wraps with `wrapGAppsHook3` for GSettings schemas and icon themes
- Installs the `.desktop` file with `MimeType=x-scheme-handler/but` so the `but gui` CLI command works

## Updating

To bump the version, query the Tauri update endpoint for the latest release info:

```sh
curl -s "https://app.gitbutler.com/releases/release/linux-x86_64/0.0.0"
```

Then update `version`, `buildNumber`, and `hash` in `flake.nix`. Get the new hash with:

```sh
nix-prefetch-url "https://releases.gitbutler.com/releases/release/<version>-<build>/linux/x86_64/GitButler_<version>_amd64.deb"
nix hash convert --hash-algo sha256 --to sri <hash>
```

## License

The packaging code in this repository is MIT licensed. GitButler itself is [FSL-1.1-MIT](https://github.com/gitbutlerapp/gitbutler/blob/master/LICENSE.md).
