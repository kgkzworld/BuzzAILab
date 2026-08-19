---
title: "Buzz Installation Walkthrough"
description: "The end-to-end Windows and macOS path from an uninspected computer to one validated Buzz agent."
tags: [buzz, installation, windows, macos, ai-guided]
---

# Buzz installation walkthrough

This walkthrough is the human-readable version of the [AI installer prompt](../INSTALL_WITH_AI.md). It is built from a real Windows installation and a later Apple Silicon macOS migration, including the failures that had to be diagnosed before either setup was trustworthy.

## What you are installing

There are three separate layers:

1. **Buzz itself**, built from an immutable official [`block/buzz`](https://github.com/block/buzz) release.
2. **A community and owner identity**, created or recovered through Buzz and protected with an encrypted backup.
3. **Your AI agents**, selected and personalized from this repository after the application works.

BuzzAILab supplies the walkthrough and agent library. It is not the Buzz application source.

## Choose your route

| Your computer | Build route | Important distinction |
| --- | --- | --- |
| Windows 11, 64-bit | [Windows setup](runbooks/windows-setup.md) | Native Windows checkout and Git Bash; Docker Desktop may use WSL 2 internally, but Buzz is not installed inside WSL. |
| Apple Silicon or Intel Mac | [macOS source build](runbooks/macos-source-build.md) | Match the architecture, use one verified Docker-compatible engine, and bundle real sidecars. |

If you want an assistant to inspect the computer and drive the correct route, start with [Install Buzz with an AI assistant](../INSTALL_WITH_AI.md).

## Stage 1 — inspect before changing

Collect the machine facts first:

- OS release and architecture;
- CPU, memory, available disk, GPU, and usable VRAM or unified memory;
- developer toolchain and package manager state;
- Docker-compatible engine, active context, Compose version, and port ownership;
- existing Buzz application data or identities;
- installed Claude Code, Codex, OpenCode, Ollama, and local models.

Turn those facts into a compatibility plan. It should name the official source tag-selection method, container engine, install directories, prerequisites, runtime/model choice, expected downloads, approval points, validation, and rollback. Do not install first and explain later.

## Stage 2 — protect existing state

Before a reinstall, upgrade, or migration:

- stop and identify any existing Buzz instance;
- preserve application data, managed-agent configuration, and Docker volumes without publishing them;
- recover the existing identity through Buzz's supported backup, private-key, or paired-phone flow;
- never create a new identity accidentally during a migration;
- never put an `nsec`, provider token, registry, or decrypted backup into this repository or a synced note.

For a truly new installation, plan where the password-protected identity backup and its separately stored passphrase will live before first launch.

## Stage 3 — select and record official source

Query the current official releases rather than copying a version from this repository. Choose an immutable release tag, clone it outside synchronized storage, and record:

```text
official repository URL
release tag
full commit hash
target OS and architecture
date built
```

Read the selected release's own `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `.env.example`, and the build recipes you are about to invoke. Those files are authoritative for version-specific commands.

## Stage 4 — bootstrap the platform

### Windows

- Keep the checkout on the Windows filesystem.
- Use Git Bash for repository, Hermit, and `just` commands.
- Use Docker Desktop for container services; its WSL 2 backend does not make the source tree a WSL installation.
- Prefer Hermit, but verify the release's launcher actually supports the detected Windows shell. The real build documented here required a native manual toolchain when that launcher failed.

### macOS

- Match `arm64` to `aarch64-apple-darwin` and Intel to `x86_64-apple-darwin`.
- Reuse one healthy Docker-compatible engine. Do not start multiple engines and guess which context owns the volumes.
- Prefer the repository-pinned Hermit environment.
- If containers report healthy while host PostgreSQL connections reset, diagnose Docker context and port forwarding before weakening migrations or database checks.

## Stage 5 — build the application, not only the workspace

A successful Rust workspace build is necessary but does not prove that the native desktop bundle is usable.

The complete path is:

1. bootstrap services and migrations;
2. build the workspace;
3. run the release-appropriate checks;
4. build the companion CLI/agent sidecars in release mode;
5. stage them under the exact target names expected by Tauri;
6. verify that none are zero-byte placeholders;
7. build the OS-native application bundle;
8. verify architecture, version, signature state, executable sizes, and source commit.

Use the OS runbook for exact commands.

## Stage 6 — recognize the real failure patterns

These are not theoretical edge cases; each occurred during the source installations behind this guide.

| Symptom | What it meant | Safe response |
| --- | --- | --- |
| Port 3000 is occupied | Another local application already owns the default relay port | Identify the owner and select a documented alternative; never kill it blindly. |
| Keycloak restarts or stays unhealthy on Windows | The 512 MB limit and inherited health endpoint did not fit the observed build | Use a local, ignored Compose override with enough memory and a verified endpoint; keep the upstream file unchanged. |
| Hermit launcher fails in Windows Git Bash | The generated launcher did not bootstrap on the detected platform | Use the documented native toolchain fallback and verify every installed version. |
| Containers are healthy but migrations see connection resets on macOS | The selected engine's host-port forwarding failed before PostgreSQL | Test context and forwarding; switch to a verified engine instead of bypassing migrations. |
| The macOS app bundles but agent/CLI functions fail | Tauri accepted zero-byte placeholder sidecars | Build and stage real release binaries, then prove their file sizes and architecture. |
| A newly created agent does not appear | `accepted: true` described relay acceptance, not a saved Desktop record | Verify the managed-agent registry before proceeding. |

## Stage 7 — first launch and identity backup

Launch the verified app normally. Resolve unexpected Windows trust or macOS Gatekeeper warnings by rechecking source, architecture, and signature state; do not suppress them reflexively.

After signing in or creating a deliberate new identity:

1. create Buzz's password-protected NIP-49 backup;
2. store the encrypted file outside repositories and synced notes;
3. store the passphrase separately in a password manager or OS keychain;
4. test the supported restore-selection flow;
5. record what the backup protects without writing down the private key.

## Stage 8 — add one agent

Only after Buzz itself is healthy:

1. read [SECURITY.md](../SECURITY.md);
2. personalize paths and scope using [Personalize](personalize.md);
3. create one squad and populate **both** description and instructions;
4. select one platform agent;
5. deploy it with the exact display name, complete system prompt, `owner-only`, parallelism `1`, and autostart disabled;
6. verify the saved registry record;
7. run the six tests in [Getting Started](getting-started.md).

Do not deploy the 51-persona library as a first move. One agent that passes its refusal, evidence, routing, and documentation tests is more useful than a fleet that merely starts.

## Completion checklist

- [ ] Official repository, immutable tag, and full commit recorded.
- [ ] OS, architecture, storage, and prerequisites verified.
- [ ] Source checkout is outside synchronized storage.
- [ ] One container engine and context selected and healthy.
- [ ] Setup and migrations completed.
- [ ] Workspace build and relevant tests passed.
- [ ] Native desktop bundle contains real sidecars.
- [ ] App architecture, version, and signature state inspected.
- [ ] Owner identity deliberately created or recovered.
- [ ] Encrypted identity backup created and tested.
- [ ] One agent saved and all six acceptance tests passed.
- [ ] Remaining limitations and rollback steps recorded.

Anything not tested should be labeled **not tested**, not assumed complete.
