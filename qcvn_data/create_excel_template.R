# ============================================================================ #
#              TẠO EXCEL TEMPLATE TRỰC QUAN CHO QCVN                           #
# ============================================================================ #
# Script này tạo file Excel mẫu với format đẹp, dễ chỉnh sửa

library(writexl)
library(jsonlite)

#' Tạo Excel Template từ JSON template
create_qcvn_excel_template <- function(output_file = "qcvn_data/qcvn_template.xlsx") {
  
  # ---- SHEET 1: THÔNG TIN CHUNG ----
  info_sheet <- data.frame(
    Field = c("name", "description", "category", "unit"),
    Value = c(
      "QCVN XX:YYYY/BTNMT",
      "Quy chuẩn kỹ thuật quốc gia về [mô tả]",
      "water",
      "mg/L"
    ),
    Description = c(
      "Tên quy chuẩn (bắt buộc)",
      "Mô tả chi tiết quy chuẩn (bắt buộc)",
      "Loại: water / air / soil / noise / other (bắt buộc)",
      "Đơn vị đo: mg/L, µg/m³, dBA, mg/kg, etc. (bắt buộc)"
    ),
    stringsAsFactors = FALSE
  )
  
  # ---- SHEET 2: CỘT (COLUMNS) ----
  columns_sheet <- data.frame(
    Column_ID = c("A", "B", "", ""),
    Column_Name = c("Loại A", "Loại B", "", ""),
    Description = c(
      "Mô tả cho cột A (ví dụ: Xả vào nguồn nước sinh hoạt)",
      "Mô tả cho cột B (ví dụ: Xả vào nguồn nước khác)",
      "",
      ""
    ),
    Note = c(
      "Thêm hàng nếu có nhiều cột hơn",
      "Ví dụ: A1, A2, B1, B2 hoặc TB1h, TB8h, TB24h",
      "",
      ""
    ),
    stringsAsFactors = FALSE
  )
  
  # ---- SHEET 3: THÔNG SỐ (PARAMETERS) ----
  parameters_sheet <- data.frame(
    Parameter = c("pH", "BOD5", "DO", "COD", "TSS", "NH4_N", "Fe", ""),
    Type = c("range", "max", "min", "max", "max", "max", "max", ""),
    A_Min = c(6, NA, 6, NA, NA, NA, NA, NA),
    A_Max = c(9, 30, NA, 75, 50, 5, 1, NA),
    B_Min = c(5.5, NA, 4, NA, NA, NA, NA, NA),
    B_Max = c(9, 50, NA, 150, 100, 10, 5, NA),
    Unit = c("", "mg/L", "mg/L", "mg/L", "mg/L", "mg/L", "mg/L", ""),
    Description = c(
      "Độ pH",
      "Nhu cầu oxy sinh hóa",
      "Oxy hòa tan",
      "Nhu cầu oxy hóa học",
      "Chất rắn lơ lửng",
      "Amoni",
      "Sắt",
      ""
    ),
    stringsAsFactors = FALSE
  )
  
  # ---- SHEET 4: HƯỚNG DẪN ----
  guide_sheet <- data.frame(
    Step = c(
      "1",
      "1a",
      "1b",
      "1c",
      "1d",
      "2",
      "2a",
      "2b",
      "2c",
      "3",
      "3a",
      "3b",
      "3c",
      "3d",
      "4",
      "4a",
      "4b",
      "4c",
      "5",
      "5a",
      "5b",
      "5c",
      "5d",
      "5e",
      "6",
      "6a",
      "6b",
      "6c",
      "6d",
      "END"
    ),
    Content = c(
      "THÔNG TIN CHUNG - Điền vào Sheet 'Thong_Tin'",
      "name: Tên QCVN (VD: QCVN 99:2024/BTNMT)",
      "description: Mô tả chi tiết",
      "category: water / air / soil / noise / other",
      "unit: Đơn vị đo (mg/L, µg/m³, dBA, mg/kg, ...)",
      "CỘT (COLUMNS) - Khai báo trong Sheet 'Cot'",
      "Column_ID: Mã cột (A, B, A1, A2, TB1h, ...)",
      "Column_Name: Tên hiển thị",
      "Description: Mô tả chi tiết cho từng cột",
      "THÔNG SỐ - Nhập vào Sheet 'Thong_So'",
      "Parameter: Tên thông số (pH, BOD5, DO, ...)",
      "Type: Loại kiểm tra (max / min / range)",
      "Điền giá trị vào cột tương ứng với Column_ID",
      "Ví dụ: A_Min, A_Max, B_Min, B_Max",
      "LOẠI KIỂM TRA (Type)",
      "max: Giá trị tối đa cho phép (điền vào _Max)",
      "min: Giá trị tối thiểu yêu cầu (điền vào _Max)",
      "range: Khoảng [min, max] (điền cả _Min và _Max)",
      "CÁC BƯỚC THỰC HIỆN",
      "Bước 1: Điền Sheet 'Thong_Tin'",
      "Bước 2: Khai báo cột trong Sheet 'Cot'",
      "Bước 3: Nhập thông số vào Sheet 'Thong_So'",
      "Bước 4: Lưu file Excel",
      "Bước 5: Upload file vào EnviroAnalyzer Pro",
      "LƯU Ý QUAN TRỌNG",
      "Mỗi thông số phải có giá trị cho TẤT CẢ các cột",
      "Với type='range', phải điền cả _Min và _Max",
      "Với type='max' hoặc 'min', chỉ điền _Max",
      "Có thể thêm nhiều hàng (parameters) và cột tùy ý",
      "Xem ví dụ hoàn chỉnh trong các sheet Vi_Du_*"
    ),
    stringsAsFactors = FALSE
  )
  
  # ---- SHEET 5: VÍ DỤ HOÀN CHỈNH ----
  example_info <- data.frame(
    Field = c("name", "description", "category", "unit"),
    Value = c(
      "QCVN 99:2024/BTNMT",
      "Quy chuẩn nước thải công nghiệp dệt nhuộm",
      "water",
      "mg/L"
    ),
    Description = c(
      "Tên quy chuẩn",
      "Mô tả",
      "Loại",
      "Đơn vị"
    ),
    stringsAsFactors = FALSE
  )
  
  example_columns <- data.frame(
    Column_ID = c("A", "B"),
    Column_Name = c("Loại A", "Loại B"),
    Description = c(
      "Xả vào nguồn nước sinh hoạt",
      "Xả vào nguồn nước không sinh hoạt"
    ),
    stringsAsFactors = FALSE
  )
  
  example_params <- data.frame(
    Parameter = c("pH", "BOD5", "DO", "COD", "TSS", "NH4_N", "Color"),
    Type = c("range", "max", "min", "max", "max", "max", "max"),
    A_Min = c(6, NA, 5, NA, NA, NA, NA),
    A_Max = c(9, 30, NA, 80, 50, 10, 50),
    B_Min = c(5.5, NA, 4, NA, NA, NA, NA),
    B_Max = c(9, 50, NA, 120, 80, 15, 100),
    Unit = c("", "mg/L", "mg/L", "mg/L", "mg/L", "mg/L", "Pt-Co"),
    Description = c("Độ pH", "BOD5", "Oxy hòa tan", "COD", "TSS", "Amoni", "Màu sắc"),
    stringsAsFactors = FALSE
  )
  
  # Tạo list các sheets
  sheets <- list(
    "Thong_Tin" = info_sheet,
    "Cot" = columns_sheet,
    "Thong_So" = parameters_sheet,
    "Huong_Dan" = guide_sheet,
    "Vi_Du_Info" = example_info,
    "Vi_Du_Cot" = example_columns,
    "Vi_Du_Params" = example_params
  )
  
  # Ghi file Excel
  write_xlsx(sheets, output_file)
  
  cat("✓ Đã tạo Excel template:", output_file, "\n")
  return(output_file)
}

# Chạy nếu script được execute trực tiếp
if (!interactive()) {
  create_qcvn_excel_template()
}
