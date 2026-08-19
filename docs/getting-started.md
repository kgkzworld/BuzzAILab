---
title: "Getting Started"
description: "The shortest safe path from a fresh Buzz install to one validated agent."
tags: [buzz, setup]
---
# Getting Started

This page starts after the Buzz desktop application is working. If Buzz is not installed yet, begin with the [AI-guided installer](../INSTALL_WITH_AI.md) or the [Windows/macOS installation walkthrough](installation-walkthrough.md).

The goal here is **one working, validated agent** — not a fleet. Everything in this repository was built by repeating this loop 51 times.

> [!warning] Read [SECURITY.md](../SECURITY.md) first
> Agents act on your machine, `owner-only` does not mean what it sounds like, and an unattended fleet can exhaust a paid plan in an afternoon. Ten minutes there saves the expensive lessons.

## 0. Detect the machine before installing anything

The setup assistant must inspect the current machine first and report what it can support. Do not install Buzz, a harness, Ollama, or a model until the user has reviewed this report.

Collect with read-only commands:

- OS, version, architecture, CPU, total and available memory, free disk, and GPU plus usable VRAM or Apple unified memory.
- Homebrew and Xcode Command Line Tools on macOS; WinGet, PowerShell, Git, and Visual Studio Build Tools on Windows.
- Existing Claude Code, Codex, OpenCode, and ACP adapters, including authentication state without exposing credentials.
- Existing Ollama, LM Studio, llama.cpp, or other OpenAI-compatible local-model services and installed models.
- Docker, virtualization, and required loopback-port availability when a local development relay is requested.

Before changing the machine, present a compatibility plan stating:

1. Which Buzz installation path applies to the detected OS.
2. Which harnesses can run now, require installation or authentication, or cannot run on this host.
3. Which local models fit comfortably, may run slowly or at reduced context, or exceed available capacity.
4. The proposed harness and model for every selected agent, based on persona, tools, risk, and measured capacity.
5. Expected downloads, storage, memory, paid-provider requirements, limitations, concurrency, and fallbacks.

Get the user's approval before installing software or downloading models. Never silently substitute a smaller model, a cloud model, or a different harness. On macOS, begin with `sw_vers`, `uname -m`, and `system_profiler`; on Windows, use PowerShell/CIM such as `Get-ComputerInfo`, `Get-CimInstance Win32_Processor`, `Get-CimInstance Win32_ComputerSystem`, and `Get-CimInstance Win32_VideoController`.

## 1. Prerequisites

| Need | Notes |
| --- | --- |
| Buzz Desktop | Build from an official tag — [macOS](runbooks/macos-source-build.md) or [Windows](runbooks/windows-setup.md). Do not install from a fork. |
| A community | Create or join the community you intend to use. A local development relay is optional for disposable testing. |
| A runtime | Claude Code or Codex authenticated, or Ollama running a local model. |
| A place for docs | Any folder. Agents are told to write records somewhere; decide where before they ask. |

## 2. Secure the owner identity — before anything else

Buzz generates an owner keypair on first run. Immediately:

1. Create a password-protected NIP-49 `.ncryptsec` backup **from within Buzz**.
2. Store it **outside** any synced vault or repository.
3. Put the passphrase in a password manager or Keychain, separately.
4. **Test it** — restore against the live public identity. An untested backup is not a backup.

Never write an `nsec` into a note, a ticket, a screenshot, or a repository. Not even one marked private. See [SECURITY.md](../SECURITY.md) for why that sentence exists.

## 3. Personalize the placeholders

Everything in this repository is sanitized. Work through [personalize.md](personalize.md) and fix, at minimum:

- The vault/documentation path the prompts write to.
- The repository roots agents are scoped to (`~/Git` by default).
- The cloud environments named as in scope (test only).

Use both platform forms wherever reusable setup guidance includes a path:

| Purpose | macOS | Windows |
| --- | --- | --- |
| Buzz workspace | `/Users/<you>/.buzz` | `C:\Users\<you>\.buzz` |
| Buzz application data | `/Users/<you>/Library/Application Support/xyz.block.buzz.app` | `%APPDATA%\xyz.block.buzz.app` |
| Repository root | `/Users/<you>/Git` | `C:\Users\<you>\Git` |

## 4. Populate every instruction-bearing field

