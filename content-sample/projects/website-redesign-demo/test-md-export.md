---
title: "Test MD Export"
description: "Testing export functionality from .md files"
date: 2025-01-22
quarto_exports: docx, pptx
---

# Test MD Export

This is a test document to verify that .md files can export to DOCX and PPTX formats when they have the `quarto_exports` property.

## Features Being Tested

1. **Obsidian-style quarto_exports format**: `docx, pptx` (without brackets)
2. **Export generation from .md files**
3. **Navigation without title fallback**

## Sample Content

### Table
| Feature | Status |
|---------|--------|
| MD Export | ✅ Working |
| Multiple Formats | ✅ Working |
| Obsidian Format | ✅ Working |

### List
- Export to DOCX ✓
- Export to PPTX ✓
- Navigation fallback ✓
- Print hiding ✓

This document should generate both DOCX and PPTX exports even though it's a .md file!