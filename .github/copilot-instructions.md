# EnviroAnalyzer Pro - Copilot Instructions

## Project Overview
R Shiny application for environmental quality assessment using Vietnamese standards (QCVN). Compares measurement data against regulatory limits for water, air, soil, and noise.

## Architecture

### Core Files (load order matters)
1. **constants.R** - QCVN standards definitions
2. **functions.R** - Data processing (`check_single_compliance()`, `check_compliance()`)
3. **visuals.R** - Charts (`create_radar_chart()`, `create_gauge_chart()`)
4. **app.R** - Main Shiny UI/Server (~2700 lines)
5. **run.R** - Local launcher with auto package install

### QCVN Standard Pattern
```r
QCVN_XX <- list(
  name = "QCVN XX:YYYY/BTNMT",
  columns = c("A", "B"),
  parameters = list(
    Param = list(A = value, B = value, type = "max|min|range")
  )
)
```

### Compliance Types
- `"max"` → value ≤ threshold
- `"min"` → value ≥ threshold  
- `"range"` → value in `c(lower, upper)`

## Conventions

### Vietnamese Labels
- `"Đạt"` (Pass), `"Không đạt"` (Fail), `"Cảnh báo"` (Warning)

### Color Coding
```r
success = "#2E7D32"  # Green
warning = "#F57C00"  # Orange (≥80%)
danger  = "#C62828"  # Red (exceeds)
```

## Run Application
```bash
Rscript run.R
# OR with full path:
& "C:\Program Files\R\R-4.5.2\bin\Rscript.exe" run.R
```

## File Structure
```
├── app.R          # Main Shiny app
├── constants.R    # QCVN definitions
├── functions.R    # Business logic
├── visuals.R      # Visualization
├── run.R          # Local launcher
└── README.md
```
