---
title: "Buzz - macOS and Server Deployment Runbook"
description: "Reproducible runbook for restoring the owner's Buzz Desktop on macOS and deploying a new single-node Buzz relay for another operator."
tags:
 - "buzz"
 - "macos"
 - "server"
 - "deployment"
 - "handoff"
category: "AI / Buzz / Operations"
---
# Buzz - macOS and Server Deployment Runbook

This runbook has two deliberately separate tracks:

- **Track A — move the existing installation to a Mac.** Preserve the same owner and agent identities, communities, prompts, teams, workspaces, and the locally patched `buzz-acp` behavior.
- **Track B — give another operator their own Buzz infrastructure.** Create new owner/server secrets and deploy a reproducible single-node relay. Do not clone the owner's identity or private agent registry for another person.

Use [Buzz - Machine Migration and Recovery](machine-migration-and-recovery.md) for the source-machine backup and final acceptance checklist. Never put a private key, `.env`, registry backup, provider token, or decrypted archive in this Obsidian folder or in Git.

## Private-key location and portability boundary

Verified on the Windows source machine:

```text
Windows Credential Manager target: LegacyGeneric:target=secrets.buzz-desktop
Buzz keyring service: buzz-desktop
Blob username/key: secrets
Owner logical entry: identity
Agent logical entries: agent:<agent-public-key>
App migration marker: %APPDATA%\xyz.block.buzz.app\identity.migrated
```

The Credential Manager value is a secret JSON blob and must never be printed into a terminal transcript or copied into this vault. The marker is not a key. `managed-agents.json` intentionally clears the private-key field after writing each key into the OS keyring.

For the owner identity, Buzz provides the supported cross-platform route: **Settings → Profile → Private key backup** creates a password-protected NIP-49 `.ncryptsec` file and includes a **Test backup** flow. Create and test that file on Windows before migration; keep its passphrase in a separate password manager entry. On macOS onboarding, import the `.ncryptsec` file and passphrase, then compare the resulting public key with the source.

The owner backup does not automatically include managed-agent keys. Each existing agent identity has its own key under `agent:<pubkey>`. Until Buzz supplies a supported bulk agent-key export/import, preserving the source Windows installation and verifying all 34 destination pubkeys is a migration gate. Do not assume app-data restore can regenerate the same keys; regenerated agents would be new identities.

## Release baseline and required customization

| Item | Required value |
| --- | --- |
| Repository | `https://github.com/block/buzz.git` |
| Baseline commit | `9213090f6076bf3b7667b9b984752b3e47ef8f2f` |
| Desktop version | `0.5.5` |
| macOS bundle identifier | `xyz.block.buzz.app` |
| Local source patch | **Required for parity**; three modified `buzz-acp` files, exported before migration |
| Communities | `<community>`, `<community>`, `<community>` |

The source machine is not a stock checkout. On 2026-08-15, `git status` reported modifications to:

```text
crates/buzz-acp/src/config.rs
crates/buzz-acp/src/lib.rs
crates/buzz-acp/src/queue.rs
```

They reduce automatic context from 12 messages to 6, rotate ACP sessions after 8 turns, treat authentication/account/session/credit/quota failures as terminal, and reduce ordinary retry count from 10 to 1. These changes are part of the operating configuration. A clone of the pinned commit without the patch is not equivalent.

Before leaving Windows, export and verify the patch into the encrypted migration bundle:

```powershell
$backup = '<absolute-path-to-encrypted-backup>'
git -C 'D:\Source\Dev\buzz' diff --binary --full-index -- `
 crates/buzz-acp/src/config.rs `
 crates/buzz-acp/src/lib.rs `
 crates/buzz-acp/src/queue.rs |
 Set-Content -LiteralPath (Join-Path $backup 'buzz-9213090-local.patch') -Encoding utf8

