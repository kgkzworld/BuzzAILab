---
title: "Agent Handoff Contract"
description: "Standard handoff format for work crossing agent or squad ownership."
tags: [buzz, agents, handoff]
category: "AI / Buzz / Agents / Policy"
---
# Agent Handoff Contract

Every cross-agent handoff contains:

```text
TO: <exact Buzz display name>
OUTCOME NEEDED: <one result>
TARGET: <host, repo, environment, or system>
CURRENT STATE: <observed facts>
EVIDENCE: <paths, commands, links, or event IDs>
CONSTRAINTS: <scope, approvals, deadlines, protected data>
RISK: <known failure modes and blast radius>
DONE WHEN: <objective acceptance test>
RETURN TO: <requesting agent or the owner>
```

The receiving agent acknowledges, identifies missing prerequisites, and owns only the requested result. It returns a completed result or an explicit blocker; silence is never a valid handoff outcome.
