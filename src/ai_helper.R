# ============================================================================ #
#                      AI HELPER - N8N INTEGRATION                             #
# ============================================================================ #
# Functions để tương tác với n8n AI workflows

library(httr)
library(jsonlite)

# ============================================================================ #
#                         N8N API CALLER                                       #
# ============================================================================ #

#' Gọi n8n webhook/API
#' @param endpoint URL của n8n webhook
#' @param data Dữ liệu gửi đến n8n
#' @param timeout Timeout (giây)
#' @return Response từ n8n hoặc NULL nếu lỗi
call_n8n_api <- function(endpoint, data, timeout = 30) {
  tryCatch({
    if (is.null(endpoint) || endpoint == "") {
      return(list(
        success = FALSE,
        error = "N8N endpoint chưa được cấu hình"
      ))
    }
    
    response <- httr::POST(
      url = endpoint,
      body = data,
      encode = "json",
      httr::timeout(timeout),
      httr::add_headers(
        "Content-Type" = "application/json"
      )
    )
    
    if (httr::status_code(response) == 200) {
      content <- httr::content(response, as = "text", encoding = "UTF-8")
      return(jsonlite::fromJSON(content))
    } else {
      return(list(
        success = FALSE,
        error = paste("HTTP", httr::status_code(response))
      ))
    }
  }, error = function(e) {
    return(list(
      success = FALSE,
      error = as.character(e$message)
    ))
  })
}

# ============================================================================ #
#                         AI ANALYSIS FUNCTIONS                                #
# ============================================================================ #

#' Phân tích kết quả bằng AI
#' @param results Data frame kết quả đánh giá
#' @param qcvn_name Tên QCVN
#' @param endpoint N8N endpoint URL
#' @return Text phân tích từ AI
ai_analyze_results <- function(results, qcvn_name, endpoint) {
  # Tạo summary
  total <- nrow(results)
  pass <- sum(results$Status == "Đạt", na.rm = TRUE)
  warning <- sum(results$Status == "Cảnh báo", na.rm = TRUE)
  fail <- sum(results$Status == "Không đạt", na.rm = TRUE)
  
  # Tìm các thông số vượt ngưỡng
  failed_params <- results[results$Status == "Không đạt", ]
  warning_params <- results[results$Status == "Cảnh báo", ]
  
  # Chuẩn bị data cho AI
  data <- list(
    action = "analyze_results",
    qcvn = qcvn_name,
    summary = list(
      total = total,
      pass = pass,
      warning = warning,
      fail = fail,
      compliance_rate = round(pass / total * 100, 2)
    ),
    failed_parameters = if (nrow(failed_params) > 0) {
      list(
        count = nrow(failed_params),
        details = as.list(failed_params)
      )
    } else NULL,
    warning_parameters = if (nrow(warning_params) > 0) {
      list(
        count = nrow(warning_params),
        details = as.list(warning_params)
      )
    } else NULL
  )
  
  # Gọi n8n AI
  response <- call_n8n_api(endpoint, data)
  
  if (!is.null(response$success) && response$success) {
    return(response$analysis %||% response$message %||% "Đã nhận phân tích từ AI")
  } else {
    return(paste("Lỗi:", response$error))
  }
}

#' Gợi ý hành động khắc phục
#' @param parameter Tên thông số vượt ngưỡng
#' @param value Giá trị đo được
#' @param limit Giới hạn cho phép
#' @param percentage Phần trăm vượt
#' @param endpoint N8N endpoint URL
#' @return Text gợi ý từ AI
ai_suggest_action <- function(parameter, value, limit, percentage, endpoint) {
  data <- list(
    action = "suggest_action",
    parameter = parameter,
    measured_value = value,
    limit = limit,
    exceed_percentage = percentage,
    severity = if (percentage > 200) "critical" else if (percentage > 100) "high" else "moderate"
  )
  
  response <- call_n8n_api(endpoint, data)
  
  if (!is.null(response$success) && response$success) {
    return(response$suggestion %||% response$message %||% "Đã nhận gợi ý từ AI")
  } else {
    return(paste("Lỗi:", response$error))
  }
}

