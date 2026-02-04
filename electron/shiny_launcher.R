# ============================================================================ #
#                    ELECTRON SHINY LAUNCHER                                    #
# ============================================================================ #
# This script is called by Electron to start the Shiny server

args <- commandArgs(trailingOnly = TRUE)

# Get app directory and port from arguments
app_dir <- if (length(args) >= 1) args[1] else getwd()
port <- if (length(args) >= 2) as.integer(args[2]) else 3838L

# Set working directory
setwd(app_dir)

# Set working directory
setwd(app_dir)

# Ensure source files are accessible
if (file.exists("src/constants.R")) {
  cat("✓ Found src/ directory\n")
} else if (file.exists("constants.R")) {
  cat("✓ Using root directory\n")
} else {
  cat("✗ Warning: Source files may not be found\n")
}

cat("Starting Shiny server...\n")
cat(paste0("App directory: ", app_dir, "\n"))
cat(paste0("Port: ", port, "\n"))

# Suppress startup messages
suppressPackageStartupMessages({
  library(shiny)
})

# Run app
shiny::runApp(
  appDir = app_dir,
  port = port,
  host = "127.0.0.1",
  launch.browser = FALSE
)
