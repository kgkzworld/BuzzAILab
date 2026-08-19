---
title: "Buzz - macOS Source Build Guide - Generic"
description: "Sanitized technical guide for building and validating Buzz from source on Apple Silicon or Intel macOS."
tags:
 - "buzz"
 - "macos"
 - "source-build"
 - "shareable"
category: "AI / Buzz / Setup"
---
# Buzz - macOS Source Build Guide - Generic

This is the publishable source-build guide. It deliberately contains no personal community names, email addresses, private keys, identity backups, agent registries, or machine-specific recovery details.

## What this guide builds

The Buzz repository contains several distinct things:

- a native Tauri desktop application;
- a Rust relay and administration tools;
- agent harness and CLI sidecars;
- a local development Compose stack for Postgres, Redis, MinIO, Keycloak, Adminer, and Prometheus;
- a separate production Compose bundle for a single-node or VPS relay.

This guide produces a local macOS development environment and an unsigned native desktop bundle from an immutable official release tag. It does not make a laptop into a secure public relay automatically.

## Security model

Keep these layers separate:

```text
Documentation -> non-secret setup, decisions, and recovery procedures
Source checkout -> repository, dependencies, and build artifacts
macOS Keychain -> application identity secrets
Encrypted backup -> portable identity and private agent state
Docker volumes -> local development or relay data
Community relay -> communities, channels, and message events
```

Never publish or commit:

- a Buzz private key or `nsec`;
- a portable identity backup;
- `BUZZ_PRIVATE_KEY`, `BUZZ_AUTH_TAG`, or provider tokens;
- a complete managed-agent registry;
- a production `.env` file;
- unredacted logs that may contain prompts or private operational data.

## 1. Choose an immutable release

Do not copy a version number from this guide. Query the official repository when you build:

```bash
gh api repos/block/buzz/releases/latest \
 --jq '{tag_name, published_at, target_commitish}'
```

Review the latest release notes and open macOS issues before selecting a tag. Record both the tag and full commit hash in your private build record.

Set task-specific shell variables; do not reuse system variables such as `HOME`:

```bash
BUZZ_TAG='desktop-vX.Y.Z'
BUZZ_SOURCE_ROOT="$HOME/Source/Dev/buzz"
```

## 2. Identify Mac architecture

```bash
uname -m
```

| Result | Tauri target | Release artifact label |
| --- | --- | --- |
| `arm64` | `aarch64-apple-darwin` | `aarch64` |
| `x86_64` | `x86_64-apple-darwin` | `x64` |

Do not run an Intel build recipe on Apple Silicon unless cross-compilation is an intentional, separately tested requirement.

## 3. Prerequisites

Required:

- macOS with Xcode Command Line Tools;
- Git;
- a working Docker-compatible engine with Compose v2.24.4 or newer;
- network access to GitHub, container registries, Rust crates, and npm packages;
- enough disk space for Rust targets, container images, and optional mesh dependencies.

Recommended:

- GitHub CLI (`gh`) for release inspection;
- the repository's Hermit environment for pinned Rust, Node, pnpm, `just`, and Lefthook versions.

Check the baseline:

```bash
xcode-select -p
git --version
docker info
docker compose version
gh --version
```

Docker Desktop, Rancher Desktop, Colima, and OrbStack can all expose a Docker-compatible API, but compatibility is empirical. Select one engine, verify its Docker context, and run the migration and port checks. Do not keep multiple engines active unless you understand which context owns each set of volumes.

## 4. Clone outside synced storage

Do not place the live repository inside iCloud Drive, Google Drive, Dropbox, OneDrive, an Obsidian vault, or another synchronized folder.

```bash
BUZZ_TAG='desktop-vX.Y.Z'
BUZZ_SOURCE_ROOT="$HOME/Source/Dev/buzz"

mkdir -p "$HOME/Source/Dev"
git clone --branch "$BUZZ_TAG" --depth 1 \
 https://github.com/block/buzz.git "$BUZZ_SOURCE_ROOT"
cd "$BUZZ_SOURCE_ROOT"
git status --short --branch
git rev-parse HEAD
git remote -v
```

