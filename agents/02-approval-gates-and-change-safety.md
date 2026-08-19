---
title: "Approval Gates and Change Safety"
description: "Approval requirements and change classes for the Infrastructure, Security, and Cloud agent fleet."
tags: [buzz, agents, approvals, change-management]
category: "AI / Buzz / Agents / Policy"
---
# Approval Gates and Change Safety

## Enforcement boundary

These gates are mandatory behavioral instructions for the agents, but prompts alone are not a technical security boundary. A capable or compromised runtime could still attempt a prohibited command. Enforce consequential boundaries with least-privilege OS accounts, sandbox/workspace restrictions, tool allowlists or hooks, network controls, provider spending limits, protected branches, secret-store policy, and human-controlled credentials. Acceptance tests show that a model followed the policy in tested scenarios; they do not prove universal enforcement.

Never grant a harness broader filesystem, shell, network, cloud, or credential access merely because this document tells the model not to misuse it. Technical controls should prevent or contain the effect whenever practical, while this policy governs the remaining judgment calls.

## Mandatory approval gates

The owner's explicit approval is required before:

- destructive deletion, reset, reformat, irreversible migration, or overwriting the only known copy;
- production or public deployment, public DNS changes, or opening an inbound network path;
- firewall, routing, VPN, IAM, SSO, MFA, Intune, Jamf, or privileged-role changes;
- creating, exporting, rotating, revoking, or relocating secrets, private keys, certificates, recovery codes, or trust anchors;
- spending, paid-resource creation, quota increases, reservations, subscriptions, or actions with material cost impact;
- compliance assertions, risk acceptance, control exceptions, or evidence submitted to an auditor;
- incident containment that disconnects systems, disables accounts, blocks traffic, or destroys evidence;
- declaring an incident closed or a disaster-recovery test successful;
- operating on production or customer infrastructure, which is outside the current standing scope;
- installing persistent privileged software, kernel/system extensions, endpoint controls, or device-management profiles;
- changing backup retention, deleting recovery points, or treating an untested backup as authoritative.

## Change classes

| Class | Examples | Authority |
| --- | --- | --- |
| Observe | Inventory, diagnostics, status, documentation reads | Autonomous |
| Prepare | Plans, patches, IaC, scripts, dry runs, proposed policies | Autonomous; do not apply gated effects |
| Routine reversible | Approved-scope test, lint, local config with immediate rollback, restart of disposable dev service | Autonomous with pre-check and verification |
| Sensitive | Access, network, secrets, persistent system configuration, external test cloud changes | Explicit approval |
| Destructive/public/production | Deletion, irreversible migration, public exposure, production mutation | Explicit approval plus rollback/backup evidence |

## Change record

Before a sensitive change, record target, current state, intended state, owner, dependencies, blast radius, validation, rollback, and approval. Afterward record actual result, timestamps, evidence, deviations, and follow-up.

## Stop rules

Stop immediately when the target is ambiguous, backup validity is unknown, the observed state contradicts the plan, secrets appear in output, production scope is discovered, rollback is unavailable, or another actor is changing the same state.
