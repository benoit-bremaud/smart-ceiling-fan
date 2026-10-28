# Local review — smart-ceiling-fan (branch chore/11-gate-followups)

One-pass local gate for issue #11 (pre-push gate follow-ups).

- Date: 2026-10-28
- Commit: 74c09a0
- Scope: branch diff main...HEAD (.gitleaks.toml, scripts/test-secret-gate.sh, .github/workflows/security.yml)
- Checks run: design · docs · tests · security · correctness (one Opus reviewer, proportional to a 3-file tooling diff)
- Verdict: ship as-is · Must 0 · Should 0 open (3 fixed in 74c09a0) · Nice 2

## Pre-merge gate (head SHA 74c09a0)
| Step | Result |
|---|---|
| 1 Tests | ✅ canary 53/53 (`scripts/test-secret-gate.sh`), shellcheck and actionlint clean |
| 2 Coverage | n/a — no runtime code; every rule has blocking and near-miss canary cases |
| 3 SonarQube | ⚠️ not run — no Sonar project yet, waived by the owner, tracked in #12 |
| 4 Secrets | ✅ gitleaks git `--all` and `dir` clean · no tracked .env · diff read: only fragmented fake values |
| 5 QA pass | ✅ smoke (tooling diff): canary run green; hooks-path check proven to fail with a wrong `core.hooksPath` and to recover after `install-hooks.sh` |
- Gate: **GREEN for push** (SonarQube waived, #12)

## 🔴 Must Have
_None._

## 🟡 Should Have
- `.gitleaks.toml:24` `[security]` · `feb1:12:30` (a time after a month) matched `private-ipv6` · fixed: require `::` or four more groups, canary `ipv6-time-near-miss`
- `scripts/test-secret-gate.sh:7` `[correctness]` · `pwd` vs `realpath` gave a false hooks-path FAIL through a symlinked path · fixed: `pwd -P`
- `scripts/test-secret-gate.sh` `[tests]` · edges not pinned · fixed: `ipv6-full`, `\b` guard, `wifi-anchor-block`, `wifi-anchor-next-line`

## 🔵 Nice to Have
- `.gitleaks.toml:25` `[design]` · keyword `fd` is a broad prefilter · kept: keywords only prefilter, the regex decides
- `.gitleaks.toml` `[docs]` · `&\S+` also accepts odd anchor names · harmless, kept

## ⚪ Disagree / Intentional
- `.gitleaks.toml` `[security]` · regex kept over a YAML-aware check · owner MCDA decision 2026-10-28 (A 400 / B 335 / C 285); `? key` and next-line values documented as not covered

## Per-dimension summary
- Design: proportional, one tool. · Docs: comments match behaviour. · Tests: 53 isolated cases. · Security: no false negative found. · Correctness: symlink edge fixed.
