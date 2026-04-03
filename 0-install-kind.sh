OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && ARCH="amd64"
[ "$ARCH" = "aarch64" ] && ARCH="arm64"
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.31.0/kind-${OS}-${ARCH}"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
