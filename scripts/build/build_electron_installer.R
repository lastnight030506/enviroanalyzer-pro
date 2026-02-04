# ============================================================================ #
#           BUILD ELECTRON INSTALLER - ENVIROANALYZER PRO                      #
# ============================================================================ #
# Creates a standalone Windows installer using electricShine (Electron + R)
# 
# Features:
#   - Portable R bundled (no R installation required)
#   - All packages pre-installed for offline use
#   - Desktop shortcut created
#   - Runs as standalone Electron window
#
# Requirements:
#   - Node.js: https://nodejs.org/
#   - npm (comes with Node.js)
#   - Inno Setup (optional, for .exe installer)
# ============================================================================ #

cat("\n")
cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║     ENVIROANALYZER PRO - ELECTRON INSTALLER BUILD             ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

# ---- 1. INSTALL/LOAD ELECTRICSHINE ----
cat("[1/6] Installing electricShine package...\n")

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cloud.r-project.org")
}

if (!requireNamespace("electricShine", quietly = TRUE)) {
  cat("    → Installing electricShine from GitHub...\n")
  remotes::install_github("chColumn/electricShine", upgrade = "never")
}

library(electricShine)
cat("    ✓ electricShine loaded\n\n")

# ---- 2. CHECK NODE.JS ----
cat("[2/6] Checking Node.js installation...\n")

node_check <- tryCatch({
  system("node --version", intern = TRUE)
}, error = function(e) NULL)

npm_check <- tryCatch({
  system("npm --version", intern = TRUE)
}, error = function(e) NULL)

if (is.null(node_check)) {
  stop("Node.js not found! Please install from: https://nodejs.org/")
} else {
  cat(paste0("    ✓ Node.js: ", node_check, "\n"))
  cat(paste0("    ✓ npm: ", npm_check, "\n\n"))
}

# ---- 3. SETUP BUILD CONFIGURATION ----
cat("[3/6] Configuring build settings...\n")

# Get project directory
project_dir <- dirname(getwd())
if (basename(getwd()) != "build") {
  project_dir <- getwd()
}

# Build output directory
build_dir <- file.path(project_dir, "electron_build")
if (!dir.exists(build_dir)) {
  dir.create(build_dir, recursive = TRUE)
}

cat(paste0("    → Project: ", project_dir, "\n"))
cat(paste0("    → Output: ", build_dir, "\n\n"))

# App configuration
app_name <- "EnviroAnalyzer Pro"
app_version <- "3.0.0"
app_description <- "Environmental Quality Assessment Application (QCVN)"
app_author <- "Environmental Engineering Team"

# Required packages for the Shiny app
required_packages <- c(
  "shiny",
  "shinyjs", 
  "bslib",
  "thematic",
  "tidyverse",
  "gt",
  "DT",
  "shinyWidgets",
  "rhandsontable",
  "writexl",
  "scales",
  "readxl",
  "ggplot2",
  "dplyr",
  "tidyr",
  "stringr",
  "lubridate",
  "purrr",
  "tibble",
  "readr",
  "forcats"
)

cat("    ✓ Configuration complete\n\n")

# ---- 4. CREATE APP COPY FOR BUILD ----
cat("[4/6] Preparing app files...\n")

app_build_dir <- file.path(build_dir, "app")
if (dir.exists(app_build_dir)) {
  unlink(app_build_dir, recursive = TRUE)
}
dir.create(app_build_dir, recursive = TRUE)

# Copy required files
files_to_copy <- c("app.R", "constants.R", "functions.R", "visuals.R")
for (f in files_to_copy) {
  src <- file.path(project_dir, f)
  if (file.exists(src)) {
    file.copy(src, file.path(app_build_dir, f), overwrite = TRUE)
    cat(paste0("    ✓ Copied ", f, "\n"))
  } else {
    warning(paste0("File not found: ", f))
  }
}

cat("\n")

# ---- 5. BUILD ELECTRON APP ----
cat("[5/6] Building Electron application...\n")
cat("    ⏳ This may take 10-30 minutes on first run...\n")
cat("    (Downloading R Portable and installing packages)\n\n")

tryCatch({
  electricShine::electrify(
    app_name = app_name,
    short_description = app_description,
    semantic_version = app_version,
    build_path = build_dir,
    mran_date = NULL,  # Use latest CRAN
    cran_like_url = "https://cloud.r-project.org",
    function_name = "run_app",
    git_host = NULL,
    git_repo = NULL,
    local_package_path = app_build_dir,
    package_install_opts = list(
      type = "binary",
      dependencies = TRUE
    ),
    
    # R version (use latest stable)
    r_version = "4.3.2",
    
    # Include packages
    run_build = TRUE,
    
    # Electron options
    nodejs_version = "18.17.0",
    
    # Windows specific
    permission = FALSE,
    
    # Build installer
    build_installer = TRUE
  )
  
  cat("\n    ✓ Electron build complete!\n\n")
  
}, error = function(e) {
  cat(paste0("\n    ✗ Build error: ", conditionMessage(e), "\n"))
  cat("    Try running the alternative method below.\n\n")
})

# ---- 6. RESULTS ----
cat("[6/6] Build Results\n")
cat("════════════════════════════════════════════════════════════════\n")

installer_path <- file.path(build_dir, paste0(gsub(" ", "-", app_name), "-", app_version, "-win.exe"))
if (file.exists(installer_path)) {
  file_size <- round(file.info(installer_path)$size / (1024^2), 2)
  cat(paste0("✓ Installer created: ", installer_path, "\n"))
  cat(paste0("  Size: ", file_size, " MB\n"))
} else {
  cat("⚠ Installer not found at expected location.\n")
  cat("  Check build_dir for output files.\n")
}

cat("\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("Build directory contents:\n")
print(list.files(build_dir, recursive = FALSE))
cat("\n")
