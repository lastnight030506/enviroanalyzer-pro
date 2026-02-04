# ============================================================================ #
#                     CONSTANTS.R - QUY CHUẨN MÔI TRƯỜNG VIỆT NAM              #
# ============================================================================ #
# Tác giả: Environmental Engineering Student
# Mô tả: Chứa tất cả các quy chuẩn QCVN cho Nước, Không khí, Đất và Tiếng ồn
# V3.1: Hỗ trợ load QCVN từ file JSON + Upload QCVN tùy chỉnh
# ============================================================================ #

# ---- LOAD REQUIRED PACKAGES ----
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite", repos = "https://cloud.r-project.org", quiet = TRUE)
}
library(jsonlite)

# ---- JSON LOADER FUNCTIONS ----

#' Load QCVN từ file JSON
#' @param json_path Đường dẫn tới file JSON
#' @return List object QCVN hoặc NULL nếu lỗi
load_qcvn_from_json <- function(json_path) {
  tryCatch({
    if (!file.exists(json_path)) {
      warning(paste("File không tồn tại:", json_path))
      return(NULL)
    }
    
    json_data <- fromJSON(json_path, simplifyVector = FALSE)
    
    # Validate required fields
    required_fields <- c("name", "description", "category", "unit", "columns", "parameters")
    missing_fields <- setdiff(required_fields, names(json_data))
    
    if (length(missing_fields) > 0) {
      warning(paste("File JSON thiếu các trường:", paste(missing_fields, collapse = ", ")))
      return(NULL)
    }
    
    return(json_data)
  }, error = function(e) {
    warning(paste("Lỗi khi load JSON:", json_path, "-", e$message))
    return(NULL)
  })
}

#' Load tất cả QCVN từ thư mục
#' @param dir_path Đường dẫn thư mục chứa các file JSON
#' @return Named list of QCVN objects
load_qcvn_directory <- function(dir_path) {
  qcvn_list <- list()
  
  if (!dir.exists(dir_path)) {
    warning(paste("Thư mục không tồn tại:", dir_path))
    return(qcvn_list)
  }
  
  json_files <- list.files(dir_path, pattern = "\\.json$", full.names = TRUE)
  
  for (json_file in json_files) {
    qcvn <- load_qcvn_from_json(json_file)
    if (!is.null(qcvn)) {
      # Tạo key từ tên file (bỏ extension)
      key <- tools::file_path_sans_ext(basename(json_file))
      qcvn_list[[key]] <- qcvn
    }
  }
  
  return(qcvn_list)
}

# ---- FALLBACK: HARDCODED QCVN (nếu không load được JSON) ----

# ---- QCVN 08-MT:2015/BTNMT - Chất lượng nước mặt ----
QCVN_08_Surface_Water <- list(
  name = "QCVN 08-MT:2015/BTNMT",
  description = "Quy chuẩn kỹ thuật quốc gia về chất lượng nước mặt",
  unit = "mg/L",
  columns = c("A1", "A2", "B1", "B2"),
  column_descriptions = list(
    A1 = "Sử dụng cho mục đích cấp nước sinh hoạt (sau xử lý thông thường)",
    A2 = "Sử dụng cho mục đích cấp nước sinh hoạt (sau xử lý phù hợp), bảo tồn động thực vật thủy sinh",
    B1 = "Sử dụng cho mục đích tưới tiêu, thủy lợi",
    B2 = "Giao thông thủy và các mục đích khác"
  ),
  parameters = list(
    pH = list(A1 = c(6, 8.5), A2 = c(6, 8.5), B1 = c(5.5, 9), B2 = c(5.5, 9), type = "range"),
    DO = list(A1 = 6, A2 = 5, B1 = 4, B2 = 2, type = "min"),
    BOD5 = list(A1 = 4, A2 = 6, B1 = 15, B2 = 25, type = "max"),
    COD = list(A1 = 10, A2 = 15, B1 = 30, B2 = 50, type = "max"),
    TSS = list(A1 = 20, A2 = 30, B1 = 50, B2 = 100, type = "max"),
    NH4_N = list(A1 = 0.3, A2 = 0.3, B1 = 0.9, B2 = 0.9, type = "max"),
    NO3_N = list(A1 = 2, A2 = 5, B1 = 10, B2 = 15, type = "max"),
    PO4_P = list(A1 = 0.1, A2 = 0.2, B1 = 0.3, B2 = 0.5, type = "max"),
    Coliform = list(A1 = 2500, A2 = 5000, B1 = 7500, B2 = 10000, type = "max"),
    Fe = list(A1 = 0.5, A2 = 1, B1 = 1.5, B2 = 2, type = "max"),
    Mn = list(A1 = 0.1, A2 = 0.2, B1 = 0.5, B2 = 1, type = "max"),
    Pb = list(A1 = 0.02, A2 = 0.02, B1 = 0.05, B2 = 0.05, type = "max"),
    As = list(A1 = 0.01, A2 = 0.02, B1 = 0.05, B2 = 0.1, type = "max"),
    Hg = list(A1 = 0.001, A2 = 0.001, B1 = 0.001, B2 = 0.002, type = "max"),
    Cd = list(A1 = 0.005, A2 = 0.005, B1 = 0.01, B2 = 0.01, type = "max")
  )
)

