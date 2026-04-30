#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER_BEGIN="<!-- BEGIN agent-config-public -->"
MARKER_END="<!-- END agent-config-public -->"

ALL_IDES="cursor claude codex gemini"

ide_display_name() {
  case "$1" in
    cursor) echo "Cursor" ;;
    claude) echo "Claude Code" ;;
    codex)  echo "Codex CLI" ;;
    gemini) echo "Gemini CLI" ;;
    *)      echo "$1" ;;
  esac
}

ide_home() {
  case "$1" in
    cursor) echo "$HOME/.cursor" ;;
    claude) echo "$HOME/.claude" ;;
    codex)  echo "$HOME/.codex" ;;
    gemini) echo "$HOME/.gemini" ;;
    *)      echo "" ;;
  esac
}

ide_detected() {
  local home
  home="$(ide_home "$1")"
  [ -n "$home" ] && [ -d "$home" ]
}

ide_has_agents_dir() {
  case "$1" in
    cursor|claude) return 0 ;;
    *)             return 1 ;;
  esac
}

ide_has_rules_dir() {
  case "$1" in
    cursor|claude) return 0 ;;
    *)             return 1 ;;
  esac
}

ide_global_rules_file() {
  case "$1" in
    claude) echo "$HOME/.claude/CLAUDE.md" ;;
    codex)  echo "$HOME/.codex/AGENTS.md" ;;
    gemini) echo "$HOME/.gemini/GEMINI.md" ;;
    *)      echo "" ;;
  esac
}

THOUGHTS_DIR="${THOUGHTS_DIR:-}"
IDE_FLAG=""
prev_arg=""
require_value() {
  local flag="$1" val="$2"
  case "$val" in
    --*) echo "ERROR: $flag expects a value, got '$val'" >&2; exit 2 ;;
    "")  echo "ERROR: $flag expects a non-empty value" >&2; exit 2 ;;
  esac
}
for arg in "$@"; do
  if [ "$prev_arg" = "--thoughts-dir" ]; then
    require_value "--thoughts-dir" "$arg"
    THOUGHTS_DIR="$arg"; prev_arg=""; continue
  fi
  if [ "$prev_arg" = "--ide" ]; then
    require_value "--ide" "$arg"
    IDE_FLAG="$arg"; prev_arg=""; continue
  fi
  case "$arg" in
    --thoughts-dir=*) THOUGHTS_DIR="${arg#*=}" ;;
    --thoughts-dir)   prev_arg="$arg" ;;
    --ide=*)          IDE_FLAG="${arg#*=}" ;;
    --ide)            prev_arg="$arg" ;;
    -h|--help)
      cat <<USAGE
Usage: ./install.sh [--ide LIST] [--thoughts-dir PATH]

Install agent skills, subagents, and rules for one or more AI coding IDEs.

Options:
  --ide LIST            Comma-separated IDE list (cursor, claude, codex, gemini),
                        or 'auto' to use only detected IDEs, or 'all' for every
                        supported IDE. If omitted, prompts interactively.
                        Aliases: --ide=cursor,claude is equivalent to --ide cursor,claude.

  --thoughts-dir PATH   Set the thoughts journal directory in the local config
                        (default: ~/code/thoughts/). Equivalent to setting the
                        THOUGHTS_DIR environment variable. A leading ~ is
                        expanded to \$HOME, and a trailing / is added if missing.
                        Has no effect if rules/journal-config.local.mdc already
                        exists.

  -h, --help            Show this help and exit.

Examples:
  ./install.sh                                # interactive
  ./install.sh --ide=cursor                   # Cursor only, non-interactive
  ./install.sh --ide=cursor,claude            # both
  ./install.sh --ide=auto                     # only IDEs detected on this system
  ./install.sh --ide=all --thoughts-dir=~/notes
USAGE
      exit 0
      ;;
  esac
done

