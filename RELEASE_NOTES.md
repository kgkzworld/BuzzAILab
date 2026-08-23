# BuzzAILab Release Notes

## Overview
This repository contains the documentation, prompts, and hard-won mistakes from one real build of a multi-agent workspace on [Buzz](https://github.com/block/buzz), with 51 infrastructure, security, and cloud personas.

## Declarative harness update — 2026-08-23

- **The model moved out of the roster and into a registry.** Roles are now model-independent `.role.md` sources with a `preferred_runtime_class`; a single `runtime-classes.json` is the only file that names a model; a compiler resolves the two into deployable packs. Swapping a model is one edit and a recompile instead of an edit per record.
- **Rewrote [ARCHITECTURE.md](ARCHITECTURE.md) §6** around that resolution step, including why a strict persona schema forces roles to compile into packs rather than be authored as packs.
- **Superseded the runtime matrix.** [agents/07](agents/07-runtime-and-llm-assignment-matrix.md) now opens with a pointer to the current registry and closes with the live runtime classes. The dated sections between are kept for their reasoning, not their model names.
- **Added an `image_generation` capability** to [agents/08](agents/08-capability-routing-catalog.json), with the routing rule that a pinned capability overrides scoring — the correction that stopped image requests from being scored onto a vulnerability-management engineer.
- **Four new lessons** in the README, each from a real failure: synthetic test wording hides classifier defects; one queue flush can hold more than one message; the desktop app rewrites its registry on exit; an image agent orchestrates a renderer rather than running on it.
- **New decisions and build-log entries** covering the declarative cutover, identity-free workers, and the native image-routing correction.

## Friends-and-family installer update

- Added a copy/paste AI installer prompt for Windows and macOS.
- Added an end-to-end installation walkthrough with the real Windows and macOS failure patterns.
- Reframed the landing page around installing Buzz from the official source instead of presenting the repository as only a historical account.
- Restored the complete public 51-persona library: platform prompts, role charters, squad instructions, creation runbook, runtime guidance, and validation template.

## What This Repository Contains

### Core Components:
- **Agents Library**: 51 platform personas including role charters, squads, shared operating contracts and approval gates
- **Architecture Documentation**: Complete architecture including identity model, substrate integration, and agent library design
- **Security Documentation**: SECURITY.md detailing private-key mistakes and security lessons learned
- **Runbooks & Guides**:
  - Getting started guide
  - Personalization instructions
  - Environment and operations procedures
  - Squad management documentation
  - Glossary of terms

### Key Documentation Files:
1. README.md - Overview and getting started guide
2. ARCHITECTURE.md - Complete architectural documentation
3. SECURITY.md - Security considerations and lessons from the build
4. docs/ folder - Detailed guides and decision logs
5. agents/ folder - Persona specifications, role charters, and platform agents

## Key Lessons Learned
- A note marked "private" in a synced vault is not a secret store
- Retrying a quota error is a bill multiplier
- A squad with an empty "instructions" field is a label, not a prompt layer
- An identity gets exactly one team_id
- "accepted: true" does not mean saved
- "owner-only" does not mean "only the human"
- A handoff written in prose fires nothing
- Ten Codex ACP workers take eight minutes to cold-start
- Testing a router with synthetic wording tests the wording, not the router
- One queue flush can hold more than one message
- The desktop app rewrites its agent registry when it exits
- An image agent does not run on the image model

## Status
This provides a repeatable Buzz installer guide and reusable agent library; it is not a redistribution of the Buzz application. Version-specific details can drift and should be checked against upstream.
