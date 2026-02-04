# ============================================================================ #
#                     FUNCTIONS.R - XỬ LÝ DỮ LIỆU MÔI TRƯỜNG                   #
# ============================================================================ #
# Tác giả: Environmental Engineering Student
# Mô tả: Logic xử lý dữ liệu, kiểm tra tuân thủ, chuyển đổi đơn vị
# ============================================================================ #

library(tidyverse)
library(lubridate)

# ---- 1. KIỂM TRA TUÂN THỦ QCVN ----

#' Kiểm tra tuân thủ cho một giá trị đơn lẻ
#' @param value Giá trị đo được
#' @param threshold Ngưỡng giới hạn (số đơn hoặc vector 2 phần tử cho range)
#' @param type Loại ngưỡng: "min", "max", "range"
#' @param safety_margin Ngưỡng cảnh báo sớm (% của limit)
#' @return List chứa status, percent_of_limit, message
check_single_compliance <- function(value, threshold, type = "max", safety_margin = 90) {
  if (is.na(value) || is.null(threshold) || all(is.na(threshold))) {
    return(list(
      status = "Không áp dụng",
      percent_of_limit = NA,
      message = "Không có dữ liệu hoặc ngưỡng",
      color = "gray"
    ))
  }
  
  if (type == "range") {
    # Kiểm tra trong khoảng [min, max]
    lower <- threshold[1]
    upper <- threshold[2]
    
    if (value < lower) {
      percent <- (lower - value) / lower * 100
      return(list(
        status = "Không đạt",
        percent_of_limit = -percent,
        message = sprintf("Dưới ngưỡng tối thiểu (%.2f < %.2f)", value, lower),
        color = "#C62828"
      ))
    } else if (value > upper) {
      percent <- value / upper * 100
      return(list(
        status = "Không đạt",
        percent_of_limit = percent,
        message = sprintf("Vượt ngưỡng tối đa (%.2f > %.2f)", value, upper),
        color = "#C62828"
      ))
    } else {
      # Tính % nằm trong khoảng
      range_size <- upper - lower
      position <- (value - lower) / range_size * 100
      return(list(
        status = "Đạt",
        percent_of_limit = position,
        message = sprintf("Trong khoảng cho phép [%.2f - %.2f]", lower, upper),
        color = "#2E7D32"
      ))
    }
  } else if (type == "min") {
    # Giá trị phải >= threshold
    if (value >= threshold) {
      percent <- threshold / value * 100
      return(list(
        status = "Đạt",
        percent_of_limit = percent,
        message = sprintf("Đạt ngưỡng tối thiểu (%.2f >= %.2f)", value, threshold),
        color = "#2E7D32"
      ))
    } else {
      percent <- value / threshold * 100
      if (percent >= safety_margin) {
        return(list(
          status = "Cảnh báo",
          percent_of_limit = percent,
          message = sprintf("Gần ngưỡng tối thiểu (%.2f/%.2f = %.1f%%)", value, threshold, percent),
          color = "#F57C00"
        ))
      }
      return(list(
        status = "Không đạt",
        percent_of_limit = percent,
        message = sprintf("Dưới ngưỡng tối thiểu (%.2f < %.2f)", value, threshold),
        color = "#C62828"
      ))
    }
  } else {
    # type == "max": Giá trị phải <= threshold
    percent <- value / threshold * 100
    
    if (value > threshold) {
      return(list(
        status = "Không đạt",
        percent_of_limit = percent,
        message = sprintf("Vượt ngưỡng (%.2f > %.2f = %.1f%%)", value, threshold, percent),
        color = "#C62828"
      ))
    } else if (percent >= safety_margin) {
      return(list(
        status = "Cảnh báo",
        percent_of_limit = percent,
        message = sprintf("Gần ngưỡng (%.2f/%.2f = %.1f%%)", value, threshold, percent),
        color = "#F57C00"
      ))
    } else {
      return(list(
        status = "Đạt",
        percent_of_limit = percent,
        message = sprintf("Đạt yêu cầu (%.2f/%.2f = %.1f%%)", value, threshold, percent),
        color = "#2E7D32"
      ))
    }
  }
}

