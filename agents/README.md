---
title: "Agent Documentation Collection"
created: 2026-08-16
description: "Source-of-truth library for the owner's Infrastructure, Security, and Cloud Buzz agents."
tags: [buzz, agents, infrastructure, security, cloud]
category: "AI / Buzz / Agents"
---
# Agent Documentation Collection

This collection defines **51 deployable Buzz personas**: 25 paired functions with separate Windows and `Lin` agents, plus one shared IT/Infrastructure Project Manager. `Lin` means **Linux and macOS**. Every Lin agent detects the actual OS before acting and never assumes Linux commands are valid on macOS.

## How to use this library

Each deployed persona combines three layers, in this order:

1. [Shared Operating Contract](01-shared-operating-contract.md) — authority, safety, evidence, documentation, and handoff rules shared by all agents.
2. A file in [`role-charters/`](role-charters/) — one responsibility, owned outputs, boundaries, checks, and handoffs for the function.
3. A file in [`platform-agents/`](platform-agents/) — the exact Windows or Lin deployment prompt and platform-specific behavior.

Squad instructions add coordination rules but do not replace the three layers. A persona may appear in more than one operational grouping, so squad membership never proves task capability. Managers should use the [Capability Routing Catalog](08-capability-routing-catalog.json), the current channel roster, and the applicable squad roster before every readiness check.

## Squads

| Squad | Deployable agents | Purpose |
| --- | ---: | --- |
| [Infrastructure Squad](squads/infrastructure-squad.md) | 29 | Local hosts, reliability, automation, packaging, support, networking, recovery, releases, and delivery |
| [Lin Security Squad](squads/lin-security-squad.md) | 10 | Linux and macOS security architecture, engineering, operations, identity, vulnerabilities, detection, PKI, governance, plus bounded strategic security research |
| [Win Security Squad](squads/win-security-squad.md) | 10 | Windows security architecture, engineering, operations, identity, vulnerabilities, detection, PKI, governance, and incident command |
| [Cloud Squad](squads/cloud-squad.md) | 4 | Azure/AWS test environments, Kubernetes, Terraform, capacity, and cost |
| **Unique deployable personas** | **51** | Squad membership counts are not additive because some platform roles also appear in broader operational groupings. |

## Environment boundary

- Current scope: the owner's local Windows, Linux, and macOS hosts and explicitly assigned Git repositories under a user-selected local, non-synced source root.
- Documentation source of truth: the owner's documentation workspace.
- External scope: explicitly assigned **test** Azure/AWS environments only.
- Production is out of scope unless the owner explicitly changes the scope for a named task.
- First-class technologies: Azure, AWS, Kubernetes, Terraform, Ansible, GitHub Actions, Intune, and Jamf.

## Deployment sequence

1. Review [Approval Gates and Change Safety](02-approval-gates-and-change-safety.md).
2. Review the [Roster and Ownership Matrix](03-roster-and-ownership-matrix.md).
3. Create the platform and functional Buzz squads using the ready-to-paste squad notes.
4. Create persona definitions from the platform-agent files.
5. Deploy one test identity per squad with autostart disabled.
6. Validate read/write paths, runtime authentication, and a harmless dry run.
7. Enable agents gradually; never launch all 51 untested.
8. Use [07 - Agent Runtime and LLM Assignment Matrix](07-runtime-and-llm-assignment-matrix.md) before changing any production harness or model.
9. Use the [Capability Routing Catalog](08-capability-routing-catalog.json) and the scoped channel/squad roster before selecting any worker.

## Naming convention

- Windows persona: `Windows <Role>`
- Linux/macOS persona: `Lin <Role>`
- Shared exception: `IT Infrastructure Project Manager`

Do not rename `Lin` to Linux in Buzz. Its charter deliberately covers both Linux and macOS.
