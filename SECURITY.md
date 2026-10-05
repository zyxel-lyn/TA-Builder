# Security Policy

## Supported release

The latest stable GitHub Release is the supported public distribution.

Current stable line:

- TA Builder v1.1.0
- Windows x64

## Reporting a security issue

Do **not** publish credentials, private signing material, personal academic documents, access tokens, or exploit details in a public issue.

If you believe you found a security-sensitive problem:

1. Open a minimal issue titled `[Security] Private report requested`.
2. Describe only the affected component and impact category.
3. Do not include secrets, private documents, proof-of-concept payloads, or sensitive logs.
4. A private contact path can then be established.

## Release integrity

Public releases provide:

- a signed MSIX package;
- a public certificate;
- `SHA256SUMS.txt`;
- a release ZIP whose digest is displayed on the GitHub Release.

Private signing keys are not distributed.

## Scope

This repository is a public distribution/support surface. The production source repository and private build/signing environment are intentionally separate.
