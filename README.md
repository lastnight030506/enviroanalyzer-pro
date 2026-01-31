# EnviroAnalyzer Pro v3.0

[![R](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://cran.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)]()

## 🌿 Environmental Quality Assessment Application

EnviroAnalyzer Pro là ứng dụng phân tích chất lượng môi trường theo các Quy chuẩn Việt Nam (QCVN).

---

## 📥 Cài đặt

### Cách 1: Windows Installer (Khuyến nghị)

1. Tải file `EnviroAnalyzer_Pro_Setup.exe` từ [Releases](../../releases)
2. Chạy installer và làm theo hướng dẫn
3. Khởi động từ Start Menu hoặc Desktop

### Cách 2: Cài đặt thủ công

#### Yêu cầu
- [R 4.0+](https://cran.r-project.org/bin/windows/base/)

#### Các bước
```bash
# Clone repository
git clone https://github.com/yourusername/enviroanalyzer-pro.git
cd enviroanalyzer-pro

# Chạy setup (lần đầu)
setup.bat

# Khởi động ứng dụng
run_app.bat
```

---

## 🎯 Tính năng

### Nhập dữ liệu
- ✅ Nhập trực tiếp vào Data Grid
- ✅ Import từ Excel (.xlsx, .xls)
- ✅ Import từ CSV

### Quy chuẩn hỗ trợ (QCVN)
| Ma trận | Quy chuẩn | Cột |
|---------|-----------|-----|
| Nước mặt | QCVN 08-MT:2015/BTNMT | A1, A2, B1, B2 |
| Nước thải CN | QCVN 40:2011/BTNMT | A, B |
| Nước thải SH | QCVN 14:2008/BTNMT | A, B |
| Không khí | QCVN 05:2013/BTNMT | - |
| Đất | QCVN 03-MT:2015/BTNMT | Nông nghiệp, Dân cư, CN |
| Tiếng ồn | QCVN 26:2010/BTNMT | Đặc biệt, Thông thường |

### Phân tích
- ✅ Đánh giá tuân thủ QCVN
- ✅ Thống kê (Mean, Max, Min)
- ✅ Phân loại: Compliant, Warning, Critical

### Trực quan hóa
- 📊 Biểu đồ so sánh
- 🎯 Radar chart
- ⏱️ Gauge chart
- 🔥 Heatmap
- 🥧 Pie chart

### Xuất báo cáo
- 📄 Excel
- 📑 PDF

### Tùy chỉnh
- 🌙 Dark/Light mode
- 🎨 Accent color
- ➕ Custom QCVN

---

## 📁 Cấu trúc

```
enviroanalyzer-pro/
├── app.R                 # Ứng dụng chính
├── constants.R           # QCVN definitions
├── functions.R           # Data processing
├── visuals.R             # Visualization
├── run_app.bat           # Launcher
├── setup.bat             # Installer
├── build_installer.R     # Build script
└── README.md
```

---

## 🔧 Build Installer

### Yêu cầu
1. Cài [Inno Setup](https://jrsoftware.org/isdl.php)
2. Cài R 4.0+

### Build
```r
setwd("path/to/project")
source("build_installer.R")
```

Installer sẽ được tạo trong thư mục `installer/`

---

## 📝 License

MIT License

---

*Version 3.0.0 - January 2026*