#' Kiểm tra tuân thủ cho một data.frame
#' @param data Data frame có cột Parameter và các cột Sample_X
#' @param standard_type Loại quy chuẩn
#' @param column Cột áp dụng
#' @param safety_margin Ngưỡng cảnh báo sớm (%)
#' @return Data frame với thêm các cột đánh giá
check_compliance <- function(data, standard_type, column, safety_margin = 90) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) {
    warning("Không tìm thấy quy chuẩn: ", standard_type)
    return(data)
  }
  
  sample_cols <- grep("^Sample_", names(data), value = TRUE)
  
  results <- data %>%
    rowwise() %>%
    mutate(
      Threshold = {
        th <- get_threshold(standard_type, Parameter, column)
        if (is.null(th) || all(is.na(th))) NA
        else if (length(th) == 2) paste(th[1], "-", th[2])
        else as.character(th)
      },
      Threshold_Type = get_threshold_type(standard_type, Parameter)
    ) %>%
    ungroup()
  
  # Initialize result columns to prevent "Unknown or uninitialised column" warnings
  results$Mean_Value <- NA_real_
  results$Max_Value <- NA_real_
  results$Min_Value <- NA_real_
  results$Status <- NA_character_
  results$Percent_of_Limit <- NA_real_
  results$Status_Color <- NA_character_
  
  # Tính giá trị trung bình và đánh giá cho mỗi thông số
  for (i in seq_len(nrow(results))) {
    param <- results$Parameter[i]
    threshold <- get_threshold(standard_type, param, column)
    th_type <- get_threshold_type(standard_type, param)
    
    sample_values <- as.numeric(results[i, sample_cols])
    sample_values <- sample_values[!is.na(sample_values)]
    
    if (length(sample_values) > 0) {
      avg_value <- mean(sample_values, na.rm = TRUE)
      max_value <- max(sample_values, na.rm = TRUE)
      min_value <- min(sample_values, na.rm = TRUE)
      
      # Đánh giá dựa trên giá trị xấu nhất
      eval_value <- if (th_type == "min") min_value else max_value
      result <- check_single_compliance(eval_value, threshold, th_type, safety_margin)
      
      results$Mean_Value[i] <- round(avg_value, 3)
      results$Max_Value[i] <- round(max_value, 3)
      results$Min_Value[i] <- round(min_value, 3)
      results$Status[i] <- result$status
      results$Percent_of_Limit[i] <- round(result$percent_of_limit, 1)
      results$Status_Color[i] <- result$color
    } else {
      results$Mean_Value[i] <- NA
      results$Max_Value[i] <- NA
      results$Min_Value[i] <- NA
      results$Status[i] <- "Không có dữ liệu"
      results$Percent_of_Limit[i] <- NA
      results$Status_Color[i] <- "gray"
    }
  }
  
  return(results)
}

# ---- 2. CHUYỂN ĐỔI ĐƠN VỊ ----

#' Chuyển đổi đơn vị
#' @param value Giá trị cần chuyển đổi
#' @param from_unit Đơn vị gốc
#' @param to_unit Đơn vị đích
#' @return Giá trị đã chuyển đổi
convert_unit <- function(value, from_unit, to_unit) {
  if (from_unit == to_unit) return(value)
  
  # Nước: mg/L, µg/L, g/L
  if (from_unit == "mg/L" && to_unit == "µg/L") return(value * 1000)
  if (from_unit == "µg/L" && to_unit == "mg/L") return(value / 1000)
  if (from_unit == "mg/L" && to_unit == "g/L") return(value / 1000)
  if (from_unit == "g/L" && to_unit == "mg/L") return(value * 1000)
  
  # Không khí: µg/m³, mg/m³, ppm (cần biết khối lượng phân tử)
  if (from_unit == "µg/m³" && to_unit == "mg/m³") return(value / 1000)
  if (from_unit == "mg/m³" && to_unit == "µg/m³") return(value * 1000)
  
  # Đất: mg/kg, µg/kg, g/kg
  if (from_unit == "mg/kg" && to_unit == "µg/kg") return(value * 1000)
  if (from_unit == "µg/kg" && to_unit == "mg/kg") return(value / 1000)
  if (from_unit == "mg/kg" && to_unit == "g/kg") return(value / 1000)
  if (from_unit == "g/kg" && to_unit == "mg/kg") return(value * 1000)
  
  warning("Không thể chuyển đổi từ ", from_unit, " sang ", to_unit)
  return(value)
}

