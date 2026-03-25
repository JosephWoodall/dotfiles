#!/bin/bash

# exit immediately if a command fails  
set -e

echo "==> Updating system and installing core packages..."
# Using paru instead of pacman to access both official repos and the AUR.
# Notice we dropped the 'sudo' here!
paru -Syu --noconfirm  

echo "==> Installing development tools and applications..."
paru -S --needed --noconfirm \
        git micro base-devel fzf ripgrep \
        python python-pip python-virtualenv \
        google-chrome steam zed opencode-bin \
		github-cli antigravity \
		llama.cpp

echo "==> Vacuuming orphan programs..."
paru -c --noconfirm

echo "==> Deployment Complete! Your environment is ready."
