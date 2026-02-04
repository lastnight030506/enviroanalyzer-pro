# 📁 EnviroAnalyzer Pro - Clean Project Structure

## Root Directory (Simplified)

Chỉ có các files **thiết yếu** để khởi động app:

```
enviroanalyzer-pro-main/
│
├── 📄 app.R                    # Main Shiny application
├── 📄 run.R                    # Quick launcher
├── 📄 README.md                # Documentation
├── 📄 LICENSE                  # MIT License
├── 📄 .gitignore               # Git ignore rules
│
├── 📁 src/                     # Source code
├── 📁 qcvn_data/               # QCVN standards data
├── 📁 electron/                # Desktop app (Electron)
├── 📁 docs/                    # Documentation
├── 📁 scripts/                 # Build & utility scripts
├── 📁 assets/                  # Images, icons
├── 📁 dist/                    # Build output
└── 📁 .github/                 # GitHub configs
```

---

## 📂 Detailed Structure

### 🎯 ROOT - App Entry Points

| File | Purpose | Usage |
|------|---------|-------|
| **app.R** | Main Shiny app | Used by all launchers |
| **run.R** | Web mode launcher | `Rscript run.R` |

### 📁 src/ - Source Code

All R source files organized here:

```
src/
├── constants.R       # QCVN definitions
├── functions.R       # Assessment logic
├── visuals.R         # Charts & plots
├── ai_helper.R       # AI integration
├── api.R             # REST API
└── n8n_config.R      # AI config
```

### 📁 qcvn_data/ - Standards Data

```
qcvn_data/
├── defaults/         # Default QCVN (JSON)
│   ├── qcvn_08_surface_water.json
│   ├── qcvn_40_industrial_wastewater.json
│   ├── ...
├── custom/           # User custom QCVN
├── qcvn_template.xlsx
├── create_excel_template.R
├── excel_to_json.R
└── HUONG_DAN_SU_DUNG.md
```

### 💻 electron/ - Desktop App

```
electron/
├── main.js           # Electron main process
├── preload.js        # Preload script
├── shiny_launcher.R  # R launcher
├── package.json      # Dependencies
├── install_and_run.ps1
└── run_electron.bat  # Windows launcher
```

**Run Electron:**
```bash
cd electron
npm start
```

### 📚 docs/ - Documentation

```
docs/
├── API_DOCUMENTATION.md
├── HUONG_DAN_EXCEL_TEMPLATE.md
├── PROJECT_STRUCTURE.md
└── n8n_workflows/    # AI workflows
    ├── enviroanalyzer_ai_workflow.json
    ├── README.md
    └── SETUP_GUIDE.md
```

### 🔧 scripts/ - Build & Utilities

```
scripts/
├── build_installers.ps1
├── build_now.R
├── run_api.R
├── build/            # Build configs
├── installer/        # Installer configs
└── installer_build/  # Installer resources
```

**Run API Server:**
```bash
Rscript scripts/run_api.R
```

**Build Installer:**
```powershell
.\scripts\build_installers.ps1
```

---

## 🚀 Quick Start

### Option 1: Web Mode
```bash
Rscript run.R
```
Opens in browser at http://localhost:3838

### Option 2: Desktop App
```bash
cd electron
npm install    # First time only
npm start
```
Opens as native Windows application

### Option 3: API Server
```bash
Rscript scripts/run_api.R
```
API available at http://localhost:3839

---

## 📊 File Count by Category

| Category | Count | Location |
|----------|-------|----------|
| **Core App** | 2 files | Root |
| **Source Code** | 6 files | src/ |
| **QCVN Data** | 20+ files | qcvn_data/ |
| **Electron** | 6 files | electron/ |
| **Documentation** | 10+ files | docs/ |
| **Scripts** | 10+ files | scripts/ |

**Total: Clean & organized!** ✨

---

## ⚠️ Important Notes

### Don't Move These Files:
- ✋ **app.R** - Must stay in root (R convention)
- ✋ **qcvn_data/** - Accessed by app.R
- ✋ **src/** - Sourced by app.R
- ✋ **assets/** - Used by app & build

### Safe to Delete:
- ❌ `dist/` - Build output (regenerated)
- ❌ `electron/node_modules/` - npm cache (run `npm install` again)

---

## 🎓 Development Workflow

### Adding New QCVN:
1. Create Excel template: `qcvn_data/qcvn_template.xlsx`
2. Fill in data
3. Upload in app or convert with `qcvn_data/excel_to_json.R`

### Building Desktop Installer:
1. `cd scripts/`
2. `.\build_installers.ps1`
3. Find output in `dist/`

### Setting up AI:
1. Configure n8n (see `docs/n8n_workflows/SETUP_GUIDE.md`)
2. Update `src/n8n_config.R` with webhook URL
3. Rebuild/restart app

---

**Version:** 3.1  
**Last Updated:** February 2026  
**Structure:** Minimalist & Production-ready ✨