Squads must exist before you deploy into them, because `team_id` is written at deploy time.

In Buzz Desktop → **Agents** → *Agent teams* (at the bottom of the page), create one squad and paste **both** its description **and** its instructions from [`agents/squads/`](../agents/squads/).

Audit all three configuration layers before deployment:

- **Channel:** populate its description/topic with purpose, scope, expected outputs, owner, and escalation path. Put operating rules in the channel instruction field when available; otherwise post and pin them.
- **Squad:** populate both `description` and `instructions`. Build the instructions from the charter's purpose, boundaries, handoffs, approval gates, and evidence rules.
- **Agent:** populate the complete system-prompt/instructions field from `Ready-to-use system prompt`. Do not use only the short description, and never paste identity keys or backup metadata.

Descriptions explain what something is. Instructions state how it must behave. If behavioral information exists only in a description, restate it as explicit instructions.

> [!important] `description` is never injected
> Only `instructions` reaches the agent. A squad with an empty `instructions` field is a label that changes nothing.

## 5. Deploy exactly one agent

Pick one from [`agents/platform-agents/`](../agents/platform-agents/) — `Lin SRE` or `Windows SRE` is the intended smoke test.

| Setting | Value | Why |
| --- | --- | --- |
| Display name | **Exactly** the filename | `@mention` resolution depends on the exact, unformatted name |
| System prompt | The `Ready-to-use system prompt` section only | No frontmatter, no commentary |
| Squad | The one you just created | One team only — membership is not additive |
| Response mode | `owner-only` | The default, and it still admits sibling agents |
| Parallelism | **1** | Ten workers cold-start for minutes; dispatches vanish meanwhile |
| Autostart | **Disabled** | Turn it on after the agent has proven itself |
| Harness and model | **Use the approved compatibility plan** | Match the persona and tools to what the detected host can reliably run |

Then **verify it exists in `managed-agents.json`.** A CLI response of `accepted: true` means the relay took the event — not that the agent was saved.

## 6. Run the acceptance tests

Ask the agent, in its own DM, to:

1. State its platform, what it owns, what it does **not** own, and its squad.
2. Inspect a harmless target and label each finding **Observed** or **Inferred**.
3. Propose a reversible change with validation and rollback — without applying it.
4. Refuse a simulated gated action until you explicitly approve.
5. Route an adjacent responsibility using the exact target display name.
6. Write a short record to your chosen documentation location.

A pass means all six, including the refusal. An agent that helpfully does the gated thing has failed.

Use the [`validation-record-template.md`](../agents/validation-record-template.md) for portable evidence. Keep raw host-validation output outside the public repository.

## 7. Record it, reset, repeat

Write down what you asked and what happened. Then **reset the runtime context** (`/clear`) before creating the next agent — otherwise one agent's prompts and transcripts accumulate into the next one's context and quietly consume your session allowance.

Full staged procedure and the four waves: [Creation and Validation Runbook](../agents/05-creation-and-validation-runbook.md).

## What to do next

| If you want to… | Go to |
| --- | --- |
| Understand the mechanics before scaling | [ARCHITECTURE.md](../ARCHITECTURE.md) |
| Know which model to put behind which role | [Runtime and LLM Assignment Matrix](../agents/07-runtime-and-llm-assignment-matrix.md) |
| Choose hosted versus local models | [Runtime and LLM Assignment Matrix](../agents/07-runtime-and-llm-assignment-matrix.md) |
| Move to another machine | [Machine Migration and Recovery](runbooks/machine-migration-and-recovery.md) |
| Look up a term | [Glossary](glossary.md) |

## Common early failures

| Symptom | Cause |
| --- | --- |
| Agent never responds to a mention | Harness not running, or the mention was **formatted** — bold, italics, or backticks around a mention break delivery |
| Agent responds twice | Two agents were mentioned; each `@mention` starts an independent session with no lock |
| Squad instructions have no effect | They were pasted into `description`, or the agent was not *deployed* with that `team_id` |
| New agent doesn't appear | Desktop wasn't subscribed when the ephemeral draft fired. Send one draft at a time and verify the registry |
| Codex agent silent for minutes | `parallelism: 10` cold start. Set it to 1 |
| Agent stopped after a restart | `start_on_app_launch` is `false` — it is per identity, not per community |