# ---- 3. TẠO DỮ LIỆU MẪU ----

#' Tạo dữ liệu mẫu ngẫu nhiên cho một loại quy chuẩn
#' @param standard_type Loại quy chuẩn
#' @param column Cột áp dụng
#' @param n_samples Số mẫu
#' @param compliance_rate Tỷ lệ đạt mong muốn (0-1)
#' @param seed Seed cho random
#' @return Data frame với dữ liệu mẫu
generate_sample_data <- function(standard_type, column, n_samples = 5, 
                                  compliance_rate = 0.7, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return(data.frame())
  
  params <- names(std$parameters)
  template <- create_data_template(standard_type, column, n_samples)
  
  for (i in seq_along(params)) {
    param <- params[i]
    threshold <- get_threshold(standard_type, param, column)
    th_type <- get_threshold_type(standard_type, param)
    
    if (is.null(threshold) || all(is.na(threshold))) next
    
    for (j in 1:n_samples) {
      col_name <- paste0("Sample_", j)
      
      # Quyết định mẫu này đạt hay không
      is_compliant <- runif(1) < compliance_rate
      
      if (th_type == "range") {
        lower <- threshold[1]
        upper <- threshold[2]
        mid <- (lower + upper) / 2
        range_size <- upper - lower
        
        if (is_compliant) {
          # Trong khoảng
          template[i, col_name] <- round(runif(1, lower + 0.1 * range_size, upper - 0.1 * range_size), 2)
        } else {
          # Ngoài khoảng
          if (runif(1) < 0.5) {
            template[i, col_name] <- round(runif(1, lower * 0.5, lower * 0.95), 2)
          } else {
            template[i, col_name] <- round(runif(1, upper * 1.05, upper * 1.5), 2)
          }
        }
      } else if (th_type == "min") {
        if (is_compliant) {
          template[i, col_name] <- round(runif(1, threshold * 1.0, threshold * 1.5), 2)
        } else {
          template[i, col_name] <- round(runif(1, threshold * 0.3, threshold * 0.9), 2)
        }
      } else {
        # max
        if (is_compliant) {
          template[i, col_name] <- round(runif(1, threshold * 0.2, threshold * 0.8), 2)
        } else {
          template[i, col_name] <- round(runif(1, threshold * 1.1, threshold * 2.0), 2)
        }
      }
    }
  }
  
  return(template)
}

# ---- 4. THỐNG KÊ TUÂN THỦ ----

#' Tính thống kê tuân thủ tổng hợp
#' @param assessed_data Data frame đã được đánh giá tuân thủ
#' @return List chứa các thống kê
calculate_compliance_stats <- function(assessed_data) {
  if (is.null(assessed_data) || nrow(assessed_data) == 0) {
    return(list(
      total_parameters = 0,
      compliant = 0,
      warning = 0,
      non_compliant = 0,
      no_data = 0,
      compliance_rate = 0,
      critical_params = character(0)
    ))
  }
  
  stats <- list(
    total_parameters = nrow(assessed_data),
    compliant = sum(assessed_data$Status == "Đạt", na.rm = TRUE),
    warning = sum(assessed_data$Status == "Cảnh báo", na.rm = TRUE),
    non_compliant = sum(assessed_data$Status == "Không đạt", na.rm = TRUE),
    no_data = sum(assessed_data$Status %in% c("Không có dữ liệu", "Không áp dụng"), na.rm = TRUE)
  )
  
  assessed_count <- stats$total_parameters - stats$no_data
  stats$compliance_rate <- if (assessed_count > 0) {
    round(stats$compliant / assessed_count * 100, 1)
  } else 0
  
  # Các thông số nghiêm trọng (vượt ngưỡng)
  stats$critical_params <- assessed_data %>%
    filter(Status == "Không đạt") %>%
    arrange(desc(Percent_of_Limit)) %>%
    pull(Parameter)
  
  # Các thông số cảnh báo
  stats$warning_params <- assessed_data %>%
    filter(Status == "Cảnh báo") %>%
    arrange(desc(Percent_of_Limit)) %>%
    pull(Parameter)
  
  return(stats)
}

