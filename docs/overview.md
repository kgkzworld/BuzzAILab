---
title: "Buzz Overview"
description: "What Buzz is, the separation of concerns that keeps a build sane, and a map of every document in this repository."
tags:
  - "buzz"
  - "moc"
  - "ai-agents"
  - "self-hosted"
category: "AI / Agent Workspaces"
---
# Buzz Overview

Buzz is a self-hostable workspace where humans and AI agents use the same rooms, identity model, workflows, repositories, and signed Nostr event log. An agent is not a chatbot bolted onto a chat app — it is a first-class participant with its own keypair, its own channel memberships, and an audit trail attributable to that identity.

Buzz manages agents and collaboration. It does not supply the models. Agents can be backed by hosted runtimes (Claude, Codex), by a local inference fleet, or by both in the same deployment.

## Source material

- [Official repository](https://github.com/block/buzz) — the authoritative source for installation, releases, documentation, and development. Always verify a changing detail against upstream rather than against this repository.

Everything here is a field record of one build, not a substitute for the upstream docs. Where the two disagree, upstream is right and this repository is stale.

## The guiding separation

The single most useful decision in this build. Four stores, four purposes, no overlap:

```text
Knowledge vault    → runbooks, decisions, agent definitions, non-secret examples
Local source tree  → repository, dependencies, build artifacts
Secret store/.env  → private keys, credentials, tokens
Docker volumes     → PostgreSQL, Redis, and MinIO development state
```

**Nothing from column three ever enters column one.** That rule is what makes a knowledge vault publishable at all — and the one time it was broken, a live private key ended up in a cloud-synced folder. See [SECURITY.md](../SECURITY.md).

## Map of this repository

### Design and mechanics

| Document | What it answers |
| --- | --- |
| [Architecture and Agent Integration](architecture-and-agent-integration.md) | Relay, storage, protocol, persona-vs-identity, session isolation, teams, access control, ACP and MCP |
| [Agent Roster](agent-roster.md) | How personas and identities relate in practice, the built-in trio, runtime defaults, and the coordination gaps found the hard way |
| [Squads and Teams](squads-and-teams.md) | How a team's `instructions` actually reach an agent, the one-team-per-identity rule, and two expensive mistakes |
| [Decisions and Build Log](decisions-and-build-log.md) | Why each choice was made, what changed, what was verified, and how to roll it back |

### The agent library

| Document | What it answers |
| --- | --- |
| [Agent Documentation Collection](../agents/README.md) | The 51-persona Infrastructure, Security, and Cloud library and how its three layers compose |
| [Shared Operating Contract](../agents/01-shared-operating-contract.md) | The base policy every agent inherits |
| [Approval Gates and Change Safety](../agents/02-approval-gates-and-change-safety.md) | What an agent may never do without being asked |
| [Runtime and LLM Assignment Matrix](../agents/07-runtime-and-llm-assignment-matrix.md) | Which model backs which role, and the evidence behind each assignment |

### Runbooks

| Document | What it answers |
| --- | --- |
| [macOS Source Build](runbooks/macos-source-build.md) | Building Buzz from source on Apple Silicon |
| [macOS and Server Deployment](runbooks/macos-and-server-deployment.md) | Deploying to a Mac or a server, including the handoff package |
| [Windows Setup](runbooks/windows-setup.md) | Native Windows install with Git Bash and Docker Desktop |
| [Machine Migration and Recovery](runbooks/machine-migration-and-recovery.md) | Pre-move inventory, the encrypted backup boundary, rebuild order, and the acceptance test |
| [Environment and Operations](environment-and-operations.md) | Environment variables, daily commands, fleet checks, troubleshooting, and incident records |

## Installation models

**macOS** is the current primary target — build from an official tag, install to `/Applications` with real companion binaries. Start at [macOS Source Build](runbooks/macos-source-build.md).

**Windows** supports a native development setup. Use Git Bash for Hermit and Buzz commands, and Docker Desktop for the containerized backend services. WSL is not required, although Docker Desktop can use WSL 2 internally. Keep the checkout on the Windows filesystem, such as `C:\src\buzz`. Start at [Windows Setup](runbooks/windows-setup.md).

## Community setup

Create or join the community you intend to use during Buzz setup. This repository does not prescribe, inventory, or track a particular community. A local development relay is optional for disposable testing.
