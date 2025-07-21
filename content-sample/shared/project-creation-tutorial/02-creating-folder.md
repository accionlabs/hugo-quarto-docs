---
title: "Step 2: Creating Project Folder"
description: "Set up the basic project structure with folders and index files"
date: 2025-01-21
---

# Step 2: Creating Project Folder

Now let's create the actual folders and files for our project. We'll start with the basic structure and build from there.

## 📁 Where to Create Your Project

Navigate to your documentation system folder:
```bash
cd ~/hugo-quarto-docs
```

Your project will go in: `content/projects/website-redesign/`

## 🛠️ Creating the Structure

### Option A: Using File Explorer (Recommended for Beginners)

1. **Open your file manager** (Finder on Mac, File Explorer on Windows)
2. **Navigate to** your documentation folder: `~/hugo-quarto-docs/content/projects/`
3. **Create new folder** called `website-redesign`
4. **Inside that folder**, create these subfolders:
   - `research`
   - `design`
   - `development`
   - `reports`
   - `presentation`

### Option B: Using Terminal (For Advanced Users)

```bash
cd ~/hugo-quarto-docs/content/projects/
mkdir -p website-redesign/{research,design,development,reports,presentation}
```

## 📝 Creating Index Files

Every folder needs an `_index.md` file to show up in navigation. Let's create them:

### Main Project Index

Create `content/projects/website-redesign/_index.md`:

```markdown
---
title: "Website Redesign Project"
description: "Company website modernization project"
date: 2025-01-21
client: "Acme Corporation"
team:
  - "John Smith (Designer)"
  - "Sarah Johnson (Developer)"
  - "Mike Brown (Content)"
type: "project"
---

# Website Redesign Project

## Project Overview

This project focuses on modernizing our company website to improve user experience and increase conversions.

## Timeline
- **Start Date**: January 2025
- **Duration**: 6 weeks
- **Launch Date**: March 2025

## Objectives
- Improve user experience and navigation
- Modernize visual design
- Optimize for mobile devices
- Increase conversion rates by 25%

## Team Members
- John Smith - Lead Designer
- Sarah Johnson - Frontend Developer  
- Mike Brown - Content Strategist

## Project Phases
1. **Research & Discovery** - User analysis and competitive research
2. **Design** - Wireframes, mockups, and design system
3. **Development** - Frontend implementation
4. **Testing & Launch** - QA testing and deployment
```

### Subfolder Index Files

Create an `_index.md` in each subfolder:

**`research/_index.md`**:
```markdown
---
title: "Research & Discovery"
description: "User analysis and competitive research"
---

# Research & Discovery

This section contains all research activities for the website redesign project.

## Research Activities
- User interviews and surveys
- Analytics review
- Competitive analysis
- Technical audit
```

**`design/_index.md`**:
```markdown
---
title: "Design"
description: "Visual design and user experience work"
---

# Design Phase

Visual design, wireframes, and user experience documentation.

## Design Deliverables
- Design brief and requirements
- Wireframes and user flows
- Visual mockups
- Design system components
```

**`development/_index.md`**:
```markdown
---
title: "Development"
description: "Technical implementation details"
---

# Development

Technical specifications and implementation details for the website redesign.

## Development Tasks
- Technical requirements
- Architecture planning
- Frontend development
- Performance optimization
```

## 🔍 Check Your Work

After creating the structure, check that you have:

```
content/projects/website-redesign/
├── _index.md
├── research/
│   └── _index.md
├── design/
│   └── _index.md
├── development/
│   └── _index.md
├── reports/
│   └── _index.md
└── presentation/
    └── _index.md
```

## 📱 View in Your Browser

1. **Make sure Hugo is running**: `hugo serve`
2. **Open**: http://localhost:1313
3. **Navigate to**: Projects → Website Redesign Project
4. **You should see**: Your project page with navigation to all subfolders

## ✅ Success Checklist

- [ ] Created main project folder
- [ ] Created all subfolders
- [ ] Added `_index.md` to each folder
- [ ] Can see project in browser navigation
- [ ] All subfolders appear in sidebar

## 🚀 Next Step

Great! Your project structure is ready. Now let's **[write your first document](./03-first-document/)** - the project proposal.

---

💡 **Troubleshooting**: If folders don't appear in navigation, check that each folder has an `_index.md` file. The navigation system requires these files to display folders properly.