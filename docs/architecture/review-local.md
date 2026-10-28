# Local review — smart-ceiling-fan (issue #9, pre-push gate port)

- Date: 2026-10-28
- Commit: see branch `chore/9-secret-gate` head
- Scope: branch diff origin/main...HEAD
- Checks run: security · correctness · tests · docs (one Opus reviewer; shell/config-only diff, design and container audits not applicable: `dependabot.yml` covers github-actions only)
- Verdict: ship after fixes  ·  Must 0 open (1 fixed) · Should 0 open (3 fixed) · Nice 3 (follow-up issue)

## Pre-merge gate
| Step | Result |
|---|---|
| 1 Tests | ✅ `scripts/test-secret-gate.sh` 28/28 ok (gitleaks 8.30.1) |
| 2 Coverage | n/a: no application code yet; the canary covers every rule and every hook branch |
| 3 SonarQube | ⚠️ not run: no SonarQube project for this repo yet |
| 4 Secrets | ✅ `gitleaks git` origin/main..HEAD and `gitleaks dir` clean · no tracked .env · diff read: nothing sensitive |
| 5 QA pass | ✅ smoke (tooling diff): the hook is the product, exercised end to end by the canary |
- Gate: GREEN except SonarQube (⚠️, owner waiver needed)

## 🔴 Must Have
- `scripts/install-hooks.sh` `[security]` · a worktree-level `core.hooksPath` (absolute, pointing at the main checkout's old hook) shadowed the relative one, so pushes from the worktree ran the fail-open hook · fixed: the script now unsets the worktree-level override.

## 🟡 Should Have
- `.gitleaks.toml` `[security]` · personal e-mail rule missed `.net`, `.co.uk` and French ISPs · fixed, two canary cases added.
- `.github/workflows/security.yml` `[security]` · action pin comment `# v2` → `# v2.3.9` · fixed.
- `scripts/hooks/pre-push` `[correctness]` · push to a URL scans the whole history · documented in the hook (still fail closed).

## 🔵 Nice to Have
- `.gitleaks.toml` · IPv6 ULA / link-local rule.
- `scripts/test-secret-gate.sh` · assert the installed `core.hooksPath` resolves to this checkout's hooks.
- `scripts/test-secret-gate.sh` · `unknown-remote-sha` / deletion cases reuse the previous repo's state.

## ⚪ Disagree / Intentional
_None._

## Per-dimension summary
- Security: fail-open fixed, override fixed · Correctness: sound, all variables quoted · Tests: canary asserts RuleID per case · Docs: README and CLAUDE.md accurate.
