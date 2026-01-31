# ============================================================================ #
#                     RUN.R - KHỞI CHẠY ENVIROANALYZER PRO                      #
# ============================================================================ #
# Chạy file này để khởi động ứng dụng: Rscript run.R
# ============================================================================ #

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║          ENVIROANALYZER PRO v3.0                           ║\n")
cat("║     Environmental Quality Assessment (QCVN)                ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# ---- 1. KIỂM TRA & CÀI ĐẶT PACKAGES ----
required_packages <- c(
  "shiny", "shinyjs", "bslib", "thematic",
  "tidyverse", "gt", "DT", "shinyWidgets",
  "rhandsontable", "writexl", "scales", "readxl"
)

cat("[1/3] Kiểm tra packages...\n")

missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat(paste0("    → Cài đặt: ", paste(missing_packages, collapse = ", "), "\n"))
  install.packages(missing_packages, repos = "https://cloud.r-project.org", quiet = TRUE)
  cat("    ✓ Đã cài đặt xong\n")
} else {
  cat("    ✓ Tất cả packages đã sẵn sàng\n")
}

# ---- 2. THIẾT LẬP WORKING DIRECTORY ----
cat("\n[2/3] Thiết lập môi trường...\n")

# Tìm thư mục chứa app
script_dir <- tryCatch({
  dirname(sys.frame(1)$ofile)
}, error = function(e) {
  getwd()
})

if (is.null(script_dir) || script_dir == "" || script_dir == ".") {
  script_dir <- getwd()
}

setwd(script_dir)
cat(paste0("    ✓ Working directory: ", script_dir, "\n"))

# ---- 3. KHỞI CHẠY ỨNG DỤNG ----
cat("\n[3/3] Khởi động Shiny app...\n")
cat("    → Mở trình duyệt tại: http://127.0.0.1:3838\n")
cat("    → Nhấn Ctrl+C để dừng\n\n")

shiny::runApp(
  appDir = script_dir,
  port = 3838,
  host = "127.0.0.1",
  launch.browser = TRUE
)
