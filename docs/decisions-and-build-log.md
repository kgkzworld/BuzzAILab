---
title: "Buzz - Decisions and Build Log"
description: "Decision record and chronological build log for the local Buzz environment."
tags:
 - "buzz"
 - "decision-log"
 - "build-log"
category: "AI / Buzz / Operations"
---
# Buzz - Decisions and Build Log

Agent inventory that these decisions produced: [Buzz - Agent Roster](agent-roster.md).

## Decisions

### 2026-08-06 — Separate knowledge from the live repository

**Decision:** Store Buzz documentation and runbooks in Obsidian, but keep the live repository, dependencies, build artifacts, Docker state, and secrets outside the Google Drive-backed vault.

**Reason:** Avoid sync churn, path and file-locking problems, accidental secret capture, and unnecessary indexing of generated files.

**Status:** Accepted.

### 2026-08-06 — Use the official upstream repository

**Decision:** Install and track the official `block/buzz` repository.

**Repository:** `https://github.com/block/buzz`

**Reason:** The previously saved `cjain-ai/buzz-jack-dorsey` repository is only a fork of `block/buzz`. On 2026-08-06 it had no fork-only commits and was 123 commits behind upstream. The official repository is actively maintained and is the repository named by Buzz's own installation instructions.

**Status:** Accepted. Do not use the fork for installation.

### 2026-08-06 — Use native Windows with Git Bash and Docker Desktop

**Decision:** Run Buzz as a native Windows development setup. Use Git Bash for Buzz/Hermit commands and Docker Desktop for the service containers. Do not place or build the repository inside a WSL filesystem.

**Reason:** Buzz officially supports Windows and requires a Bash-compatible shell for agent tooling. Git for Windows supplies the supported Git Bash path. WSL is not required for Buzz itself; Docker Desktop may use the WSL 2 backend internally.

**Status:** Accepted.

### 2026-08-06 — One persona, many identities

**Decision:** Treat the persona as the definition and the pubkey as the deployment. Reuse an existing agent pubkey in a new channel rather than creating a second agent for the same role.

**Reason:** The registry separates persona records (`slug`, prompt, runtime) from identity instances (`pubkey`, relay, history). Memory and workspace follow the identity, so a duplicate agent starts with nothing and fragments the audit trail. `buzz channels add-member --role bot` is the cheaper move.

**Consequence:** The built-in trio has three identities each - one per community - and one prompt. Custom agents have exactly one identity, on <community>.

**Status:** Accepted.

### 2026-08-06 — The channel is the unit of context isolation

**Decision:** One channel per project or long-running workstream. Threads for tasks inside it. Durable spec on the channel canvas; artifacts in the shared workspace, not the chat.

**Reason:** Each agent runs one session per channel. Sessions share core memory, the on-disk workspace, and the relay, but not conversation context. Channel boundaries are therefore where you decide what an agent is allowed to forget.

**Also accepted:** an `@mention` starts an independent session with no lock. Mentioning two agents for the same job gets the job done twice, in parallel, with no coordination between them. Address one agent per request.

**Status:** Accepted. Written up in `C:\Users\<you>\.buzz\GUIDES\BUZZ_PROJECT_STRUCTURE.md`.

### 2026-08-06 — The Obsidian vault is the system of record for personal agents

**Decision:** Comb and Forager write to `<vault>` and keep nothing personal in the Buzz workspace. No parallel copies, no shadow lists.

**Reason:** Two systems of record for the same todo list is worse than one. The vault already holds the formats, the history, and the instruction notes in `AI_Context/10_AI_Instructions/`, which outrank either agent's own prompt.

**Guardrails written into both prompts:** re-read a file immediately before editing it (Google Drive sync plus a possibly-open Obsidian), targeted edits rather than whole-file rewrites, never delete a note, stop and report if a file looks truncated or cloud-only. Forager is additionally barred from `003_Health/`, `002_Legal/`, and the profile notes.

**Status:** Accepted.

### 2026-08-06 — Mixed runtimes in one fleet

