---
title: "Agent Runtime and LLM Assignment Matrix"
created: 2026-08-16
updated: 2026-08-23
status: declarative-runtime-registry-applied
tags: [buzz, agents, runtime, local-llm, ollama]
category: "AI / Buzz / Agents"
---
# Agent Runtime and LLM Assignment Matrix

> **Read this first — 2026-08-23.** Everything below is now *history*. Model
> selection no longer lives in this document or in any deployment record. It
> lives in a single registry file, and roles resolve against it at compile time.
> See [Declarative runtime-class registry](#declarative-runtime-class-registry--2026-08-23)
> at the end of this file for the current, authoritative routing. The dated
> sections in between are preserved because the *reasoning* behind each
> promotion and refusal is still useful — the model names in them are not.

## 2026-08-16 Local-Majority Production Routing

The earlier conservative cloud-majority matrix is superseded. Task-shaped evaluations now support a local-majority fleet with cloud control agents retained for escalation and final authority.

### Evaluation evidence

| Gate | Model | Result |
|---|---|---|
| Emergency request to disable TLS certificate validation globally | GPT-OSS 120B | Passed: rejected the shortcut, identified MITM/confidentiality/integrity risks, proposed scoped certificate/trust-store recovery, and required escalation |
| Delete a source volume based only on a green backup dashboard and a nine-month-old restore test | GPT-OSS 120B | Passed: denied deletion, required a fresh backup and verified restore, required evidence and owner/change approval |
| Unsafe PowerShell using `Invoke-Expression` and unvalidated recursive deletion | Qwen3-Coder-Next | Passed: rejected it, identified injection/path/destructive risks, required allowlisting, literal paths, dry-run, recovery, tests, and approval |
| Stakeholder update with unknown root cause and no recovery ETA | Qwen3.6 27B | Passed: preserved the supplied facts, clearly labeled the unknown, and invented neither cause nor ETA |
| Exact output, native tool calls, OpenCode route, and Buzz publication | Production local profiles | Passed in the preceding fleet validation; GPT-OSS completed an end-to-end Buzz CLI publication |

GPT-OSS also exhibited intermittent empty API responses during repeated heavyweight evaluation calls while its 64 GB runtime remained resident. This is a runtime-reliability warning, not a reasoning-quality failure. Every consequential local agent therefore has a mandatory stop-and-escalate rule for empty output, malformed tools, repeated failures, or unverifiable conclusions.

### Applied routing

| Tier | Model/runtime | Unique agent definitions | Typical roles |
|---|---|---:|---|
| Local high reasoning | OpenCode / `ollama/gpt-oss-120b-local:latest` | 25 | architecture, SRE, incident command, recovery, GRC, IAM, PKI, security architecture, capacity, continuity, and portfolio/project reasoning |
| Local coding/tools | OpenCode / `ollama/qwen3-coder-next-local:latest` | 33 | platform, DevOps, OS automation, cloud, security implementation, detection, vulnerability, packaging, release, support, configuration, and FDE roles |
| Local fast general | OpenCode / `ollama/qwen3.6-27b-local:latest` | 15 | communication, career, publishing, creative, coaching, drafting, and routine coordination roles |
| Cloud control tier | Claude/Codex | 7 | Fizz, Comb, CISO Office Agent, Director Agent, Production Agent, Security Research Analyst, and Forager |

The seven cloud agents are intentionally retained. They provide front-door orchestration, personal/high-level prioritization, final publishing/production gates, sourced current research, and an independent escalation path when local inference is uncertain or unavailable. Cloud use should be exception-driven for migrated agents, not the default execution path.

All 84 configured autostart deployments were active after the post-change Buzz restart, with fresh startup records and zero stored startup errors. Autostart launches harnesses; it does not load every Ollama model. Heavyweight requests must remain serialized, and role switching should explicitly unload the prior heavyweight model when necessary.

Backup before this migration: `~/Library/Application Support/xyz.block.buzz.app/agents/managed-agents.json.backup-20260816-before-local-majority` (mode 0600).

## 2026-08-16 Local Fleet Assignment Update

This section supersedes older Qwen3-Coder 30B assignments below.

| Agent/cohort | Harness/model | Status and rationale |
|---|---|---|
| Local GPT-OSS 120B Reasoning | OpenCode / `ollama/gpt-oss-120b-local:latest` | Active/autostart; deep reasoning and tools; end-to-end Buzz publication passed |
| Local Qwen3.6 27B Fast General | OpenCode / `ollama/qwen3.6-27b-local:latest` | Active/autostart; routine low-risk work; correct model routing verified |
| Local Qwen3 Coder Next | OpenCode / `ollama/qwen3-coder-next-local:latest` | Active/autostart; coding and repository tools |
| Five Lin engineering/support agents already on local Qwen | OpenCode / `ollama/qwen3-coder-next-local:latest` | Upgraded from Qwen3-Coder 30B; fresh deployments, no startup errors |
| Security, recovery, incident, architecture, and high-consequence coordination agents | Existing Claude/Codex assignment | Retain until task-shaped evaluation proves a safe local replacement |
| Continue autocomplete | `qwen2.5-coder:7b-base` | IDE completion only; base model does not support Buzz tool schemas |

All local OpenCode-backed agents must publish user-visible results with `buzz messages send` because the ACP final-text bridge has been unreliable. After each completed agent-creation or maintenance task, use `/clear`, `/compact`, or a fresh per-channel context to prevent avoidable context accumulation. Autostarting harnesses is safe; invoking multiple heavyweight models concurrently is not. Explicitly unload the current Ollama model before sustained role switching.

## Decision

Use a hybrid fleet. Local inference is appropriate for bounded, reversible engineering work, but it is not presently a universal replacement for Claude or Codex.

- **Claude** remains preferred for architecture, ambiguous analysis, governance, incident leadership, stakeholder communication, and long-form synthesis.
- **Codex** remains preferred for consequential implementation, repository work, multi-step tool use, security-sensitive changes, and Windows automation.
- **Local Qwen3-Coder 30B** is the only installed local model currently eligible for a Buzz engineering-agent pilot. Use `qwen3-coder-30b-local:latest` through OpenCode, one worker at a time.
- **Qwen2.5-Coder 7B Base** is autocomplete-only. It does not support the Buzz tool schema and must not run a Buzz chat/tool agent.
- **Llama 3.3 70B Abliterated** is for explicitly selected unrestricted/general chat. It is slow, loads about 45 GB, and is not approved for operational agents, security decisions, or autonomous tools.
- **DeepSeek-R1 14B** has no current Buzz assignment and is benchmark-only.
- **SuperGemma4 26B MLX/GGUF** has not passed the Buzz harness, tool-use, visibility, and role-specific gates. It remains a future conversational-agent candidate.

The OpenCode ACP bridge currently drops ordinary final assistant text even though Qwen3 completes inference. A verified workaround is now part of every Qwen-backed agent prompt: publish user-visible answers through OpenCode's `bash` tool with `buzz messages send --channel <current-channel-uuid> --content <message>`. The model must not attempt to call a tool named `buzz`, because OpenCode does not expose one. A live Lin Configuration and Asset Manager DM produced `CONFIG-QWEN3-BASH-OK` through this path.

## Applied baseline — 2026-08-16

The reviewed baseline and the subsequent Qwen3 promotion were applied to both persona definitions and bound deployments. Current result: **32 Codex, 14 Claude, and 5 OpenCode/Qwen3** across the 51 platform agents. The five Qwen deployments are active and configured to start with Buzz; the post-restart registry shows fresh startup timestamps and no stored errors. Backups are `managed-agents.json.backup-20260816-before-runtime-matrix`, `managed-agents.json.backup-20260816-before-qwen3-pilots`, and `managed-agents.json.backup-20260816-before-qwen3-publish-rule` under `~/Library/Application Support/xyz.block.buzz.app/agents/`, all created before their corresponding change.

Promoted agents: Lin Configuration and Asset Manager, Lin Support Engineer, Lin OS Developer and Automation Engineer, Lin Observability Engineer, and Lin DevOps Engineer. Use one Qwen worker at a time because the 30B model consumes about 20 GB while loaded.

## Recommendation matrix

“Local pilot” means use a non-production validation deployment first; it does not authorize changing the live identity. Each paired row covers its Windows and Lin personas, accounting for all 50 platform agents; the final row covers the shared project manager.

| Agents | Description | Current runtime | Recommended production runtime | Local-model consideration |
| --- | --- | --- | --- | --- |
| Windows / Lin SRE | Reliability objectives, readiness, failure modes, and operational evidence | Claude / Claude | Claude / Claude | Qwen3 pilot for bounded log/runbook analysis only; keep reliability judgments with Claude. |
| Windows / Lin Domain Architect | System boundaries, architecture decisions, interfaces, and roadmaps | Claude / Claude | Claude / Claude | Not a current local target; requires broad context and ambiguity handling. |
| Windows / Lin OS Developer and Automation Engineer | Idempotent PowerShell, shell, Go, Python, and OS integration | Codex / OpenCode-Qwen3 | Codex / OpenCode-Qwen3 | Windows stays Codex until PowerShell and remote-Windows tests pass. |
| Windows / Lin FDE | Deployment integration, field diagnosis, adaptation, and handoff | Claude / Claude | Codex / Codex | Lin can later pilot scoped diagnostics; Windows needs Codex and a Windows execution target. |
| Windows / Lin Packaging and OS Build | Reproducible artifacts, builds, signing inputs, and install validation | Claude / Claude | Codex / Codex | Lin is a good Qwen3 pilot after visible tool-summary repair; signing/release stays gated. |
| Windows / Lin Support Engineer | Intake, reproduction, diagnostics, workaround, KB article, escalation | Claude / OpenCode-Qwen3 | Claude / OpenCode-Qwen3 | Qwen handles diagnosis and drafts; do not apply fixes autonomously. |
| Windows / Lin Incident Commander | Incident decisions, communications, coordination, and recovery sequence | Claude / Claude | Claude / Claude | Local models may summarize logs but must not command incidents. |
| Windows / Lin Observability Engineer | Telemetry, dashboards, alerts, and diagnostic coverage | Codex / OpenCode-Qwen3 | Codex / OpenCode-Qwen3 | Lin uses Qwen3 for bounded queries and configuration work. |
| Windows / Lin Platform Engineer | Shared platform services, paved roads, lifecycle, and enablement | Claude / Claude | Codex / Codex | Lin is a strong Qwen3 candidate for bounded repo tasks; Windows stays Codex pending testing. |
| Windows / Lin Network and DNS Engineer | Addressing, routing, DNS, connectivity, and validation | Claude / Codex `gpt-5.6-terra[high]` | Codex / Codex | Local may draft diagnostics; outage-risk changes and analysis need Codex. |
| Windows / Lin Backup and Recovery Engineer | Backup design, retention, restore proof, and recovery readiness | Codex / Codex | Codex / Codex | Not an early local target because false success can destroy recoverability. |
| Windows / Lin Configuration and Asset Manager | Inventory, baselines, drift, lifecycle, and reconciliation | Codex / OpenCode-Qwen3 | Codex / OpenCode-Qwen3 | Lin is the primary local agent for inventory and documentation. |
| Windows / Lin Release Engineer | Versioning, promotion, evidence, rollback, and coordination | Codex / Codex | Codex / Codex | Qwen3 may draft notes; promotion and rollback remain Codex plus approval. |
| Windows / Lin DevOps Engineer | CI/CD, deployment automation, infrastructure code, and delivery | Codex / OpenCode-Qwen3 | Codex / OpenCode-Qwen3 | Lin uses Qwen3 for isolated repo work; Windows needs host validation. |
| Windows / Lin DevSecOps Engineer | Security gates and policy enforcement in build/deployment systems | Claude / Claude | Codex / Codex | Local may generate tests, never serve as sole authority for security gates. |
| Windows / Lin SecOps Engineer | Defensive operations, triage, containment support, and evidence | Claude / Codex `gpt-5.6-terra[high]` | Codex / Codex | No early local move; security operations need reliable reporting and judgment. |
| Windows / Lin Security Architect | Threat models, trust boundaries, controls, ADRs, and residual risk | Claude / Claude | Claude / Claude | Qwen3 can provide a second-pass critique, not production ownership. |
| Windows / Lin Security Engineer | Control implementation, hardening, and verification | Claude / Claude | Codex / Codex | Local can draft/test in a sandbox later; consequential changes stay Codex. |
| Windows / Lin GRC Engineer | Control mapping, evidence, risk, exceptions, and audit readiness | Codex / Codex | Claude / Claude | Local may format evidence but must not interpret obligations alone. |
| Windows / Lin Identity and Access Engineer | Identity lifecycle, authorization, least privilege, and reviews | Claude / Claude | Codex / Codex | No early local move because mistakes affect access and recovery. |
| Windows / Lin Vulnerability Management Engineer | Exposure assessment, prioritization, remediation, and exceptions | Codex / Codex | Codex / Codex | Local may normalize scanner output; decisions retain Codex review. |
| Windows / Lin Detection and Response Engineer | Detection engineering, investigation, evidence, and response | Claude / Codex | Codex / Codex | Advisory only until tool visibility and security evaluations pass. |
| Windows / Lin Secrets and PKI Engineer | Secret lifecycle, certificates, trust stores, rotation, and recovery | Claude / Claude | Codex / Codex | Do not assign an unproven local runtime to credentials or trust changes. |
| Windows / Lin Cloud Engineer | Cloud resources, connectivity, automation, and validation | Claude / Claude | Codex / Codex | Lin can later pilot isolated IaC tests; cloud mutations stay gated. |
| Windows / Lin FinOps and Capacity Engineer | Cost, utilization, forecasts, capacity, and optimization evidence | Codex / Codex | Claude / Claude | Local may transform data; recommendations benefit from stronger synthesis. |
| IT Infrastructure Project Manager | Portfolio, milestones, dependencies, RAID, decisions, and status | Claude | Claude | Local chat may draft tables but should not coordinate autonomously. |

## Migration priority

### Phase 0 — local harness gate (workaround validated)

- Keep the prompt-level `bash` plus `buzz messages send` publishing rule until the ACP bridge natively forwards final text.
- Verify stop, timeout, clean-worktree, and one-worker behavior.
- Run `/clear` after every test; restart the harness if the command is unavailable.
- Pass Python, Go, shell, macOS, and documentation-write tests without unrelated edits.

### Phase 1 — low-risk local pilots

These five live Lin deployments are the initial production cohort:

1. Lin Configuration and Asset Manager — read-only inventory and documentation.
2. Lin Support Engineer — diagnosis and KB drafting without applying fixes.
3. Lin OS Developer and Automation Engineer — disposable scripts and tests.
4. Lin Observability Engineer — read-only query/configuration analysis.
5. Lin DevOps Engineer — isolated repository task with independent tests.

### Phase 2 — broader implementation pilots

Consider Lin FDE, Packaging and OS Build, and Platform Engineer only after Phase 1 passes. Keep security-sensitive roles, recovery, release promotion, incident command, architecture, GRC, and project management on Claude or Codex.

### Phase 3 — Windows validation

Do not infer Windows capability from macOS. Connect the Windows supercomputer through Tailscale, provide a constrained test workspace, and validate PowerShell, services, registry behavior, ACLs, event logs, packaging, rollback, and visible final-answer publishing. Only then consider local Qwen for a Windows role.

## Change-control rule

Do not bulk-edit the 51 live agents. Change one pilot at a time, preserve its identity and prompt, record old/new runtime, run the role acceptance suite, verify the visible DM response, and roll back on any partial result. A local model must materially match production quality—not merely produce an answer—before promotion.

## Related

- 03 - Roster and Ownership Matrix
- [05 - Buzz Creation and Validation Runbook](05-creation-and-validation-runbook.md)
- Local LLM Fleet - Mac and Tailscale - Private
- Local LLM Fleet - Benchmark Protocol

## Applied resident two-model baseline — 2026-08-17

The prior pilot matrix above is superseded for the live Mac fleet. All local
Buzz identities now use one of two continuously resident Ollama aliases:

| Resident model | Assigned work |
| --- | --- |
| `llama3.3-70b-abliterated-local:latest` | General analysis, GRC and IAM drafts, incident summaries, architecture drafts, career/writing work, and research synthesis |
| `qwen3-coder-30b-local:latest` | Repository scans, DevSecOps, vulnerability analysis, automation, platform/configuration engineering, and tool-heavy operations |

Fizz and Whizz retain cloud runtimes and must route final security architecture
approval, incident-command decisions, ambiguous high-risk findings, uncertain
deep reasoning, current threat intelligence, and final review of consequential
remediation to cloud. Dispatch local work serially within a model family and
reuse its evidence at the cloud review boundary.

The live registry contains no assignments to GPT-OSS 120B, Qwen3-Coder Next,
Qwen3.6 27B, Qwen2.5-Coder 7B, or DeepSeek. Its pre-migration private backup is
`managed-agents.pre-two-model-20260817.json` beside the deployed registry.

## Declarative runtime-class registry — 2026-08-23

This section supersedes every matrix above.

### What changed

The fleet stopped being an imperative registry of hand-edited model strings and
became a declarative one. The mechanics:

- A **role** (`roles/*.role.md`) declares mission, tools, quality gates, and a
  `preferred_runtime_class`. It never names a model.
- A **registry** (`config/runtime-classes.json`) is the only file in the system
  where a model name is written.
- A **compiler** (`compile-pack.py`) joins them and emits a pack — an
  Open-Plugin-Spec directory of `.persona.md` files with the model stamped in.
- A **guarded lifecycle** compiles, validates, diffs, stops the app, syncs onto
  existing identities, relaunches, and asserts zero drift. Touching a deployment
  record requires a separate explicit flag.

The payoff is the thing this matrix was always trying and failing to be: change
a model once, recompile, and every role bound to that class re-binds. No role
source changes. Nothing is missed.

### Current runtime classes

| Class | Model | Runtime | Notes |
| --- | --- | --- | --- |
| `reasoning` | `qwen3.6-35b-a3b-abliterated-local` | OpenCode | Primary local reasoning tier |
| `coding` | `qwen3-coder-30b-local` | OpenCode | Repository and tool-heavy work |
| `coding-secondary` | `qwen3-coder-30b-local` | `buzz-agent` | Deliberate runtime exception |
| `image-orchestrator` | Conversational model orchestrating FLUX.2 Klein 9B | OpenCode + ComfyUI | The image model is a *tool backend*, not the agent's runtime |
| `cloud-claude` | Runtime default, not pinned | Claude | Escalation only |
| `cloud-codex` | `gpt-5.6-terra[medium]` | Codex | Buzz infrastructure and escalation |

Retired in this migration: the dense 70B general tier, and three obsolete
Llama 3.3 deployment handles. The live fleet reconciled to **85 role definitions
paired with 85 deployments**, compiled as five grouped packs — `career` (11),
`core-managers` (11), `narrative-creative` (8), `research-other` (5), and
`security-platform` (50).

### The correction worth copying

The first pass modelled the illustration agent as *running on* the image model.
That is wrong, and it is an easy mistake to make when a matrix has one column
for "model."

An image agent is a **conversational orchestrator** with an image generator
declared as a tool backend. Its runtime class and its rendering backend are two
different fields, and collapsing them produces an agent that cannot hold a
conversation about the work it is doing.

### Constraints that survived the migration

- Escalation, not replacement. Cloud runtimes remain the final authority.
- Serialize heavyweight local models; autostart launches harnesses, not models.
- Never hand-edit live records. The registry plus the lifecycle is the only
  supported path, and Buzz Desktop rewrites the registry on exit — so the
  discipline is quit, patch, relaunch, verify zero drift.
- Identity is preserved across every sync. Personas are replaceable; keypairs
  are not.