if [ -n "$THOUGHTS_DIR" ]; then
  case "$THOUGHTS_DIR" in
    "~")    THOUGHTS_DIR="$HOME" ;;
    "~/"*)  THOUGHTS_DIR="$HOME/${THOUGHTS_DIR#\~/}" ;;
  esac
  case "$THOUGHTS_DIR" in
    */) ;;
    *)  THOUGHTS_DIR="$THOUGHTS_DIR/" ;;
  esac
fi

resolve_ide_selection() {
  local input
  input="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  local out=""
  case "$input" in
    all)  echo "$ALL_IDES"; return ;;
    auto)
      for ide in $ALL_IDES; do
        if ide_detected "$ide"; then out="$out $ide"; fi
      done
      echo "${out# }"
      return
      ;;
  esac
  local IFS=','
  for token in $input; do
    token="$(echo "$token" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
    [ -z "$token" ] && continue
    case " $ALL_IDES " in
      *" $token "*) out="$out $token" ;;
      *) echo "ERROR: unknown IDE '$token' (supported: $ALL_IDES)" >&2; return 1 ;;
    esac
  done
  echo "${out# }"
}

interactive_select() {
  echo "=== Agent Config Install ==="
  echo
  echo "Select target IDE(s). Detected installations are pre-selected."
  echo
  local i=1
  local nums=""
  local default_nums=""
  for ide in $ALL_IDES; do
    local name detected_marker
    name="$(ide_display_name "$ide")"
    if ide_detected "$ide"; then
      detected_marker="[x] (detected at $(ide_home "$ide"))"
      default_nums="$default_nums $i"
    else
      detected_marker="[ ] ($(ide_home "$ide") not found)"
    fi
    printf "  %d. %-12s %s\n" "$i" "$name" "$detected_marker"
    nums="$nums $i:$ide"
    i=$((i + 1))
  done
  echo
  echo "Press Enter to accept the pre-selected (detected) IDEs,"
  echo "or type comma-separated numbers (e.g. '1,2'), 'all', or 'none'."
  default_nums="$(echo "$default_nums" | tr ' ' ',' | sed 's/^,//;s/,$//')"
  if [ -z "$default_nums" ]; then
    echo "(No IDEs detected — type at least one number, 'all', or 'none' to abort.)"
  else
    echo "Default: $default_nums"
  fi
  printf "> "
  local response=""
  read -r response || true
  response="$(echo "$response" | tr -d '[:space:]')"
  if [ -z "$response" ]; then
    response="$default_nums"
  fi
  case "$response" in
    none|NONE) echo ""; return ;;
    all|ALL)   echo "$ALL_IDES"; return ;;
    auto|AUTO) resolve_ide_selection "auto"; return ;;
  esac
  local out=""
  local IFS=','
  for token in $response; do
    token="$(echo "$token" | tr -d '[:space:]')"
    [ -z "$token" ] && continue
    case "$token" in
      ''|*[!0-9]*)
        echo "ERROR: invalid input '$token' (expected number)" >&2; return 1 ;;
    esac
    local match=""
    for entry in $nums; do
      local n="${entry%%:*}"
      local id="${entry#*:}"
      if [ "$n" = "$token" ]; then match="$id"; break; fi
    done
    if [ -z "$match" ]; then
      echo "ERROR: '$token' is not a listed option" >&2; return 1
    fi
    out="$out $match"
  done
  echo "${out# }"
}

backed_up=()
linked=()
skipped=()

link_path() {
  local src="$1" dest="$2"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      skipped+=("$dest (already linked)")
      return
    fi
    rm "$dest"
  elif [ -e "$dest" ]; then
    local bak="$dest.bak"
    local n=1
    while [ -e "$bak" ]; do
      bak="$dest.bak.$n"
      n=$((n + 1))
    done
    mv "$dest" "$bak"
    backed_up+=("$dest -> $bak")
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  linked+=("$dest -> $src")
}

