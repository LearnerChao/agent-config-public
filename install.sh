#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CURSOR_DIR="$HOME/.cursor"

THOUGHTS_DIR="${THOUGHTS_DIR:-}"
prev_arg=""
for arg in "$@"; do
  if [ "$prev_arg" = "--thoughts-dir" ]; then
    THOUGHTS_DIR="$arg"
    prev_arg=""
    continue
  fi
  case "$arg" in
    --thoughts-dir=*)
      THOUGHTS_DIR="${arg#*=}"
      ;;
    --thoughts-dir)
      prev_arg="$arg"
      ;;
    -h|--help)
      cat <<USAGE
Usage: ./install.sh [--thoughts-dir PATH | --thoughts-dir=PATH]

Symlinks skills/, agents/, and rules/ into ~/.cursor/.
Bootstraps rules/journal-config.local.mdc from journal-config.example.mdc.

Options:
  --thoughts-dir PATH   Set the thoughts journal directory in the local
                        config (default: ~/code/thoughts/). Equivalent to
                        setting the THOUGHTS_DIR environment variable.
                        A leading ~ is expanded to \$HOME, and a trailing
                        / is added if missing. Has no effect if the local
                        config already exists.

After install, you can change the path later by editing
~/.cursor/rules/journal-config.local.mdc directly.
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

backed_up=()
linked=()
skipped=()

link() {
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

echo "=== Cursor Config Install (Public) ==="
echo "Repo: $REPO_DIR"
echo

link "$REPO_DIR/skills" "$CURSOR_DIR/skills"
link "$REPO_DIR/agents" "$CURSOR_DIR/agents"
link "$REPO_DIR/rules"  "$CURSOR_DIR/rules"

echo "--- Symlinks ---"
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
echo "--- Journal Config ---"
bootstrap_journal_config

echo
echo "--- Next Steps ---"
echo "  - Copy mcp-template.json to ~/.cursor/mcp.json and fill in your server URLs."
if [ -n "$THOUGHTS_DIR" ]; then
  echo "  - Set up a thoughts journal at $THOUGHTS_DIR (see README.md)."
else
  echo "  - Set up a thoughts journal at ~/code/thoughts/ (see README.md),"
  echo "    or edit ~/.cursor/rules/journal-config.local.mdc to use a different path."
fi
echo
echo "Done."