git -C 'D:\Source\Dev\buzz' diff --check
Get-FileHash -Algorithm SHA256 (Join-Path $backup 'buzz-9213090-local.patch')
```

Save the printed checksum beside, not inside, the archive. Also save these non-secret audit outputs:

```powershell
git -C 'D:\Source\Dev\buzz' rev-parse HEAD
git -C 'D:\Source\Dev\buzz' status --short
git -C 'D:\Source\Dev\buzz' remote get-url origin
```

## Track A: restore the existing installation on macOS

### 1. Decide what the Mac will run

The normal migration uses Buzz Desktop on the Mac and continues connecting to the three communities. The local Docker development relay is optional; it is not needed merely to reconnect to communities. Install the local development stack only if you develop Buzz or need the old local relay.

Determine the CPU architecture:

```bash
uname -m
```

- `arm64`: Apple Silicon; use target `aarch64-apple-darwin`.
- `x86_64`: Intel Mac; use target `x86_64-apple-darwin`.

### 2. Install prerequisites

Install current macOS updates, Xcode Command Line Tools, Git, Docker Desktop only if the local stack is required, and provider CLIs used by the agents.

```bash
xcode-select --install
git --version
```

For a source build, use the repository-pinned Hermit toolchain. The documented fallback minimums for this baseline are Rust 1.88+, Node 24+, pnpm 10+, and `just`. Do not copy Windows executables or `node_modules` to the Mac.

### 3. Clone the exact baseline and apply the local patch

Keep source outside Google Drive/iCloud-synced folders:

```bash
mkdir -p "$HOME/src"
git clone https://github.com/block/buzz.git "$HOME/src/buzz"
cd "$HOME/src/buzz"
git checkout --detach 9213090f6076bf3b7667b9b984752b3e47ef8f2f
. ./bin/activate-hermit
git apply --check '/Volumes/<encrypted-media>/buzz-9213090-local.patch'
git apply '/Volumes/<encrypted-media>/buzz-9213090-local.patch'
git diff --check
git status --short
```

Expected status: exactly the same three modified files listed above. If `git apply --check` fails, stop; do not hand-recreate the patch or switch commits.

### 4. Build and test the matching desktop

From the repository root:

```bash
. ./bin/activate-hermit
just setup
cargo test -p buzz-acp
just desktop-release-build "$(if [ "$(uname -m)" = arm64 ]; then echo aarch64-apple-darwin; else echo x86_64-apple-darwin; fi)"
```

The unsigned local bundle/DMG is produced under the Tauri target output beneath `desktop/src-tauri/target/<target>/release/bundle/`. Use `find desktop/src-tauri/target -path '*release/bundle*' -maxdepth 8 -type f` to locate it. A locally built unsigned app may require macOS privacy/security approval. For redistribution, use a signed and notarized release; do not tell recipients to bypass Gatekeeper.

If parity with the custom patch is not required, an official architecture-matched DMG can be used instead. That is a stock Buzz install and must not be described as an exact migration.

### 5. Create and stop the destination app once

Install Buzz into `/Applications`, launch it once to create its data directories, then quit it completely. Verify there are no running Buzz processes:

```bash
pgrep -afil 'Buzz|buzz-acp|buzz-agent' || true
```

Back up the newly created empty destination state before replacing it.

During onboarding, import the tested `.ncryptsec` owner backup rather than creating a new identity. Confirm the displayed public key matches the source before proceeding.

### 6. Restore app and workspace state

The expected production app-data directory follows the bundle identifier:

```text
~/Library/Application Support/xyz.block.buzz.app/
```

Restore the contents of the encrypted Windows `%APPDATA%\xyz.block.buzz.app\` backup into that directory while Buzz is stopped. Do not restore `agents/agent-pids/`; PIDs are machine-local. Preserve file permissions so only the destination user can read the restored private state.

Restore the shared workspace to:

```text
~/.buzz/
```

Then search both restored trees for Windows-only paths without printing credential values:

```bash
rg -n -uu 'C:\\Users\\<you>|D:\\Source\\Dev\\buzz|<cloud-drive>|<cloud-drive>' \
 "$HOME/.buzz" "$HOME/Library/Application Support/xyz.block.buzz.app/agents"