build_global_rules_content() {
  local rules_dir="$REPO_DIR/rules"
  printf '%s\n' "$MARKER_BEGIN"
  printf '%s\n' "<!-- Generated by agent-config-public install.sh. Do not edit by hand;"
  printf '%s\n' "     re-run install.sh to refresh, or remove this section to opt out. -->"
  printf '\n'
  printf '%s\n' "# Agent Configuration"
  printf '\n'
  printf '%s\n' "These rules are managed by agent-config-public's install.sh and embedded into this"
  printf '%s\n' "file because the IDE uses a single rules file rather than a rules directory."
  printf '%s\n' "Path-scoped rules (alwaysApply: false) are not embedded here."
  printf '\n'

  if [ ! -d "$rules_dir" ]; then
    printf '%s\n' "$MARKER_END"
    return
  fi

  local rule has_any=0
  for rule in "$rules_dir"/*.mdc; do
    [ -f "$rule" ] || continue
    if grep -q "^alwaysApply: true" "$rule"; then
      has_any=1
      local rule_name
      rule_name="$(basename "$rule" .mdc)"
      printf '## %s\n\n' "$rule_name"
      awk '
        /^---$/ { count++; next }
        count >= 2 { print }
      ' "$rule"
      printf '\n'
    fi
  done

  if [ "$has_any" -eq 0 ]; then
    printf '%s\n\n' "_(No always-applied rules found in rules/.)_"
  fi

  printf '%s\n' "$MARKER_END"
}

write_global_rules_file() {
  local target="$1"
  local content_file
  content_file="$(mktemp)"
  build_global_rules_content > "$content_file"

  mkdir -p "$(dirname "$target")"

  if [ ! -f "$target" ]; then
    cat "$content_file" > "$target"
    rm -f "$content_file"
    echo "  CREATED: $target"
    return
  fi

  if grep -qF "$MARKER_BEGIN" "$target"; then
    if ! grep -qF "$MARKER_END" "$target"; then
      rm -f "$content_file"
      echo "  ERROR: $target contains '$MARKER_BEGIN' but no matching '$MARKER_END'." >&2
      echo "         Refusing to rewrite — fix the file (add the END marker, or remove the BEGIN marker)" >&2
      echo "         and re-run install.sh." >&2
      exit 3
    fi
    local begin_count end_count
    begin_count="$(grep -cF "$MARKER_BEGIN" "$target" || true)"
    end_count="$(grep -cF "$MARKER_END" "$target" || true)"
    if [ "$begin_count" -gt 1 ] || [ "$end_count" -gt 1 ]; then
      rm -f "$content_file"
      echo "  ERROR: $target has duplicate '$MARKER_BEGIN'/'$MARKER_END' markers" >&2
      echo "         (begin=$begin_count, end=$end_count). Refusing to rewrite — clean up the file" >&2
      echo "         (keep exactly one matching pair) and re-run install.sh." >&2
      exit 3
    fi
    local tmp
    tmp="$(mktemp)"
    awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" -v cf="$content_file" '
      BEGIN { skip = 0 }
      $0 == begin { while ((getline line < cf) > 0) print line; close(cf); skip = 1; next }
      $0 == end   { skip = 0; next }
      !skip       { print }
    ' "$target" > "$tmp"
    mv "$tmp" "$target"
    rm -f "$content_file"
    echo "  UPDATED: $target (managed section)"
  else
    printf '\n' >> "$target"
    cat "$content_file" >> "$target"
    rm -f "$content_file"
    echo "  APPENDED: $target (managed section added at end)"
  fi
}

install_for_ide() {
  local ide="$1"
  local home
  home="$(ide_home "$ide")"
  local name
  name="$(ide_display_name "$ide")"
  echo
  echo "--- $name ($home) ---"

  link_path "$REPO_DIR/skills" "$home/skills"

  if ide_has_agents_dir "$ide"; then
    link_path "$REPO_DIR/agents" "$home/agents"
  else
    echo "  NOTE: $name does not have a separate agents directory; skipping."
  fi

  if ide_has_rules_dir "$ide"; then
    link_path "$REPO_DIR/rules" "$home/rules"
  fi

  local global_file
  global_file="$(ide_global_rules_file "$ide")"
  if [ -n "$global_file" ]; then
    write_global_rules_file "$global_file"
  fi
}

bootstrap_journal_config() {
  local example="$REPO_DIR/journal-config.example.mdc"
  local local_cfg="$REPO_DIR/rules/journal-config.local.mdc"

  if [ ! -f "$example" ]; then
    echo "  WARN: $example not found; skipping journal config bootstrap."
    return
  fi

  if [ -f "$local_cfg" ]; then
    if [ -n "$THOUGHTS_DIR" ]; then
      echo "  SKIPPED: rules/journal-config.local.mdc (already exists; --thoughts-dir/THOUGHTS_DIR ignored)"
      echo "           To change the path, edit the file directly or remove it and re-run."
    else
      echo "  SKIPPED: rules/journal-config.local.mdc (already exists)"
    fi
    return
  fi

  cp "$example" "$local_cfg"

  if [ -n "$THOUGHTS_DIR" ]; then
    local escaped
    escaped="$(printf '%s' "$THOUGHTS_DIR" | sed -e 's/[\/&]/\\&/g')"
    sed -i.bak "s/~\/code\/thoughts\//${escaped}/g" "$local_cfg"
    rm -f "${local_cfg}.bak"
    echo "  CREATED: rules/journal-config.local.mdc (path: $THOUGHTS_DIR)"
  else
    echo "  CREATED: rules/journal-config.local.mdc (default path: ~/code/thoughts/)"
  fi
}

SELECTED_IDES=""
if [ -n "$IDE_FLAG" ]; then
  SELECTED_IDES="$(resolve_ide_selection "$IDE_FLAG")"
elif [ ! -t 0 ]; then
  echo "ERROR: stdin is not a TTY and --ide was not provided." >&2
  echo "       For non-interactive use (e.g., piped install or CI), pass --ide=auto," >&2
  echo "       --ide=all, or --ide=cursor,claude,codex,gemini." >&2
  exit 2
else
  SELECTED_IDES="$(interactive_select)"
fi

if [ -z "$SELECTED_IDES" ]; then
  echo
  echo "No IDEs selected. Nothing to install."
  echo "Re-run with --ide=<list> or interactively to install."
  exit 0
fi

echo
echo "=== Agent Config Install ==="
echo "Repo:    $REPO_DIR"
printf "IDEs:   "
for ide in $SELECTED_IDES; do printf " %s" "$(ide_display_name "$ide")"; done
echo

echo
echo "--- Journal Config (shared by all IDEs) ---"
bootstrap_journal_config

for ide in $SELECTED_IDES; do
  install_for_ide "$ide"
done

echo
echo "--- Summary ---"
if [ ${#linked[@]} -gt 0 ]; then
  for item in "${linked[@]}"; do echo "  LINKED: $item"; done
fi
if [ ${#skipped[@]} -gt 0 ]; then
  for item in "${skipped[@]}"; do echo "  SKIPPED: $item"; done
fi
if [ ${#backed_up[@]} -gt 0 ]; then
  echo
  echo "--- Backups ---"
  for item in "${backed_up[@]}"; do echo "  BACKUP: $item"; done
fi

echo
echo "--- Next Steps ---"
echo "  - MCP servers (optional): copy mcp-template.json to your IDE's MCP config path"
echo "    and fill in your endpoints. Common locations:"
for ide in $SELECTED_IDES; do
  case "$ide" in
    cursor) echo "      Cursor:      ~/.cursor/mcp.json" ;;
    claude) echo "      Claude Code: ~/.claude/.mcp.json (or ~/Library/.../claude_desktop_config.json)" ;;
    codex)  echo "      Codex CLI:   ~/.codex/config.toml (mcp_servers section)" ;;
    gemini) echo "      Gemini CLI:  ~/.gemini/settings.json (or per project)" ;;
  esac
done
if [ -n "$THOUGHTS_DIR" ]; then
  echo "  - Set up your thoughts journal at $THOUGHTS_DIR (see README.md)."
else
  echo "  - Set up your thoughts journal at ~/code/thoughts/ (see README.md),"
  echo "    or edit rules/journal-config.local.mdc to use a different path."
fi
echo
echo "Done."
