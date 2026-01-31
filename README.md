# EnviroAnalyzer Pro v3.0

[![R](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://cran.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-1.7%2B-green.svg)](https://shiny.rstudio.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 🌿 **Ứng dụng đánh giá chất lượng môi trường theo Quy chuẩn Việt Nam (QCVN)**

## ✨ Tính năng

- 📊 **Đánh giá tuân thủ QCVN** - Nước, Không khí, Đất, Tiếng ồn
- 📈 **Trực quan hóa** - Radar, Gauge, Heatmap, Bar charts
- 📁 **Import/Export** - Excel (.xlsx), CSV
- 🌙 **Dark/Light mode** - Tùy chỉnh giao diện
- ⚡ **Xử lý nhanh** - Hỗ trợ 100+ samples

## 🚀 Cài đặt & Chạy

### Yêu cầu
- [R >= 4.0](https://cran.r-project.org/bin/windows/base/)

### Chạy ứng dụng

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/enviroanalyzer-pro.git
cd enviroanalyzer-pro

# Chạy app
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
