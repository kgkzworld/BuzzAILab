# BuzzAILab Release Notes

## Overview
This repository contains the documentation, prompts, and hard-won mistakes from one real build of a multi-agent workspace on [Buzz](https://github.com/block/buzz), with 51 infrastructure, security, and cloud personas.

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

## Status
This documents a working build, not a supported product. Version-specific details were true when recorded and drift quickly.