# ---- QCVN 40:2011/BTNMT - Nước thải công nghiệp ----
QCVN_40_Industrial_Wastewater <- list(
  name = "QCVN 40:2011/BTNMT",
  description = "Quy chuẩn kỹ thuật quốc gia về nước thải công nghiệp",
  unit = "mg/L",
  columns = c("A", "B"),
  column_descriptions = list(
    A = "Xả vào nguồn nước dùng cho cấp nước sinh hoạt",
    B = "Xả vào nguồn nước không dùng cho cấp nước sinh hoạt"
  ),
  parameters = list(
    pH = list(A = c(6, 9), B = c(5.5, 9), type = "range"),
    BOD5 = list(A = 30, B = 50, type = "max"),
    COD = list(A = 75, B = 150, type = "max"),
    TSS = list(A = 50, B = 100, type = "max"),
    NH4_N = list(A = 5, B = 10, type = "max"),
    NO3_N = list(A = 20, B = 40, type = "max"),
    PO4_P = list(A = 4, B = 6, type = "max"),
    Coliform = list(A = 3000, B = 5000, type = "max"),
    Fe = list(A = 1, B = 5, type = "max"),
    Mn = list(A = 0.5, B = 1, type = "max"),
    Pb = list(A = 0.1, B = 0.5, type = "max"),
    As = list(A = 0.05, B = 0.1, type = "max"),
    Hg = list(A = 0.005, B = 0.01, type = "max"),
    Cd = list(A = 0.05, B = 0.1, type = "max"),
    Cr_VI = list(A = 0.05, B = 0.1, type = "max"),
    Cu = list(A = 2, B = 2, type = "max"),
    Zn = list(A = 3, B = 3, type = "max"),
    Ni = list(A = 0.2, B = 0.5, type = "max"),
    Oil_Grease = list(A = 5, B = 10, type = "max"),
    Phenol = list(A = 0.1, B = 0.5, type = "max"),
    CN = list(A = 0.07, B = 0.1, type = "max")
  )
)

# ---- QCVN 14:2008/BTNMT - Nước thải sinh hoạt ----
QCVN_14_Domestic_Wastewater <- list(
  name = "QCVN 14:2008/BTNMT",
  description = "Quy chuẩn kỹ thuật quốc gia về nước thải sinh hoạt",
  unit = "mg/L",
  columns = c("A", "B"),
  column_descriptions = list(
    A = "Xả vào nguồn nước dùng cho cấp nước sinh hoạt",
    B = "Xả vào nguồn nước không dùng cho cấp nước sinh hoạt"
  ),
  parameters = list(
    pH = list(A = c(5, 9), B = c(5, 9), type = "range"),
    BOD5 = list(A = 30, B = 50, type = "max"),
    TSS = list(A = 50, B = 100, type = "max"),
    TDS = list(A = 500, B = 1000, type = "max"),
    NH4_N = list(A = 5, B = 10, type = "max"),
    NO3_N = list(A = 30, B = 50, type = "max"),
    PO4_P = list(A = 6, B = 10, type = "max"),
    Oil_Grease = list(A = 10, B = 20, type = "max"),
    Coliform = list(A = 3000, B = 5000, type = "max")
  )
)

