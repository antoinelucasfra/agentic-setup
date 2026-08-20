# Agent Safety & Governance

## Core Principles

- **Fail closed**: Deny on ambiguity.
- **Least privilege**: Minimum tool access for the task.
- **Append-only audit**: Never modify or delete audit entries.

## Essentials

- Explicit allowlist of tools per agent; block dangerous ops (shell, file DDL, deploy).
- Rate-limit tool calls per request.
- Never hardcode secrets or allow agents to self-modify governance.
- Log every tool call: timestamp, agent, tool, allow/deny.
