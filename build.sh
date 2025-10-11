#!/usr/bin/env bash
set -e

ZOLA_VERSION=0.21.0

echo "Installing Zola ${ZOLA_VERSION}..."
curl -L "https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/zola-v${ZOLA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" -o zola.tar.gz
tar -xzf zola.tar.gz
mv zola /usr/local/bin/zola
zola --version

echo "Building site..."
zola build