**Decision:** Default new agents to the Claude runtime on `opus[1m]`; run selected agents on Codex with `gpt-5.6-sol` and `parallelism: 1` so they retain the Codex workflow without a ten-worker cold start.

**Reason:** Buzz identity and messaging are provider-agnostic - a message event carries no field identifying the model or runtime behind a pubkey - so runtime is a per-agent choice with no protocol cost. Mixing runtimes lets you compare two models' output directly inside one pipeline.

**Verification:** Both harnesses run as `buzz-acp` processes and are indistinguishable to the other agents on the relay.

**Status:** Accepted. This is the first Codex-backed agent observed on this relay; earlier notes recorded that combination as structurally supported but unobserved.

### 2026-08-07 — Instantiate a missing charter rather than redesign the roster

**Decision:** When an audit found that a squad's independent-verifier role had been designed but never actually created in Buzz, the fix was to create it from its existing charter — not to reshape the other agents to cover the gap.

**Why the verifier mattered most:** the squad's governing rule was that no agent verifies its own output, and that only the independent verifier clears a blocking finding. Without it, the lead role both directed and approved, with no check — the exact failure mode the rule was written to prevent, after repeated false completion reports.

**Generalisable:** audit what you actually deployed against what you designed. A role that exists only in documentation provides no safety at all, and the documentation will keep claiming otherwise.

### 2026-08-07 — Verify agent creation against the registry, never against the CLI response

**Decision:** Treat `buzz agents draft-create` returning `accepted: true` as evidence only that the relay accepted the event. Confirm against `managed-agents.json` before reporting an agent as created.

**Reason:** One agent's first draft returned `accepted: true` with a valid event id and never surfaced in Buzz Desktop. It was reported as "open for review" on the strength of that response; the owner had to report it missing. A second `draft-create` landed it.

**Root cause, found 2026-08-07 while creating the Executive Career Office:** agent drafts are published as **ephemeral** events (kind 24200 via `publish_ephemeral_event`). The relay never stores them, and Desktop holds one review form at a time, so any draft arriving while a form is open is lost permanently. Batching is the failure mode: fifteen drafts sent in two seconds yielded three forms. Full mechanics in [Buzz - Architecture and Agent Integration](architecture-and-agent-integration.md).

**Procedure that works:** one draft, confirm it in `managed-agents.json`, then the next. Fifteen for fifteen with no anomalies.

**Status:** Accepted.

### 2026-08-07 — A squad shapes behaviour only through `instructions`, and an identity gets exactly one

**Decision:** Treat a team's `instructions` field as the only thing that reaches an agent, and `team_id` as a single exclusive slot per identity. Shared discipline goes there once instead of being copied into each member's system prompt.

**Reason:** `TeamRecord` carries both `description` and `instructions` (`managed_agents/types.rs:762`), and only `instructions` is injected — via `BUZZ_ACP_TEAM_INSTRUCTIONS` (`runtime.rs:688`) into `compose_prompt` (`buzz-acp/src/pool.rs:1305`). `description` is display-only. An entire project brief was written into `description`, so no agent ever read it. Separately, `effective_team_instructions` (`spawn_snapshot.rs:48`) resolves one team by `team_id`, so membership is not additive — three agents were listed in two squads each, and only one of the two could ever apply.

**Consequence:** The binding is per-harness, not per-channel, so team instructions follow an agent into every room it works in. General-purpose help belongs in the channel, not the team.

**Status:** Accepted. Detail and the four Executive Career Office squad definitions in [Buzz - Squads and Teams](squads-and-teams.md).

### 2026-08-07 — Audit autostart per identity, never per community

**Decision:** Check `start_on_app_launch` across every record with a non-empty `pubkey` after any fleet change. An empty result set is the only healthy state.

**Reason:** On 2026-08-06 the <community> and <community> identities were deliberately left `false` because those communities were not live. They became live and the flag was never revisited. Six identities — Fizz, Honey, and Bumble on both secondary communities — therefore stayed down after every Buzz restart until someone started them by hand. One of the six was the secondary-community Fizz, which serves the owner DM: it read as an agent that "kept stopping" when it had simply never been asked to start. Nothing in the UI surfaces the flag at a glance, and the per-community reasoning that created the gap looked correct at the time.

