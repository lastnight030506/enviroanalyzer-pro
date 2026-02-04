# ============================================================================ #
#     COMPLETE ELECTRON BUILD - ENVIROANALYZER PRO (STANDALONE)                #
# ============================================================================ #
# This script creates a fully standalone Windows app using electricShine
# The output is a .exe that runs without any R installation
#
# PREREQUISITES:
#   1. Node.js LTS: https://nodejs.org/
#   2. npm (included with Node.js)
#   3. ~2GB disk space for build
#   4. Internet connection (first build downloads R Portable ~200MB)
# ============================================================================ #

# ---- CONFIGURATION ----
APP_CONFIG <- list(
  name = "EnviroAnalyzer Pro",
  version = "3.0.0",
  description = "Environmental Quality Assessment Application (QCVN Standards)",
  author = "Environmental Engineering Team",
  
  # R version to bundle (use stable version)
  r_version = "4.3.2",
  
  # Node.js version for Electron
  nodejs_version = "18.17.0",
  
  # Required packages
  packages = c(
    # Core Shiny
    "shiny",
    "shinyjs",
    "bslib",
    "thematic",
    "shinyWidgets",
    "rhandsontable",
    
    # Data manipulation
    "dplyr",
    "tidyr",
    "stringr",
    "lubridate",
    "purrr",
    "tibble",
    "readr",
    "forcats",
    
    # Visualization
    "ggplot2",
    "scales",
    "gt",
    "DT",
    
    # IO
    "readxl",
    "writexl"
  )
)

# ---- START BUILD ----
cat("\n")
cat("╔═══════════════════════════════════════════════════════════════════╗\n")
cat("║     ENVIROANALYZER PRO - ELECTRON STANDALONE BUILD               ║\n")
cat("╠═══════════════════════════════════════════════════════════════════╣\n")
cat(sprintf("║  App: %-58s║\n", APP_CONFIG$name))
cat(sprintf("║  Version: %-54s║\n", APP_CONFIG$version))
cat(sprintf("║  R Version: %-52s║\n", APP_CONFIG$r_version))
cat("╚═══════════════════════════════════════════════════════════════════╝\n\n")

# ---- STEP 1: CHECK SYSTEM REQUIREMENTS ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[1/8] Checking system requirements...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

# Check Node.js
node_version <- tryCatch({
  trimws(system("node --version", intern = TRUE))
}, error = function(e) NULL, warning = function(w) NULL)

npm_version <- tryCatch({
  trimws(system("npm --version", intern = TRUE))
}, error = function(e) NULL, warning = function(w) NULL)

if (is.null(node_version) || length(node_version) == 0) {
  cat("✗ Node.js NOT FOUND!\n\n")
  cat("Please install Node.js LTS from: https://nodejs.org/\n")
  cat("After installation, restart R and run this script again.\n\n")
  stop("Node.js is required for Electron builds.")
} else {
  cat(sprintf("✓ Node.js: %s\n", node_version))
  cat(sprintf("✓ npm: %s\n", npm_version))
}

# Check R version
cat(sprintf("✓ R: %s\n", R.version.string))
cat("\n")

# ---- STEP 2: INSTALL ELECTRICSHINE ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[2/8] Installing electricShine package...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cloud.r-project.org", quiet = TRUE)
}

if (!requireNamespace("electricShine", quietly = TRUE)) {
  cat("→ Installing electricShine from GitHub...\n")
  remotes::install_github("chColumn/electricShine", upgrade = "never", quiet = TRUE)
}

library(electricShine)
cat("✓ electricShine loaded successfully\n\n")

# ---- STEP 3: SETUP BUILD DIRECTORIES ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[3/8] Setting up build directories...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

# Get project root
project_dir <- getwd()
if (basename(project_dir) == "build") {
  project_dir <- dirname(project_dir)
}

build_path <- file.path(project_dir, "electron_output")
temp_app_path <- file.path(build_path, "app_source")

# Clean previous builds
if (dir.exists(build_path)) {
  cat("→ Cleaning previous build...\n")
  unlink(build_path, recursive = TRUE)
}

dir.create(temp_app_path, recursive = TRUE)
cat(sprintf("✓ Build directory: %s\n", build_path))
cat(sprintf("✓ App source: %s\n\n", temp_app_path))

# ---- STEP 4: PREPARE APP SOURCE ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[4/8] Preparing application source...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

# Files to include in the build
source_files <- c("app.R", "constants.R", "functions.R", "visuals.R")

for (f in source_files) {
  src <- file.path(project_dir, f)
  dst <- file.path(temp_app_path, f)
  
  if (file.exists(src)) {
    file.copy(src, dst, overwrite = TRUE)
    cat(sprintf("✓ Copied: %s\n", f))
  } else {
    cat(sprintf("⚠ Missing: %s\n", f))
  }
}

# Copy LICENSE if exists
if (file.exists(file.path(project_dir, "LICENSE"))) {
  file.copy(file.path(project_dir, "LICENSE"), 
            file.path(temp_app_path, "LICENSE"), overwrite = TRUE)
  cat("✓ Copied: LICENSE\n")
}

cat("\n")

# ---- STEP 5: CREATE PACKAGE WRAPPER ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[5/8] Creating package wrapper for electricShine...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

# electricShine needs the app as an R package
# Create a minimal package structure

# Create R folder
r_dir <- file.path(temp_app_path, "R")
dir.create(r_dir, showWarnings = FALSE)

# Move source files to R folder
for (f in source_files) {
  src <- file.path(temp_app_path, f)
  dst <- file.path(r_dir, f)
  if (file.exists(src)) {
    file.rename(src, dst)
  }
}

