# ============================================================================ #
#                   INSTALL DEPENDENCIES FOR ENVIROANALYZER PRO                #
# ============================================================================ #
# Run this script once before first use to install all required packages
# ============================================================================ #

cat("\n")
cat("========================================\n")
cat("   EnviroAnalyzer Pro - Setup\n")
cat("   Installing Dependencies...\n")
cat("========================================\n\n")

# List of required packages
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
  "readxl"
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste0("[INSTALLING] ", pkg, "...\n"))
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
    if (requireNamespace(pkg, quietly = TRUE)) {
      cat(paste0("[OK] ", pkg, " installed successfully\n"))
    } else {
      cat(paste0("[ERROR] Failed to install ", pkg, "\n"))
    }
  } else {
    cat(paste0("[OK] ", pkg, " already installed\n"))
  }
}

# Install all packages
for (pkg in required_packages) {
  install_if_missing(pkg)
}

cat("\n")
cat("========================================\n")
cat("   Setup Complete!\n")
cat("   Run 'run_app.bat' to start the app\n")
cat("========================================\n\n")
