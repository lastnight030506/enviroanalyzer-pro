# ============================================================================ #
#                   N8N CONFIGURATION - AI SERVICE                             #
# ============================================================================ #
# Cấu hình n8n endpoint cho AI features
# Người phát triển: Thay đổi DEFAULT_N8N_ENDPOINT bên dưới

# ============================================================================ #
#                         DEFAULT N8N ENDPOINT                                 #
# ============================================================================ #

# TODO: Thay đổi URL này thành webhook n8n của bạn
# Ví dụ: "https://your-n8n-instance.com/webhook/enviroanalyzer"
DEFAULT_N8N_ENDPOINT <- ""

# Nếu để trống, AI features sẽ bị disable
# Người dùng có thể override trong Settings nếu muốn dùng n8n riêng

# ============================================================================ #
#                         CONFIGURATION OPTIONS                                #
# ============================================================================ #

N8N_CONFIG <- list(
  # Default endpoint (from above)
  default_endpoint = DEFAULT_N8N_ENDPOINT,
  
  # Allow user to override endpoint in Settings?
  allow_custom_endpoint = TRUE,
  
  # Auto-enable AI on startup if endpoint configured?
  auto_enable = TRUE,
  
  # Timeout for AI requests (seconds)
  timeout = 30,
  
  # Retry on failure?
  retry_on_fail = TRUE,
  max_retries = 2,
  
  # Show "Powered by n8n" badge?
  show_badge = TRUE
)

# ============================================================================ #
#                         HELPER FUNCTIONS                                     #
# ============================================================================ #

#' Check if AI is available
is_ai_available <- function() {
  return(!is.null(DEFAULT_N8N_ENDPOINT) && DEFAULT_N8N_ENDPOINT != "")
}

#' Get effective n8n endpoint (default or user override)
get_n8n_endpoint <- function(user_override = NULL) {
  if (!is.null(user_override) && user_override != "") {
    return(user_override)
  }
  return(DEFAULT_N8N_ENDPOINT)
}

#' Show AI status message
get_ai_status_message <- function() {
  if (is_ai_available()) {
    return("✅ AI Assistant is ready to use!")
  } else {
    return("⚠️ AI features are not configured. Contact developer for setup.")
  }
}
