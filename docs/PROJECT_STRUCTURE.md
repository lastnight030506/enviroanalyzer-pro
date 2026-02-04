# EnviroAnalyzer Pro - Project Structure

```
enviroanalyzer-pro-main/
│
├── src/                          # Source code
│   ├── constants.R               # QCVN standards definitions  
│   ├── functions.R               # Data processing functions
│   ├── visuals.R                 # Visualization functions
│   ├── ai_helper.R               # AI integration helpers
│   ├── api.R                     # REST API for n8n
│   └── n8n_config.R              # n8n configuration
│
├── docs/                         # Documentation
│   ├── API_DOCUMENTATION.md      # API docs for n8n
│   └── HUONG_DAN_EXCEL_TEMPLATE.md # Excel template guide
│
├── scripts/                      # Build & utility scripts
│   ├── build_installers.ps1     # Build Windows installers
│   ├── build_now.R               # Quick build script
│   └── run_api.R                 # Run REST API server
│
├── qcvn_data/                    # QCVN data files
│   ├── defaults/                 # Default QCVN (JSON)
│   ├── custom/                   # User custom QCVN
│   ├── qcvn_template.xlsx        # Excel template
│   └── HUONG_DAN_SU_DUNG.md      # Usage guide
│
├── n8n_workflows/                # n8n AI workflows
│   ├── enviroanalyzer_ai_workflow.json
│   ├── README.md
│   └── SETUP_GUIDE.md
│
├── electron/                     # Electron desktop app
│   ├── main.js                   # Main process
│   ├── preload.js                # Preload script
│   ├── shiny_launcher.R          # R launcher
│   ├── package.json              # Dependencies
│   └── install_and_run.ps1       # Installer
│
├── installer/                    # Installer configs
│   ├── lightweight.iss           # Lightweight installer
│   └── standalone.iss            # Standalone installer
│
├── assets/                       # Images, icons, etc
│
├── app.R                         # Main Shiny app
├── run.R                         # App launcher
├── run_electron.bat              # Electron launcher (Windows)
├── README.md                     # Main documentation
└── LICENSE                       # MIT License
```

## 📁 Core Files (Root)

- **app.R** - Main Shiny application (keep in root for R compatibility)
- **run.R** - Simple launcher script
- **run_electron.bat** - Windows batch file to launch Electron app

## 🎯 Why This Structure?

### ✅ Organized
- Source code in `src/`
- Documentation in `docs/`
- Scripts in `scripts/`
- Data in `qcvn_data/`

### ✅ Clean Root
- Only essential files in root
- Easy to find main entry points
- No clutter

### ✅ Maintainable
- Related files grouped together
- Clear separation of concerns
- Easy to navigate

## 🚀 Quick Start

### Run Web Mode
```bash
Rscript run.R
```

### Run Electron Mode
```bash
cd electron
npm start
```

### Run API Server
```bash
Rscript scripts/run_api.R
```

## 📝 File Roles

| File | Purpose |
|------|---------|
| `app.R` | Main Shiny UI/Server |
| `src/constants.R` | QCVN definitions |
| `src/functions.R` | Assessment logic |
| `src/visuals.R` | Charts & plots |
| `src/ai_helper.R` | AI integration |
| `src/api.R` | REST API endpoints |
| `src/n8n_config.R` | AI service config |

---

**Version:** 3.1  
**Updated:** February 2026
