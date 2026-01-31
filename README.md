# EnviroAnalyzer Pro v3.0

[![Release](https://img.shields.io/github/v/release/lastnight030506/enviroanalyzer-pro?style=flat-square)](https://github.com/lastnight030506/enviroanalyzer-pro/releases)
[![R](https://img.shields.io/badge/R-4.0%2B-blue.svg?style=flat-square)](https://cran.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg?style=flat-square)]()

> 🌿 **Ứng dụng đánh giá chất lượng môi trường theo Quy chuẩn Việt Nam (QCVN)**

---

## 📥 Download

### Windows Installers

| Version | Size | Description | Download |
|---------|------|-------------|----------|
| **🪶 Lightweight** | ~2 MB | Requires R installed | [Download](https://github.com/lastnight030506/enviroanalyzer-pro/releases/latest/download/EnviroAnalyzer_Lightweight_Setup.exe) |
| **📦 Standalone** | ~300 MB | Includes R Portable, works out-of-the-box | [Download](https://github.com/lastnight030506/enviroanalyzer-pro/releases/latest/download/EnviroAnalyzer_Standalone_Setup.exe) |

### Which version should I choose?

| If you... | Choose |
|-----------|--------|
| Already have R installed | **Lightweight** (smaller download) |
| Don't have R / Unsure | **Standalone** (just works) |
| Want offline use | **Standalone** (all included) |
| Limited disk space | **Lightweight** + install R |

---

## ✨ Tính năng

- 📊 **Đánh giá tuân thủ QCVN** - Nước, Không khí, Đất, Tiếng ồn
- 📈 **Trực quan hóa** - Radar, Gauge, Heatmap, Bar charts
- 📁 **Import/Export** - Excel (.xlsx), CSV
- 🌙 **Dark/Light mode** - Tùy chỉnh giao diện
- ⚡ **Xử lý nhanh** - Hỗ trợ 100+ samples

---

## 🚀 Run from Source

### Requirements
- [R >= 4.0](https://cran.r-project.org/bin/windows/base/)

### Quick Start

```bash
# Clone repository
git clone https://github.com/lastnight030506/enviroanalyzer-pro.git
cd enviroanalyzer-pro

# Run app
Rscript run.R
```

Hoặc mở R Console:

```r
setwd("path/to/enviroanalyzer-pro")
source("run.R")
```

App sẽ mở tại: **http://127.0.0.1:3838**

## 📋 QCVN Hỗ trợ

| Ma trận | Quy chuẩn | Cột áp dụng |
|---------|-----------|-------------|
| **Nước mặt** | QCVN 08-MT:2015/BTNMT | A1, A2, B1, B2 |
| **Nước thải CN** | QCVN 40:2011/BTNMT | A, B |
| **Nước thải SH** | QCVN 14:2008/BTNMT | A, B |
| **Không khí** | QCVN 05:2023/BTNMT | TB1h, TB24h, TBnăm |
| **Đất** | QCVN 03-MT:2015/BTNMT | Nông nghiệp, Dân cư, CN |
| **Tiếng ồn** | QCVN 26:2010/BTNMT | Ngày, Đêm |

## 📁 Cấu trúc

```
enviroanalyzer-pro/
├── app.R          # Ứng dụng Shiny chính
├── constants.R    # Định nghĩa QCVN standards
├── functions.R    # Logic xử lý dữ liệu
├── visuals.R      # Hàm trực quan hóa
├── run.R          # Script khởi chạy
├── LICENSE
└── README.md
```

## 🎯 Sử dụng

1. **Chọn loại ma trận** (Nước/Khí/Đất/Tiếng ồn)
2. **Chọn QCVN** và cột áp dụng
3. **Nhập dữ liệu** hoặc import từ Excel
4. **Xem kết quả** đánh giá tuân thủ
5. **Xuất báo cáo** Excel/PDF

## 📦 Dependencies

```r
shiny, shinyjs, bslib, thematic, tidyverse, 
gt, DT, shinyWidgets, rhandsontable, writexl, 
scales, readxl
```

## 📄 License

MIT License - Xem [LICENSE](LICENSE)

## 👤 Author

Last Night

---

⭐ **Star repo này nếu hữu ích!**
