---
title: "Document Types & Examples"
description: "Learn about different document types and when to use them"
date: 2025-01-21
---

# Document Types & Examples

Your documentation system supports different types of documents for different purposes. Here's when and how to use each type.

## 📝 Markdown Files (.md)

**Best for**: Simple documentation, notes, web-only content

**Features**:
- Fast loading and processing
- Perfect for web display  
- Great for notes and simple documents
- No export capabilities

**Example**: [Simple Project Notes](./simple-notes-example/)

## 📄 Quarto Documents (.qmd)

**Best for**: Documents you want to export (DOCX, PPTX), rich content with diagrams

**Features**:
- Export to Word, PowerPoint
- Support for diagrams (Mermaid)
- Mathematical equations
- Code blocks with syntax highlighting
- All Markdown features plus more

**Examples**: 
- [Project Proposal with Export](./project-proposal-example/)
- [Presentation with Diagrams](./presentation-example/)
- [Report with Charts](./report-example/)

## 🎯 When to Use Which?

### Use .md files for:
- ✅ Meeting notes
- ✅ Internal documentation
- ✅ Quick reference guides
- ✅ Web-only content
- ✅ Index pages and overviews

### Use .qmd files for:
- ✅ Client deliverables
- ✅ Presentations
- ✅ Formal reports
- ✅ Documents with diagrams
- ✅ Content with mathematical formulas
- ✅ Anything you need to export

## 📊 Rich Content Examples

### Diagrams with Mermaid
Both .md and .qmd files support Mermaid diagrams, but .qmd files can export them to Word/PowerPoint.

### Tables and Data
Enhanced table formatting and export capabilities in .qmd files.

### Mathematical Content
LaTeX-style math equations in .qmd files.

### Code Examples  
Syntax highlighting and code execution examples.

## 🔄 Converting Between Types

**From .md to .qmd**:
1. Rename file extension
2. Add export configuration to frontmatter
3. Enhance with rich content as needed

**From .qmd to .md**:
1. Remove export configuration
2. Rename file extension  
3. Simplify complex features if needed

## 🚀 Next Steps

Explore the example documents to see these features in action:
- **[Simple Notes Example](./simple-notes-example/)**
- **[Project Proposal with Export](./project-proposal-example/)**
- **[Presentation with Diagrams](./presentation-example/)**

Or continue with the **[Step-by-Step Tutorial](../project-creation-tutorial/)** to build your own project.