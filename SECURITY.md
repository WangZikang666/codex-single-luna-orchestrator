# Security Policy

## Supported versions

| Version | Supported |
| --- | --- |
| 1.0.x | Yes |
| < 1.0 | No public support |

## Reporting a vulnerability

For security-sensitive issues, do **not** post secrets, credentials, private repository data,
or exploit details in a public issue.

Preferred reporting path:

1. use GitHub's **Private vulnerability reporting** feature for this repository when enabled;
2. include the affected version, reproduction steps, impact, and suggested mitigation;
3. redact credentials, tokens, private paths, and private code.

For non-sensitive security hardening or installer safety improvements, a normal GitHub issue
is appropriate.

## Scope

Security concerns may include:

- installer behavior that overwrites unrelated user configuration;
- accidental modification of `hooks.json`;
- unsafe command construction;
- path traversal or arbitrary file deletion;
- leaking private paths, tokens, emails, or repository content;
- workflow permissions that are broader than necessary.

The Single-Luna policy itself is not a security sandbox. Users remain responsible for Codex
permissions, repository trust, shell access, and commands executed in their environment.
