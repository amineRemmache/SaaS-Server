#!/bin/bash
set -euo pipefail

sudo apt install -y git
#
# deploy helm.

helm_version="${1:-v3.11.2}"; shift || true

# install helm.
# see https://helm.sh/docs/intro/install/
echo "installing helm $helm_version client..."
case `uname -m` in
    x86_64)
        # wget -qO- "https://get.helm.sh/helm-$helm_version-linux-amd64.tar.gz" | tar xzf - --strip-components=1 linux-amd64/helm
        sudo wget -O- "https://get.helm.sh/helm-v3.12.0-rc.1-linux-amd64.tar.gz" | tar xzf - --strip-components=1 linux-amd64/helm
        ;;
    armv7l)
        wget -O- "https://get.helm.sh/helm-$helm_version-linux-arm.tar.gz" | tar xzf - --strip-components=1 linux-arm/helm
        ;;
esac
sudo install helm /usr/local/bin
rm helm

# install the bash completion script.
touch /usr/share/bash-completion/completions/helm
sudo helm completion bash > /usr/share/bash-completion/completions/helm

# install the helm-diff plugin.
# NB this is especially useful for helmfile.
sudo helm plugin install https://github.com/databus23/helm-diff

# kick the tires.
printf "#\n# helm version\n#\n"
helm version