# ---- QCVN 05:2023/BTNMT - Chất lượng không khí xung quanh ----
QCVN_05_Ambient_Air <- list(
  name = "QCVN 05:2023/BTNMT",
  description = "Quy chuẩn kỹ thuật quốc gia về chất lượng không khí xung quanh",
  unit = "µg/m³",
  columns = c("TB1h", "TB8h", "TB24h", "TBnam"),
  column_descriptions = list(
    TB1h = "Trung bình 1 giờ",
    TB8h = "Trung bình 8 giờ",
    TB24h = "Trung bình 24 giờ",
    TBnam = "Trung bình năm"
  ),
  parameters = list(
    SO2 = list(TB1h = 350, TB24h = 125, TBnam = 50, type = "max"),
    NO2 = list(TB1h = 200, TB24h = 100, TBnam = 40, type = "max"),
    CO = list(TB1h = 30000, TB8h = 10000, type = "max"),
    O3 = list(TB1h = 180, TB8h = 120, type = "max"),
    PM10 = list(TB24h = 100, TBnam = 50, type = "max"),
    PM2_5 = list(TB24h = 50, TBnam = 25, type = "max"),
    Pb = list(TB24h = 1.5, TBnam = 0.5, type = "max"),
    Benzene = list(TBnam = 5, type = "max"),
    Toluene = list(TB1h = 1000, type = "max"),
    Xylene = list(TB1h = 1000, type = "max"),
    H2S = list(TB1h = 42, type = "max"),
    NH3 = list(TB1h = 200, type = "max"),
    TSP = list(TB1h = 300, TB24h = 200, TBnam = 100, type = "max")
  )
)

# ---- QCVN 03-MT:2015/BTNMT - Chất lượng đất ----
QCVN_03_Soil <- list(
  name = "QCVN 03-MT:2015/BTNMT",
  description = "Quy chuẩn kỹ thuật quốc gia về giới hạn cho phép kim loại nặng trong đất",
  unit = "mg/kg",
  columns = c("Nong_nghiep", "Lam_nghiep", "Dan_cu", "Thuong_mai", "Cong_nghiep"),
  column_descriptions = list(
    Nong_nghiep = "Đất nông nghiệp",
    Lam_nghiep = "Đất lâm nghiệp",
    Dan_cu = "Đất khu dân cư",
    Thuong_mai = "Đất thương mại, dịch vụ",
    Cong_nghiep = "Đất công nghiệp"
  ),
  parameters = list(
    As = list(Nong_nghiep = 15, Lam_nghiep = 20, Dan_cu = 15, Thuong_mai = 20, Cong_nghiep = 25, type = "max"),
    Cd = list(Nong_nghiep = 1.5, Lam_nghiep = 3, Dan_cu = 2, Thuong_mai = 5, Cong_nghiep = 10, type = "max"),
    Cu = list(Nong_nghiep = 100, Lam_nghiep = 150, Dan_cu = 100, Thuong_mai = 200, Cong_nghiep = 300, type = "max"),
    Pb = list(Nong_nghiep = 70, Lam_nghiep = 100, Dan_cu = 120, Thuong_mai = 200, Cong_nghiep = 300, type = "max"),
    Zn = list(Nong_nghiep = 200, Lam_nghiep = 200, Dan_cu = 200, Thuong_mai = 300, Cong_nghiep = 500, type = "max"),
    Cr = list(Nong_nghiep = 150, Lam_nghiep = 200, Dan_cu = 200, Thuong_mai = 250, Cong_nghiep = 300, type = "max"),
    Hg = list(Nong_nghiep = 0.5, Lam_nghiep = 1, Dan_cu = 1, Thuong_mai = 2, Cong_nghiep = 5, type = "max"),
    Ni = list(Nong_nghiep = 50, Lam_nghiep = 70, Dan_cu = 50, Thuong_mai = 100, Cong_nghiep = 200, type = "max")
  )
)

