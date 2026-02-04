# ============================================================================ #
#          ĐỌC EXCEL TEMPLATE VÀ CHUYỂN THÀNH JSON QCVN                        #
# ============================================================================ #

library(readxl)
library(jsonlite)

#' Đọc Excel template và chuyển thành QCVN JSON
#' @param excel_file Đường dẫn file Excel
#' @return List object QCVN hoặc NULL nếu lỗi
excel_to_qcvn_json <- function(excel_file) {
  
  tryCatch({
    # Đọc thông tin chung
    info_df <- read_excel(excel_file, sheet = "Thong_Tin")
    
    # Đọc cột
    columns_df <- read_excel(excel_file, sheet = "Cot")
    columns_df <- columns_df[!is.na(columns_df$Column_ID) & columns_df$Column_ID != "", ]
    
    # Đọc thông số
    params_df <- read_excel(excel_file, sheet = "Thong_So")
    params_df <- params_df[!is.na(params_df$Parameter) & params_df$Parameter != "", ]
    
    # Tạo QCVN object
    qcvn <- list()
    
    # Thông tin cơ bản
    for (i in 1:nrow(info_df)) {
      field <- info_df$Field[i]
      value <- info_df$Value[i]
      qcvn[[field]] <- value
    }
    
    # Columns
    qcvn$columns <- as.list(columns_df$Column_ID)
    
    # Column descriptions
    qcvn$column_descriptions <- setNames(
      as.list(columns_df$Description),
      columns_df$Column_ID
    )
    
    # Parameters
    qcvn$parameters <- list()
    
    for (i in 1:nrow(params_df)) {
      param_name <- params_df$Parameter[i]
      param_type <- params_df$Type[i]
      
      param_values <- list()
      
      # Lấy giá trị cho từng cột
      for (col_id in columns_df$Column_ID) {
        min_col <- paste0(col_id, "_Min")
        max_col <- paste0(col_id, "_Max")
        
        if (param_type == "range") {
          # Range cần [min, max]
          min_val <- if (min_col %in% names(params_df)) params_df[[min_col]][i] else NA
          max_val <- if (max_col %in% names(params_df)) params_df[[max_col]][i] else NA
          
          if (!is.na(min_val) && !is.na(max_val)) {
            param_values[[col_id]] <- c(min_val, max_val)
          }
        } else {
          # max hoặc min chỉ cần 1 giá trị
          val <- if (max_col %in% names(params_df)) params_df[[max_col]][i] else NA
          
          if (!is.na(val)) {
            param_values[[col_id]] <- val
          }
        }
      }
      
      param_values$type <- param_type
      
      # Thêm description nếu có
      if ("Description" %in% names(params_df) && !is.na(params_df$Description[i])) {
        param_values$description <- params_df$Description[i]
      }
      
      qcvn$parameters[[param_name]] <- param_values
    }
    
    return(qcvn)
    
  }, error = function(e) {
    warning(paste("Lỗi khi đọc Excel:", e$message))
    return(NULL)
  })
}

#' Chuyển Excel sang JSON file
#' @param excel_file File Excel input
#' @param json_file File JSON output
convert_excel_to_json <- function(excel_file, json_file) {
  qcvn <- excel_to_qcvn_json(excel_file)
  
  if (is.null(qcvn)) {
    stop("Không thể đọc Excel file")
  }
  
  # Ghi JSON
  json_str <- toJSON(qcvn, pretty = TRUE, auto_unbox = TRUE)
  writeLines(json_str, json_file)
  
  cat("✓ Đã chuyển đổi:", excel_file, "->", json_file, "\n")
  return(json_file)
}

# Test nếu script được execute trực tiếp
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) >= 1) {
    excel_file <- args[1]
    json_file <- if (length(args) >= 2) args[2] else sub("\\.xlsx$", ".json", excel_file)
    convert_excel_to_json(excel_file, json_file)
  } else {
    cat("Usage: Rscript excel_to_json.R <excel_file> [json_file]\n")
  }
}
