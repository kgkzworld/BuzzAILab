---
title: "Buzz - Windows Setup Runbook"
description: "A staged, verification-first plan for building and running Buzz on Windows without placing the live repository inside the Obsidian vault."
tags:
 - "buzz"
 - "windows"
 - "setup"
 - "runbook"
 - "docker"
 - "git-bash"
category: "AI / Buzz / Operations"
---
# Buzz - Windows Setup Runbook

> [!note] Status
> Shareable Windows installation runbook, grounded in a completed native Windows build. Current users must query an official release tag and verify that release's requirements rather than copying the historical versions below.

## Recommended layout

```text
C:\src\buzz                         # live repository
C:\Users\<you>\Documents\BuzzNotes # non-secret documentation
```

Do not clone Buzz into the Google Drive-backed Obsidian vault.

## Stage 1: Use the official source

- [ ] Select the official upstream repository: `https://github.com/block/buzz`.
- [ ] Select and record an immutable official release tag.
- [ ] Record the selected branch and commit in [Buzz - Decisions and Build Log](../decisions-and-build-log.md).

Selected source:

```text
https://github.com/block/buzz
```

## Windows and WSL model

- Buzz can be built and run natively on 64-bit Windows.
- Run repository commands from **Git Bash**, including `. ./bin/activate-hermit` and `just` recipes.
- WSL is not required for the Buzz source tree, desktop app, or agent shell.
- Docker Desktop may use its WSL 2 backend internally; that implementation detail does not make Buzz a WSL installation.
- Keep the repository on the Windows filesystem, for example `C:\src\buzz`.
- Avoid running the same checkout interchangeably from Git Bash and WSL because path formats, permissions, dependencies, and build artifacts can diverge.
- If shell auto-detection selects WSL Bash, set `BUZZ_SHELL=C:\Program Files\Git\bin\bash.exe`.

## Stage 2: Audit prerequisites

- [x] Windows 11 64-bit environment
- [x] Git for Windows and Git Bash
- [ ] Docker Desktop with its engine running
- [ ] Hermit, preferred for the repository-pinned toolchain
- [ ] Node.js 24+
- [ ] pnpm 10+
- [ ] Rust 1.88+
- [ ] `just`
- [ ] Sufficient local disk space for dependencies, images, and build artifacts

When Hermit is used, avoid independently upgrading pinned project tools without a documented reason.

## Stage 3: Clone locally

Clone the official repository:

```bash
cd /c/src
git clone --branch desktop-vX.Y.Z --depth 1 https://github.com/block/buzz.git
cd buzz
git status --short --branch
git rev-parse HEAD
git remote -v
```

Record the resolved commit before setup.

## Stage 4: Activate the pinned environment

Run from Git Bash:

```bash
. ./bin/activate-hermit
```

Confirm versions after activation:

```bash
node --version
pnpm --version
rustc --version
just --version
docker version
```

## Stage 5: Review before bootstrap

- [ ] Read repository `AGENTS.md`, if present.
- [ ] Read `.env.example` without adding secrets to Obsidian.
- [ ] Inspect `just setup` and related recipes.
- [ ] Confirm Docker targets and volume names.
- [ ] Confirm no ports conflict with existing services.

## Stage 6: Bootstrap and build

```bash
just setup
just build
```

Expected setup behavior from the README:

- Copy `.env.example` to `.env` when necessary
- Download required tools through Hermit
- Start Docker services
- Run migrations

## Stage 7: Run and verify

```bash
just dev
```

Expected relay:

```text
ws://localhost:3000
```

Alternative split-terminal workflow:

```bash
just relay
```

```bash
just desktop-dev
```

Verification checklist:

- [ ] Relay accepts a connection.
- [ ] Desktop application launches.
- [ ] Desktop connects to the intended relay.
- [ ] A local identity can be created or loaded.
- [ ] A test channel/message persists across restart.
- [ ] PostgreSQL, Redis, and MinIO containers are healthy.
- [ ] Search and audit history function.

## Stage 8: Baseline checks

```bash
just check
just test-unit
```

Run the full suite only after the basic environment is stable:

```bash
just test
```

## Safety

> [!danger]
> `just reset` wipes local Buzz development data and recreates the environment. Do not run it casually or through an auto-approved agent.

Keep agent command approval enabled until the environment boundaries and destructive recipes have been reviewed.

