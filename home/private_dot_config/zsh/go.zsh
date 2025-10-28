# --- Go (Homebrew) ---
# XDG dirs already set

# Go workspace + binaries
export GOPATH="${GOPATH:-$XDG_DATA_HOME/go}"
export GOBIN="${GOBIN:-$HOME/.local/bin}"

# Build/module caches under XDG
export GOCACHE="${GOCACHE:-$XDG_CACHE_HOME/go-build}"
export GOMODCACHE="${GOMODCACHE:-$GOPATH/pkg/mod}"

# Ensure dirs exist
mkdir -p "$GOBIN" "$GOPATH" "$GOCACHE" "$GOMODCACHE"

# Prepend ~/.local/bin if missing
case ":$PATH:" in (*":$GOBIN:"*) ;; (*) PATH="$GOBIN:$PATH" ;; esac

# Ensure Homebrew's Go is on PATH (Apple/Intel)
if ! command -v go >/dev/null 2>&1; then
  for p in /opt/homebrew/bin /usr/local/bin; do
    [ -x "$p/go" ] && { case ":$PATH:" in (*":$p:"*) ;; (*) PATH="$p:$PATH" ;; esac; break; }
  done
  if command -v brew >/dev/null 2>&1 && brew --prefix go >/dev/null 2>&1; then
    _gobin="$(brew --prefix go)/bin"
    [ -d "$_gobin" ] && case ":$PATH:" in (*":$_gobin:"*) ;; (*) PATH="$_gobin:$PATH" ;; esac
    unset _gobin
  fi
fi

# Toolchain behavior (Go 1.21+)
export GOTOOLCHAIN="${GOTOOLCHAIN:-auto}"

# Module proxy/sumdb
export GOPROXY="${GOPROXY:-https://proxy.golang.org,direct}"
export GOSUMDB="${GOSUMDB:-sum.golang.org}"

# Private modules (adjust as needed)
export GOPRIVATE="${GOPRIVATE:-dev.azure.com/redacted-org/*}"

# Handy aliases (optional)
alias g='go'
alias gtest='go test ./...'
alias gtidy='go mod tidy'
alias gvet='go vet ./...'

# Quick summary helper
goinfo() {
  echo "go:      $(command -v go || echo 'not found')"
  command -v go >/dev/null 2>&1 && go version
  echo "GOPATH:  $GOPATH"
  echo "GOBIN:   $GOBIN"
  echo "GOPROXY: ${GOPROXY:-unset}"
  echo "GOPRIVATE: ${GOPRIVATE:-unset}"
}