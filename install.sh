#!/bin/bash
set -e

echo "==> Updating system and installing core packages..."
paru -Syu --noconfirm

echo "==> Installing development tools and applications..."
paru -S --needed --noconfirm \
        git micro base-devel fzf ripgrep \
        python python-pip python-virtualenv \
        google-chrome steam \
        github-cli antigravity \
        gemini-cli \
        lib32-libldap

echo "==> Vacuuming orphan programs..."
paru -c --noconfirm

echo "==> Deployment Complete! Your environment is ready."
