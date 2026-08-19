# BuzzAILab

Build your own [Buzz](https://github.com/block/buzz) workspace on Windows or macOS with an AI assistant guiding the installation. This repository turns one real, hard-won setup into a repeatable walkthrough: install Buzz from the official source, verify the machine and runtime, secure the owner identity, and add the first validated AI agent.

This repository is the **installer guide and reusable agent library**. It does not redistribute Buzz or replace the official [`block/buzz`](https://github.com/block/buzz) source.

## Install Buzz with an AI assistant

1. Open **[INSTALL_WITH_AI.md](INSTALL_WITH_AI.md)**.
2. Copy the installer prompt into Codex, Claude Code, ChatGPT, or another tool-capable AI assistant running on the computer you want to set up.
3. Let it perform the read-only preflight and show you the compatibility plan.
4. Approve the plan, then follow the assistant through build, launch, identity backup, and the first agent validation.

Prefer to work manually? Use the **[installation walkthrough](docs/installation-walkthrough.md)** and choose the [Windows](docs/runbooks/windows-setup.md) or [macOS](docs/runbooks/macos-source-build.md) path.

## What Buzz is

Buzz is a self-hostable workspace where humans and AI agents share the same rooms, identity model, workflows, repositories, and signed Nostr event log. Each agent gets its own keypair and its own channel memberships, so what an agent did is attributable the same way a person's actions are.

Buzz manages the agents. It does not supply the models — the fleet here mixes Claude, Codex, and local models served through Ollama.

## What is in this repository

| | |
| --- | --- |
| **[`agents/`](agents/)** | The library. 51 platform personas, 26 role charters, 5 squad templates, the shared operating contract, approval gates, handoff contract, and the runtime assignment matrix. |
| **[`agents/validation-record-template.md`](agents/validation-record-template.md)** | Sanitized template for recording portable acceptance evidence without publishing host reconnaissance. |
| **[`docs/`](docs/)** | Architecture, roster, squad mechanics, the decisions log, and runbooks for macOS, Windows, deployment, and migration. |

## The three-layer agent

Every persona composes from three files, in order. This is the part worth stealing even if you never touch Buzz:

1. **[Shared Operating Contract](agents/01-shared-operating-contract.md)** — authority, safety, evidence standards, and handoff rules inherited by every agent.
2. **A [role charter](agents/role-charters/)** — one responsibility, owned outputs, explicit boundaries, and who owns the work it must refuse.
3. **A [platform agent](agents/platform-agents/)** — the deployable prompt with OS-specific behavior.

Squad `instructions` add coordination rules on top, but never replace the three layers. The payoff: shared rules are written once instead of copy-pasted 51 times, where they drift.

`Lin` means **Linux and macOS**. Every Lin agent detects the actual OS before acting rather than assuming Linux commands work on a Mac.

## Start here

1. **[INSTALL_WITH_AI.md](INSTALL_WITH_AI.md)** — the copy/paste AI-guided installer.
2. **[docs/installation-walkthrough.md](docs/installation-walkthrough.md)** — the complete human-readable Windows/macOS flow.
3. **[SECURITY.md](SECURITY.md)** — including the private-key mistake this build actually made.
4. **[docs/getting-started.md](docs/getting-started.md)** — from a working Buzz app to one validated agent.
5. **[docs/personalize.md](docs/personalize.md)** — every placeholder and what to replace it with.
6. **[ARCHITECTURE.md](ARCHITECTURE.md)** — how the substrate, the identity model, and the agent library fit together.
7. **[docs/overview.md](docs/overview.md)** — a map of every document here.

Unfamiliar with the vocabulary? [docs/glossary.md](docs/glossary.md) defines persona vs identity, `team_id`, sibling, ACP, and the rest.

The rule the whole repository is built around: deploy **one** agent, with autostart disabled and `parallelism: 1`, and run its acceptance tests before you deploy the next.

## Lessons that cost the most to learn

Each of these was a real failure in this build. They are documented in full where they happened, and they are the reason this repository exists.

- **A note marked "private" in a synced vault is not a secret store.** A live Nostr owner key sat in cloud storage for weeks. → [SECURITY.md](SECURITY.md)
- **Retrying a quota error is a bill multiplier.** Agents retried the same event ten times each after the provider had already said "session limit," exhausting a plan in an afternoon while output went backwards. → [Environment and Operations](docs/environment-and-operations.md)
- **A squad with an empty `instructions` field is a label, not a prompt layer.** A full project brief was pasted into `description`, which is display-only. No agent ever read a word of it. → [Squads and Teams](docs/squads-and-teams.md)
- **An identity gets exactly one `team_id`.** Membership is not additive; joining a second squad silently leaves the first. → [Squads and Teams](docs/squads-and-teams.md)
- **`accepted: true` does not mean saved.** It means the relay took the event. Verify against the registry, never against a CLI response. → [Architecture](docs/architecture-and-agent-integration.md)
- **`owner-only` does not mean "only the human."** It admits verified same-owner siblings, so your agents can already fire each other's turns by default. → [SECURITY.md](SECURITY.md)
- **A handoff written in prose fires nothing.** A turn starts only on a resolved `@mention` carrying a `p` tag; naming an agent in a message body is just text. The pipeline reads as if it is running while nothing happens. → [Agent Roster](docs/agent-roster.md)
- **Ten Codex ACP workers take eight minutes to cold-start,** and anything dispatched in that window vanishes without a trace in the turn log. → [Environment and Operations](docs/environment-and-operations.md)

## Using this with Obsidian

The files keep their YAML frontmatter and folder structure, and the links are relative — so they render correctly on GitHub *and* resolve if you copy the folders into an Obsidian vault. Wikilinks were converted to relative Markdown links, which Obsidian follows natively.

## Status and scope

This is a practical installation guide and reusable agent library, not a redistribution of Buzz itself. Version-specific details — Buzz Desktop 0.5.x behavior, ACP quirks, adapter patches — can drift, so verify changing implementation details against [block/buzz](https://github.com/block/buzz).

Personal agents are described only where they illustrate reusable architecture or operating lessons.

## License

[MIT](LICENSE). The prompts and charters are yours to adapt. Attribution is welcome, not required.
