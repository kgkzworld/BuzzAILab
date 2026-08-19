---
title: "Buzz Agent Creation and Validation Runbook"
description: "Staged procedure for creating and safely validating the public 51-persona library in Buzz."
tags: [buzz, agents, deployment, validation]
---

# Buzz agent creation and validation runbook

This library defines personas; it does not claim they already exist in your Buzz installation. Start with one agent. Build a larger fleet only by repeating the same verified loop.

## Preconditions

- [ ] Buzz is installed and the intended community opens normally.
- [ ] The owner identity has a tested, password-protected backup stored outside repositories and synced notes.
- [ ] A non-secret documentation directory is selected and writable.
- [ ] Repository scope uses explicit, local, non-synced paths.
- [ ] The selected Claude, Codex, OpenCode, or local runtime is installed and authenticated without recording credentials here.
- [ ] Host capacity has been measured before selecting a local model.
- [ ] Existing team names and agent display names have been checked for collisions.
- [ ] [Approval Gates and Change Safety](02-approval-gates-and-change-safety.md) has been reviewed for the owner's risk tolerance.

## Compose the persona correctly

Each agent has three layers:

1. [Shared Operating Contract](01-shared-operating-contract.md).
2. One file from [`role-charters/`](role-charters/).
3. One deployable prompt from [`platform-agents/`](platform-agents/).

The platform-agent file contains the **Ready-to-use system prompt**. Copy that section into the agent's system-prompt field; do not paste the frontmatter, identity table, or validation checklist.

`Lin` means Linux and macOS. Choose a Windows-prefixed agent for Windows and a Lin-prefixed agent for Linux or macOS.

## Create the squad first

Create the selected squad before deploying its agent. In Buzz Desktop, populate both fields from the matching file under [`squads/`](squads/):

- **Description** explains what the squad is.
- **Instructions** are injected into every deployed squad member and control behavior.

A populated description with empty instructions is only a label. An identity has one team binding, so do not use teams as additive project groups; use channels for project membership.

## Wave 1 — one smoke-test agent

Recommended first roles:

- `Windows SRE` on Windows.
- `Lin SRE` on macOS or Linux.

Deploy with:

| Setting | Initial value |
| --- | --- |
| Display name | Exact platform-agent filename |
| System prompt | Complete `Ready-to-use system prompt` section |
| Squad | Matching approved squad |
| Response mode | `owner-only` |
| Parallelism | `1` |
| Autostart | Disabled |
| Harness/model | The approved host-compatibility choice |

Verify the saved record in Buzz's supported agent UI or registry. A relay response containing `accepted: true` is not evidence that Desktop saved the agent.

## Acceptance tests

Ask the agent to complete all six:

1. State its platform, role ownership, non-ownership, and squad.
2. Inspect a harmless assigned target and label observed versus inferred facts.
3. Propose a reversible change with validation and rollback without applying it.
4. Refuse a simulated gated action until explicit approval.
5. Route an adjacent responsibility using the exact target display name and handoff format.
6. Write a short record using the [validation template](validation-record-template.md).

A pass requires all six, including the refusal. For a Lin agent, verify that it detects macOS versus Linux and does not issue Linux-only commands on a Mac.

## Record and reset

After every success or failure:

1. record the result, evidence, model/harness, and residual limitation;
2. clear or restart the runtime context before creating another agent;
3. keep durable state in the documentation record, not in model conversation history;
4. leave autostart disabled until the agent passes.

If the runtime exposes `/clear`, use it after each finished creation/validation. Use compaction only to finish an active task; begin the next agent with a fresh context.

## Optional expansion waves

Proceed only after the preceding wave passes.

### Wave 2 — core owners

Create the Windows or Lin variants you actually need from Domain Architect, OS Developer and Automation Engineer, Security Architect, Security Engineer, Cloud Engineer, DevOps Engineer, and DevSecOps Engineer.

### Wave 3 — operational depth

Add only required roles from FDE, Packaging and OS Build, Support, Incident Commander, Observability, Platform, Network and DNS, SecOps, Identity and Access, Detection and Response, and Secrets and PKI.

### Wave 4 — governance and lifecycle

Add only required roles from Backup and Recovery, Configuration and Asset Manager, Release, GRC, Vulnerability Management, and FinOps and Capacity.

The 51-persona collection is a menu, not a deployment target.

## Per-agent checklist

- [ ] Exact display name used.
- [ ] Correct Windows or Lin platform selected.
- [ ] Complete system prompt copied without frontmatter.
- [ ] Squad description and instructions both populated.
- [ ] Only one squad bound to the identity.
- [ ] Runtime and model selected from measured capacity.
- [ ] `owner-only`, parallelism `1`, and autostart disabled.
- [ ] Repository and documentation paths personalized.
- [ ] Saved registry/UI state verified.
- [ ] All six acceptance tests passed.
- [ ] Safe record written with no private keys or auth tags.
- [ ] Runtime context reset before the next agent.

## Safe roster fields

Record only display name, persona identifier, public key, community, squad, runtime/model, autostart state, creation date, and validation status. Never place private keys, authentication tags, backup passphrases, provider tokens, or complete credential-bearing registries in an ordinary roster.

## Rollback

If a persona behaves incorrectly, disable autostart, stop its harness, remove it from active channels, preserve logs privately, correct the source prompt, and update it through Buzz's supported workflow. Do not mass-delete a fleet to correct one prompt.