**Status:** Accepted. All 34 identities now autostart; the audit command is in [Buzz - Environment and Operations](environment-and-operations.md).

### 2026-08-21 — The roster is declarative; the model is chosen in one registry

**Decision:** Agent definitions become model-independent `.role.md` sources. A single `config/runtime-classes.json` registry is the only file that names a model. A compiler resolves the two into deployable packs, and a guarded lifecycle syncs them onto existing identities.

**Reason:** The fleet had grown to 85 paired definitions and deployments, each carrying a hand-edited model string. Swapping one model meant editing every record that referenced it, with nothing to detect the records that were missed. Roles and runtimes were entangled for no reason: nothing about a role's mission changes when the model underneath it changes.

**Constraint discovered:** A deployable persona rejects unknown fields, so factory-only metadata — preferred runtime class, allowed tools, write scope, quality checks, escalation conditions — cannot live in the persona. It lives in the role source and the pack build manifest and is stripped at compile time. This is the reason roles compile into packs rather than being authored as packs.

**Status:** Accepted and applied to all five grouped packs. Model changes now happen in the registry plus a lifecycle apply, never by hand-editing records.

### 2026-08-23 — Workers execute without an identity; the controller owns publication

**Decision:** Ordinary workers are roster entries, not Buzz identities. They execute ephemerally with a unique run ID and JSON `identity: null` and `buzz_pubkey: null`. Channel creation and artifact publication are performed by the controller's credential. Persistent identities and signing keys remain controller-only.

**Reason:** Every worker that needs to publish does not need a keypair to do it. Issuing one makes every transient task a permanent identity to inventory, rotate, audit, and eventually revoke. Keeping the credential with the controller means a worker can be created, run, and discarded without changing the trust surface at all.

**Status:** Accepted. Five persistent launch-enabled controllers remain; everything else is roster-only and ephemeral.

## Build log

### 2026-08-23 — Native image routing corrected and validated

**Goal:** Let an ordinary sentence — not a magic phrase — reach the illustration role through the native controller path, with the worker holding no identity.

**Original failure:** The interceptor required synthetic wording: the literal phrase `image workflow`, a `Brief:` marker, and private/task-channel language. It passed every synthetic test. The first natural request a human typed fell through to the generic model classifier and was assigned to a vulnerability-management engineer, which declined it as out of scope. This was a classifier defect, not a bad roster match — the roster never got a chance to answer.

**Second failure, found during the corrected run:** One queue flush contained both the user's request and the controller's own previous failed reply. The helper concatenated them, so a failed reply became part of the next request's instructions. The correction selects only the individual event that matched image-creation intent, and takes the requester's public key from that same event.

**Change:** The classifier now recognizes explicit creation intent combined with `image`, `illustration`, or `artwork`, with a negative case keeping container-image vulnerability review out of the generation path. The dispatcher pins an `image-generate` capability, which resolves deterministically to the illustration role.

**Verification:** Two live runs. The second was structured as an isolation test: a decoy message was sent first, then the request, so one flush window could hold both. The decoy was answered conversationally and never entered the image path. The resulting channel charter carried only the matching request — no decoy text — and the run produced one private review channel, one upload, a null worker identity and public key, and a structured receipt in the intake DM. Focused routing regressions, 46 harness tests, and a zero-drift fleet lifecycle all passed alongside it.

**Rollback:** The classifier is additive; removing the natural-language branch restores the previous synthetic-only trigger without touching the dispatcher or the roster.

### 2026-08-21 — Declarative fleet cutover

**Goal:** Move all live agents onto compiled, model-independent role sources without disturbing a single identity.

**Change:** Exported the live fleet, reconciled a historical 88-agent count to the authoritative 85 definitions paired with 85 deployments after retiring three obsolete handles, generated five grouped packs — `career` (11), `core-managers` (11), `narrative-creative` (8), `research-other` (5), `security-platform` (50) — and synced each onto its existing identities behind a guard that requires the app to be stopped, writes a per-pack rollback backup, and refuses incomplete name pairing.

