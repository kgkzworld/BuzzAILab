# Security

This repository is documentation. It contains no credentials, no private keys, and no live infrastructure. But it describes a system that handles all three, and the whole point of running agents is that they act on your machine. Read this before you deploy anything here.

## What was removed before publishing

This repository was ported from a private Obsidian vault. The following were stripped:

| Removed | Replaced with |
| --- | --- |
| Nostr private keys (`nsec1…`) and the note holding them | Nothing — that file is excluded entirely |
| Agent identity metadata | Omitted from setup documentation |
| Team, channel, and persona UUIDs | `<team-id>`, `<channel-uuid>`, `<persona-id>` |
| Owner name, username, email addresses | `the owner`, `<you>`, `you@example.com` |
| Hostnames and machine names | `mac-host`, `win-workstation` |
| Network and posture details | `<tailnet>`, `<gateway-ip>`, `<host-ip>`, `<subnet>`, `<iface>`, `<port>` |
| Host and software fingerprints | `<os-version>`, `<os-build>`, `<kernel-build>`, `<hw-model>`, `<cpu-model>`, `<memory-size>`, `<tool-version>` |
| Community and relay names | Omitted; each builder configures their own community |
| Vault, cloud-drive, and project paths | `<vault>`, `<cloud-drive>` |
| Personal project and family identifiers | Removed |
| Raw agent validation records | Kept as private operator evidence outside the public corpus; publish only sanitized summaries |

Upstream `block/buzz` commit hashes are deliberately **kept** — they are public and they are what makes the source-verified claims in these docs checkable.

If you find something that should have been removed, see [Reporting](#reporting) below.

## The mistake worth learning from

During this build, a live Nostr owner private key was written in plaintext into a note inside a **cloud-synced** vault, deliberately, as a recovery convenience. The note was labelled "do not share." That label is not a control.

The key was in a folder that syncs to a third-party cloud provider, is readable by anything with access to that account, is included in every device that mounts the drive, and would have been captured by any backup, screenshot, or export of that vault. **Anyone holding that value can act as that identity** — post as it, be trusted as its owner's sibling agents, and inherit whatever those agents can reach.

A note marked private inside a synced vault is not a secret store. If you take one thing from this repository, take this one.

### Where key material actually belongs

- Buzz stores agent private keys in its own registry (`managed-agents.json`) and injects them into the harness as `BUZZ_PRIVATE_KEY`. They never appear in prompts. Leave them there.
- The **owner** identity gets a password-protected NIP-49 `.ncryptsec` backup, created by Buzz, stored **outside** the vault, with its passphrase in a password manager or Keychain.
- Test the backup by restoring it against the live public identity. An untested backup is not a backup.
- Registry snapshots (`managed-agents.backup-*.json`) contain credentials. They are operational artifacts, not documentation. Never copy one into a vault, a ticket, a repository, or a support bundle.

## Rules this repository's agents are built around

Every persona in [`agents/`](agents/) inherits these. If you adapt the prompts, keep them.

- **Never place secrets in agent output, logs, Git, tickets, or shareable notes.** ([Shared Operating Contract](agents/01-shared-operating-contract.md))
- **Approval is mandatory** before destructive deletion, production or public deployment, firewall/IAM/SSO/MFA changes, any secret or certificate operation, spending, compliance assertions, incident containment, or installing privileged software. Silence is not approval, and prior approval for a similar change is not approval for this one. ([Approval Gates](agents/02-approval-gates-and-change-safety.md))
- **Never claim a backup, restore, deployment, or control passed without checking the result.**
- **Stop immediately** when the target is ambiguous, rollback is unavailable, secrets appear in output, or production scope is discovered.

These approval rules are prompt-enforced behavior, not a substitute for sandboxing, least privilege, tool restrictions, protected branches, network controls, provider limits, and human-held credentials.

## Access control: read this before you trust `owner-only`

`owner-only` does **not** mean "only the human."

The gate is `is_owner_or_sibling`. An unknown author's profile is fetched and its auth tag checked against the agent's own owner; a match makes them a **sibling**. Every agent in your workspace shares one owner — so under the default setting, **your agents can already mention each other and fire each other's turns.** Agent-to-agent coordination needs no configuration change, and mention chains have genuine runaway potential. Nothing in the harness caps agent-to-agent depth.

Two mitigations matter:

- The production Desktop is compiled to clamp every managed-agent runtime to `owner-only`. Editing the registry directly cannot widen live access — but do not rely on a build flag you have not verified.
- Inside a DM, only the owner and verified same-owner siblings may fire a turn; `allowlist` and `anyone` do not apply there. Clients auto-tag every DM participant, so without this, any participant's message would read as a mention.

## Cost and blast radius are security properties

A squad running unattended exhausted a paid plan in an afternoon by retrying quota errors ten times per event. Before you run any fleet unattended:

- Make account, authentication, session-limit, credit, and quota errors **terminal**. They are not transient.
- Cap turn duration and turns per session. Bound inherited channel context.
- Start every agent at `parallelism: 1` and autostart **disabled**.
- Deploy in waves. Never launch 51 untested agents.

Full incident record in [Environment and Operations](docs/environment-and-operations.md).

## Before you commit to your own copy

Run the included scanner:

```bash
./scripts/check-secrets.sh
```

It greps for private keys, 64-hex identifiers, UUIDs, emails, and absolute home paths. It is a safety net, not a guarantee — it cannot know your names. Add your own to the pattern list, and read your diff.

The scanner also blocks raw validation-record directories, observed disabled or
missing security-control statements, and private repository layouts. Exact
toolchain versions are warnings because version strings can be legitimate in
portable installation documentation and require human review.

The repository also installs this scan as a local `pre-commit` hook through
`.pre-commit-config.yaml` and runs it in CI with full Git history available.
After cloning, run `pre-commit install --install-hooks` once; CI remains the
independent enforcement layer if a contributor has not installed the hook.

Local `.scratch/` content is private operator evidence, not publication
content. Git ignores it, but that protection applies only to Git operations.
Never upload, share, or archive the repository directory wholesale while
`.scratch/` exists; publish from a clean Git checkout instead.

## Reporting

If you find a credential, key, personal identifier, or anything else in this repository that should not be here, open an issue **without quoting the value**, or contact the repository owner privately. Say which file and line, not what it contains.
