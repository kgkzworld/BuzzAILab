# Contributing

This is a personal field record shared with friends, family, and anyone else rebuilding something similar. Corrections and additions are welcome; so is forking it and going your own way.

## Before you open a pull request

**Never include a real identifier.** Not a public key, not an event ID, not a channel or team UUID, not a hostname, not a username, not an email, and obviously not a private key. Use the placeholders in [docs/personalize.md](docs/personalize.md).

Run the scanner before you push:

```bash
./scripts/check-secrets.sh
```

If it flags something in your own machine's output that you pasted into a validation record, sanitize it rather than adding an exception.

## What is most useful

- **Corrections.** Version-specific behavior drifts fast. If something here is wrong against current `block/buzz`, say so and cite the commit or file you checked.
- **New validation guidance.** Use the [sanitized template](agents/validation-record-template.md). Raw operator validation records are private runtime evidence and must not be submitted because they can disclose host posture, tool versions, and private repository layout.
- **Linux-tested `Lin` agents.** Every `Lin` persona was validated on macOS only. Real Linux validation is the biggest open gap in this repository.
- **Role charters for functions not covered.** Follow the existing structure: one responsibility, owned outputs, explicit non-ownership naming the role that *does* own it, checks, and handoffs.

## Style

- Match the surrounding document. Frontmatter stays; keep `title`, `description`, `tags`, `category`.
- Links are **relative Markdown**, not wikilinks — that is what makes the files render on GitHub and still resolve in Obsidian.
- Label evidence honestly: **Observed** (verified with a command or file), **Inferred** (a conclusion, say so), **Proposed** (not implemented), **Blocked** (needs a named decision). This convention comes from the [Shared Operating Contract](agents/01-shared-operating-contract.md) and applies to the docs too.
- Never claim something passed without showing what proved it.

## Prompt changes

Changing a prompt in [`agents/platform-agents/`](agents/platform-agents/) changes behavior on anyone's machine who deploys it. Say in the PR:

1. What behavior changes.
2. Whether it belongs in the [shared contract](agents/01-shared-operating-contract.md), a [role charter](agents/role-charters/), or the platform prompt — put it at the highest layer that is true, so it does not drift across copies.
3. Whether you re-ran the agent's acceptance tests, and what happened.

## Scope

Out of scope: anything that widens an agent's default authority, removes an approval gate, or makes a failure mode quieter. If you think a gate is wrong, open an issue and argue for it first.