Read `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, and any release-specific notes before building.

## 5. Activate the pinned toolchain

```bash
cd "$BUZZ_SOURCE_ROOT"
. ./bin/activate-hermit

node --version
pnpm --version
rustc --version
cargo --version
just --version
docker compose version
```

Hermit downloads pinned tools on first use. Its first activation may take time.

## 6. Bootstrap local development infrastructure

```bash
just setup
```

This operation creates a development `.env` from `.env.example` if needed, starts the root Compose services, applies database migrations, installs JavaScript dependencies, and installs repository hooks.

Verify:

```bash
docker compose ps
```

Default development endpoints include:

| Service | Endpoint |
| --- | --- |
| Postgres | `localhost:5432` |
| Redis | `localhost:6379` |
| MinIO | `localhost:9000` and `localhost:9001` |
| Adminer | `http://localhost:8082` |
| Keycloak | `http://localhost:8180` |
| Prometheus | `http://localhost:9090` |

If a database migration sees connection resets while the container itself is healthy, test the host port and the selected Docker context. A container engine's host-port forwarding can fail independently of container health. Switching engines is preferable to weakening Buzz or bypassing migrations.

## 7. Build the Rust workspace

```bash
. ./bin/activate-hermit
just build
```

A successful build ends with the complete Rust workspace in the `dev` profile. This proves the server-side workspace compiles but does not by itself create an installable desktop application.

## 8. Build real desktop sidecars

The native app expects companion executables. Build and stage them before creating a local release bundle:

```bash
. ./bin/activate-hermit

cargo build --release \
 -p buzz-acp \
 -p buzz-agent \
 -p buzz-backend-kubernetes \
 -p buzz-dev-mcp \
 -p buzz-cli \
 -p git-credential-nostr

BUZZ_TARGET="$(rustc -vV | sed -n 's|host: ||p')"
mkdir -p desktop/src-tauri/binaries

for BUZZ_BIN_NAME in \
 buzz-acp buzz-agent buzz-backend-kubernetes \
 buzz-dev-mcp git-credential-nostr buzz
do
 cp "target/release/$BUZZ_BIN_NAME" \
 "desktop/src-tauri/binaries/$BUZZ_BIN_NAME-$BUZZ_TARGET"
 chmod +x \
 "desktop/src-tauri/binaries/$BUZZ_BIN_NAME-$BUZZ_TARGET"
done
```

> [!warning] Placeholder sidecars are not a usable installation
> Tauri validates declared external binaries at build time, so upstream recipes may create zero-byte placeholders. Confirm your staged files are real executables before bundling.

```bash
find desktop/src-tauri/binaries -type f -size 0 -print
```

The command should print nothing for the selected target.

## 9. Build the native application

Apple Silicon:

```bash
just desktop-release-build aarch64-apple-darwin
```

Intel:

```bash
just desktop-release-build x86_64-apple-darwin
```

The full recipe enables optional mesh/LLM support and may compile hundreds of additional crates.

Expected outputs follow this pattern:

```text
desktop/src-tauri/target/<target>/release/bundle/macos/Buzz.app
desktop/src-tauri/target/<target>/release/bundle/dmg/Buzz_<version>_<arch>.dmg
```

## 10. Verify the bundle before installation

```bash
BUZZ_APP="desktop/src-tauri/target/$BUZZ_TARGET/release/bundle/macos/Buzz.app"

file "$BUZZ_APP/Contents/MacOS/buzz-desktop"
find "$BUZZ_APP/Contents/MacOS" -maxdepth 1 -type f -exec ls -lh {} \;
codesign -dv --verbose=2 "$BUZZ_APP" 2>&1 | head -30
```

Confirm:

- the main executable matches the Mac architecture;
- every required companion executable is present and non-empty;
- the version matches the selected tag;
- the source tree remains at the recorded commit.

A local source build is normally ad-hoc signed. It is not the same artifact as the official notarized release. Do not redistribute your local app bundle as though it were vendor-signed.

## 11. Install and launch

