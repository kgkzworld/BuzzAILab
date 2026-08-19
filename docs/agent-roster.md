---
title: "Buzz - Agent Roster"
description: "Portable inventory of Buzz personas, runtimes, squads, and operating responsibilities."
tags: [buzz, ai-agents, agent-roster, personas]
category: "AI / Buzz / Agents"
---
# Buzz - Agent Roster

This roster tracks reusable setup information: display names, personas, squads, runtimes, harness requirements, and operating boundaries. Identity keys, creation timestamps, community-specific records, process IDs, and backup/restore metadata do not belong here.

## Sources of truth

| Fact | macOS | Windows |
| --- | --- | --- |
| Persona and deployed-agent registry | `/Users/<you>/Library/Application Support/xyz.block.buzz.app/agents/managed-agents.json` | `%APPDATA%\xyz.block.buzz.app\agents\managed-agents.json` |
| Team records | `/Users/<you>/Library/Application Support/xyz.block.buzz.app/agents/teams.json` | `%APPDATA%\xyz.block.buzz.app\agents\teams.json` |
| Harness logs | `/Users/<you>/Library/Application Support/xyz.block.buzz.app/agents/logs/` | `%APPDATA%\xyz.block.buzz.app\agents\logs\` |
| Global runtime defaults | `/Users/<you>/Library/Application Support/xyz.block.buzz.app/agents/global-agent-config.json` | `%APPDATA%\xyz.block.buzz.app\agents\global-agent-config.json` |
| Suggested workspace | `/Users/<you>/.buzz` | `C:\Users\<you>\.buzz` |

Buzz generates identity material when an agent is deployed. Do not ask a user to type or paste identity keys during normal setup. Key handling belongs only in an encrypted backup-and-recovery procedure.

## Required fields

Every deployed agent must have:

- Exact Buzz display name.
- Full system prompt from its persona document, not only the description.
- One owning squad and that squad's populated `instructions` field.
- Approved harness and model selected from a machine-capability assessment.
- Response policy, tool access, workspace, parallelism, and autostart settings.
- A completed role acceptance test before autostart or fleet deployment.

Every squad must have both a human-readable `description` and behavioral `instructions`. Every channel must have a purpose/scope description plus operating instructions in a supported channel field or a pinned message.

## Platform and infrastructure fleet

The authoritative ownership matrix is [03 - Roster and Ownership Matrix](../agents/03-roster-and-ownership-matrix.md). Each shared role normally has two deployable personas:

- `Windows <Role>` for Windows-native tooling and operational behavior.
- `Lin <Role>` for Linux and macOS, with mandatory detection of the actual OS before acting.

The shared IT Infrastructure Project Manager coordinates dependencies and status without taking over specialist work.

## Squads

| Squad | Purpose | Authoritative instructions |
| --- | --- | --- |
| Infrastructure Squad | Local-host infrastructure, reliability, delivery systems, support, and recovery | [Infrastructure Squad](../agents/squads/infrastructure-squad.md) |
| Security Squad | Security design, implementation, operations, verification, and security research | [Security Squad](../agents/squads/security-squad.md) |
| Cloud Squad | Explicitly approved Azure/AWS test environments, capacity, automation, and cost visibility | [Cloud Squad](../agents/squads/cloud-squad.md) |
| Researcher Squad | General research with primary-source evidence and explicit uncertainty | [Researcher Squad](../agents/squads/researcher-squad.md) |

Security Research Analyst belongs to Security Squad for security-specialist research and evidence synthesis. Broad research remains with the two General Researcher personas.

## Runtime assignment

Do not treat a sample runtime as universally installable. First scan the host's OS, architecture, CPU, memory, disk, GPU/VRAM or Apple unified memory, installed harnesses, authentication state, and local-model services. Present what can and cannot run and obtain approval before installing or downloading anything.

Use [Agent Runtime and LLM Assignment Matrix](../agents/07-runtime-and-llm-assignment-matrix.md) to map personas after that assessment. High-impact security, identity, PKI, incident, recovery, release, compliance, and architecture work requires a runtime with dependable tool use, visible reporting, and escalation behavior. A local model may assist without becoming the sole decision authority.

## Validation

For every deployed agent, verify:

1. It reports the correct display name, OS, persona, squad, scope, and boundaries.
2. Its complete system instructions and squad instructions are present.
3. It distinguishes observed evidence from inference.
4. It refuses gated actions until approval.
5. It hands adjacent work to the exact responsible display name.
6. It produces visible output through the selected harness.
7. It survives a controlled restart before autostart is enabled.

Record outcomes without identity keys, creation timestamps, private paths, community names, or other machine-specific operational reconnaissance.

## Related

- [Getting Started](getting-started.md)
- [Squads and Teams](squads-and-teams.md)
- [Creation and Validation Runbook](../agents/05-creation-and-validation-runbook.md)
- [Machine Migration and Recovery](runbooks/machine-migration-and-recovery.md)