# ---- 5. XỬ LÝ DỮ LIỆU NHẬP TỪ RHANDSONTABLE ----

#' Xử lý và validate dữ liệu từ rhandsontable
#' @param hot_data Data từ rhandsontable
#' @return Data frame đã được xử lý
process_handsontable_data <- function(hot_data) {
  if (is.null(hot_data) || nrow(hot_data) == 0) {
    return(NULL)
  }
  
  # Chuyển đổi các cột Sample thành numeric
  sample_cols <- grep("^Sample_", names(hot_data), value = TRUE)
  
  for (col in sample_cols) {
    hot_data[[col]] <- suppressWarnings(as.numeric(hot_data[[col]]))
  }
  
  return(hot_data)
}

#' Validate giá trị nhập vào
#' @param value Giá trị cần validate
#' @param parameter Tên thông số
#' @param standard_type Loại quy chuẩn
#' @return List chứa is_valid và message
validate_input_value <- function(value, parameter, standard_type) {
  if (is.na(value)) {
    return(list(is_valid = TRUE, message = ""))
  }
  
  if (!is.numeric(value)) {
    return(list(is_valid = FALSE, message = "Giá trị phải là số"))
  }
  
  if (value < 0) {
    # Một số thông số có thể âm (nhiệt độ)
    if (!parameter %in% c("Temperature", "Nhiet_do")) {
      return(list(is_valid = FALSE, message = "Giá trị không thể âm"))
    }
  }
  
  return(list(is_valid = TRUE, message = ""))
}

# ---- 6. XUẤT BÁO CÁO ----

#' Chuẩn bị dữ liệu cho báo cáo Excel
#' @param assessed_data Data frame đã đánh giá
#' @param stats Thống kê tuân thủ
#' @param metadata Thông tin bổ sung
#' @return List chứa các sheets
prepare_excel_report <- function(assessed_data, stats, metadata = list()) {
  sheets <- list()
  
  # Sheet 1: Thông tin tổng quan
  overview <- data.frame(
    Thong_tin = c(
      "Ngày tạo báo cáo",
      "Loại quy chuẩn",
      "Cột áp dụng",
      "Tổng số thông số",
      "Số thông số đạt",
      "Số thông số cảnh báo",
      "Số thông số không đạt",
      "Tỷ lệ tuân thủ (%)"
    ),
    Gia_tri = c(
      format(Sys.time(), "%d/%m/%Y %H:%M"),
      metadata$standard_name %||% "N/A",
      metadata$column %||% "N/A",
      as.character(stats$total_parameters),
      as.character(stats$compliant),
      as.character(stats$warning),
      as.character(stats$non_compliant),
      as.character(stats$compliance_rate)
    ),
    stringsAsFactors = FALSE
  )
  sheets$Tong_quan <- overview
  
  # Sheet 2: Chi tiết đánh giá
  detail <- assessed_data %>%
    select(Parameter, Unit, Limit = Threshold, Type = Threshold_Type,
           Mean_Value, Max_Value, Min_Value, Status, Percent_of_Limit) %>%
    mutate(across(where(is.numeric), ~round(., 3)))
  sheets$Chi_tiet <- detail
  
  # Sheet 3: Dữ liệu gốc
  raw_data <- assessed_data %>%
    select(Parameter, Unit, starts_with("Sample_"))
  sheets$Du_lieu_goc <- raw_data
  
  return(sheets)
}

message("✓ Đã tải functions.R - Các hàm xử lý dữ liệu đa ma trận")
