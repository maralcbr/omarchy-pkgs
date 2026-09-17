#!/bin/bash

# Conditional put-object needs --if-none-match (2.17.34+) and --if-match (2.22.5+).

set -euo pipefail

AWS_CLI_VERSION=2.36.40
AWS_CLI_KEY_FINGERPRINT=FB5DB77FD5C118B80511ADA8A6310ACC4672475C

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
case $(uname -m) in
  aarch64|arm64) architecture=aarch64 ;;
  x86_64) architecture=x86_64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
url="https://awscli.amazonaws.com/awscli-exe-linux-$architecture-$AWS_CLI_VERSION.zip"
curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location --retry 3 --output "$work/awscli.zip" "$url"
curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location --retry 3 --output "$work/awscli.zip.sig" "$url.sig"

export GNUPGHOME=$work/gnupg
mkdir -m 0700 "$GNUPGHOME"
gpg --batch --import "$script_dir/aws-cli-team.asc" >/dev/null 2>&1
status=$(gpg --batch --status-fd 1 --verify "$work/awscli.zip.sig" "$work/awscli.zip" 2>/dev/null) || status=""
awk -v key="$AWS_CLI_KEY_FINGERPRINT" '$2 == "VALIDSIG" && $NF == key { valid=1 } END { exit !valid }' <<<"$status" || {
  echo "AWS CLI $AWS_CLI_VERSION is not signed by the AWS CLI Team key" >&2
  exit 1
}

unzip -q "$work/awscli.zip" -d "$work"
sudo "$work/aws/install" --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin --update
[[ $(/usr/local/bin/aws --version 2>&1) == "aws-cli/$AWS_CLI_VERSION "* ]] || {
  echo "AWS CLI $AWS_CLI_VERSION did not install" >&2
  exit 1
}
[[ $(command -v aws) == /usr/local/bin/aws ]] || {
  echo "aws resolves to $(command -v aws), not the pinned /usr/local/bin/aws" >&2
  exit 1
}
