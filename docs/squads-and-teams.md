---
title: "Squads and Teams"
description: "How a Buzz team actually reaches an agent - verified against the source - plus the one-team-per-identity rule and ready-to-paste squad descriptions."
tags:
 - "buzz"
 - "ai-agents"
 - "squads"
 - "teams"
category: "AI / Buzz / Agents"
---
# Squads and Teams

How groupings work in Buzz, verified against `teams.json`, the agent registry, and the Buzz source tree. Companion to [Agent Roster](agent-roster.md), which covers individual agents; this note covers the groupings.

The mechanics below are the important part. Getting them wrong is the difference between a squad that shapes behaviour and a squad that is only a label — and the mistakes recorded here were all made first.

## Where the truth lives

| Fact | Source |
| --- | --- |
| Team records | `%APPDATA%\xyz.block.buzz.app\agents\teams.json` |
| An identity's team binding | `team_id` inside `%APPDATA%\xyz.block.buzz.app\agents\managed-agents.json` |
| Injection path | `desktop/src-tauri/src/managed_agents/spawn_snapshot.rs:48` |

> [!warning] Creating a team is a Buzz Desktop action
> There is no CLI verb. `buzz agents` covers drafts and archiving only. Teams are created and edited in the Desktop UI.

## How a team actually reaches an agent

Four mechanics, all verified against the source at commit `9213090f` - the commit the installed Desktop 0.5.5 was built from. Getting these wrong is the difference between a squad that shapes behaviour and a squad that is only a label.

### 1. `instructions` is injected. `description` is not.

`TeamRecord` (`managed_agents/types.rs:762`) carries both fields, and only one of them travels:

```text
team.instructions
 -> BUZZ_ACP_TEAM_INSTRUCTIONS (managed_agents/runtime.rs:688)
 -> compose_prompt (crates/buzz-acp/src/pool.rs:1305)
 -> [Team Instructions] block in every member's prompt
```

`description` is display-only. It appears in the Desktop UI and nowhere else. Nothing an agent can read.

### 2. An identity gets exactly one team

`effective_team_instructions` resolves the single team whose `id` matches the record's `team_id`:

```rust
teams.iter()
 .find(|team| Some(team.id.as_str()) == record.team_id.as_deref())
 .and_then(|team| team.instructions.as_deref())
```

`team_id` is an `Option<String>`, not a list. **Membership is not additive - joining a second team means leaving the first.**

### 3. The binding is per-harness, not per-channel

`BUZZ_ACP_TEAM_INSTRUCTIONS` is set on the spawned process. One agent runs one harness across all its channels, so team instructions apply everywhere that agent works - including channels that have nothing to do with the squad. This is why adding the built-in trio to a project team is a bad trade: it would layer project-specific instructions onto Fizz, Honey, and Bumble in every room they occupy.

If you want general-purpose help in a squad's channel, add the agent to the **channel**, not the team. Channel membership is per-channel, additive, and costs nothing.

### 4. `team_id` is written at deploy time

`commands/agents.rs:759` sets it from the deploy input and validates the team exists. Listing a persona in a team's `persona_ids` is the Desktop's grouping view - it does **not** by itself write `team_id` onto the deployed identity.

> [!important] A squad with no `instructions` is only a label
> In the first build, **none** of the teams had an `instructions` field, and only the built-in-trio identities carried a `team_id` at all. Every squad was a grouping in the UI and nothing more. If you create squads and skip this field, you have organised your roster without changing a single agent's behaviour.

## The built-in Welcome Team

Buzz ships with a Welcome Team (`builtin-team:welcome`) holding Fizz, Honey, and Bumble. Every identity of those three personas already carries that `team_id`.

That matters more than it looks: **their one team slot is already spent.** The built-in team sets no `instructions`, so the binding costs nothing and delivers nothing — but the moment you want Fizz in a real squad, you have to take it out of Welcome first.

## Two mistakes worth inheriting

Both of these were made in the original build, found by reading the source, and are cheap to avoid.

### The brief in the wrong field

A squad was created with a full project brief — source-of-truth paths, hard rules, build commands, current status — pasted into its **`description`**. `description` is never injected. Not one agent ever read a word of it, and the squad looked correctly configured the whole time.

If you want a brief to reach the members, it goes in `instructions`, and each member has to be *deployed* with that `team_id`.

### The same agent in two squads

Three agents were listed in `persona_ids` for two different squads. Because an identity carries a single `team_id`, **only one of the two can ever apply.** Whichever squad they were deployed into last wins; the other silently stops being a prompt layer for them, with no warning anywhere in the UI.

Decide which squad owns an agent. If two groupings genuinely need the same specialist, merge the squads and separate the work with **channels** instead — channel membership is per-channel, additive, and free.

