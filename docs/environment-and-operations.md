---
title: "Buzz - Environment and Operations"
description: "Non-secret configuration inventory, operational commands, security boundaries, and troubleshooting scaffold for Buzz."
tags:
 - "buzz"
 - "environment-variables"
 - "operations"
 - "troubleshooting"
category: "AI / Buzz / Operations"
---
# Buzz - Environment and Operations

## Known variables

| Variable | Purpose | Secret? | Example |
| --- | --- | --- | --- |
| `BUZZ_RELAY_URL` | Select the relay used by the application or agent harness | No | `wss://<community>.communities.buzz.xyz` (hosted) or `ws://localhost:3001` (local dev) |
| `BUZZ_AUTH_TAG` | Authorize an agent to open owner-reviewed agent drafts from chat | **Yes** | Required by `buzz agents draft-create` / `draft-update` |
| `BUZZ_SHELL` | Override the Bash-compatible shell used by agent tooling on Windows | No | `C:\Program Files\Git\bin\bash.exe` |
| `BUZZ_PRIVATE_KEY` | Authenticate an agent identity | **Yes** | Never record a real value in Obsidian |

The complete inventory must be generated from the selected repository's `.env.example`, not from memory.

## Secret-handling rules

- Never paste a real Buzz private key, token, password, or connection secret into this vault.
- Keep secrets in the local `.env`, operating-system credential storage, or an approved secret manager.
- Commit only `.env.example` files containing placeholders.
- Give each agent a separate identity and rotate compromised keys.
- Treat logs, screenshots, terminal transcripts, and AI chat context as possible disclosure surfaces.

## Daily commands

### Automatic startup

Normal daily startup is automatic after Windows logon. The `Buzz Stack Autostart` scheduled task starts or verifies Docker Desktop, Compose services, and the local relay on port 3001.

Status and logs:

```powershell
Get-ScheduledTask -TaskName 'Buzz Stack Autostart'
Get-ScheduledTaskInfo -TaskName 'Buzz Stack Autostart'
Get-Content 'C:\ProgramData\Buzz\logs\startup.log' -Tail 20
Invoke-RestMethod 'http://127.0.0.1:8080/_readiness'
```

Manually rerun the idempotent startup controller:

```powershell
Start-ScheduledTask -TaskName 'Buzz Stack Autostart'
```

The controller refuses to start a second relay and reports an error if a non-Buzz process owns port 3001.

### Repository commands

```bash
. ./bin/activate-hermit
just dev
```

> [!note] Windows installation
> Hermit did not bootstrap on this Windows Git Bash platform. This machine uses the manually installed pinned toolchain recorded in [Buzz - Decisions and Build Log](decisions-and-build-log.md). The automatic startup controller invokes the already-built relay directly and does not depend on Hermit.

Split workflow:

```bash
just relay
just desktop-dev
```

Quality checks:

```bash
just check
just test-unit
just test
just ci
```

## Agent fleet operations

### Where agent state lives

| Item | Path |
| --- | --- |
| Persona and identity registry | `%APPDATA%\xyz.block.buzz.app\agents\managed-agents.json` |
| Running harness records | `%APPDATA%\xyz.block.buzz.app\agents\agent-pids\<pubkey>__<community>.json` |
| Per-agent harness logs | `%APPDATA%\xyz.block.buzz.app\agents\logs\<pubkey>__<community>.log` |
| Runtime installer logs | `...\agents\logs\install-claude.log`, `install-codex.log` |
| Global runtime defaults | `%APPDATA%\xyz.block.buzz.app\agents\global-agent-config.json` |
| Team groupings | `%APPDATA%\xyz.block.buzz.app\agents\teams.json` |
| Conversation retention | `%APPDATA%\xyz.block.buzz.app\agents\retention\<hash>.db` |
| Shared agent workspace | `C:\Users\<you>\.buzz` |

> [!warning] The registry holds agent private keys
> `managed-agents.json` is the credential store for every agent identity. Read it, never paste it - not into this vault, not into a chat, not into a log. Only public keys belong here.

### Global defaults applied to new agents

