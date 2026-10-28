#!/usr/bin/env bash
# Canary test of the pre-push gate: in a throw-away repository, a clean commit must pass
# and every kind of sensitive data must be refused by the rule meant to catch it. Fake
# values are built from fragments so this file never contains a literal the scanner flags.
set -uo pipefail

here=$(cd "$(dirname "$0")/.." && pwd -P)
hook="$here/scripts/hooks/pre-push"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0
zero=0000000000000000000000000000000000000000
# Ignore the developer's git config (commit signing, a global core.hooksPath...).
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

# Developer setup, not the gate itself: this checkout must run its own hooks (a worktree-level core.hooksPath once shadowed them).
hooks_dir=$(cd "$here" && realpath -m "$(git rev-parse --git-path hooks)")
if [ "$hooks_dir" = "$here/scripts/hooks" ]; then
  echo "ok   hooks-path (scripts/hooks)"
else
  echo "FAIL hooks-path: git runs $hooks_dir, run scripts/install-hooks.sh"; fail=1
fi

rand() { LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$1" || true; }

new_repo() { # dir: fresh repo with one base commit holding the config; sets $base
  mkdir -p "$1" && cd "$1" || exit 2
  git init -q -b main && git config user.email t@example.com && git config user.name t || exit 2
  cp "$here/.gitleaks.toml" . && git add .gitleaks.toml && git commit -q -m base || exit 2
  base=$(git rev-parse HEAD)
}

commit_file() { # file content: commit it; sets $head
  mkdir -p "$(dirname "$1")" && printf '%s\n' "$2" >"$1"
  git add "$1" && git commit -q -m "add $1" || exit 2
  head=$(git rev-parse HEAD)
}

expect() { # name expected(pass|RuleID) remote_sha: push $head through the hook
  local name=$1 expected=$2 out got=pass
  out=$(echo "refs/heads/x $head refs/heads/x $3" | "$hook" 2>&1 >/dev/null) || got=block
  if [ "$expected" = pass ] && [ "$got" = pass ]; then
    echo "ok   $name (pass)"
  elif [ "$expected" != pass ] && [ "$got" = block ] && grep -q "RuleID: *$expected" <<<"$out"; then
    echo "ok   $name (blocked by $expected)"
  else
    echo "FAIL $name: expected $expected, got $got"; printf '%s\n' "$out" | sed 's/^/     /'; fail=1
  fi
}

check() { # name expected(pass|RuleID) file content
  new_repo "$tmp/$1" && commit_file "$3" "$4"
  expect "$1" "$2" "$base"
}

check clean-doc pass docs/a.md "Use <MODULE_IP> and <SSH_HOST> from esphome/secrets.yaml."
check near-miss-ip pass a.md "version 1.192.168"".1 and 192.169.""1.1"
check work-email pass a.md "maintainer: someone@example.org"
check github-token github-pat a.txt "token = ghp_$(rand 36)"
check private-ip-192 private-ipv4 a.md "module at 192.168"".1.50"
check private-ip-10 private-ipv4 a.md "gateway 10.""0.0.1"
check private-ip-172 private-ipv4 a.md "host 172.""16.4.9"
check cgnat-ip private-ipv4 a.md "tailnet 100.""101.2.3"
check ipv6-ula private-ipv6 a.md "node fd12"":3456:789a::1"
check ipv6-link-local private-ipv6 a.md "iface fe80""::1ff:fe23:4567"
check ipv6-link-local-upper private-ipv6 a.md "iface FE80""::1"
check ipv6-near-miss pass a.md "doc 2001:db8::1, site fec0::1, word fd12 and ff02::1"
check ipv6-time-near-miss pass a.md "at feb1:12:30:45 and deadfd12:ab:cd"
check ipv6-full private-ipv6 a.md "iface fe80"":1:2:3:4:5:6:7"
check homelab-host homelab-host a.md "ssh me@bb-""homelab"
check tailnet-name homelab-host a.md "host pi.tail1234.ts"".net"
check home-path home-directory-path a.md "/home/""someone/project/file"
check home-path-upper home-directory-path a.md "/home/""Bob/project/file"
check macos-path home-directory-path a.md "/Users/""bob/project/file"
check github-users-url pass a.md "https://github.com/users/""someone/projects/1"
check personal-email personal-email a.md "contact: someone@gm""ail.com"
check personal-email-upper personal-email a.md "contact: someone@GM""AIL.com"
check personal-email-fr personal-email a.md "contact: someone@ora""nge.fr"
check personal-email-net personal-email a.md "contact: someone@laposte"".net"
check mac-address mac-address a.txt "sta aa:bb:cc:""11:22:33"
check wifi-literal wifi-literal-credential esphome/a.yaml $'wifi:\n  ssid: "MyHome"'
check wifi-password wifi-literal-credential esphome/a.yaml $'wifi:\n  password: "hunter22"'
check wifi-quoted-hash wifi-literal-credential esphome/a.yaml $'wifi:\n  ssid: "#MyHome"'
check wifi-quoted-bang wifi-literal-credential esphome/a.yaml $'wifi:\n  password: \'!hunter22\''
check wifi-list-item wifi-literal-credential esphome/a.yaml $'wifi:\n  networks:\n    - ssid: "MyHome"'
check wifi-flow-map wifi-literal-credential esphome/a.yaml 'wifi: {ssid: "MyHome"}'
check wifi-flow-list wifi-literal-credential esphome/a.yaml $'networks:\n  - {password: hunter22, ssid: !secret s}'
check wifi-flow-secret pass esphome/a.yaml 'wifi: {ssid: !secret wifi_ssid, password: !secret wifi_password}'
check wifi-quoted-key wifi-literal-credential esphome/a.yaml $'wifi:\n  "ssid": "MyHome"'
check wifi-flow-quoted-key wifi-literal-credential esphome/a.yaml "wifi: {'password': hunter22}"
check yaml-nested-key pass esphome/a.yaml $'key:\n  nested: value'
check yaml-nested-flow pass esphome/a.yaml 'key: {nested: value}'
check wifi-block-scalar wifi-literal-credential esphome/a.yaml $'wifi:\n  ssid: |-\n    MyHome'
check wifi-anchor wifi-literal-credential esphome/a.yaml $'wifi:\n  ssid: &wifi MyHome'
check wifi-anchor-quoted wifi-literal-credential esphome/a.yaml $'wifi:\n  password: &pw "hunter22"'
check wifi-anchor-block wifi-literal-credential esphome/a.yaml $'wifi:\n  ssid: &a |\n    MyHome'
check wifi-anchor-next-line pass esphome/a.yaml $'wifi:\n  ssid: &a\n    MyHome'
check wifi-alias pass esphome/a.yaml $'wifi:\n  ssid: *wifi'
check wifi-anchor-secret pass esphome/a.yaml $'wifi:\n  ssid: &w !secret wifi_ssid'
check wifi-comment pass esphome/a.yaml $'wifi:\n  ssid: # set below'
check wifi-secret pass esphome/a.yaml $'wifi:\n  ssid: !secret wifi_ssid'
check wifi-example pass esphome/secrets.yaml.example $'wifi_ssid: "MyHome"'

# A leak in an older commit of the range is caught even when the last commit is clean.
new_repo "$tmp/older" && commit_file a.md "ip 192.168"".7.7" && commit_file b.md "clean"
expect older-commit private-ipv4 "$base"

# A new branch (remote sha all zeros) is scanned.
new_repo "$tmp/newbranch" && commit_file a.md "ip 192.168"".9.9"
expect new-branch private-ipv4 "$zero"

# A remote tip unknown locally (not fetched) must not shrink the scan to nothing.
new_repo "$tmp/unknown" && commit_file a.md "ip 192.168"".9.9"
expect unknown-remote-sha private-ipv4 "$(printf 'dead%.0s' {1..10})"

# A deletion line is skipped, and does not hide the ref lines after it.
new_repo "$tmp/deletion" && commit_file a.md "ip 192.168"".9.9"
out=$(printf 'refs/heads/d %s refs/heads/d %s\nrefs/heads/x %s refs/heads/x %s\n' \
  "$zero" "$base" "$head" "$base" | "$hook" 2>&1 >/dev/null) && got=pass || got=block
if [ "$got" = block ] && grep -q "RuleID: *private-ipv4" <<<"$out"; then
  echo "ok   deletion-then-leak (blocked by private-ipv4)"
else
  echo "FAIL deletion-then-leak: expected private-ipv4, got $got"; fail=1
fi

# Fail closed when gitleaks is missing (git itself stays on PATH).
mkdir -p "$tmp/bin" && ln -s "$(command -v git)" "$tmp/bin/git"
out=$(echo "refs/heads/n $head refs/heads/n $zero" | PATH="$tmp/bin" /bin/bash "$hook" 2>&1 >/dev/null)
if grep -q "gitleaks not found" <<<"$out"; then
  echo "ok   missing-gitleaks (refused)"
else
  echo "FAIL missing-gitleaks: hook did not refuse for a missing gitleaks"; fail=1
fi
exit $fail