# ---- QCVN 26:2010/BTNMT - Tiếng ồn ----
QCVN_26_Noise <- list(
  name = "QCVN 26:2010/BTNMT",
  description = "Quy chuẩn kỹ thuật quốc gia về tiếng ồn",
  unit = "dBA",
  columns = c("Ngay_6h_21h", "Dem_21h_6h"),
  column_descriptions = list(
    Ngay_6h_21h = "Ban ngày (6h-21h)",
    Dem_21h_6h = "Ban đêm (21h-6h)"
  ),
  parameters = list(
    Benh_vien = list(Ngay_6h_21h = 55, Dem_21h_6h = 45, type = "max", description = "Khu vực đặc biệt (bệnh viện, thư viện, nhà điều dưỡng)"),
    Khu_dan_cu = list(Ngay_6h_21h = 70, Dem_21h_6h = 55, type = "max", description = "Khu dân cư, khách sạn, nhà nghỉ"),
    Thuong_mai = list(Ngay_6h_21h = 75, Dem_21h_6h = 60, type = "max", description = "Khu thương mại, dịch vụ"),
    San_xuat = list(Ngay_6h_21h = 75, Dem_21h_6h = 60, type = "max", description = "Khu sản xuất, công nghiệp")
  )
)

# ---- Master QCVN Standards List ----
# Try to load from JSON first, fallback to hardcoded if failed
QCVN_Standards <- tryCatch({
  # Try loading from qcvn_data directory
  qcvn_defaults <- load_qcvn_directory("qcvn_data/defaults")
  qcvn_custom <- load_qcvn_directory("qcvn_data/custom")
  
  # Merge defaults and custom (custom override defaults if same key)
  qcvn_all <- c(qcvn_defaults, qcvn_custom)
  
  if (length(qcvn_all) > 0) {
    # Rename keys to match old naming convention
    names(qcvn_all) <- gsub("^qcvn_08.*", "Surface_Water", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_40.*", "Industrial_Wastewater", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_14.*", "Domestic_Wastewater", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_05.*", "Ambient_Air", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_03.*", "Soil", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_26.*", "Noise", names(qcvn_all))
    
    message(paste("✓ Loaded", length(qcvn_all), "QCVN standards from JSON files"))
    qcvn_all
  } else {
    # Fallback to hardcoded
    message("⚠ No JSON files found, using hardcoded QCVN")
    list(
      Surface_Water = QCVN_08_Surface_Water,
      Industrial_Wastewater = QCVN_40_Industrial_Wastewater,
      Domestic_Wastewater = QCVN_14_Domestic_Wastewater,
      Ambient_Air = QCVN_05_Ambient_Air,
      Soil = QCVN_03_Soil,
      Noise = QCVN_26_Noise
    )
  }
}, error = function(e) {
  message(paste("⚠ Error loading JSON, using hardcoded QCVN:", e$message))
  list(
    Surface_Water = QCVN_08_Surface_Water,
    Industrial_Wastewater = QCVN_40_Industrial_Wastewater,
    Domestic_Wastewater = QCVN_14_Domestic_Wastewater,
    Ambient_Air = QCVN_05_Ambient_Air,
    Soil = QCVN_03_Soil,
    Noise = QCVN_26_Noise
  )
})

# ---- Matrix Types for UI ----
MATRIX_TYPES <- list(
  Water = list(
    name = "Nước",
    icon = "tint",
    fa_icon = "💧",
    standards = c("Surface_Water", "Industrial_Wastewater", "Domestic_Wastewater"),
    color = "#1E88E5"
  ),
  Air = list(
    name = "Không khí",
    icon = "wind",
    fa_icon = "🌬️",
    standards = c("Ambient_Air"),
    color = "#43A047"
  ),
  Soil = list(
    name = "Đất",
    icon = "globe",
    fa_icon = "🌍",
    standards = c("Soil"),
    color = "#8D6E63"
  ),
  Noise = list(
    name = "Tiếng ồn",
    icon = "volume-up",
    fa_icon = "🔊",
    standards = c("Noise"),
    color = "#F4511E"
  )
)

# ---- Helper Functions ----

#' Lấy ngưỡng giới hạn cho một thông số
get_threshold <- function(standard_type, parameter, column) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return(NA)
  param <- std$parameters[[parameter]]
  if (is.null(param)) return(NA)
  value <- param[[column]]
  if (is.null(value)) return(NA)
  return(value)
}