Quit any running Buzz instance before replacing it. Preserve existing identity and app state before upgrades.

For a new installation, copy the verified `Buzz.app` to `/Applications` using Finder or a standard macOS copy operation. Launch it normally. Do not bypass an unexpected Gatekeeper warning; re-check the source, commit, architecture, and signature first.

Buzz may ask you to:

- create a new identity;
- enter an existing private key;
- select a portable backup file;
- recover from a paired phone.

Do not create a new identity during a migration merely because recovery material is temporarily unavailable. A new key is a different identity and may not have access to existing private communities or encrypted rooms.

## 12. Development run mode

```bash
cd "$BUZZ_SOURCE_ROOT"
. ./bin/activate-hermit
just dev
```

This starts the local relay at `ws://localhost:3000` and launches a development desktop instance. Development and production desktop builds may use different app identifiers, Keychain services, and workspace directories. Do not assume that signing into a development build configures the installed production app.

Stop supporting containers without deleting data:

```bash
docker compose down
```

Avoid reset recipes unless the data is explicitly disposable and backed up.

## 13. Community versus self-community relay

A community has a public `wss://` relay URL managed by its provider. Desktop and mobile clients connect directly to that URL. A Mac running the desktop client does not need public inbound ports merely so another device can join the same community.

A self-hosted public relay is a different deployment. Use the production bundle under `deploy/compose/`, not the root development Compose file. Plan for:

- stable DNS;
- trusted TLS certificates;
- closed-relay owner and membership configuration;
- strong, stable secrets;
- encrypted backups of Postgres, MinIO, and identity material;
- monitoring and update procedures;
- a reverse proxy or carefully controlled tunnel;
- an explicit mobile pairing and push-notification design.

Never expose the unencrypted local-development URL `ws://localhost:3000` directly to the internet.

## 14. Identity backup and recovery

After the first successful sign-in:

1. Use Buzz's supported portable backup/export flow.
2. Store the backup in an encrypted destination outside public documentation and source control.
3. Record a checksum separately.
4. Test that the backup can be selected and parsed without completing a destructive replacement.
5. Document which identity and communities it protects without recording the private key.

Back up agent workspaces and registries separately if you use managed agents. The owner's portable identity backup does not necessarily contain every agent's private state, memory, provider login, or working files.

## 15. Upgrade procedure

Before upgrading:

```bash
git status --short --branch
git rev-parse HEAD
docker compose ps
```

Then:

1. Export and verify current identity and agent backups.
2. Review release notes and macOS issues.
3. Fetch the new immutable tag into a separate checkout or clean worktree.
4. Repeat setup, workspace build, sidecar staging, desktop build, and bundle verification.
5. Launch once without enabling automatic agent startup.
6. Verify identity, community history, CLI tools, and one agent turn.
7. Retain the prior app and encrypted backup until several normal sessions succeed.

## Acceptance checklist

- [ ] Official repository and immutable tag recorded.
- [ ] Full commit hash recorded.
- [ ] Correct Mac architecture selected.
- [ ] Docker context and engine verified.
- [ ] `just setup` completed with migrations.
- [ ] `just build` completed.
- [ ] Real release-mode sidecars staged.
- [ ] Native `.app` and `.dmg` produced.
- [ ] Bundle architecture, version, and sidecar sizes verified.
- [ ] Existing identity recovered or a deliberate new identity created.
- [ ] Intended community opens with expected rooms and history.
- [ ] One CLI operation succeeds.
- [ ] One managed agent turn succeeds, if agents are used.
- [ ] Portable identity backup created and tested.
- [ ] Public networking remains closed unless a production relay was intentionally deployed.

## Authoritative references

- [Official Buzz repository](https://github.com/block/buzz)
- [Official Buzz releases](https://github.com/block/buzz/releases)
- [Buzz README](https://github.com/block/buzz/blob/main/README.md)
- [Buzz contributor setup](https://github.com/block/buzz/blob/main/CONTRIBUTING.md)
- [Buzz production Compose guide](https://github.com/block/buzz/blob/main/deploy/compose/README.md)
