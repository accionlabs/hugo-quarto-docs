---
title: "Getting Started - For Complete Beginners"
description: "Step-by-step guide for non-technical users to set up and use the documentation system"
date: 2025-01-22
---

# Getting Started - For Complete Beginners

*No technical experience required! This guide will walk you through everything step by step.*

## 🎯 What You'll Learn

By the end of this guide, you'll be able to:
- ✅ Install the documentation system without using the terminal
- ✅ Find and organize your documents easily  
- ✅ Create beautiful documents that export to Word and PowerPoint
- ✅ Use the system like a pro

## 📋 Before You Start

**What you need:**
- A Mac computer (this guide is for Mac users)
- Internet connection
- 15 minutes of your time

**What you DON'T need:**
- Any programming knowledge
- Terminal or command line experience
- Complex technical setup

---

# Step 1: Download the Easy Installer

## Option A: Direct Download (Easiest)

1. **Right-click this link** and choose "Save Link As": [Download Easy Installer](https://raw.githubusercontent.com/accionlabs/hugo-quarto-docs/main/gui-install.sh)
2. **Save it to your Downloads folder**
3. **Rename the file** from `gui-install.sh` to `Easy Installer.command`
4. **Double-click the file** to run it

## Option B: From GitHub

1. **Go to**: [https://github.com/accionlabs/hugo-quarto-docs](https://github.com/accionlabs/hugo-quarto-docs)
2. **Click the green "Code" button**
3. **Select "Download ZIP"**
4. **Unzip the file** (usually happens automatically)
5. **Find the file called `gui-install.sh`**
6. **Rename it to `Easy Installer.command`**
7. **Double-click to run**

---

# Step 2: Run the Easy Installer

## What the installer will ask you:

### 📁 "Where would you like to install?"

**We recommend choosing Option 1: Documents folder**

This creates a folder called `my-documentation` in your Documents folder, which is easy to find.

### 🔍 Finding Your Documents After Installation

After installation, you'll find your documentation system here:

**Path**: `Documents > my-documentation`

**How to get there**:
1. Open **Finder**
2. Click **Documents** in the sidebar
3. Look for the **my-documentation** folder

---

# Step 3: Understanding Your New Folder

After installation, your `my-documentation` folder will contain:

## 🚀 Double-Click Files (These are your shortcuts!)

- **🚀 Start.command** 
  - *What it does*: Starts your website
  - *When to use*: Every time you want to work on documents

- **📁 Documents.command**
  - *What it does*: Opens the folder where you put your documents  
  - *When to use*: When you want to add or organize documents

- **📝 Obsidian.command** (if you have Obsidian)
  - *What it does*: Opens your documents in the Obsidian app
  - *When to use*: For a beautiful writing experience

## 📁 Important Folders

- **content/** - 🎯 **THIS IS WHERE YOUR DOCUMENTS GO**
  - **content/projects/** - Client work and projects
  - **content/shared/** - Team resources and guides  
  - **content/private/** - Your personal notes

- **📖 HOW TO USE.md** - Complete instructions (always available)

---

# Step 4: Your First Document

## Creating a Simple Document

1. **Double-click "📁 Documents.command"**
2. **Go into the "projects" folder**
3. **Right-click in empty space** and choose "New Folder"
4. **Name your folder**: `my-first-project` (no spaces, use hyphens)
5. **Go into your new folder**
6. **Right-click and choose**: New File → Text Document
7. **Name the file**: `project-notes.md`

## Adding Content to Your Document

**Open your new file in any text editor** (TextEdit works fine) and type:

```
---
title: "My First Project Notes"
description: "Learning how to use the documentation system"
date: 2025-01-22
---

# My First Project Notes

This is my first document in the system!

## What I learned today
- How to install the documentation system
- Where to find my content folder
- How to create new documents

## Next steps
- [ ] Create more project folders
- [ ] Try making a document that exports to Word
- [ ] Explore the sample content for examples
```

**Save the file**

## Viewing Your Document

1. **Double-click "🚀 Start.command"**
2. **Wait for your browser to open** (it will show http://localhost:1313)
3. **Click "Projects"** in the navigation
4. **Find your project** and click on it
5. **See your document** formatted beautifully!

---

# Step 5: Creating Professional Documents (With Exports)

## For documents you want to share as Word or PowerPoint:

1. **Create a new file** ending in `.qmd` (instead of `.md`)
2. **Example**: `client-proposal.qmd`
3. **Use this template**:

```
---
title: "Client Proposal"
description: "Proposal for new client project"
date: 2025-01-22
client: "ABC Company"
quarto_exports: ["docx", "pptx"]
---

# Client Proposal

*Prepared for ABC Company*

## Executive Summary
Your proposal content here...

## Project Timeline
- Week 1: Discovery and planning
- Week 2: Design and development
- Week 3: Testing and launch

## Investment
| Item | Cost |
|------|------|
| Design | $5,000 |
| Development | $10,000 |
| **Total** | **$15,000** |
```

4. **Save the file**
5. **Start the documentation system** (Launch Documentation.command)
6. **Navigate to your document** in the browser
7. **Look for "Download Formats"** section - you'll see DOCX and PPTX links!

---

# Step 6: Daily Workflow

## Every time you want to work on documents:

1. **Double-click "🚀 Start.command"**
2. **Wait for browser to open**
3. **Double-click "📁 Documents.command"** (opens in a new window)
4. **Edit your documents** in the content folder
5. **Refresh your browser** to see changes

## Organizing Your Work:

### For Client Projects:
- **Folder**: `content/projects/client-name/`
- **Files**: 
  - `project-proposal.qmd` (exports to Word/PowerPoint)
  - `meeting-notes.md` (internal notes)
  - `final-report.qmd` (exports to Word/PowerPoint)

### For Team Resources:
- **Folder**: `content/shared/topic-name/`
- **Files**: Process guides, templates, reference materials

### For Personal Notes:
- **Folder**: `content/private/`
- **Files**: Your personal methodologies, draft ideas, confidential notes

---

# 🆘 Troubleshooting

## "I can't find my content folder"

**Solution**:
1. Open **Finder**
2. Look in **Documents** for `my-documentation` folder
3. Inside that folder, double-click **"Open Content Folder.command"**

## "The website won't load"

**Solution**:
1. Close any terminal windows
2. Double-click **"Launch Documentation.command"** again
3. Wait for "Site will be available at..." message
4. Try refreshing your browser

## "My changes don't show up"

**Solutions**:
- Make sure you're editing files in the **content/** folder (not content-sample)
- **Refresh your browser** after making changes
- Check that your file is saved

## "Export links don't work"

**Solutions**:
- Make sure your file ends in `.qmd` (not `.md`)
- Check that you have `quarto_exports: ["docx", "pptx"]` in your file header
- Wait a moment after starting the system for exports to generate

---

# 🎉 You're Ready!

## What you've accomplished:
- ✅ Installed a professional documentation system
- ✅ Created your first document
- ✅ Learned how to export to Word and PowerPoint
- ✅ Understood the folder structure
- ✅ Know how to troubleshoot common issues

## Next steps:
- Explore the **sample content** for more examples
- Read the **Obsidian guide** if you want an even better writing experience
- Start creating documents for your real projects!

## 💡 Pro Tips:

### File Organization:
- Use **hyphens instead of spaces** in file and folder names
- Keep **consistent naming**: `project-proposal.qmd`, `meeting-notes.md`
- Create **one folder per project** in the projects directory

### Writing Tips:
- Start every document with the header section (between the `---` lines)
- Use `#` for main headings, `##` for subheadings
- Put `**text**` around words you want to make bold

### Sharing Work:
- For **internal team documents**: use `.md` files (faster, simpler)
- For **client deliverables**: use `.qmd` files with exports
- **Export links appear automatically** when you view QMD files in the browser

---

**🎈 Congratulations!** You now have a professional documentation system that requires zero technical knowledge to use. Focus on creating great content - the system handles the rest!