# Create run_app function
run_app_content <- sprintf('
#\' Run EnviroAnalyzer Pro
#\'
#\' @param port Port number for Shiny app
#\' @param host Host address
#\' @export
run_app <- function(port = 3838, host = "127.0.0.1") {
  # Source app files
  app_dir <- system.file("app", package = "%s")
  if (app_dir == "") {
    app_dir <- file.path(getwd(), "R")
  }
  
  # Load dependencies
  source(file.path(app_dir, "constants.R"), local = TRUE)
  source(file.path(app_dir, "functions.R"), local = TRUE)
  source(file.path(app_dir, "visuals.R"), local = TRUE)
  
  # Run the Shiny app
  shiny::runApp(
    appDir = file.path(app_dir, "app.R"),
    port = port,
    host = host,
    launch.browser = FALSE
  )
}
', gsub(" ", "", APP_CONFIG$name))

writeLines(run_app_content, file.path(r_dir, "run_app.R"))
cat("✓ Created run_app.R\n")

# Create DESCRIPTION file
description_content <- sprintf('
Package: %s
Title: %s
Version: %s
Author: %s
Description: %s
License: MIT
Encoding: UTF-8
Imports: %s
',
  gsub(" ", "", APP_CONFIG$name),
  APP_CONFIG$name,
  APP_CONFIG$version,
  APP_CONFIG$author,
  APP_CONFIG$description,
  paste(APP_CONFIG$packages, collapse = ", ")
)

writeLines(description_content, file.path(temp_app_path, "DESCRIPTION"))
cat("✓ Created DESCRIPTION\n")

# Create NAMESPACE
namespace_content <- 'export(run_app)'
writeLines(namespace_content, file.path(temp_app_path, "NAMESPACE"))
cat("✓ Created NAMESPACE\n\n")

# ---- STEP 6: BUILD ELECTRON APP ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[6/8] Building Electron application...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

cat("⏳ This process takes 15-45 minutes on first run.\n")
cat("   - Downloading R Portable (~200MB)\n")
cat("   - Installing R packages\n")
cat("   - Building Electron wrapper\n")
cat("   - Creating installer\n\n")
cat("Please wait...\n\n")

build_start <- Sys.time()

build_result <- tryCatch({
  
  electricShine::electrify(
    app_name = gsub(" ", "_", APP_CONFIG$name),
    short_description = APP_CONFIG$description,
    semantic_version = APP_CONFIG$version,
    build_path = build_path,
    
    # R configuration
    cran_like_url = "https://cloud.r-project.org",
    r_version = APP_CONFIG$r_version,
    
    # App configuration  
    function_name = "run_app",
    local_package_path = temp_app_path,
    
    # Build options
    run_build = TRUE,
    nodejs_version = APP_CONFIG$nodejs_version,
    
    # Create installer
    build_installer = TRUE
  )
  
  TRUE
  
}, error = function(e) {
  cat(sprintf("\n✗ Build error: %s\n", conditionMessage(e)))
  FALSE
})

build_time <- round(difftime(Sys.time(), build_start, units = "mins"), 1)

if (build_result) {
  cat(sprintf("\n✓ Build completed in %s minutes\n\n", build_time))
}

# ---- STEP 7: LOCATE OUTPUT ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[7/8] Locating build output...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

# Find installer files
exe_files <- list.files(build_path, pattern = "\\.exe$", 
                        full.names = TRUE, recursive = TRUE)

if (length(exe_files) > 0) {
  cat("Found installers:\n")
  for (exe in exe_files) {
    size_mb <- round(file.info(exe)$size / (1024^2), 2)
    cat(sprintf("  📦 %s (%s MB)\n", basename(exe), size_mb))
  }
} else {
  cat("⚠ No .exe installer found\n")
  cat("Check build_path for output:\n")
  cat(sprintf("  %s\n", build_path))
}

cat("\n")

# ---- STEP 8: SUMMARY ----
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("[8/8] Build Summary\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

if (build_result && length(exe_files) > 0) {
  cat("╔═══════════════════════════════════════════════════════════════════╗\n")
  cat("║                    ✓ BUILD SUCCESSFUL!                           ║\n")
  cat("╚═══════════════════════════════════════════════════════════════════╝\n\n")
  
  cat(sprintf("App: %s v%s\n", APP_CONFIG$name, APP_CONFIG$version))
  cat(sprintf("Build time: %s minutes\n", build_time))
  cat(sprintf("Output directory: %s\n\n", build_path))
  
  cat("Installer location:\n")
  for (exe in exe_files) {
    cat(sprintf("  → %s\n", exe))
  }
  
  cat("\n")
  cat("Next steps:\n")
  cat("  1. Test the installer on a clean Windows machine\n")
  cat("  2. The app runs without any R installation\n")
  cat("  3. Distribute the .exe installer to users\n")
  
} else {
  cat("╔═══════════════════════════════════════════════════════════════════╗\n")
  cat("║                    ✗ BUILD FAILED                                ║\n")
  cat("╚═══════════════════════════════════════════════════════════════════╝\n\n")
  
  cat("Troubleshooting:\n")
  cat("  1. Ensure Node.js is installed: https://nodejs.org/\n")
  cat("  2. Check internet connection\n")
  cat("  3. Try running as Administrator\n")
  cat("  4. Check build log in: ", build_path, "\n")
  cat("\n")
  cat("Alternative: Use RInno build (build_rinno_installer.R)\n")
}

cat("\n")
