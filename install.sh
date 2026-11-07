#!/bin/sh
set -eu

repo="sbularca/solventius-harness"
dir="${SOLV_INSTALL_DIR:-$HOME/solv}"

fail() {
    echo "error: $1" >&2
    exit 1
}

for tool in curl unzip; do
    command -v "$tool" >/dev/null 2>&1 || fail "$tool is not installed. Install it and run this again."
done

case "$(uname -m)" in
    x86_64 | amd64) arch="x64" ;;
    arm64 | aarch64) arch="arm64" ;;
    *) fail "unsupported CPU: $(uname -m)" ;;
esac

case "$(uname -s)" in
    Linux)
        [ "$arch" = "x64" ] || fail "Linux $arch is not supported yet; only x64."
        if [ -f /etc/alpine-release ] || ldd --version 2>&1 | grep -q musl; then
            system="linux-x64-musl"
        else
            system="linux-x64"
        fi
        ;;
    Darwin) system="macos-$arch" ;;
    *) fail "unsupported system: $(uname -s). On Windows use install.ps1." ;;
esac

latest=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest") || fail "cannot reach GitHub"
tag="${latest##*/}"
case "$tag" in
    v[0-9]*) ;;
    *) fail "cannot find the latest release" ;;
esac
version="${tag#v}"
name="solventius-harness-$version-$system"
base="https://github.com/$repo/releases/download/$tag"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $name.zip"
curl -fsSL -o "$tmp/$name.zip" "$base/$name.zip" || fail "download failed: $base/$name.zip"
curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS" || fail "download failed: $base/SHA256SUMS"

expected=$(grep " $name.zip\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)
[ -n "$expected" ] || fail "$name.zip is not in SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$tmp/$name.zip" | cut -d' ' -f1)
else
    actual=$(shasum -a 256 "$tmp/$name.zip" | cut -d' ' -f1)
fi
[ "$actual" = "$expected" ] || fail "checksum mismatch for $name.zip"

unzip -q "$tmp/$name.zip" -d "$tmp/unpacked"
mkdir -p "$dir"
for file in "$tmp/unpacked/$name"/*; do
    target="$dir/$(basename "$file")"
    cp "$file" "$target.new"
    mv -f "$target.new" "$target"
done
chmod +x "$dir/solv"

if [ "$system" = "macos-$arch" ]; then
    xattr -d com.apple.quarantine "$dir/solv" 2>/dev/null || true
    codesign --force --sign - "$dir/solv" 2>/dev/null || echo "warning: codesign failed; see the README if macOS blocks solv" >&2
fi

if "$dir/solv" --selftest >/dev/null 2>&1; then
    echo "Self-test passed."
else
    echo "warning: the self-test failed. Run '$dir/solv --selftest' to see why." >&2
fi

case ":$PATH:" in
    *":$dir:"*) on_path=1 ;;
    *) on_path=0 ;;
esac
if [ "$on_path" = 0 ]; then
    case "$(basename "${SHELL:-sh}")" in
        zsh) rc="$HOME/.zshrc" ;;
        bash) if [ "$(uname -s)" = "Darwin" ]; then rc="$HOME/.bash_profile"; else rc="$HOME/.bashrc"; fi ;;
        *) rc="$HOME/.profile" ;;
    esac
    line="export PATH=\"$dir:\$PATH\""
    if ! grep -qxF "$line" "$rc" 2>/dev/null; then
        printf '\n%s\n' "$line" >>"$rc"
        echo "Added $dir to PATH in $rc."
    fi
    echo "Open a new terminal to use solv."
fi

echo "Installed solv $version in $dir"
echo "Run: solv --help"