**Result:** Zero drift across all five packs after relaunch, 85 unique deployment public keys, no broken definition/deployment pairs.

**Problem encountered:** The desktop app has pack validation and inspection but no pack-install command, and its boot migration detaches legacy directory-backed teams. Copying packs into the old teams path is actively wrong.

**Resolution:** Install means a guarded declarative sync onto existing identities, not a filesystem drop.

**Discipline that this depends on:** The app rewrites its agent registry on exit. Patch a live registry while it is running and the edit is gone at quit. The order is always quit, patch, relaunch, verify zero drift.

**Rollback:** The pre-migration registry snapshot restores the previous fleet exactly, and each pack sync wrote its own dated backup.

### 2026-08-15 — macOS and server handoff audit

**Goal:** Make the environment reproducible on the owner's Mac and separable from a fresh infrastructure deployment for another operator.

**Finding:** The pinned checkout at `9213090f` has three intentional uncommitted `buzz-acp` modifications (`config.rs`, `lib.rs`, `queue.rs`). They implement context/session limits and retry/account-error containment. A pinned clone alone is not functional parity.

**Documentation change:** Added [Buzz - macOS and Server Deployment Runbook](runbooks/macos-and-server-deployment.md), updated the migration entry point, made the patch export a mandatory encrypted-backup step, documented macOS app-data/path/wrapper differences, and separated personal identity restoration from a sanitized new-owner server deployment.

**Remaining human preflight:** Authenticated channel enumeration requires the owner's private credential and must be run privately before the Windows source is retired. No secret was exposed or copied into the vault.

### 2026-08-15 — Correct private-key migration boundary

**Finding:** The production desktop uses Windows Credential Manager service `buzz-desktop`, blob entry `secrets`. `%APPDATA%\xyz.block.buzz.app\identity.migrated` confirms the owner key was migrated to that keyring. The same blob stores managed-agent keys as `agent:<pubkey>`. `managed-agents.json` carries auth tags and configuration but intentionally no private keys.

**Correction:** An app-data archive alone is not a complete identity backup. The runbooks now require Buzz's tested, password-protected NIP-49 `.ncryptsec` backup for the owner identity and explicitly gate source retirement on preservation and verification of all 34 managed-agent keys.