```json
{ "env_vars": {}, "provider": null, "model": "opus[1m]", "preferred_runtime": "claude" }
```

Per-agent records add `parallelism: 10`, `turn_timeout_seconds: 320`, `acp_command: buzz-acp`, and no idle or max-turn cap.

### Checking the fleet

Audit which identities will come back after a Buzz restart. `start_on_app_launch` is the only thing that decides whether an agent returns on its own, and nothing surfaces it in the UI at a glance:

```powershell
$store = "$env:APPDATA\xyz.block.buzz.app\agents\managed-agents.json"
$j = Get-Content $store -Raw | ConvertFrom-Json
$j | Where-Object { $_.pubkey -and -not $_.start_on_app_launch } |
 Select-Object name, relay_url, pubkey
```

An empty result is the healthy state. Records with an empty `pubkey` are definitions, not identities - filter them out or every agent looks broken.

```powershell
Get-Process buzz-acp | Select-Object Id, StartTime
Get-Process buzz-desktop, buzz-relay
Get-ChildItem "$env:APPDATA\xyz.block.buzz.app\agents\agent-pids"
Get-Content "$env:APPDATA\xyz.block.buzz.app\agents\logs\<pubkey>__<community>.log" -Tail 40
```

```bash
buzz channels list
buzz channels members --channel <channel-uuid>
buzz messages get --channel <channel-uuid> --since <ts>
buzz feed get
```

> [!note] pid files over-report
> A pid file is left behind when a harness exits. At the 2026-08-07 07:30 snapshot there were 34 pid files but only 29 live `buzz-acp` processes. All five stale files are dated 2026-08-06 17:00-17:32 and all belong to <community> and <community>. Cross-check with `Get-Process` before concluding an agent is running.

Pair the pid files against live processes rather than trusting either alone. Two traps make the naive check wrong: the pid file is **JSON, not a bare integer**, and `runtime_pid` inside `managed-agents.json` is `null` on disk for every record - the registry does not persist live PIDs at all, so filtering on it reports the entire fleet as down.

```powershell
$dir = "$env:APPDATA\xyz.block.buzz.app\agents\agent-pids"
$live = @{}; Get-Process buzz-acp -EA SilentlyContinue | ForEach-Object { $live[$_.Id] = $true }
Get-ChildItem $dir | ForEach-Object {
 $d = Get-Content $_.FullName -Raw | ConvertFrom-Json
 [pscustomobject]@{
 PK = $d.key.pubkey.Substring(0, 8)
 Relay = ($d.key.relayUrl -replace '.*//', '' -replace '\..*', '')
 ProcId = $d.pid
 Live = $live.ContainsKey([int]$d.pid)
 Started = [string]$d.startedAt
 }
} | Sort-Object Live, Relay | Format-Table -AutoSize
```

