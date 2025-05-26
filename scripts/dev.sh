#!/bin/bash

echo "🚀 Starting development environment..."

make up
make ingress-install
make ingress-proxy

echo "🌍 Opening http://localhost:8080 ..."
if command -v xdg-open > /dev/null; then
  xdg-open http://localhost:8080
elif command -v open > /dev/null; then
  open http://localhost:8080
else
  echo "Open http://localhost:8080 in your browser"
fi
