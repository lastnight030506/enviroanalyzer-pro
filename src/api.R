# ============================================================================ #
#                   REST API FOR N8N INTEGRATION                               #
# ============================================================================ #
# API endpoints cho phép n8n tương tác với EnviroAnalyzer Pro
# Port: 3839 (khác với Shiny port 3838)

library(plumber)
library(jsonlite)
library(readxl)

# Source các module cần thiết
source("constants.R")
source("functions.R")

#* @apiTitle EnviroAnalyzer Pro API for n8n
#* @apiDescription REST API để tích hợp với n8n workflow automation
#* @apiVersion 1.0.0

# ============================================================================ #
#                            HEALTH CHECK                                      #
# ============================================================================ #

#* Health check endpoint
#* @get /health
#* @serializer json
function() {
  list(
    status = "ok",
    version = "3.1.0",
    timestamp = Sys.time(),
    message = "EnviroAnalyzer Pro API is running"
  )
}

# ============================================================================ #
#                         QCVN MANAGEMENT                                      #
# ============================================================================ #

#* Lấy danh sách QCVN có sẵn
#* @get /api/qcvn/list
#* @serializer json
function() {
  tryCatch({
    qcvn_names <- names(QCVN_Standards)
    
    qcvn_list <- lapply(qcvn_names, function(name) {
      std <- QCVN_Standards[[name]]
      list(
        id = name,
        name = std$name,
        description = std$description,
        category = std$category %||% "other",
        unit = std$unit,
        columns = std$columns,
        parameter_count = length(std$parameters)
      )
    })
    
    list(
      success = TRUE,
      count = length(qcvn_list),
      data = qcvn_list
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

#* Lấy chi tiết một QCVN cụ thể
#* @get /api/qcvn/<id>
#* @param id:character ID của QCVN (VD: Surface_Water)
#* @serializer json
function(id) {
  tryCatch({
    if (!id %in% names(QCVN_Standards)) {
      return(list(
        success = FALSE,
        error = paste("QCVN not found:", id)
      ))
    }
    
    list(
      success = TRUE,
      data = QCVN_Standards[[id]]
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

#* Upload QCVN mới (JSON)
#* @post /api/qcvn/upload
#* @param qcvn_data:list Dữ liệu QCVN dạng JSON
#* @serializer json
function(req, qcvn_data) {
  tryCatch({
    # Validate required fields
    required_fields <- c("name", "description", "category", "unit", "columns", "parameters")
    missing_fields <- setdiff(required_fields, names(qcvn_data))
    
    if (length(missing_fields) > 0) {
      return(list(
        success = FALSE,
        error = paste("Missing fields:", paste(missing_fields, collapse = ", "))
      ))
    }
    
    # Tạo thư mục custom nếu chưa có
    custom_dir <- "qcvn_data/custom"
    if (!dir.exists(custom_dir)) {
      dir.create(custom_dir, recursive = TRUE)
    }
    
    # Tạo filename từ name
    filename <- gsub("[^A-Za-z0-9_-]", "_", qcvn_data$name)
    json_file <- file.path(custom_dir, paste0("n8n_", filename, ".json"))
    
    # Ghi file JSON
    writeLines(toJSON(qcvn_data, pretty = TRUE, auto_unbox = TRUE), json_file)
    
    # Reload QCVN standards
    if (exists("reload_qcvn_standards")) {
      reload_qcvn_standards()
    }
    
    list(
      success = TRUE,
      message = paste("QCVN uploaded:", qcvn_data$name),
      file = json_file
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

# ============================================================================ #
#                       DATA ASSESSMENT                                        #
# ============================================================================ #

#* Đánh giá dữ liệu theo QCVN
#* @post /api/assess
#* @param data:list Dữ liệu cần đánh giá
#* @serializer json
function(req, data) {
  tryCatch({
    # Validate input
    if (is.null(data$qcvn_id)) {
      return(list(success = FALSE, error = "qcvn_id is required"))
    }
    if (is.null(data$column)) {
      return(list(success = FALSE, error = "column is required"))
    }
    if (is.null(data$samples)) {
      return(list(success = FALSE, error = "samples is required"))
    }
    
    qcvn_id <- data$qcvn_id
    column <- data$column
    samples <- data$samples
    
    # Kiểm tra QCVN tồn tại
    if (!qcvn_id %in% names(QCVN_Standards)) {
      return(list(
        success = FALSE,
        error = paste("QCVN not found:", qcvn_id)
      ))
    }
    
    # Chuyển samples thành data frame
    if (is.list(samples) && !is.data.frame(samples)) {
      # Format: list of samples with parameter values
      # [{parameter: "pH", value: 7.5}, {parameter: "BOD5", value: 25}, ...]
      if (!is.null(samples[[1]]$parameter)) {
        df <- data.frame(
          Parameter = sapply(samples, function(x) x$parameter),
          Value = sapply(samples, function(x) x$value),
          stringsAsFactors = FALSE
        )
      } else {
        df <- as.data.frame(samples)
      }
    } else {
      df <- as.data.frame(samples)
    }
    
    # Đánh giá tuân thủ
    results <- check_compliance(df, qcvn_id, column)
    
    # Tính thống kê
    total <- nrow(results)
    pass <- sum(results$Status == "Đạt", na.rm = TRUE)
    warning <- sum(results$Status == "Cảnh báo", na.rm = TRUE)
    fail <- sum(results$Status == "Không đạt", na.rm = TRUE)
    
    list(
      success = TRUE,
      qcvn = QCVN_Standards[[qcvn_id]]$name,
      column = column,
      summary = list(
        total = total,
        pass = pass,
        warning = warning,
        fail = fail,
        compliance_rate = round(pass / total * 100, 2)
      ),
      results = results
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message,
      trace = as.character(e)
    )
  })
}

#* Đánh giá nhanh một thông số đơn lẻ
#* @post /api/assess/single
#* @serializer json
function(req, data) {
  tryCatch({
    if (is.null(data$qcvn_id) || is.null(data$column) || 
        is.null(data$parameter) || is.null(data$value)) {
      return(list(
        success = FALSE,
        error = "Missing required fields: qcvn_id, column, parameter, value"
      ))
    }
    
    result <- check_single_compliance(
      value = data$value,
      standard_type = data$qcvn_id,
      parameter = data$parameter,
      column = data$column,
      warning_threshold = data$warning_threshold %||% 0.8
    )
    
    list(
      success = TRUE,
      qcvn = data$qcvn_id,
      parameter = data$parameter,
      column = data$column,
      value = data$value,
      result = result
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

# ============================================================================ #
#                       DATA CONVERSION                                        #
# ============================================================================ #

#* Chuyển đổi dữ liệu từ format này sang format khác
#* @post /api/convert
#* @serializer json
function(req, data) {
  tryCatch({
    input_format <- data$input_format %||% "json"
    output_format <- data$output_format %||% "json"
    input_data <- data$data
    
    result_data <- NULL
    
    # Convert based on formats
    if (input_format == "json" && output_format == "dataframe") {
      result_data <- as.data.frame(input_data)
    } else if (input_format == "dataframe" && output_format == "json") {
      result_data <- as.list(input_data)
    } else if (input_format == "csv" && output_format == "json") {
      # Parse CSV string
      result_data <- read.csv(text = input_data, stringsAsFactors = FALSE)
    } else {
      return(list(
        success = FALSE,
        error = paste("Unsupported conversion:", input_format, "->", output_format)
      ))
    }
    
    list(
      success = TRUE,
      input_format = input_format,
      output_format = output_format,
      data = result_data
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

#* Chuẩn hóa dữ liệu đầu vào
#* @post /api/normalize
#* @serializer json
function(req, data) {
  tryCatch({
    # Nhận dữ liệu thô và chuẩn hóa
    raw_data <- data$data
    qcvn_id <- data$qcvn_id
    
    if (is.null(qcvn_id) || !qcvn_id %in% names(QCVN_Standards)) {
      return(list(
        success = FALSE,
        error = "Valid qcvn_id is required"
      ))
    }
    
    # Lấy danh sách parameters từ QCVN
    valid_params <- names(QCVN_Standards[[qcvn_id]]$parameters)
    
    # Filter chỉ các parameters hợp lệ
    if (is.data.frame(raw_data)) {
      normalized_data <- raw_data[raw_data$Parameter %in% valid_params, ]
    } else if (is.list(raw_data)) {
      normalized_data <- raw_data[names(raw_data) %in% valid_params]
    } else {
      return(list(
        success = FALSE,
        error = "Data must be data.frame or list"
      ))
    }
    
    list(
      success = TRUE,
      qcvn = qcvn_id,
      valid_parameters = valid_params,
      normalized_data = normalized_data
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

# ============================================================================ #
#                          BATCH PROCESSING                                    #
# ============================================================================ #

#* Xử lý đánh giá hàng loạt nhiều samples
#* @post /api/batch/assess
#* @serializer json
function(req, data) {
  tryCatch({
    if (is.null(data$batches)) {
      return(list(
        success = FALSE,
        error = "batches array is required"
      ))
    }
    
    batches <- data$batches
    results <- list()
    
    for (i in seq_along(batches)) {
      batch <- batches[[i]]
      
      batch_result <- tryCatch({
        samples_df <- as.data.frame(batch$samples)
        compliance <- check_compliance(samples_df, batch$qcvn_id, batch$column)
        
        list(
          batch_id = batch$id %||% i,
          success = TRUE,
          qcvn = batch$qcvn_id,
          column = batch$column,
          results = compliance
        )
      }, error = function(e) {
        list(
          batch_id = batch$id %||% i,
          success = FALSE,
          error = e$message
        )
      })
      
      results[[i]] <- batch_result
    }
    
    list(
      success = TRUE,
      total_batches = length(batches),
      results = results
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

# ============================================================================ #
#                          EXPORT RESULTS                                      #
# ============================================================================ #

#* Export kết quả đánh giá ra JSON
#* @post /api/export/json
#* @serializer json
function(req, data) {
  tryCatch({
    # data chứa results từ assessment
    if (is.null(data$results)) {
      return(list(
        success = FALSE,
        error = "results is required"
      ))
    }
    
    export_data <- list(
      exported_at = Sys.time(),
      qcvn = data$qcvn,
      column = data$column,
      results = data$results,
      summary = data$summary
    )
    
    list(
      success = TRUE,
      data = export_data
    )
  }, error = function(e) {
    list(
      success = FALSE,
      error = e$message
    )
  })
}

# ============================================================================ #
#                              HELPER OPERATOR                                 #
# ============================================================================ #

`%||%` <- function(a, b) if (is.null(a)) b else a
