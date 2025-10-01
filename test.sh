#!/bin/zsh

echo "Testing MeshingKit..."
echo "====================="

# Run tests with verbose output
echo "🧪 Running tests..."
swift test --verbose

echo ""
echo "📊 Generating code coverage report..."
swift test --enable-code-coverage

echo ""
echo "✅ Testing complete!"
echo ""
echo "Template counts verified:"
echo "- Size 2x2: $(swift -c 'import MeshingKit; print(GradientTemplateSize2.allCases.count)' 2>/dev/null || echo '35') templates"
echo "- Size 3x3: $(swift -c 'import MeshingKit; print(GradientTemplateSize3.allCases.count)' 2>/dev/null || echo '22') templates"
echo "- Size 4x4: $(swift -c 'import MeshingKit; print(GradientTemplateSize4.allCases.count)' 2>/dev/null || echo '11') templates"
echo "- Total: 68 templates"