```

Path mapping must be decided before agents autostart. Recommended mappings are symlinks or prompt/config edits to stable Mac roots, for example:

```text
<vault> -> ~/Library/CloudStorage/GoogleDrive-<account>/My Drive/Notebooks/personal
D:\Source\Dev\buzz -> ~/src/buzz
C:\Users\<you>\.buzz -> ~/.buzz
```

Google Drive folder names vary by account and client version. Discover the actual path with `find "$HOME/Library/CloudStorage" -maxdepth 3 -type d -name 'My Drive' -print`; never paste a guessed path into agent prompts. Let Google Drive finish syncing and make required folders available offline before starting agents.

### 7. Recreate machine-local integrations

Windows scheduled tasks and `.cmd`/`.ps1` wrappers do not transfer to macOS. Recreate only their intent:

- Add Buzz Desktop to **System Settings → General → Login Items** after the manual restore passes.
- Start Docker Desktop at login only if using a local relay.
- Reinstall and authenticate Claude Code, Codex, Goose, and Antigravity as applicable.
- Replace Windows wrapper commands with executable macOS shell scripts or restore the default bundled ACP command.
- Recreate any agent's additional writable directories using real macOS paths. Windows `.cmd` harness wrappers under `%APPDATA%\Buzz\node-tools\` and patched Windows adapters cannot run on macOS.

Do not enable login startup until a manual Buzz launch passes the acceptance test.

### 8. First launch sequence

1. Disconnect the old Windows machine from the network or keep Buzz Desktop stopped to avoid two desktops launching the same 34 agent identities.
2. Start provider CLIs and confirm their authentication independently.
3. Start the local relay only if it is needed.
4. Launch Buzz Desktop on the Mac.
5. Confirm the same owner identity and three communities before allowing all agent harnesses to run.
6. Execute the acceptance checklist in [Buzz - Machine Migration and Recovery](machine-migration-and-recovery.md#acceptance-test).
7. Keep the Windows installation and encrypted backup intact until several normal sessions succeed.

## Track B: deploy a fresh Buzz relay for another operator

This track creates independent infrastructure. Never provide another operator with the owner's `%APPDATA%` backup, `.buzz` workspace, owner private key, agent private keys, provider sessions, or hosted-community credentials.

### 1. Server prerequisites and network

Use a supported 64-bit Linux VPS with a static public IP, DNS name, Docker Engine, Docker Compose v2.24.4 or newer, Git, `curl`, and enough persistent disk for Postgres, MinIO, Git data, logs, and backups. Open inbound TCP 80 and 443 when using bundled Caddy/TLS. Do not expose Postgres, Redis, MinIO, or Adminer publicly.

Create DNS `A`/`AAAA` records for the chosen hostname before requesting TLS. Confirm the firewall and cloud security group agree.

### 2. Pin source and image versions

```bash
sudo mkdir -p /opt/buzz
sudo chown "$USER":"$USER" /opt/buzz
git clone https://github.com/block/buzz.git /opt/buzz/source
cd /opt/buzz/source
git checkout --detach 9213090f6076bf3b7667b9b984752b3e47ef8f2f
```

The production bundle is `deploy/compose/`, not the repository-root development Compose file. In `.env`, pin `BUZZ_IMAGE` to an immutable digest or known `sha-<7>`/release tag. `ghcr.io/block/buzz:main` is moving and is unsuitable for a reproducible handoff.

### 3. Generate unique secrets

```bash
cd /opt/buzz/source/deploy/compose
cp .env.example .env
chmod 600 .env
openssl rand -hex 32 # relay private key: store output securely
openssl rand -hex 32 # git-hook HMAC secret
openssl rand -base64 36 # database password
openssl rand -base64 36 # Redis password
openssl rand -hex 20 # MinIO access key
openssl rand -base64 36 # MinIO secret key
```

Generate each value separately and place it directly in the protected `.env`; avoid shell history and screen sharing. Set the operator's 64-character hex public key in `RELAY_OWNER_PUBKEY`. Set the public domain consistently in `BUZZ_DOMAIN`, `RELAY_URL`, media URLs, and CORS origins. Keep relay, HMAC, database, Redis, and S3 secrets stable across restarts.

### 4. Validate configuration before starting

```bash
cd /opt/buzz/source/deploy/compose
./run.sh config
docker compose config --quiet
```

Inspect the rendered configuration for unwanted host port exposure. Do not paste rendered output into tickets because it may contain secrets.

### 5. Start with TLS and verify

```bash
cd /opt/buzz/source/deploy/compose
BUZZ_COMPOSE_TLS=true ./run.sh start
./run.sh status
curl -fsS https://buzz.example.com/_liveness
curl -fsS https://buzz.example.com/_readiness
```

Replace the example hostname. Confirm the certificate is trusted, WebSocket upgrade works, and a desktop client can connect with the intended owner identity. Keep `BUZZ_REQUIRE_AUTH_TOKEN=true` and `BUZZ_REQUIRE_RELAY_MEMBERSHIP=true` unless there is a reviewed reason to operate an open relay.

### 6. Persistence, backup, and restore drill

Record the exact Git commit, image digest, Compose version, hostname, volume names, and restore owner. Back up:

- the protected `.env` through a secrets manager or encrypted backup;
- Postgres with a consistent logical dump;
- MinIO media data and configuration;
- the Git data volume;
- the relay identity and HMAC secrets;
- Compose files and any reviewed overrides.

Redis is operational state; the authoritative durable records are Postgres/object/Git data, but keep its password stable. Run `./run.sh backup-hint`, then write the chosen commands, schedule, retention, encryption, off-host destination, and responsible person into the receiving operator's runbook. Perform a restore drill on an isolated host before calling the service production-ready.

### 7. Updates and rollback

Never update by pulling `main` and restarting blindly. For each change:

1. Back up durable state and `.env`.
2. Record the current commit and image digest.
3. Review release notes and migrations.
4. Pin the new commit/image in a test environment.
5. Run configuration validation and health checks.
6. Test login, channel history, posting, media, and agent access.
7. Promote during a maintenance window.
8. Retain the prior image and a compatible pre-migration backup for rollback.

## Handoff package checklist

The package for another operator contains documentation and non-secret templates only:

> [!danger] Mandatory exclusion
> Never include `Buzz - Private Identity Recovery.md`. It contains the owner's live owner private key. Other operators generate their own keys.

- [ ] This runbook and the linked architecture/operations notes.
- [ ] Exact source commit and immutable container image digest.
- [ ] A sanitized `.env.example` with every secret replaced by `CHANGE_ME`.
- [ ] DNS, firewall, port, storage, backup, monitoring, upgrade, and restore decisions.
- [ ] Named service owner and emergency contact.
- [ ] Acceptance-test evidence with no tokens or private keys.

The operator receives secrets through a separate approved secret channel. The owner's personal migration archive is never part of a generic server handoff.
