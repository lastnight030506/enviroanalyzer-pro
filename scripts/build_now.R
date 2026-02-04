# ============================================================================ #
#                   BUILD INSTALLER - QUICK VERSION                            #
# ============================================================================ #

cat("\n╔════════════════════════════════════════════════════════════════╗\n")
cat("║     ENVIROANALYZER PRO - BUILDING WINDOWS INSTALLER           ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

library(RInno)

# Config
app_name <- "EnviroAnalyzer_Pro"
app_version <- "3.0.0"
project_dir <- getwd()

cat("[1/4] Preparing build directories...\n")
build_dir <- file.path(project_dir, "installer_build")
output_dir <- file.path(project_dir, "installer_output")

if (dir.exists(build_dir)) unlink(build_dir, recursive = TRUE)
if (dir.exists(output_dir)) unlink(output_dir, recursive = TRUE)
dir.create(build_dir, recursive = TRUE)
dir.create(output_dir, recursive = TRUE)

# Copy app files
cat("[2/4] Copying application files...\n")
for (f in c("app.R", "constants.R", "functions.R", "visuals.R", "LICENSE")) {
  if (file.exists(f)) {
    file.copy(f, file.path(build_dir, f), overwrite = TRUE)
    cat(paste0("    ✓ ", f, "\n"))
  }
}

# Packages list
pkgs <- c("shiny", "shinyjs", "bslib", "thematic", "tidyverse", 
          "gt", "DT", "shinyWidgets", "rhandsontable", "writexl", 
          "scales", "readxl")

cat("\n[3/4] Creating installer configuration...\n")
cat("    Packages: ", paste(pkgs, collapse = ", "), "\n")

# Create installer config
create_app(
  app_name = app_name,
  app_dir = build_dir,
  dir_out = output_dir,
  app_version = app_version,
  publisher = "Environmental Engineering Team",
  pkgs = pkgs,
  include_R = TRUE,
  R_version = "4.4.2",
  default_dir = "pf",
  privilege = "lowest",
  compression = "lzma2/ultra64"
)

cat("    ✓ Configuration created\n")

cat("\n[4/4] Compiling installer...\n")
cat("    ⏳ Downloading R Portable + packages (15-30 min first time)...\n\n")

tryCatch({
  compile_iss()
  
  cat("\n╔════════════════════════════════════════════════════════════════╗\n")
  cat("║     ✓ BUILD SUCCESSFUL!                                       ║\n")
  cat("╚════════════════════════════════════════════════════════════════╝\n\n")
  
  exe_files <- list.files(output_dir, pattern = "\\.exe$", full.names = TRUE)
  if (length(exe_files) > 0) {
    for (exe in exe_files) {
      size_mb <- round(file.info(exe)$size / (1024^2), 2)
      cat(paste0("📦 ", exe, " (", size_mb, " MB)\n"))
    }
  }
}, error = function(e) {
  cat(paste0("\n✗ Error: ", conditionMessage(e), "\n"))
})
