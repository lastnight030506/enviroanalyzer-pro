# ============================================================================ #
#           ALTERNATIVE BUILD - USING RINNO + INNO SETUP                       #
# ============================================================================ #
# Creates Windows installer with bundled R Portable
# More reliable than electricShine for complex apps
#
# Requirements:
#   - Inno Setup 6: https://jrsoftware.org/isdl.php
# ============================================================================ #

cat("\n")
cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║     ENVIROANALYZER PRO - RINNO INSTALLER BUILD                ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

# ---- 1. INSTALL DEPENDENCIES ----
cat("[1/7] Installing build dependencies...\n")

required_build_pkgs <- c("RInno", "installr", "remotes")
for (pkg in required_build_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste0("    → Installing ", pkg, "...\n"))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

library(RInno)
cat("    ✓ RInno loaded\n\n")

# ---- 2. CHECK INNO SETUP ----
cat("[2/7] Checking Inno Setup...\n")

inno_paths <- c(
  "C:/Program Files (x86)/Inno Setup 6/ISCC.exe",
  "C:/Program Files/Inno Setup 6/ISCC.exe"
)

inno_found <- FALSE
for (path in inno_paths) {
  if (file.exists(path)) {
    inno_found <- TRUE
    cat(paste0("    ✓ Found: ", path, "\n\n"))
    break
  }
}

if (!inno_found) {
  cat("    ⚠ Inno Setup not found!\n")
  cat("    → Download from: https://jrsoftware.org/isdl.php\n")
  cat("    → Install to default location\n\n")
  
  # Offer to install automatically
  response <- readline("Install Inno Setup now? (y/n): ")
  if (tolower(response) == "y") {
    installr::install.inno()
  } else {
    stop("Inno Setup is required to continue.")
  }
}

# ---- 3. SETUP DIRECTORIES ----
cat("[3/7] Setting up build directories...\n")

# Project paths
app_dir <- getwd()
build_dir <- file.path(app_dir, "installer_build")
output_dir <- file.path(app_dir, "installer_output")

# Clean and create directories
if (dir.exists(build_dir)) unlink(build_dir, recursive = TRUE)
if (dir.exists(output_dir)) unlink(output_dir, recursive = TRUE)
dir.create(build_dir, recursive = TRUE)
dir.create(output_dir, recursive = TRUE)

cat(paste0("    → Build: ", build_dir, "\n"))
cat(paste0("    → Output: ", output_dir, "\n\n"))

# ---- 4. PREPARE APP FILES ----
cat("[4/7] Preparing application files...\n")

# Copy app files to build directory
app_files <- c("app.R", "constants.R", "functions.R", "visuals.R")
for (f in app_files) {
  if (file.exists(f)) {
    file.copy(f, file.path(build_dir, f), overwrite = TRUE)
    cat(paste0("    ✓ ", f, "\n"))
  }
}

# Copy LICENSE if exists
if (file.exists("LICENSE")) {
  file.copy("LICENSE", file.path(build_dir, "LICENSE"), overwrite = TRUE)
}

cat("\n")

# ---- 5. CONFIGURE INSTALLER ----
cat("[5/7] Configuring installer...\n")

# Package list for the app
app_packages <- c(
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
  "readxl"
)

# Create RInno configuration
create_app(
  app_name = "EnviroAnalyzer Pro",
  app_dir = build_dir,
  dir_out = output_dir,
  
  # App info
  app_version = "3.0.0",
  publisher = "Environmental Engineering Team",
  
  # Include portable R
  include_R = TRUE,
  R_version = "4.3.2",
  
  # Packages to install
  pkgs = app_packages,
  
  # Installation settings
  default_dir = "pf",  # Program Files
  privilege = "lowest",
  
  # UI settings
  info_before = "",
  info_after = "EnviroAnalyzer Pro has been installed successfully!\n\nLaunch from Start Menu or Desktop shortcut.",
  
  # Installer options
  compression = "lzma2/ultra64"
)

cat("    ✓ Configuration created\n\n")

# ---- 6. CREATE LAUNCHER SCRIPT ----
cat("[6/7] Creating launcher script...\n")

# Create a launcher that runs the Shiny app
launcher_content <- '
# EnviroAnalyzer Pro Launcher
# This script is called by the shortcut

# Set working directory to app location
app_dir <- dirname(sys.frame(1)$ofile)
if (is.null(app_dir) || app_dir == "") {
  app_dir <- getwd()
}
setwd(app_dir)

# Load and run app
message("Starting EnviroAnalyzer Pro...")
shiny::runApp(
  appDir = ".",
  port = 3838,
  host = "127.0.0.1", 
  launch.browser = TRUE
)
'

writeLines(launcher_content, file.path(build_dir, "run_app.R"))
cat("    ✓ Launcher script created\n\n")

# ---- 7. COMPILE INSTALLER ----
cat("[7/7] Compiling installer...\n")
cat("    ⏳ This may take 15-30 minutes (downloading R Portable)...\n\n")

tryCatch({
  compile_iss()
  
  cat("\n")
  cat("╔════════════════════════════════════════════════════════════════╗\n")
  cat("║     ✓ BUILD SUCCESSFUL!                                       ║\n")
  cat("╚════════════════════════════════════════════════════════════════╝\n\n")
  
  # Find the output installer
  exe_files <- list.files(output_dir, pattern = "\\.exe$", full.names = TRUE)
  if (length(exe_files) > 0) {
    for (exe in exe_files) {
      size_mb <- round(file.info(exe)$size / (1024^2), 2)
      cat(paste0("📦 Installer: ", exe, "\n"))
      cat(paste0("   Size: ", size_mb, " MB\n\n"))
    }
  }
  
}, error = function(e) {
  cat(paste0("\n✗ Build failed: ", conditionMessage(e), "\n"))
  cat("\nTroubleshooting:\n")
  cat("1. Ensure Inno Setup is installed\n")
  cat("2. Check internet connection (for R Portable download)\n")
  cat("3. Run as Administrator if permission issues\n")
})

cat("════════════════════════════════════════════════════════════════\n")
