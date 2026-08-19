---
title: "Buzz - Machine Migration and Recovery"
description: "Authoritative pre-move inventory, backup boundary, rebuild order, and verification checklist for moving the complete Buzz environment to Windows or macOS."
tags:
 - "buzz"
 - "migration"
 - "backup"
 - "disaster-recovery"
category: "AI / Buzz / Operations"
---
# Buzz - Machine Migration and Recovery

This is the entry point for moving Buzz to another machine. It records what exists, where the authoritative state lives, what may safely be kept in Obsidian, what must be transferred separately as a secret-bearing backup, and how to prove the restored system is complete. For macOS commands and for a separate new-operator server deployment, use [Buzz - macOS and Server Deployment Runbook](macos-and-server-deployment.md).

> [!danger] The Obsidian folder is documentation, not a complete backup
> Agent private keys, owner identity material, authentication tags, tokens, and relay credentials must **not** be copied into these notes. The agent registry and owner identity must be transferred through an encrypted channel. Without the same identity material, the new machine may see none of the existing private communities or channels and the deployed agents will not retain their identities.

> [!important] The private keys are not in the app-data backup
> Verified: the production build stores one secret JSON blob in Windows Credential Manager under service `buzz-desktop`, username/key `secrets` (displayed as `LegacyGeneric:target=secrets.buzz-desktop`). That blob holds the owner identity entry and `agent:<pubkey>` entries for managed agents. The one-byte `%APPDATA%\xyz.block.buzz.app\identity.migrated` marker confirms migration to the OS keyring. `managed-agents.json` intentionally has no private-key property. A copy of `%APPDATA%` without a portable owner-key backup and a managed-agent key migration is incomplete.

## Documentation map

| Subject | Authoritative note |
| --- | --- |
| Complete persona and identity roster, purpose, runtime, community, public key, and behavior | [Buzz - Agent Roster](../agent-roster.md) |
| All current and proposed squads, members, descriptions, instructions, IDs, and binding mechanics | [Buzz - Squads and Teams](../squads-and-teams.md) |
| Architecture, prompt composition, sessions, identity model, ACP/MCP, and orchestration | [Buzz - Architecture and Agent Integration](../architecture-and-agent-integration.md) |
| Paths, environment variables, startup, daily commands, fleet checks, and troubleshooting | [Buzz - Environment and Operations](../environment-and-operations.md) |
| Native Windows installation and build | [Buzz - Windows Setup Runbook](windows-setup.md) |
| Decisions, pinned source commit, and historical changes | [Buzz - Decisions and Build Log](../decisions-and-build-log.md) |
| Migration order, backup boundary, channels, and acceptance test | This note |
| macOS restore and independent server handoff | [Buzz - macOS and Server Deployment Runbook](macos-and-server-deployment.md) |

## Verified source-machine snapshot

Original live read-only audit on **2026-08-10**, refreshed **2026-08-15**, America/New_York.