`Started` is the field that carries the diagnosis. A fleet-wide cluster of identical timestamps means Buzz Desktop relaunched and every agent is a cold process - see [Agent sessions drop mid-task - 2026-08-07](#agent-sessions-drop-mid-task-2026-08-07).

### What actually starts, and when

Three separate layers, each with its own trigger. Confusing them is why "everything is set to autostart" and "nothing is running" can both be true at once.

| Layer | Trigger | Covers | State on 2026-08-07 |
| --- | --- | --- | --- |
| Docker, Compose, local relay | `Buzz Stack Autostart` scheduled task, at logon + 15s | Backend services only | Working. Last run 2026-08-06 12:51, result `0` |
| Buzz Desktop | `Buzz Desktop Autostart` scheduled task, at logon + 1m | The app that owns every agent process | Created 2026-08-07 12:20; **first real test is the next logon** |
| Agent harnesses | Buzz Desktop launch, gated on `start_on_app_launch` | All 34 identities | 34 of 34 set `true` |

### `Buzz Desktop Autostart`

Created 2026-08-07 to close a gap that had gone unnoticed: `Start-BuzzStack.ps1` starts Docker Desktop and `buzz-relay` and **never references `buzz-desktop.exe`**. There was no `Buzz` value under `HKCU:\...\CurrentVersion\Run` or `HKLM:\...\CurrentVersion\Run` and no Startup-folder shortcut either, so after a reboot all 34 identities marked `start_on_app_launch: true` produced zero running agents until someone opened the app by hand.

```powershell
$exe = 'C:\Program Files\Buzz\buzz-desktop.exe'
$action = New-ScheduledTaskAction -Execute $exe
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$trigger.Delay = 'PT1M'
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" `
 -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries `
 -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) `
 -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName 'Buzz Desktop Autostart' -Action $action -Trigger $trigger `
 -Principal $principal -Settings $settings -Force
```

Three deliberate choices:

- **A separate task, not an edit to `Start-BuzzStack.ps1`.** Different concern, and Buzz Desktop no longer depends on the local stack - agents connect to community relays, so ordering does not matter. Keeping them apart means either can be disabled without touching the other.
- **`RunLevel Limited`, not `Highest`.** `Buzz Stack Autostart` runs elevated because it drives Docker and binds a port. A chat GUI needs none of that, and launching it elevated would break drag-and-drop from Explorer.
- **`PT1M` delay.** A launch spawns ~29 `buzz-acp` processes. Letting the logon storm clear first is kinder than racing it.

Verify, and remove if unwanted:

```powershell
Get-ScheduledTask -TaskName 'Buzz Desktop Autostart'
Get-ScheduledTaskInfo -TaskName 'Buzz Desktop Autostart' # LastTaskResult 0 after a logon
Unregister-ScheduledTask -TaskName 'Buzz Desktop Autostart' -Confirm:$false
```

> [!note] Registered but not fired
> The task definition was verified after registration (`State: Ready`, logon trigger, correct path, `RunLevel: Limited`). It was deliberately **not** test-fired with `Start-ScheduledTask`, because Buzz Desktop was already running and a second instance risked duplicate harnesses. The end-to-end proof is the next logon - check `LastTaskResult` then.

Autostart fan-out is per **configured community**, not per record. `managed_agents/runtime_commands.rs:471-477` filters on `start_on_app_launch && backend == Local` and then deliberately ignores the per-record relay pin, pairing every eligible agent with every configured community. An identity whose community is not currently configured in Desktop is simply never spawned, with no error surfaced.

## Production distinction

## Goose using Antigravity CLI

Configured and verified. This provides the following runtime chain:

```text
Buzz relay -> buzz-acp -> goose acp -> Goose gemini-cli provider -> agy
```

### Installed components

| Component | Version/path |
| --- | --- |
| Goose CLI | 1.45.0 at `C:\Users\<you>\.local\bin\goose.exe` |
| Antigravity CLI | 1.1.11 at `C:\Users\<you>\AppData\Local\agy\bin\agy.exe` |
| Compatibility launcher | `C:\Users\<you>\.local\bin\agy-goose.cmd` |
| Argument/output translator | `C:\Users\<you>\.local\bin\agy-goose.ps1` |
| Goose configuration | `%APPDATA%\Block\goose\config\config.yaml` |

Goose is configured with provider `gemini-cli`, model `gemini-3.5-flash-low`, and `GEMINI_CLI_COMMAND` pointing to the compatibility launcher. The launcher translates Goose's Gemini arguments to Antigravity equivalents and converts Antigravity `stream-json` events into the Gemini event shape Goose expects.

### Verified tests

Direct Antigravity:

```text
agy --print "Reply with exactly: AGY_OK" ... -> AGY_OK
```

Goose through the persisted Antigravity provider:

```text
goose run --no-session --quiet -t "Reply with exactly: PERSISTED_OK" -> PERSISTED_OK
```

Buzz ACP discovery through Goose:

```powershell
& 'C:\Program Files\Buzz\buzz-acp.exe' models `
 --agent-command 'C:\Users\<you>\.local\bin\goose.exe' `
 --agent-args acp --json
```

Verified result: agent `goose` version 1.45.0, current model `gemini-3.5-flash-low`.

### Selecting it in Buzz

Goose is a compiled-in, first-class Buzz runtime. In Buzz Desktop, edit or create an agent and select **Goose** as its runtime. Use provider `gemini-cli` and model `gemini-3.5-flash-low`; the provider is also available from Goose's persisted configuration. Do not change an existing production identity until its owner chooses which identity should move.

### Limitations

- Antigravity 1.1.11 does not expose ACP. The compatibility layer relies on its non-interactive `--print --output-format stream-json` interface.
- Goose marks `gemini-cli` as deprecated but retains it for pass-through compatibility. A Goose or Antigravity update can change arguments or event schemas; rerun all three tests after either upgrade.
- Goose extensions are not available through this CLI-provider path. Antigravity uses its own tools.
- Antigravity print mode is turn-oriented rather than a fully interactive nested ACP session. Goose session resume is translated to Antigravity's `--conversation`, but cancellation and mid-turn permission requests are not equivalent to native ACP.
- `GOOSE_MODE: auto` becomes Antigravity `--dangerously-skip-permissions`. This is necessary for an unattended Buzz agent but grants broad tool authority. Use a narrowly scoped workspace and dedicated identity.
- Google authentication remains in Antigravity's credential store. No token or private key is stored in Obsidian or Goose `config.yaml`.

After upgrading Goose or Antigravity, rerun:

```powershell
goose info -v
goose run --no-session --quiet -t 'Reply with exactly: PERSISTED_OK'
& 'C:\Program Files\Buzz\buzz-acp.exe' models `
 --agent-command 'C:\Users\<you>\.local\bin\goose.exe' `
 --agent-args acp --json
```

- Root `docker-compose.yml`: development environment
- `deploy/compose/`: single-node or VPS-oriented production bundle
- Production bundle may include PostgreSQL, Redis, MinIO, and optional Caddy/TLS

Do not promote the development Compose stack directly to an internet-exposed deployment.

## Troubleshooting template

### Automatic-start troubleshooting

1. Check `Get-ScheduledTaskInfo -TaskName 'Buzz Stack Autostart'`.
2. Read `C:\ProgramData\Buzz\logs\startup.log`.
3. Read `C:\ProgramData\Buzz\logs\relay.stderr.log` and `relay.stdout.log`.
4. Verify Docker with `docker info` and `docker compose ps` from `D:\Source\Dev\buzz`.
5. Verify that port 3001 is either free or owned by `buzz-relay`.
6. Verify `http://127.0.0.1:8080/_readiness` returns `{"status":"ready"}`.

The startup controller waits for dependencies and logs a concrete error instead of repeatedly spawning relay processes.

### Agent sessions drop mid-task - 2026-08-07

**Symptom:** An agent is given a task, appears to work, and then never replies. Asked again later, it has no memory of the earlier instruction. From the human side this reads as the agent ignoring the request or deciding to stop.

**Root cause: a Buzz Desktop relaunch, not an agent decision.** Every `buzz-acp` harness is a child of `buzz-desktop.exe`. When the app restarts, every harness is killed and respawned as a cold process with no conversation context. Any turn that was in flight dies silently - no error is published to the channel, because the process that would have published it is gone.

**Evidence from the 2026-08-07 07:03 event:**

| Fact | Value |
| --- | --- |
| `buzz-desktop` process start | 07:03:28 local |
| Harnesses respawned | 28, all stamped `2026-08-07T11:03:35Z` - 7 seconds later |
| Owner message arrived | 07:04 - into a Fizz that was 49 seconds old |
| Second isolated restart | Fizz alone, `11:25:15Z`, one minute before the 07:26 follow-up |

The 28 that respawned are exactly the 25 custom <community> identities plus the three <community> trio identities. The six <community> and <community> trio records did not respawn because their `start_on_app_launch` was still `false` at 07:03; the flag was flipped to `true` at 07:20, **17 minutes after the launch it needed to affect**. That flip is therefore correct but unexercised - the next Desktop launch is its first real test.

**Diagnosis:** run the pid-file pairing snippet under [Checking the fleet](#checking-the-fleet) and read `Started`. A fleet-wide cluster of one timestamp is a relaunch. Correlate with:

```powershell
Get-Process buzz-desktop | Select-Object Id, StartTime
```

If `buzz-desktop.StartTime` is close to the harness timestamps, the app restarted and no agent-side fault occurred.

**Distinguish from a genuine crash.** A crashed harness leaves a real signature in the registry - `last_exit_code`, `last_error`, `last_stopped_at`:

```powershell
$j = Get-Content "$env:APPDATA\xyz.block.buzz.app\agents\managed-agents.json" -Raw | ConvertFrom-Json
$j | Where-Object { $_.pubkey -and $_.last_exit_code -ne $null } |
 Select-Object name, last_exit_code, last_error, last_stopped_at
```

At this snapshot only three records carry one: `harness exited with status exit code: 0xffffffff`, all stopped `2026-08-06T17:13:37Z`, all <community>. Nothing from the 07:03 event, confirming it as an orderly restart rather than a fault.

#### What actually survives a restart

The first version of this entry claimed a new process "cannot recover what it missed." That is wrong for messages and right only for session state. The three layers behave very differently:

| Layer | Survives? | Where it lives | How to get it back |
| --- | --- | --- | --- |
| **Channel messages** | **Yes, fully** | Signed Nostr events on the relay | `buzz messages get --channel <id> --since <ts>` |
| **Harness log** | Yes, but operational only | `agents\logs\<pubkey>__<community>.log` | Records event ids, steer acks, reconnects - never content or reasoning |
| **Session working state** | **No** | In-memory only | Nothing. Gone with the process |

**Messages are recoverable, and recovery is already automatic.** The harness starts with `context_limit=12` (visible in the first line of every log), so a fresh session is handed the last 12 channel messages before its first turn. That is how the 07:25 Fizz answered a request originally made at 04:53 by a session that no longer existed. Verified directly: `buzz messages get --since 1786100000` returns the 07:04 message in full, hours later.

**Session state is genuinely gone.** `pool.rs:89` holds `channel_id → session_id` as an in-memory map, and **buzz-acp never calls ACP session load or resume** - `loadSession`, `load_session`, and `session_resume` return zero hits across `crates/buzz-acp/src/`. The Claude agent advertises `loadSession: true` and `sessionCapabilities.resume` in its init handshake, so the capability exists on the agent side and buzz-acp simply does not use it. What dies is the reasoning, the tool results, and any knowledge of whether a half-finished action completed.

> [!important] The real failure is triggering, not storage
> A missed message is not lost - it is *unread*, because nothing wakes an agent for it. A fresh harness acts only on new mentions arriving after it starts. The 07:04 message sat unanswered not because the data was gone but because no event triggered anyone to look. The 07:26 nudge is what fixed it.
>
> This means **asking an agent to go back and review what it missed does work.** `buzz feed get --type needs_action` and `buzz messages get --since` both reach the same relay history. The gap is that nothing runs them unprompted.

**Fix:** the drop itself is inherent to the process model. Mitigations, in order of value:

1. **Do not restart Buzz Desktop while an agent is mid-task.** A restart is a fleet-wide interrupt with no notification to anyone.
2. **After a restart, just ask.** The messages are still on the relay - a nudge is enough, and no information has to be re-typed. What the agent cannot tell you is what the dead session had already decided or half-done.
3. **Prefer a targeted Stop → Start on one identity** over an app restart when only one agent needs new settings picked up.

**Verification:** all 34 deployed identities audited `start_on_app_launch: true`, 0 `false`. 34 pid files, 29 live processes, 5 stale. Live count by relay: 29 <community>, 0 elsewhere. Arithmetic closes exactly: 28 respawned at 07:03:35 plus 1 at 07:25:15.

### Claude agents cannot publish replies in `dontAsk` mode — 2026-08-06

**Symptom:** A managed Claude agent completes its work but reports that Bash and PowerShell are denied, so `buzz messages send` never publishes the response.

**Root cause:** Buzz intentionally launches unattended Claude ACP sessions with `permission_mode=dontAsk`. In that mode Claude runs only pre-approved commands. The user-level Claude configuration did not previously allow the Buzz CLI.

**Fix:** Added these narrow user-level rules to `C:\Users\<you>\.claude\settings.json`:

```json
"permissions": {
 "allow": [
 "Bash(buzz:*)",
 "Bash(printf:*)",
 "PowerShell(buzz:*)"
 ]
}
```

The `:*` suffix is required by the Claude SDK version bundled with `claude-agent-acp` 0.65.0 on this machine; the initially attempted space-wildcard form still produced permission denials. `Bash(printf:*)` supports Buzz's documented multiline-content pipeline; shell operators are permission-checked per subcommand. General Bash and PowerShell access remains denied. Do not replace this with `bypassPermissions` on the Windows host.

The global `ecc` plugin also installed a `gateguard-fact-force` hook that intercepted the first shell call, visible as a generated `Facts:` block between attempts. Buzz now has isolated project settings at `C:\Users\<you>\.buzz\.claude\settings.json` that repeat the narrow allowlist and disable `ecc` and `superpowers` only inside the Buzz workspace. The workspace trust record in `C:\Users\<you>\.claude.json` is accepted so project permission rules load non-interactively. Normal Claude sessions retain their global plugins.

**Follow-up correction (13:31):** Real Buzz replies contain pipelines and complex shell quoting. The installed SDK continued rejecting those real commands even though simple prefix probes passed. The Buzz-local project allowlist was therefore changed to whole-tool `Bash` and `PowerShell` approval. This applies only when Claude's project root is `C:\Users\<you>\.buzz`; global Claude settings retain the narrow `buzz`/`printf` rules. A compound shell probe then completed with zero permission denials, and <community> Fizz was restarted again (harness PIDs `64912` and `89796`). This is broader authority inside the Buzz agent workspace and should be reviewed if untrusted users are ever allowed to prompt these agents.

**File-tool correction (2026-08-07):** Claude's native `Write` tool was still denied because the Buzz-local allowlist covered only the two shell tools. The shell heredoc fallback successfully created `Buzz - Squads and Teams.md`, but the denial was noisy and unnecessary because those shells already had equivalent filesystem authority. Added whole-tool approval for `Read`, `Edit`, `Write`, `Glob`, and `Grep` to `C:\Users\<you>\.buzz\.claude\settings.json`. A native `dontAsk` `Glob` probe completed with zero permission denials. The ACP adapter snapshots these settings when a channel session is created, so an existing session must be replaced or its agent restarted before it sees a newly added tool rule. A fleet-wide restart was deliberately avoided because 29 harnesses were live and 34 identities were marked for launch.

**Affected identity clarification (2026-08-07):** The continuing denial was reported by **Fizz on `<community>`**, identity `53064f3b…`; it was not a Bumble or Honey failure. At diagnosis time its <community> harness was PID `32372`, started at `2026-08-07T11:03:35Z`, so its cached ACP channel session predated the final native-file-tool policy. The permission file itself passed an independent `dontAsk` probe. The corrective operation is therefore a targeted **Stop → Start** of this Fizz identity in Buzz Desktop, leaving the rest of the fleet online.

> [!warning] `!rotate` is not usable from the current Buzz UI or CLI
> The harness implements `!rotate`, but it accepts the command only when the kind-9 event has content exactly equal to `!rotate` **and** includes a `p` tag for Fizz. Current product surfaces derive that tag from visible `@Fizz` text, making the two requirements mutually exclusive: `@Fizz !rotate` has the tag but fails the exact-content check, while bare `!rotate` has no tag. Until that product bug is fixed, use the managed-agent **Stop → Start** controls to replace Fizz's session. Do not treat an unsuccessful `@Fizz !rotate` message as a permission-policy failure.

**Post-restart diagnostic correction (2026-08-07, 07:26 local):** Fizz did restart successfully at 07:03 local, connected to <community>, discovered the Welcome channel, and subscribed. The subsequent red tool entries were not another permission failure or a stopped harness. One optional-path probe ended with exit code 2 because Linux-style locations were absent, and one PowerShell audit called `Substring(0,8)` on Fizz's persona-definition record, whose `pubkey` is intentionally empty. The same JSON file contains 28 persona definitions and 34 deployed identities; only deployed identities belong in autostart and PID audits. Added Windows-safe diagnostic rules to `C:\Users\<you>\.buzz\AGENTS.md`: test optional paths, filter for a non-empty pubkey before string operations, audit autostart only on deployed identities, and verify stale PID metadata against the process table. These rules apply to every Buzz agent using the shared workspace.

**Verification:** A native Claude CLI probe launched from `C:\Users\<you>\.buzz` in `dontAsk` mode executed `printf` exactly once, returned the expected output, reported no permission denials, and showed no project-trust warning or plugin hook interception.

**Managed-agent reload (13:28 on 2026-08-06):** Restarted Buzz Desktop and the active <community> Fizz identity (`53064f3b…`) after the final policy change. Buzz recreated its <community> harness (PID `69380`) and mesh relay pair (PID `83440`), initialized ten Claude ACP workers, opened live TLS connections, and kept the Buzz relay readiness check healthy. The temporary one-time launch flag was returned to its prior `false` value afterward.

**Activation:** Start a fresh managed-agent session after changing the Claude permission file. For a single affected identity, use **Stop → Start** in Buzz Desktop; do not restart the entire fleet. Agents with `start_on_app_launch = false` must be started from Buzz after an application restart.

### Symptom

Exact visible error or behavior.

### Environment

- Repository and commit:
- Windows version:
- Shell:
- Docker version:
- Hermit state:
- Relay URL:
- Relevant component:

### Checks performed

1. Reproduction command
2. Relevant logs
3. Container health
4. Port availability
5. Environment-variable presence without secret values

### Root cause

Evidence-backed explanation.

### Fix

Exact minimal change.

### Verification

Command or behavior proving the fix.

### Rollback

How to reverse the change safely.

## 2026-08-11 - Built-in agent dispatch authority over a squad

- **Goal:** Let the built-in <community> Fizz coordinate a project squad in their shared private channel without the owner pasting every phase dispatch by hand.
- **Finding:** The production Desktop is compiled with `BUZZ_DESKTOP_BUILD_AGENT_ACCESS_OWNER_ONLY`. It clamps every managed-agent runtime to `respond_to=owner-only`, even if a stored record says `anyone` or `allowlist`. **Direct registry edits cannot widen live access.**
- **Semantics:** Here `owner-only` means the human owner *plus cryptographically verified same-owner sibling agents*. Fizz was always permitted to mention and dispatch the squad. An empty explicit allowlist does not remove that sibling authority.
- **Root cause:** Not a permission problem at all. Fizz *inferred* from the `owner-only` label and the empty allowlist that dispatch was prohibited, and stopped before trying. No rejected dispatch appears anywhere in the harness logs.
- **Fix:** Left every squad agent at `owner-only` and extended the shared built-in Fizz prompt to explain sibling authority, require an actual mentioned dispatch attempt, and forbid requesting a policy change purely from a displayed setting. The shared persona instruction applies to all three Fizz identities.
- **Verification:** Buzz Desktop restarted; all `buzz-acp` runtimes returned; every squad record remains `owner-only`; the revised Fizz prompt persisted. Startup logs confirm the runtime clamp is still `owner-only`, as designed.
- **Recovery:** use a mode-`0600` temporary registry copy only during the bounded change; remove it immediately after validation or rollback. It contains credentials and must never become a retained artifact.
- **Rollback:** Restore the prior prompt from the private snapshot and restart Buzz Desktop. Never copy that snapshot into a shared vault or repository.

> [!important] The generalisable lesson
> An agent will act on what its configuration *appears* to say. If a setting's real semantics are broader than its label, put the semantics in the prompt — otherwise the agent enforces a restriction that does not exist.

## 2026-08-11 - Codex-backed agent denied access to an external drive

- **Symptom:** The one Codex-backed agent in a squad reported `Access is denied` for its project root and stopped before reading anything. Every Claude-backed agent could read the same tree.
- **Cause:** Buzz's installed Codex ACP creates each turn in `workspace-write` mode with `writableRoots: []`. That explicit per-turn policy **wins over** the global `[sandbox_workspace_write]` config entry, and Buzz does not pass ACP `additionalDirectories` — leaving the external drive outside the session boundary entirely.
- **First fix:** Backed up and patched the installed adapter (`%APPDATA%\Buzz\node-tools\node_modules\@agentclientprotocol\codex-acp\dist\index.js`) to set an explicit writable root, scoped to that one project tree.
- **Restart:** Stopping the harness was not enough; Buzz Desktop had to be restarted because the supervisor did not relaunch that identity by itself.
- **Persistence warning:** Reinstalling or updating Buzz's Node tools **overwrites this patched dependency.** After any migration or upgrade, inspect the adapter and reapply. The durable product fix is for Buzz to pass the root through ACP `additionalDirectories`.

### Follow-up: the real failure was cold-start parallelism

After the patch and a clean restart, the agent was dispatched twice and returned nothing at all — no file, no fallback, no error. Its log reached `agent_pool_ready` but contained no subsequent prompt or turn event, proving the failure happened *before* any filesystem work.

The cause was `parallelism: 10`. The first dispatch initialized ten Codex app-server workers and took about eight minutes to become ready, and the dispatch never became a logged turn during that window. Final configuration: `parallelism: 1`.

> [!warning] A silent agent during cold start is not an ignored mention
> Ten Codex ACP workers take minutes to initialize. Anything dispatched in that window disappears without a trace in the turn log. Start Codex-backed agents at `parallelism: 1`.

### Final correction: filesystem ACLs, not Buzz

The Windows sandbox log eventually proved `workspace-write` could never activate on that root: the cloud-drive letter is exposed as **FAT32**, and `SetNamedSecurityInfoW` returned error 87 every time Codex tried to grant its sandbox group an ACE. That is why the same account can write to the drive from the Codex CLI (which runs unsandboxed) while the Buzz-hosted workspace sandbox cannot.

The final fix was scoped to the single agent rather than the global Codex configuration:

- A dedicated wrapper command under `%APPDATA%\Buzz\node-tools\`.
- The wrapper sets a marker environment variable and invokes the normal Buzz `codex-acp.cmd`.
- The adapter selects `dangerFullAccess` **only** when that marker is present; its normal `workspaceWrite` policy is otherwise unchanged.
- Both the persona and its deployed identity carry the wrapper override at `parallelism: 1`.

Policy afterwards forbade staging copies on the local disk: read and write the real root directly, and report an explicit error if that fails. Staged mirror files were removed only after SHA-256 comparison proved the authoritative copies identical.

## 2026-08-12 - Token-runaway containment

The most expensive incident in this build, and the one most worth copying the fix from.

- **Incident:** Squad execution exhausted a Claude Max plan and nearly exhausted Codex while producing repeated or rejected work. Running the same production directly through the CLI showed no such multiplier.
- **Evidence:** Harnesses launched with `agents=10`, `max_turns_per_session=0`, two-hour turns, and twelve inherited channel messages. Two reviewer agents each **retried the same event ten times** after the provider had already returned `You've hit your session limit`. Buzz dead-lettered each event only on attempt eleven. An observer message also exceeded the NIP-44 payload limit, obscuring the status the whole time.
- **Runtime fix:** Account, authentication, session-limit, credit, and quota errors are now **terminal**. Buzz posts a failure notice and performs zero retries. Ordinary transient failures get at most one retry.
- **Configuration fix:** Every squad member runs `parallelism=1` and `max_turn_duration_seconds=1800` in both persona and deployed records.
- **Context controls:** Default inherited channel context is six messages. Sessions rotate after eight turns to prevent an indefinitely growing conversation.
- **Review policy:** Review stayed autonomous — no author approval gate was added. **The safety mechanism is bounded execution, not manual review.**
- **Verification:** Focused account-limit tests passed, plus 114 configuration and 112 queue tests. Live startup reports `agents=1`, `max_turn=1800s`, `context_limit=6`, `max_turns_per_session=8`.
- **Private rollback:** use a mode-`0600` temporary registry copy during the bounded change, then remove it immediately after validation or rollback. It contains credentials and must never be retained in a shared vault or repository.

> [!danger] Retry-on-quota-error is a bill multiplier
> A quota error is not transient. Retrying it ten times per event, across a squad, on two-hour turns, is how a plan gets exhausted in an afternoon while the visible output goes backwards. Make credential and quota failures terminal before you run any squad unattended.
