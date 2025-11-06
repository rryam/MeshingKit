#!/bin/bash

# Setup script to configure Git hooks for MeshingKit
# Run this once after cloning the repository

echo "🔧 Setting up Git hooks for MeshingKit..."

# Configure Git to use the tracked hooks directory
git config core.hooksPath scripts/hooks

if [ $? -eq 0 ]; then
    echo "✅ Git hooks configured successfully!"
    echo ""
    echo "The pre-commit hook will now run automatically on every commit."
    echo "It will check your Swift code with SwiftLint before allowing commits."
else
    echo "❌ Failed to configure Git hooks"
    exit 1
fi