#' Lấy loại ngưỡng (min, max, range)
get_threshold_type <- function(standard_type, parameter) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return("max")
  param <- std$parameters[[parameter]]
  if (is.null(param)) return("max")
  return(param$type)
}

#' Lấy danh sách các cột có sẵn cho một loại quy chuẩn
get_available_columns <- function(standard_type) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return(character(0))
  return(std$columns)
}

#' Lấy danh sách các thông số cho một loại quy chuẩn
get_available_parameters <- function(standard_type) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return(character(0))
  return(names(std$parameters))
}

#' Lấy đơn vị cho một loại quy chuẩn
get_unit <- function(standard_type) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return("N/A")
  return(std$unit)
}

#' Lấy mô tả cột
get_column_description <- function(standard_type, column) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return("")
  return(std$column_descriptions[[column]])
}

#' Tạo template dữ liệu rỗng cho rhandsontable
create_data_template <- function(standard_type, column, n_samples = 5) {
  std <- QCVN_Standards[[standard_type]]
  if (is.null(std)) return(data.frame())
  
  params <- names(std$parameters)
  
  template <- data.frame(
    Parameter = params,
    Unit = rep(std$unit, length(params)),
    Limit = sapply(params, function(p) {
      val <- std$parameters[[p]][[column]]
      if (is.null(val)) return(NA)
      if (length(val) == 2) return(paste(val[1], "-", val[2]))
      return(as.character(val))
    }),
    Type = sapply(params, function(p) std$parameters[[p]]$type),
    stringsAsFactors = FALSE
  )
  
  for (i in 1:n_samples) {
    template[[paste0("Sample_", i)]] <- rep(NA_real_, length(params))
  }
  
  rownames(template) <- NULL
  return(template)
}

# ---- Theme Configuration ----
THEME_CONFIG <- list(
  fonts = list(
    primary = "Roboto",
    secondary = "Open Sans",
    monospace = "Roboto Mono"
  ),
  colors = list(
    primary = "#1565C0",
    success = "#2E7D32",
    warning = "#F57C00",
    danger = "#C62828",
    info = "#0288D1"
  ),
  accents = list(
    Blue = "#1565C0",
    Green = "#2E7D32",
    Purple = "#6A1B9A",
    Orange = "#EF6C00",
    Teal = "#00796B",
    Red = "#C62828"
  )
)

message("✓ Đã tải constants.R - Quy chuẩn QCVN (Nước, Không khí, Đất, Tiếng ồn)")
message(paste("  → Tổng số QCVN:", length(QCVN_Standards)))

#' Reload QCVN Standards (dùng sau khi upload QCVN mới)
reload_qcvn_standards <- function() {
  qcvn_defaults <<- load_qcvn_directory("qcvn_data/defaults")
  qcvn_custom <<- load_qcvn_directory("qcvn_data/custom")
  qcvn_all <- c(qcvn_defaults, qcvn_custom)
  
  if (length(qcvn_all) > 0) {
    # Rename keys
    names(qcvn_all) <- gsub("^qcvn_08.*", "Surface_Water", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_40.*", "Industrial_Wastewater", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_14.*", "Domestic_Wastewater", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_05.*", "Ambient_Air", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_03.*", "Soil", names(qcvn_all))
    names(qcvn_all) <- gsub("^qcvn_26.*", "Noise", names(qcvn_all))
    
    QCVN_Standards <<- qcvn_all
    return(TRUE)
  }
  return(FALSE)
}