| Item | Verified state |
| --- | --- |
| OS model | Native Windows; Git Bash for Buzz workflows; Docker Desktop with WSL 2 backend |
| Official source | `D:\Source\Dev\buzz`, remote `https://github.com/block/buzz.git` |
| Pinned commit | `9213090f6076bf3b7667b9b984752b3e47ef8f2f` on `main` |
| Installed desktop | `C:\Program Files\Buzz\buzz-desktop.exe`, Buzz Desktop 0.5.5 build documented in the setup notes |
| Installed companion binaries | `buzz.exe`, `buzz-acp.exe`, `buzz-agent.exe`, `buzz-dev-mcp.exe`, `git-credential-nostr.exe` in `C:\Program Files\Buzz` |
| Agent registry | 62 records: 28 persona definitions plus 34 deployed identities |
| Autostart flags | 34 of 34 deployed identities set `start_on_app_launch: true` |
| Teams | Welcome Team plus each project squad you have created |
| Team prompt injection | None of the 3 teams has an `instructions` value; only the Welcome Team has deployed identities bound by `team_id` |
| Communities | `<community>`, `<community>`, `<community>`; relay URLs are in [Buzz - Environment and Operations](../environment-and-operations.md#hosted-communities) |
| Shared agent workspace | `C:\Users\<you>\.buzz` |
| Scheduled tasks | `Buzz Stack Autostart` and `Buzz Desktop Autostart` |
| Stack task last result | `0` on 2026-08-09; healthy result |
| Desktop task last result | `4294967295` on 2026-08-09; do not treat as verified success on the destination until the acceptance test passes |
| Registry last modified | `managed-agents.json`: 2026-08-09 23:55 local |
| Teams last modified | `teams.json`: 2026-08-07 00:23 local |
| Source working tree | **Modified:** `crates/buzz-acp/src/config.rs`, `lib.rs`, and `queue.rs`; required runtime safeguards, not disposable build noise |

The roster and squad notes contain the descriptions rather than duplicating them here. That keeps a single human-readable source of truth for each agent and squad.

## State map: what must move

| State | Source path or service | Sensitivity | Migration action |
| --- | --- | --- | --- |
| Obsidian documentation | This `Buzz` folder | Mixed sensitivity | Let Google Drive finish syncing; verify all ten current Buzz notes appear on the owner's destination. `Buzz - Private Identity Recovery.md` is secret-bearing and excluded from all third-party handoffs |
| Source checkout | `D:\Source\Dev\buzz` | Usually non-secret; inspect untracked files | Fresh clone at pinned commit **plus the exported three-file local patch**; see the macOS/server runbook |
| Installed application | `C:\Program Files\Buzz` | Executables | Rebuild/install from the pinned source; do not rely only on copying installed binaries |
| Agent definitions | `%APPDATA%\xyz.block.buzz.app\agents\managed-agents.json` | **Private**; contains auth tags and full system prompts, but no private keys in this build | Encrypted backup and restore only while Buzz Desktop is stopped |
| Owner private key | Windows Credential Manager service `buzz-desktop`, blob entry `secrets`, logical key `identity` | **Critical secret** | Use Buzz Settings → Profile → Private key backup to create and test a password-protected NIP-49 `.ncryptsec` file |
| Managed-agent private keys | Same Credential Manager blob, logical entries `agent:<64-hex-pubkey>` | **Critical secrets** | Must be migrated separately; app-data alone cannot restore the existing 34 identities. Preserve the source machine until every agent pubkey passes the destination test |
| Squad/team records | `%APPDATA%\xyz.block.buzz.app\agents\teams.json` | May contain private project descriptions | Encrypted backup with agent state |
| Global defaults | `%APPDATA%\xyz.block.buzz.app\agents\global-agent-config.json` | Normally non-secret, but back up with agent state | Encrypted backup |
| Retention databases | `%APPDATA%\xyz.block.buzz.app\agents\retention\` | **Private conversation/session metadata** | Encrypted backup if continuity is wanted |
| Harness logs and pid records | `%APPDATA%\xyz.block.buzz.app\agents\logs\`, `agent-pids\` | Logs may expose operational details; pid files are stale after migration | Back up logs for diagnosis; do **not** restore `agent-pids` as live state |
| Owner/Desktop identity marker | `%APPDATA%\xyz.block.buzz.app\identity.migrated` | Non-secret marker only | Restore with app state, but do not mistake it for the key; the portable `.ncryptsec` backup is authoritative for cross-OS restore |
| Shared working memory | `C:\Users\<you>\.buzz` | Private; can contain personal work product | Encrypted backup and restore to the destination user's profile; update absolute paths if username changes |
| Local stack controller | `C:\ProgramData\Buzz\Start-BuzzStack.ps1` and `C:\ProgramData\Buzz\logs\` | Script non-secret; inspect config | Back up the script; logs are optional |
| Scheduled tasks | Windows Task Scheduler | Machine-specific | Export task XML for reference, then recreate with destination paths and user identity |
| Docker development data | Docker volumes for PostgreSQL, Redis, and MinIO | Potentially private | Export only if local relay history/dev state matters; community history lives on community relays |
| Communities, channels, and messages | `wss://*.communities.buzz.xyz` | Private relay state | Preserve the owner identity and keys; create a channel inventory before shutdown |
| Runtime credentials | Claude/Codex login or provider credentials outside the Buzz JSON files | **Secret** | Reauthenticate on the destination; do not put tokens in Obsidian |
| Goose-to-Antigravity bridge | `%APPDATA%\Block\goose\config\config.yaml`, `C:\Users\<you>\.local\bin\agy-goose.cmd`, and `agy-goose.ps1` | Config is non-secret; Antigravity login is secret-bearing state elsewhere | Back up the three files, reinstall both CLIs, reauthenticate Antigravity, and rerun the integration probes in [Buzz - Environment and Operations](../environment-and-operations.md#goose-using-antigravity-cli) |

## Channels and rooms

Channels are context and authorization boundaries, not squad records. They live on the relay as signed events. `teams.json` cannot reconstruct them, and copying the agent registry alone does not enumerate them.

### Required pre-move channel inventory

As of 2026-08-15, the CLI on this machine is installed at `C:\Program Files\Buzz\buzz.exe`, but a non-interactive audit returned `BUZZ_PRIVATE_KEY is required`. Therefore the vault does **not contain a verified list of channel names, IDs, descriptions, or membership**. This is an intentional secret-gated preflight step, not something that can be completed from documentation alone. Complete it before retiring the Windows machine; if it cannot be completed, retain the source and encrypted backup until the restored owner identity can enumerate every community.

Run the following in a private terminal session for each community while the owner credential is available. Do not paste the private key into this note, shell history, or a transcript.

```powershell
$env:BUZZ_RELAY_URL = 'wss://<community>.communities.buzz.xyz'
$env:BUZZ_PRIVATE_KEY = '<retrieve securely; never save in Obsidian>'
& 'C:\Program Files\Buzz\buzz.exe' channels list
& 'C:\Program Files\Buzz\buzz.exe' channels members --channel '<channel-uuid>'
Remove-Item Env:BUZZ_PRIVATE_KEY
```

Repeat with:

- `wss://<community>.communities.buzz.xyz`
- `wss://<community>.communities.buzz.xyz`

Record only non-secret results in the table below. Use full UUIDs and public keys; never record a private key or `BUZZ_AUTH_TAG`.

| Community | Channel name | Channel UUID | Description/purpose | Human members | Agent members | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `<community>` | _pending authenticated export_ | | | | | |
| `<community>` | _pending authenticated export_ | | | | | |
| `<community>` | _pending authenticated export_ | | | | | |

> [!important] Moving a machine does not move relay history
> Existing channel messages remain signed events on the community relay. The migration goal is to restore the same owner and agent identities so the new installation can decrypt and participate in the same rooms.

## Encrypted backup procedure

Use a destination that is encrypted at rest. The following is a checklist, not permission to place the output in the Obsidian vault.

1. Complete the channel inventory above.
2. While Buzz Desktop is running and the Windows keyring is unlocked, open **Settings → Profile → Private key backup**. Create a password-protected NIP-49 backup, save the resulting `.ncryptsec` file directly into the encrypted migration destination, and use Buzz's **Test backup** flow to prove that it decrypts to the current identity. Store the passphrase separately. Never screenshot, paste, or place either the raw `nsec` or passphrase in this vault.
3. Record the current owner public key/`npub` from Buzz and compare it with the successful backup-test result. Public identifiers may be recorded; the private key may not.
4. Confirm Google Drive reports this Obsidian folder fully synchronized.
5. Quit Buzz Desktop and verify `buzz-desktop` and `buzz-acp` processes are stopped. A consistent registry backup must not race live writes.
6. Export the two scheduled task definitions:

 ```powershell
 Export-ScheduledTask -TaskName 'Buzz Stack Autostart' |
 Set-Content -LiteralPath '<encrypted-backup>\Buzz Stack Autostart.xml'
 Export-ScheduledTask -TaskName 'Buzz Desktop Autostart' |
 Set-Content -LiteralPath '<encrypted-backup>\Buzz Desktop Autostart.xml'
 ```

7. Copy these trees into the encrypted backup:

 ```text
 %APPDATA%\xyz.block.buzz.app\
 C:\Users\<you>\.buzz\
 C:\ProgramData\Buzz\Start-BuzzStack.ps1
 ```

8. Preserve deliberate uncommitted files from `D:\Source\Dev\buzz`. The tree was clean on 2026-08-10 but contains required changes as of 2026-08-15; check again immediately before moving:

 ```powershell
 git -C 'D:\Source\Dev\buzz' status --short --branch
 git -C 'D:\Source\Dev\buzz' rev-parse HEAD
 ```

 The 2026-08-15 audit is **not clean**. Export the required three-file patch using [Buzz - macOS and Server Deployment Runbook](macos-and-server-deployment.md#release-baseline-and-required-customization), run `git diff --check`, hash it, and include it in the encrypted backup. Do not proceed with only the pinned commit.

9. Treat managed-agent keys as a separate blocking item. They are logical `agent:<pubkey>` entries in the same Windows keyring blob and are not covered by the owner-only `.ncryptsec` file. Do not retire or reset Windows until a supported bulk migration or individually verified agent-key restore has preserved all 34 public keys. Copying the Credential Manager database or using `cmdkey` is not a portable Mac restore method.
10. Inventory provider logins and licenses without exporting plaintext tokens. Plan to sign in to Claude/Codex again.
11. If the local Docker data matters, export the named volumes separately after stopping the Compose stack. If only communities matter, rebuilding the local development stack is sufficient.
12. Hash the backup archive and store the checksum separately. Test that the archive and `.ncryptsec` file open before wiping or repurposing the source machine.

## Destination rebuild order

The sequence below is the Windows recovery path. For macOS, follow [Buzz - macOS and Server Deployment Runbook](macos-and-server-deployment.md#track-a-restore-the-existing-installation-on-macos) and then return to the acceptance test here.

1. Install Windows updates, Git for Windows, Docker Desktop, Node/pnpm, Rust/Cargo, `just`, and the compiler prerequisites listed in [Buzz - Windows Setup Runbook](windows-setup.md).
2. Clone `https://github.com/block/buzz.git` and check out commit `9213090f6076bf3b7667b9b984752b3e47ef8f2f` before building the matching environment.
3. Build/install Buzz Desktop 0.5.5 using the runbook. Confirm `C:\Program Files\Buzz` contains the five companion executables listed in the snapshot.
4. Launch Buzz once, then exit it. This creates the destination app-data layout.
5. While Buzz is stopped, back up the newly created empty destination state, then restore the encrypted `%APPDATA%\xyz.block.buzz.app` backup.
6. Restore `.buzz` into the destination user's profile. If the Windows username or drive letters differ, search the restored workspace and agent prompts for the old absolute prefixes:

 ```powershell
 rg -n -uu 'C:\\Users\\<you>|D:\\Source\\Dev\\buzz|<cloud-drive>|<cloud-drive>' "$env:USERPROFILE\.buzz"
 ```

7. Restore `Start-BuzzStack.ps1`, editing only verified destination paths.
8. Recreate scheduled tasks for the destination account. Inspect imported XML first; task principals, executable paths, and drive letters are machine-specific.
9. Start Docker Desktop and the local stack; verify readiness before starting Desktop.
10. Sign in to required providers and restore the same Buzz owner identity through the supported credential flow.
11. Reinstall Goose and Antigravity, restore the Goose compatibility files, authenticate `agy`, and rerun the three probes in [Buzz - Environment and Operations](../environment-and-operations.md#goose-using-antigravity-cli).
12. Launch Buzz Desktop once. Let it spawn agents only after the identity, community list, and paths are correct.

## Acceptance test

Do not retire the source machine until every required item passes.

- [ ] the owner's private destination shows all ten current Markdown notes, including the macOS/server runbook and private recovery note. A third-party handoff contains only the nine non-secret notes and never the private recovery note.
- [ ] Repository remote is `block/buzz` and `git rev-parse HEAD` returns `9213090f6076bf3b7667b9b984752b3e47ef8f2f`.
- [ ] `git status --short` shows exactly the three expected `buzz-acp` modifications, and `git diff --check` passes.
- [ ] Buzz Desktop opens as the same owner identity.
- [ ] The password-protected `.ncryptsec` backup was tested before migration and imports on the Mac to the same owner public key.
- [ ] All three communities appear.
- [ ] Authenticated `channels list` matches the recorded channel inventory for all three communities.
- [ ] A sample private channel opens with its historical messages.
- [ ] Registry reports 28 persona definitions and 34 deployed identities.
- [ ] All 34 deployed identities have `start_on_app_launch: true`.
- [ ] Agent names, system prompts, runtimes, models, `respond_to` modes, and public keys match [Buzz - Agent Roster](../agent-roster.md).
- [ ] All 34 managed-agent private keys are available on the destination: every restored identity derives the same recorded pubkey and can sign/connect. Registry records without their keyring entries do not count as restored.
- [ ] Every Codex-backed agent uses `parallelism: 1`. If any agent relies on a custom ACP wrapper under `%APPDATA%\Buzz\node-tools\` and a full-access conditional in the installed adapter, confirm both survived — **package updates overwrite them.**
- [ ] On macOS, any Windows harness wrapper has been replaced with a working executable macOS command and its additional writable directories point to real macOS paths.
- [ ] `teams.json` contains every squad you expect, with the descriptions in [Squads and Teams](../squads-and-teams.md).
- [ ] The known team state remains intentional: no `instructions` values and only Welcome identities bound by `team_id`, unless deliberately changed after this snapshot.
- [ ] `.buzz` contains `GUIDES`, `PLANS`, `RESEARCH`, `WORK_LOGS`, `OUTBOX`, `REPOS`, `.agents`, `.claude`, and `AGENTS.md`.
- [ ] If a local relay was restored, its startup mechanism completes and `http://127.0.0.1:8080/_readiness` returns `{"status":"ready"}`. On Windows this is `Buzz Stack Autostart`; it is not required for hosted-community-only Mac use.
- [ ] On Windows, `Buzz Desktop Autostart` launches Desktop at sign-in under the non-elevated destination user.
- [ ] On macOS, Buzz launches successfully by hand before it is added to Login Items; no Windows scheduled task or wrapper is treated as portable state.
- [ ] Live `buzz-acp` process count and pid-file pairing are plausible; stale source-machine PIDs were not treated as live.
- [ ] One Claude-backed agent answers a test mention.
- [ ] Any Codex-backed agent answers, initializes one ACP worker promptly, and writes directly to its verified destination root without creating a staging tree.
- [ ] `goose run` returns a response through Antigravity and the Buzz ACP model probe recognizes Goose 1.45.0 with the configured Gemini model.
- [ ] One agent can read the intended restored `.buzz` workspace and cannot accidentally follow an old drive-letter path.
- [ ] The encrypted backup remains available until several normal work sessions complete successfully.

## Safe live-audit snippets

Count records without printing secrets:

```powershell
$store = "$env:APPDATA\xyz.block.buzz.app\agents\managed-agents.json"
$agents = Get-Content $store -Raw | ConvertFrom-Json
[pscustomobject]@{
 Records = $agents.Count
 Definitions = @($agents | Where-Object { -not $_.pubkey }).Count
 Identities = @($agents | Where-Object { $_.pubkey }).Count
 Autostart = @($agents | Where-Object { $_.pubkey -and $_.start_on_app_launch }).Count
}
```

List safe identity fields only:

```powershell
$agents | Where-Object pubkey |
 Select-Object name, pubkey, relay_url, runtime, model, respond_to, start_on_app_launch
```

Never dump the complete registry into a console transcript or Obsidian. It includes full prompts and credential-bearing fields that are intentionally absent from this migration note.