## The Executive Career Office squads

Four squads covering the fifteen ECO agents created 2026-08-07. **None of these exists in `teams.json` yet** - the descriptions below are ready to paste into Buzz Desktop.

The split is clean: no agent appears twice, which matters given the one-`team_id` rule above.

### 1. Executive Office Squad

**Short description**

> The executive record and the executive calendar. What the market sees, and what the owner does next.

**Members (4)**

| Agent |
| --- |
| Resume Architect |
| Executive Brand Manager |
| Executive Portfolio Manager |
| CISO Office Agent |

**Full description**

The outward-facing half of the career. The Resume Architect owns every version of the resume; the Brand Manager owns the narrative those versions have to agree with; the Portfolio Manager turns delivered work into artifacts that can be shown rather than described. The CISO Office Agent sits above all three as Chief of Staff, holding quarterly goals and deciding what actually matters this quarter - including what the owner is deliberately not doing.

### 2. Career Development Squad

**Short description**

> Turns what he did into what he can say, and what he can't do yet into a plan.

**Members (5)**

| Agent |
| --- |
| Achievement Collector |
| Leadership Story Builder |
| Executive Interview Coach |
| Learning and Certification Coach |
| Executive Presence Coach |

**Full description**

The engine room. The Achievement Collector is the upstream source for the entire office - nothing important gets forgotten, and no metric gets invented. The Story Builder turns one accomplishment into every format it will ever be needed in. The Interview Coach and Presence Coach close the gap between having done the work and being able to land it in a room, and neither is allowed to flatter. The Learning Coach keeps the next capability arriving before it's needed.

### 3. Market Intelligence Squad

**Short description**

> Facing outward. Every claim traces to a source you can open.

**Members (3)**

| Agent |
| --- |
| Career Intelligence Agent |
| Recruiter Relationship Manager |
| Security Research Analyst |

**Full description**

Everything the office knows about the world outside it. Career Intelligence watches openings, compensation, and which companies are moving. The Recruiter Relationship Manager makes sure no conversation goes quiet by accident and every interaction is on the record. The Security Research Analyst tracks AI, cloud, threat, and regulation at executive altitude - implications drawn out, not headlines relayed. This squad's discipline is sourcing: nothing here is opinion, and a figure without a citation gets dropped rather than guessed.

### 4. Executive Content Studio Squad

**Short description**

> Where the work becomes words - and where it's kept once it has.

**Members (3)**

| Agent |
| --- |
| Executive Writing Assistant |
| LinkedIn Strategist |
| Legacy Agent |

**Full description**

Publication and preservation. The Writing Assistant produces the documents - board papers, white papers, policy, position pieces - in the owner's voice, but never decides what should be written; the commissioning agent does. The LinkedIn Strategist owns the public surface, drafting rather than publishing: nothing goes out without the owner's approval of that specific item. The Legacy Agent works behind the wave, turning finished work into a knowledge base that outlives the context it was created in.

## Proposed team instructions

Four squads means four separate `[Team Instructions]` blocks, which is an advantage rather than a cost - each department wants a different discipline. These are proposals, not yet applied.

| Squad | The rule that belongs in its `instructions` |
| --- | --- |
| Executive Office | Consistency - nothing published contradicts the Brand Manager's narrative |
| Career Development | Never invent a metric or embellish beyond what the facts support |
| Market Intelligence | Cite it or drop it; never fabricate a figure, opening, or company fact |
| Content Studio | Draft, don't publish - The owner approves each item before it goes out |

The `instructions` field is also the cheapest place to put the `@mention` protocol: written once per squad, inherited by every member, four edits instead of fifteen.

> [!note] Why this matters more than it looks
> The ECO agents' system prompts already repeat shared boilerplate - the `10_AI_Instructions/` inheritance rule, the `01_Career/` privacy boundary, "no new top-level folders without asking." That belongs in a team's `instructions`, written once, rather than copy-pasted fifteen times where it can drift.

## Open items

1. **Create the four ECO squads in Buzz Desktop.** Descriptions above are paste-ready.
2. **Audit every squad for the two mistakes above** - a brief stranded in `description`, and any agent claimed by two squads.
3. **Decide whether the Welcome Team binding stays.** It spends the trio's only slot on an empty `instructions` field. Harmless today; blocking the moment you want Fizz in a real squad.
4. **Write the four instruction blocks** in the table above into the created teams.

## Related

- [Agent Roster](agent-roster.md) - every persona and identity, individually
- [Architecture and Agent Integration](architecture-and-agent-integration.md) - prompt composition and the harness model
- [Environment and Operations](environment-and-operations.md) - fleet operations and autostart
- [Decisions and Build Log](decisions-and-build-log.md) - why these choices were made