#' Dự đoán xu hướng
#' @param historical_data Data frame dữ liệu lịch sử (phải có cột Date, Parameter, Value)
#' @param parameter Thông số cần dự đoán
#' @param endpoint N8N endpoint URL
#' @return Kết quả dự đoán từ AI
ai_predict_trend <- function(historical_data, parameter, endpoint) {
  # Filter data cho parameter
  param_data <- historical_data[historical_data$Parameter == parameter, ]
  
  if (nrow(param_data) < 3) {
    return(list(
      success = FALSE,
      error = "Cần ít nhất 3 điểm dữ liệu để dự đoán"
    ))
  }
  
  data <- list(
    action = "predict_trend",
    parameter = parameter,
    historical_data = as.list(param_data)
  )
  
  response <- call_n8n_api(endpoint, data)
  
  if (!is.null(response$success) && response$success) {
    return(response)
  } else {
    return(list(
      success = FALSE,
      error = response$error
    ))
  }
}

#' Giải thích kết quả bằng ngôn ngữ tự nhiên
#' @param results Data frame kết quả
#' @param qcvn_name Tên QCVN
#' @param endpoint N8N endpoint URL
#' @return Text giải thích dễ hiểu
ai_explain_results <- function(results, qcvn_name, endpoint) {
  data <- list(
    action = "explain_results",
    qcvn = qcvn_name,
    results = as.list(results),
    language = "vietnamese"
  )
  
  response <- call_n8n_api(endpoint, data)
  
  if (!is.null(response$success) && response$success) {
    return(response$explanation %||% response$message %||% "Đã nhận giải thích từ AI")
  } else {
    return(paste("Lỗi:", response$error))
  }
}

#' Tạo báo cáo tự động bằng AI
#' @param results Data frame kết quả
#' @param qcvn_name Tên QCVN
#' @param sample_info Thông tin mẫu (tên, địa điểm, ngày lấy)
#' @param endpoint N8N endpoint URL
#' @return Báo cáo đầy đủ dạng text/markdown
ai_generate_report <- function(results, qcvn_name, sample_info, endpoint) {
  data <- list(
    action = "generate_report",
    qcvn = qcvn_name,
    results = as.list(results),
    sample_info = sample_info,
    format = "markdown"
  )
  
  response <- call_n8n_api(endpoint, data, timeout = 60)
  
  if (!is.null(response$success) && response$success) {
    return(response$report %||% response$message %||% "Đã tạo báo cáo")
  } else {
    return(paste("Lỗi:", response$error))
  }
}

#' So sánh với dữ liệu lịch sử bằng AI
#' @param current_results Data frame kết quả hiện tại
#' @param historical_results Data frame kết quả lịch sử
#' @param endpoint N8N endpoint URL
#' @return So sánh và nhận xét từ AI
ai_compare_historical <- function(current_results, historical_results, endpoint) {
  data <- list(
    action = "compare_historical",
    current = as.list(current_results),
    historical = as.list(historical_results)
  )
  
  response <- call_n8n_api(endpoint, data)
  
  if (!is.null(response$success) && response$success) {
    return(response$comparison %||% response$message %||% "Đã so sánh")
  } else {
    return(paste("Lỗi:", response$error))
  }
}

#' Kiểm tra kết nối n8n
#' @param endpoint N8N endpoint URL
#' @return TRUE nếu kết nối OK, FALSE nếu lỗi
test_n8n_connection <- function(endpoint) {
  data <- list(
    action = "ping",
    message = "Test connection from EnviroAnalyzer Pro"
  )
  
  response <- call_n8n_api(endpoint, data, timeout = 10)
  
  return(!is.null(response$success) && response$success)
}

# ============================================================================ #
#                              HELPER                                          #
# ============================================================================ #

`%||%` <- function(a, b) if (is.null(a)) b else a
