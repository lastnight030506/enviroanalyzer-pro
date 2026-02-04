# ============================================================================ #
#                         CONFIG MANAGER - USER SETTINGS                       #
# ============================================================================ #
# Quản lý cài đặt người dùng (lưu vào file JSON)
# ============================================================================ #

library(jsonlite)

# Đường dẫn file config
CONFIG_FILE <- "config/user_config.json"

# Cài đặt mặc định
DEFAULT_CONFIG <- list(
  app = list(
    version = "3.1",
    theme = "light",  # light, dark, auto
    language = "vi"
  ),
  theme = list(
    mode = "light",
    accent_color = "#1565C0",
    success_color = "#10b981",
    warning_color = "#f59e0b",
    danger_color = "#ef4444",
    background = "#ffffff",
    text_primary = "#1e293b",
    text_secondary = "#64748b"
  ),
  ai = list(
    enabled = FALSE,
    n8n_endpoint = "",
    auto_analyze = FALSE,
    show_suggestions = TRUE
  ),
  display = list(
    show_warnings = TRUE,
    decimal_places = 2,
    table_page_length = 10,
    chart_theme = "modern"
  ),
  qcvn = list(
    last_selected = "",
    auto_load_custom = TRUE,
    show_all_parameters = FALSE
  ),
  export = list(
    default_format = "xlsx",
    include_charts = TRUE,
    auto_open_after_export = TRUE
  )
)

#' Load user config from file
#' @return List of config settings
load_user_config <- function() {
  tryCatch({
    if (file.exists(CONFIG_FILE)) {
      config <- fromJSON(CONFIG_FILE, simplifyVector = FALSE)
      cat("✓ Loaded user config from", CONFIG_FILE, "\n")
      return(config)
    } else {
      cat("→ No config file found, using defaults\n")
      return(DEFAULT_CONFIG)
    }
  }, error = function(e) {
    cat("✗ Error loading config:", e$message, "\n")
    cat("→ Using default config\n")
    return(DEFAULT_CONFIG)
  })
}

#' Save user config to file
#' @param config List of config settings
#' @return TRUE if successful, FALSE otherwise
save_user_config <- function(config) {
  tryCatch({
    json_str <- toJSON(config, pretty = TRUE, auto_unbox = TRUE)
    write(json_str, file = CONFIG_FILE)
    cat("✓ Saved user config to", CONFIG_FILE, "\n")
    return(TRUE)
  }, error = function(e) {
    cat("✗ Error saving config:", e$message, "\n")
    return(FALSE)
  })
}

#' Get specific config value
#' @param config Config list
#' @param path Vector of keys (e.g., c("ai", "enabled"))
#' @param default Default value if not found
#' @return Config value or default
get_config_value <- function(config, path, default = NULL) {
  tryCatch({
    value <- config
    for (key in path) {
      value <- value[[key]]
      if (is.null(value)) return(default)
    }
    return(value)
  }, error = function(e) {
    return(default)
  })
}

#' Set specific config value
#' @param config Config list
#' @param path Vector of keys
#' @param value New value
#' @return Updated config
set_config_value <- function(config, path, value) {
  tryCatch({
    if (length(path) == 1) {
      config[[path[1]]] <- value
    } else if (length(path) == 2) {
      if (is.null(config[[path[1]]])) config[[path[1]]] <- list()
      config[[path[1]]][[path[2]]] <- value
    } else if (length(path) == 3) {
      if (is.null(config[[path[1]]])) config[[path[1]]] <- list()
      if (is.null(config[[path[1]]][[path[2]]])) config[[path[1]]][[path[2]]] <- list()
      config[[path[1]]][[path[2]]][[path[3]]] <- value
    }
    return(config)
  }, error = function(e) {
    cat("✗ Error setting config value:", e$message, "\n")
    return(config)
  })
}

#' Reset config to defaults
#' @return Default config
reset_user_config <- function() {
  cat("→ Resetting config to defaults\n")
  return(DEFAULT_CONFIG)
}

#' Merge configs (update existing with new values)
#' @param existing Existing config
#' @param new New values to merge
#' @return Merged config
merge_configs <- function(existing, new) {
  tryCatch({
    # Simple recursive merge
    for (name in names(new)) {
      if (is.list(new[[name]]) && is.list(existing[[name]])) {
        existing[[name]] <- merge_configs(existing[[name]], new[[name]])
      } else {
        existing[[name]] <- new[[name]]
      }
    }
    return(existing)
  }, error = function(e) {
    cat("✗ Error merging configs:", e$message, "\n")
    return(existing)
  })
}

cat("✓ Loaded config_manager.R - User settings management\n")
