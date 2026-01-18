#!/bin/bash
# Script para iniciar Cloudflare Tunnels

cd "$(dirname "$0")/../.."
mkdir -p logs

# Matar tunnels antigos
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 2

# SSH Tunnel
nohup cloudflared tunnel --url ssh://localhost:22 > logs/tunnel-ssh.log 2>&1 &
sleep 2

# Ollama Tunnel
nohup cloudflared tunnel --url http://localhost:11434 > logs/tunnel-ollama.log 2>&1 &
sleep 2
