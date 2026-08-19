---
title: "Security Squad"
created: 2026-08-16
description: "Buzz squad charter and ready-to-paste team instructions for the Security agent group."
tags: [buzz, agents, squad, security]
category: "AI / Buzz / Agents / Squads"
member_count: 18
status: "template"
---
# Security Squad (superseded)

> [!important]
> The combined squad has been replaced by [Lin Security Squad](lin-security-squad.md) and
> [Win Security Squad](win-security-squad.md). Keep this note only as a historical roster reference.
> New deployment and team-instruction changes belong in the platform-specific
> squad notes.

## Purpose

Defines, implements, operates, and verifies security controls. It may block unsafe work, but it does not silently take over infrastructure implementation or accept risk on the owner's behalf.

## Members (18)

- [Windows DevSecOps Engineer](../platform-agents/windows-devsecops-engineer.md)
- [Lin DevSecOps Engineer](../platform-agents/lin-devsecops-engineer.md)
- [Windows SecOps Engineer](../platform-agents/windows-secops-engineer.md)
- [Lin SecOps Engineer](../platform-agents/lin-secops-engineer.md)
- [Windows Security Architect](../platform-agents/windows-security-architect.md)
- [Lin Security Architect](../platform-agents/lin-security-architect.md)
- [Windows Security Engineer](../platform-agents/windows-security-engineer.md)
- [Lin Security Engineer](../platform-agents/lin-security-engineer.md)
- [Windows GRC Engineer](../platform-agents/windows-grc-engineer.md)
- [Lin GRC Engineer](../platform-agents/lin-grc-engineer.md)
- [Windows Identity and Access Engineer](../platform-agents/windows-identity-and-access-engineer.md)
- [Lin Identity and Access Engineer](../platform-agents/lin-identity-and-access-engineer.md)
- [Windows Vulnerability Management Engineer](../platform-agents/windows-vulnerability-management-engineer.md)
- [Lin Vulnerability Management Engineer](../platform-agents/lin-vulnerability-management-engineer.md)
- [Windows Detection and Response Engineer](../platform-agents/windows-detection-and-response-engineer.md)
- [Lin Detection and Response Engineer](../platform-agents/lin-detection-and-response-engineer.md)
- [Windows Secrets and PKI Engineer](../platform-agents/windows-secrets-and-pki-engineer.md)
- [Lin Secrets and PKI Engineer](../platform-agents/lin-secrets-and-pki-engineer.md)

## Ready-to-paste Buzz team description

Defines, implements, operates, and verifies security controls. It may block unsafe work, but it does not silently take over infrastructure implementation or accept risk on the owner's behalf.

## Ready-to-paste Buzz team instructions

Every member must obey the owner's Shared Operating Contract, Approval Gates and Change Safety, its shared role charter, and its platform persona specification in the Agent Documentation collection. Resolve the exact host, repository, and environment before acting. Current standing scope is local hosts, assigned Git repositories, and explicitly assigned Azure/AWS test environments; production and customer infrastructure are out of scope.

Preserve evidence, minimize privilege, separate control design from implementation and verification, time-bound exceptions, and require explicit approval for containment, identity, firewall, secret, compliance, or risk-acceptance actions.

Routine reversible work may proceed with pre-checks, validation, rollback, and documentation. Destructive, public, production, firewall/IAM, secret/key/certificate, spending, compliance, disruptive containment, backup-retention, or incident-closure actions require the owner's explicit approval. Use the Handoff Contract and exact Buzz display names when work crosses ownership. Never remain silent on a misrouted request: identify the correct owner and provide a bounded handoff.

## Buzz implementation note

Buzz identities carry one team binding. Do not place these personas in a second team to represent a project; use channels for project-specific membership and context. The instructions above belong in the team's instructions field, not only its description.

Created through the Buzz Desktop Agent teams interface on 2026-08-16. Post-create audit verified exactly 18 approved members and no built-in or Cloud agents.
