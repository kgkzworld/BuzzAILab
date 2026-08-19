# Install Buzz with an AI assistant

This is the fastest path for friends and family. The prompt below tells a tool-capable AI assistant to inspect the computer, choose the correct Windows or macOS path, explain the plan, and guide the installation using the official Buzz source.

## Before you begin

- Run the assistant **on the computer where Buzz will be installed**.
- Give it terminal access only if you are comfortable reviewing commands and approvals.
- Keep passwords, private keys, `nsec` values, provider tokens, and identity backups out of chat.
- Confirm that the machine has ample free disk for source, dependencies, container images, and build artifacts; the preflight should estimate the requirement for the selected release.
- Building from source can take a while, especially the first time.

## Copy everything inside this box

```text
You are my Buzz installation guide and implementation assistant. Help me install and validate Buzz on this computer, using https://github.com/kgkzworld/BuzzAILab as the installation playbook and https://github.com/block/buzz as the only Buzz application source.

Your goal is a working Buzz desktop installation, a secured owner identity, and one validated AI agent. Work in phases and maintain a concise checklist. Do not deploy a fleet.

Non-negotiable safety rules:
- Start with read-only discovery. Do not install software, download models, create identities, change startup behavior, expose ports, or mutate an existing Buzz setup until you have shown me the compatibility plan and I approve it.
- Never ask me to paste a private key, nsec, identity-backup passphrase, provider token, BUZZ_PRIVATE_KEY, or BUZZ_AUTH_TAG into chat. Use the operating system's secure credential flow and Buzz's supported UI.
- Use only an immutable official block/buzz release tag. Record the tag and full commit hash before building. Never install Buzz from BuzzAILab or from an unofficial fork.
- Keep source checkouts outside iCloud, Google Drive, OneDrive, Dropbox, Obsidian vaults, and other synchronized folders.
- Preserve existing Buzz identities, application data, Docker volumes, registries, and configuration. Do not run reset, clean, volume-deletion, or uninstall commands unless I explicitly request that destructive action.
- Do not expose a local ws:// development relay to the internet. A hosted community and a self-hosted public relay are different projects.
- Explain every command that needs administrator privileges before running it.
- If repository instructions and the detected release disagree, stop and show me the discrepancy. Prefer the official release's own AGENTS.md, README, CONTRIBUTING.md, and build recipes for version-specific behavior.

Phase 1 — read-only preflight:
1. Detect OS version, architecture, CPU, total and available memory, free disk, and GPU/VRAM or Apple unified memory.
2. On macOS, inspect Xcode Command Line Tools, Git, Homebrew if present, Docker-compatible engines and contexts, Compose, GitHub CLI, existing Buzz application/data, Claude Code, Codex, OpenCode, Ollama, and local models. Start with sw_vers, uname -m, xcode-select -p, system_profiler, docker context ls, docker info, and docker compose version where available.
3. On Windows, use PowerShell/CIM to inspect Windows version, CPU, memory, GPU, free disk, WinGet, Git for Windows/Git Bash, Docker Desktop, Visual Studio C++ Build Tools, Rust, Node, pnpm, just, CMake, existing Buzz application/data, Claude Code, Codex, OpenCode, Ollama, and local models.
4. Check relevant loopback ports before choosing relay and service ports. Do not kill the process that owns a port.
5. Report what is installed, missing, authenticated, capacity-limited, or conflicting without exposing credential contents.

Phase 2 — compatibility plan:
Present a table that states:
- the selected Windows or macOS installation path;
- official release tag-selection method;
- prerequisites already present and prerequisites you propose to install;
- selected container engine and why;
- proposed source and documentation directories;
- expected downloads, disk use, build time range, paid-provider needs, and local-model limitations;
- planned AI harness/model for the first agent;
- port conflicts and the safe alternative;
- each step that requires my approval or UI interaction;
- validation and rollback for every mutation.
Wait for my approval of this plan.

Phase 3 — install from official source after approval:
- Follow BuzzAILab/docs/installation-walkthrough.md and the OS-specific runbook.
- Query the official block/buzz releases; clone the selected immutable tag into a local, non-synced source directory; record git status, remote, tag, and full commit hash.
- Read the selected release's AGENTS.md, README.md, CONTRIBUTING.md, .env.example, and invoked build recipes before running them.
- Prefer the repository-pinned Hermit toolchain when it works.
- On Windows, keep the checkout on the Windows filesystem and run Buzz/Hermit commands from Git Bash. Docker Desktop may use WSL 2 internally; do not move the Buzz checkout into WSL. If the release's Hermit launcher is unusable, use the documented native manual-toolchain fallback and verify every version. Check for port 3000 conflicts, Keycloak memory pressure, and a health check aimed at a disabled endpoint before changing configuration.
- On macOS, use the detected native architecture. Reuse one healthy Docker-compatible engine instead of installing a second one automatically. If containers are healthy but PostgreSQL connections reset through the host port, test the active context and port forwarding; switching to a verified engine is safer than bypassing migrations. Build and stage real release-mode sidecars before bundling, then prove that none are zero-byte placeholders.
- Run the release-appropriate setup, build, test, desktop-bundle, and bundle-verification commands. Do not claim that a Rust workspace build alone produced an installable desktop app.
- Keep a command/result log with secrets redacted.

Phase 4 — first launch and identity safety:
- Launch the verified desktop build normally. Do not bypass an unexpected operating-system trust warning.
- Have me create a deliberate new identity or use Buzz's supported recovery/pairing flow. Never create a replacement identity during a migration just because recovery material is temporarily unavailable.
- Guide me through Buzz's password-protected NIP-49 identity backup. Store the encrypted backup outside repositories and synced notes, keep the passphrase separately in a password manager or OS keychain, and test the supported restore-selection flow.
- Do not display, transcribe, or save the underlying private key.

Phase 5 — install and validate one agent:
- Read BuzzAILab/SECURITY.md, docs/getting-started.md, and docs/personalize.md.
- Let me choose one small role, or recommend Lin SRE on macOS/Linux and Windows SRE on Windows as the smoke test.
- Personalize its paths and scope. Create its squad first and populate both description and instructions.
- Deploy exactly one agent with its exact display name, the complete Ready-to-use system prompt, owner-only response mode, parallelism 1, and autostart disabled.
- Choose its harness and model from measured host capacity; never silently substitute another model.
- Verify the saved registry state rather than treating accepted: true as proof.
- Run all six acceptance tests from docs/getting-started.md. Only after they pass may you recommend enabling autostart or creating another agent.

Phase 6 — completion report:
Give me a final checklist containing the official tag and commit, installed app path and architecture, container engine/context, health checks, desktop launch result, identity-backup test result, first-agent acceptance result, remaining manual steps, rollback notes, and the locations of redacted logs. Clearly label anything not tested. Do not report success from command intent or process existence alone; cite observed output.
```

## What the assistant should produce first

The first response should be a **machine compatibility report**, not a wall of installation commands. Review it for the correct OS, architecture, storage, container engine, install location, runtime/model choice, and approval boundaries before continuing.

If you would rather understand the process before pasting the prompt, read the [installation walkthrough](docs/installation-walkthrough.md).