## Known fixes from the completed Windows build

The following observations explain what was fixed in the real setup. They are troubleshooting evidence, not instructions to copy versions or configuration blindly:

- Repository: `https://github.com/block/buzz`
- Installed commit: `9213090f6076bf3b7667b9b984752b3e47ef8f2f`
- Desktop version: `0.5.5`
- Installed application: `C:\Program Files\Buzz\buzz-desktop.exe`
- Relay: `ws://localhost:3001`
- Health endpoint: `http://127.0.0.1:8080/_readiness`
- Port 3001 was selected because another local application owned port 3000. Identify the current owner before choosing an alternative; never terminate it blindly.
- Docker Desktop uses its WSL 2 backend; Buzz and its source/build toolchain remain native Windows.
- The repository's generated Hermit launchers do not currently bootstrap on Windows Git Bash. The documented manual-toolchain path was used instead: Rust 1.95.0 MSVC, pnpm 11.4.0, `just` 1.46.0, Lefthook 2.1.3, CMake 4.3.1, and Visual Studio 2022 C++ Build Tools.
- An ignored local `docker-compose.override.yml` raised Keycloak's memory limit from 512 MB to 1 GB and replaced a health probe aimed at a disabled endpoint with a verified working endpoint. Apply an override only after reproducing the issue on the selected release.

## Automatic startup — configured 2026-08-06

Docker Desktop and the Buzz relay are configured to start automatically after the `win-workstation\<you>` user logs on.

### Startup components

| Component | Configuration |
| --- | --- |
| Docker Desktop | `AutoStart: true` in `%APPDATA%\Docker\settings-store.json` |
| Scheduled task | `Buzz Stack Autostart` |
| Trigger | User logon, delayed 15 seconds |
| Run mode | Hidden, highest available privileges, only while the user is logged on |
| Controller | `C:\ProgramData\Buzz\Start-BuzzStack.ps1` |
| Startup log | `C:\ProgramData\Buzz\logs\startup.log` |
| Relay stdout | `C:\ProgramData\Buzz\logs\relay.stdout.log` |
| Relay stderr | `C:\ProgramData\Buzz\logs\relay.stderr.log` |

### Startup sequence

1. Start Docker Desktop if it is not already running.
2. Wait up to four minutes for the Docker engine.
3. Run `docker compose up -d` from `D:\Source\Dev\buzz`.
4. Wait for PostgreSQL and Redis health checks.
5. Inspect port 3001 before starting the relay.
6. Reuse an existing `buzz-relay` listener instead of launching a duplicate.
7. Fail safely if another process owns port 3001.
8. Start `target\debug\buzz-relay.exe` when needed.
9. Require `http://127.0.0.1:8080/_readiness` to report `ready`.

The scheduled task uses the `IgnoreNew` multiple-instance policy, runs on battery power, does not stop when power changes, and has a ten-minute execution limit for startup orchestration. The relay continues running after the controller exits.

### Manual verification

```powershell
Start-ScheduledTask -TaskName 'Buzz Stack Autostart'
Get-ScheduledTaskInfo -TaskName 'Buzz Stack Autostart'
Get-Content 'C:\ProgramData\Buzz\logs\startup.log' -Tail 20
Invoke-RestMethod 'http://127.0.0.1:8080/_readiness'
```

Expected Task Scheduler result: `LastTaskResult = 0`.

Verified with both startup paths:

- With the relay already running, the task completed successfully without starting a duplicate.
- After deliberately stopping the relay, the task created a fresh `buzz-relay.exe` process and restored `http://127.0.0.1:8080/_readiness` successfully.
- Final state: task `Ready`, `LastTaskResult = 0`, Docker `AutoStart = true`, relay PID `53968`.

### Disable or rollback autostart

Disable only the Buzz orchestration task:

```powershell
Disable-ScheduledTask -TaskName 'Buzz Stack Autostart'
```

Re-enable it:

```powershell
Enable-ScheduledTask -TaskName 'Buzz Stack Autostart'
```

Removing the scheduled task does not remove Buzz, Docker images, containers, or volumes:

```powershell
Unregister-ScheduledTask -TaskName 'Buzz Stack Autostart' -Confirm
```

Docker Desktop autostart can be toggled from Docker Desktop settings. Do not edit or delete Buzz data volumes merely to change startup behavior.