| Date | Repository / commit | Action | Result | Verification | Rollback |
| --- | --- | --- | --- | --- | --- |
| 2026-08-06 | Documentation only | Created Obsidian scaffold | Complete | Notes and links verified | Delete scaffold notes if no longer wanted |
| 2026-08-06 | `block/buzz` `9213090f6076bf3b7667b9b984752b3e47ef8f2f` | Installed native Windows development stack and Buzz Desktop 0.5.5 | Complete | Desktop process responsive; relay readiness HTTP 200; PostgreSQL, Redis, and MinIO healthy | Uninstall Buzz MSI, stop Compose services, and remove the local checkout if intentionally decommissioning |
| 2026-08-06 | Local Windows operations | Configured automatic Docker and Buzz stack startup | Complete | Scheduled task ran with result `0`; dependency and relay health checks passed; no duplicate relay launched | Disable or unregister `Buzz Stack Autostart`; toggle Docker Desktop autostart off |
| 2026-08-06 | Claude Code / Buzz ACP | Allowed unattended Claude agents to publish through the Buzz CLI and isolated interactive plugins | Verified | Clean native `dontAsk` probe: expected output, zero permission denials, no hook interception | Remove the Buzz-local settings/trust entry and the `Bash(buzz:*)`, `Bash(printf:*)`, and `PowerShell(buzz:*)` user rules |
| 2026-08-06 | <community> managed agents | Enabled app-launch startup for Bumble, Fizz, and Honey | Verified | All three connected to <community>, subscribed to Welcome, and reported online after desktop restart | Set `start_on_app_launch` back to `false` for the three <community> records |
| 2026-08-07 | Claude Code / Buzz ACP | Added native file tools to the Buzz-local `dontAsk` allowlist | Verified | `Glob` probe completed with zero denials; squads note confirmed at 234 lines | Remove `Read`, `Edit`, `Write`, `Glob`, and `Grep` from `.buzz/.claude/settings.json` |
| 2026-08-07 | <community> Fizz / Buzz ACP | Isolated the continuing tool denial to Fizz (`53064f3b…`) and documented targeted session replacement | Diagnosed; UI restart required | Fizz's <community> harness PID `32372` predates the final policy; independent native `dontAsk` probe passes. Source review also confirms `!rotate` is unreachable from current UI/CLI message construction, so use Fizz **Stop → Start** | Stop and start only <community> Fizz again if a newly created session still carries stale permissions |
| 2026-08-07 | Shared Buzz agent workspace | Added Windows-safe fleet-audit and diagnostic rules after Fizz generated false-positive command errors | Complete; takes effect in new agent sessions | Fizz's 07:03 restart was healthy; 07:26 errors traced to an absent optional path and `Substring(0,8)` on an empty persona pubkey, not a harness or permission failure | Remove the `Local Windows operating rules` section from `C:\Users\<you>\.buzz\AGENTS.md` |
| 2026-08-06 | Communities | Moved agent traffic from the local relay to `wss://*.communities.buzz.xyz` | Complete | Twelve `buzz-acp` harnesses connected to `<community>`; local relay left running and healthy | Repoint `BUZZ_RELAY_URL` at `ws://localhost:3001` |
| 2026-08-06 | Personal operations agents | Created Comb (14:40) and Forager (14:49) | Complete | Both registered, autostart enabled, harnesses live (PIDs `83132`, `74640`) | Delete the two persona records and their identities from Buzz Desktop |
| 2026-08-06 | Workspace documentation | Wrote `C:\Users\<you>\.buzz\GUIDES\BUZZ_PROJECT_STRUCTURE.md` | Complete | Answers verified against the `buzz` CLI on the <community> relay | Delete the guide |
| 2026-08-07 | Executive Career Office | Created 15 career agents across 4 departments from the ECO Framework v1.0 | Verified | All 15 present in `managed-agents.json` with live harnesses; checked for runtime, autostart, `respond_to` and pid — no anomalies. Fleet 28 personas / 34 identities / 29 processes | Delete the 15 persona records and their identities from Buzz Desktop |
| 2026-08-11 | Built-in agent dispatch | Kept squad agents `owner-only` and taught the shared built-in prompt that verified same-owner siblings are authorized dispatchers | Verified | Production policy clamps runtimes to `owner-only`; all runtimes restarted and the revised instruction persisted | Restore the prior prompt from the private pre-change registry backup and restart Desktop |
| 2026-08-11 | Codex ACP writable roots | Added a scoped project root to the Buzz-hosted Codex Agent mode | Superseded | Adapter contained the scoped root, but FAT32 ACL failure was later proved to be the real cause | Restore the adapter backup and restart Desktop |
| 2026-08-11 | Codex agent parallelism | Reduced a Codex-backed agent from `parallelism: 10` to `1` after two silent dispatches | Verified | Launch reports `agents=1`, PID live, all harnesses online | Restore the pre-change registry backup and restart Desktop |
| 2026-08-11 | Codex direct-drive access | Added a dedicated Codex ACP wrapper selecting unsandboxed mode for one agent only; prohibited local staging copies | Verified | Sandbox logs establish FAT32 ACL failure as root cause | Remove the wrapper override, restore the adapter backup, restart Desktop |
| 2026-08-16 | Goose / Antigravity pilot | Deployed a Goose ACP agent with local Qwen3 routing and a guarded sandboxed plan-mode publication bridge | Passed end-to-end | Delegated call completed in 8.2s and Buzz displayed the exact bridge response | Stop/archive the identity, remove the bridge, restore the prior Goose configuration |
| 2026-08-16 | Goose ordinary replies | Separated ordinary local Q&A from delegated work and required an explicit `buzz messages send` for ordinary replies | Passed retest | Answer published to the DM in 0.3s; post-test restart completed | Restore the prior prompt and restart the identity |
| 2026-08-07 | Obsidian vault | Documented every squad in [Buzz - Squads and Teams](squads-and-teams.md) and corrected stale squad, autostart, and team-status claims across four notes | Complete | Note written at 234 lines; three existing teams reconciled against `teams.json`; team mechanics verified against `spawn_snapshot.rs:48`, `runtime.rs:688`, and `types.rs:762` | Delete the note and revert the four link and status edits |

