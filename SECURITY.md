# Security policy

## Reporting a vulnerability

Please report security and privacy issues **privately**, through GitHub's
[security advisories](https://github.com/IanHeinrich/CVForge/security/advisories/new)
— not as a public issue.

Include what you found, how to reproduce it, and what you think the impact is.

## What is in scope

CVForge has no backend, so the interesting surface is narrower than most web
apps, and concentrated in a few places:

- **The two outbound integrations.** Anything where data leaves the browser
  when it should not, or goes somewhere it should not: the AI tailoring
  requests (Anthropic, Google Gemini) and Google Drive sync.
- **Identity stripping.** AI tailoring is supposed to remove name, email,
  phone, location and profile links before a request is built. A way to get
  those into an outbound request is a real bug, and a serious one.
- **API key handling.** Keys are the user's own and are stored locally.
  Anything that leaks one, or sends it to the wrong host, is in scope.
- **Local data at rest.** Ways one origin could read another's Vault, or a
  path that silently destroys stored data.
- **Imported files.** The JSON backup importer and the ATS Check PDF
  extractor both parse untrusted input.

## What is out of scope

- The absence of at-rest encryption for browser storage. This is a known
  trade-off of being a local-first app with no account: anything with access
  to your browser profile can read your Vault. Take a backup and use a
  trusted device.
- Data loss from clearing site data or using a private window. Documented in
  the README.
- What Anthropic or Google do with a request you deliberately sent them under
  your own API key. That is between you and their terms.

## Supported versions

The deployed app at <https://ianheinrich.github.io/CVForge/> always tracks
`main`. Older tagged releases are not patched — fixes go out by deploying
`main`.
