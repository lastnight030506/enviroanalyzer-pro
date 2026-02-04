# ============================================================================ #
#                   API SERVER LAUNCHER FOR N8N                                #
# ============================================================================ #
# Khởi chạy REST API server cho n8n integration

library(plumber)

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║     ENVIROANALYZER PRO - API SERVER FOR N8N                ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# Tạo plumber API
api <- plumber::plumb("api.R")

# Cấu hình CORS để n8n có thể gọi API
api$filter("cors", function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
})

# Khởi chạy API server
port <- 3839
host <- "0.0.0.0"  # Cho phép truy cập từ bên ngoài

cat(paste0("Starting API server...\n"))
cat(paste0("  → API endpoint: http://localhost:", port, "\n"))
cat(paste0("  → Health check: http://localhost:", port, "/health\n"))
cat(paste0("  → API docs: http://localhost:", port, "/__docs__/\n"))
cat(paste0("  → Press Ctrl+C to stop\n\n"))

api$run(host = host, port = port)
