---
name: pr-format
description: Use when the user asks to create a PR, format a PR, or write a commit message for the wondiers-store project.
---

# PR Format — wondiers-store

## Branch naming

```
<type>/<short-description>
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `style`, `test`.

Examples: `feat/add-discount-calculator`, `docs/headless-storefront`, `fix/cart-total-bug`

## Commit message

```
<type>: <present-tense description>
```

Examples: `docs: update AGENTS.md with headless storefront architecture`, `fix: correct cart total calculation`

## PR title

Same as commit message — concise, descriptive.

## PR body

Include:

1. **What** — what changed (1-2 sentences)
2. **Why** — motivation (e.g. "Spree 5 is headless-only, so the storefront must live in a separate repo")
3. **How to verify** — commands to run, URLs to visit, or curl examples

## PR target

| Source → Target | When |
|---|---|
| `feature/*` → `staging` | New feature or fix, needs testing |
| `staging` → `release` | Approved & tested, batched for daily release |
| `release` → `main` | End-of-day production deploy |

## GPG signing

All commits **must** be GPG-signed. If `git commit` fails with a GPG passphrase prompt (e.g. `gpg: cannot open '/dev/tty'`), ask the user for their GPG passphrase and retry with:

```sh
gpg --pinentry-mode loopback --passphrase "<passphrase>" --sign
```

Or use a wrapper script when `/dev/tty` is not available:

```sh
echo '#!/bin/sh
gpg --pinentry-mode loopback --passphrase "<passphrase>" --batch --yes "$@"' > /tmp/gpg-wrapper.sh
chmod +x /tmp/gpg-wrapper.sh
git -c gpg.program=/tmp/gpg-wrapper.sh commit --gpg-sign -m "message"
```

If GPG signing is not possible in the current environment, fall back to `--no-gpg-sign` and warn the user.

## PR checklist

- [ ] All commits are GPG-signed
- [ ] `bin/rubocop` passes (no new offenses)
- [ ] `bin/rails test` passes (if tests relevant)
- [ ] Only intended files are committed (no build artifacts, secrets, etc.)
- [ ] Branch is pushed with correct target (`staging` for features, `release` for batched)
