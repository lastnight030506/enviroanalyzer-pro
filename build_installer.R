# ============================================================================ #
#                   BUILD INSTALLER FOR ENVIROANALYZER PRO                     #
# ============================================================================ #
# This script creates a Windows installer (.exe) using RInno and Inno Setup
# Requirements:
#   1. Inno Setup installed: https://jrsoftware.org/isdl.php
#   2. RInno package
# ============================================================================ #

# Install RInno if not available
if (!requireNamespace("RInno", quietly = TRUE)) {
  install.packages("RInno", repos = "https://cloud.r-project.org")
}

library(RInno)

# Set app directory
app_dir <- getwd()

# Create installer
create_app(
  app_name = "EnviroAnalyzer Pro",
  app_dir = app_dir,
  dir_out = file.path(app_dir, "installer"),
  
  # App info
  app_version = "3.0.0",
  publisher = "EnviroAnalyzer Team",
  app_icon = NULL,  # Add custom icon path if available
  
  # Include R packages
  pkgs = c(
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
  ),
  
  # Additional settings
  include_R = TRUE,       # Include portable R
  R_version = "4.5.2",    # R version to include
  
  # Installer options
  default_dir = "userdocs",
  privilege = "lowest",
  
  # License
  license_file = NULL,
  
  # Info before/after install
  info_before = NULL,
  info_after = NULL
)

# Compile the installer (requires Inno Setup)
compile_iss()

cat("\n")
cat("========================================\n")
cat("   Installer Created Successfully!\n")
cat("========================================\n")
cat("\n")
cat("Output: installer/EnviroAnalyzer Pro.exe\n")
cat("\n")