### 2026-08-06 — Automatic Docker and relay startup

- **Goal:** Start Docker Desktop, Buzz service containers, and the Buzz relay automatically after Windows logon.
- **Change:** Enabled Docker Desktop `AutoStart`, created `C:\ProgramData\Buzz\Start-BuzzStack.ps1`, and registered the `Buzz Stack Autostart` scheduled task with a 15-second logon delay.
- **Process improvement:** Startup is dependency-aware and idempotent. It waits for Docker, runs Compose declaratively, waits for PostgreSQL and Redis, checks port ownership, prevents duplicate relays, and verifies the readiness endpoint.
- **Logging:** Controller output is appended to `C:\ProgramData\Buzz\logs\startup.log`; relay stdout and stderr have separate files in the same directory.
- **Security boundary:** No private key or credential is stored in the task or controller. The controller uses only non-secret local URLs, executable paths, and Docker orchestration commands.
- **Result:** Complete.
- **Verification:** Manual script run exited `0`. Task Scheduler invocation completed with `LastTaskResult = 0`. An idempotency test detected the existing relay and did not create a duplicate. A controlled restart test then stopped the relay and invoked the task; it started a new relay process (PID `53968` at 12:51:18), returned the task to `Ready` with result `0`, and restored HTTP readiness by 12:51:26.
- **Rollback:** Disable or unregister `Buzz Stack Autostart` and turn off Docker Desktop's launch-at-login setting. This does not delete Buzz data or Docker volumes.

### 2026-08-06 — Native Windows installation

- **Repository/commit:** `block/buzz` / `9213090f6076bf3b7667b9b984752b3e47ef8f2f`
- **Goal:** Install a native Windows Buzz environment and desktop application.
- **Source location:** `D:\Source\Dev\buzz`
- **Installed application:** Buzz Desktop 0.5.5 at `C:\Program Files\Buzz\buzz-desktop.exe`
- **Relay:** `ws://localhost:3001`; port 3000 was already owned by Obsidian.
- **Toolchain:** supported Docker Desktop, Visual Studio C++ Build Tools, Rust
  MSVC, Node, pnpm, `just`, Lefthook, and CMake releases. Capture exact versions
  in private build evidence rather than the public build log.
- **Result:** Docker services started, migrations applied, community hosts seeded, JavaScript dependencies installed, Rust workspace built, MSI/NSIS bundles created, MSI installed, relay and desktop launched.
- **Verification:** `http://127.0.0.1:8080/_readiness` returned HTTP 200; installed desktop process was responsive; PostgreSQL, Redis, MinIO, and Keycloak reported healthy.
- **Problems encountered:** Hermit has no usable Windows Git Bash bootstrap artifact for the detected platform; port 3000 was occupied; CMake was not initially installed; the Compose Keycloak limit of 512 MB caused an OOM restart loop; its inherited health check targeted a disabled endpoint.
- **Resolution:** Used the README-supported manual toolchain, moved the relay to port 3001, installed signed CMake 4.3.1 from Kitware, and added an ignored local Compose override giving Keycloak 1 GB with a working HTTP-root health probe.
- **Rollback:** Uninstall Buzz using Windows Installed Apps or MSI product entry; run `docker compose down` from the checkout to stop services while preserving volumes. Removing Docker volumes or the checkout is a separate destructive decision.

## Entry template

### YYYY-MM-DD — Short title

- **Repository/commit:**
- **Goal:**
- **Change or command:**
- **Result:**
- **Verification:**
- **Problems encountered:**
- **Resolution:**
- **Rollback:**
- **Follow-up:**
