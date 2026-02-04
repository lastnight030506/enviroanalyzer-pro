# EnviroAnalyzer v1.0.0

[![Release](https://img.shields.io/badge/Version-1.0.0-blue.svg?style=flat-square)]()
[![R](https://img.shields.io/badge/R-4.0%2B-blue.svg?style=flat-square)](https://cran.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg?style=flat-square)]()

> 🌿 **Ứng dụng đánh giá chất lượng môi trường theo Quy chuẩn Việt Nam (QCVN)**

## ✨ Tính năng

- 📊 **Đánh giá tuân thủ QCVN** - Nước, Không khí, Đất, Tiếng ồn
- 📈 **Trực quan hóa** - Radar, Gauge, Heatmap, Bar charts
- 📁 **Import/Export** - Excel (.xlsx), CSV
- 🌙 **Dark/Light mode** - Tùy chỉnh giao diện đầy đủ
- ⚡ **Xử lý nhanh** - Hỗ trợ 100+ samples
- ➕ **QCVN tùy chỉnh** - Thêm quy chuẩn riêng qua JSON
- 🤖 **AI Analysis** - Tích hợp n8n để phân tích bằng AI (chỉ cần WiFi)
- 💾 **Config persist** - Tự động lưu cài đặt người dùng

---

## 🚀 Khởi chạy nhanh

### Yêu cầu
- [R >= 4.0](https://cran.r-project.org/bin/windows/base/)
- Kết nối internet (lần đầu để cài packages)

### Cách 1: Khởi chạy trực tiếp

**Windows:**
```bash
# Double-click vào file
KHOI_CHAY_APP.vbs
```

**Hoặc dùng Terminal:**
```bash
cd enviroanalyzer-pro-main
Rscript run.R
```

App sẽ tự động:
- ✅ Kiểm tra và cài đặt R packages cần thiết
- ✅ Khởi động Shiny server
- ✅ Mở trình duyệt tại http://127.0.0.1:3838

### Cách 2: Chạy trong R Console

```r
setwd("path/to/enviroanalyzer-pro-main")
source("run.R")
```

---

## ➕ Thêm QCVN Tùy Chỉnh

### Phương pháp 1:              # Ứng dụng Shiny chính
├── constants.R                 # Định nghĩa QCVN standards
├──📁 Cấu trúc Project

```
enviroanalyzer-pro-main/
├── 📄 app.R                    # Ứng dụng Shiny chính
├── 📄 run.R                    # Script khởi chạy
├── 📄 KHOI_CHAY_APP.vbs        # Launcher cho Windows (double-click)
├── 📄 README.md                # Tài liệu này
│
├─ ⚙️ Cài đặt & Cấu hình

### Settings Modal (⚙️)

Click icon bánh răng ở góc phải để mở Settings:

**🎨 Theme & Colors**
- Dark/Light mode
- Accent color (màu chủ đạo)
- Success/Warning/Danger colors

**💻 Display**
## 📋 QCVN được hỗ trợ

| Ma trận | Quy chuẩn | Cột áp dụng | File JSON |
|---------|-----------|-------------|-----------|
| **Nước mặt** | QCVN 08-MT:2015/BTNMT | A1, A2, B1, B2 | `qcvn_08_surface_water.json` |
| **Nước thải CN** | QCVN 40:2011/BTNMT | A, B | `qcvn_40_industrial_wastewater.json` |
| **Nước thải SH** | QCVN 14:2008/BTNMT | A, B | `qcvn_14_domestic_wastewater.json` |
| **Không khí** | QCVN 05:2023/BTNMT | TB1h, TB24h, TBnăm | `qcvn_05_ambient_air.json` |
| **Đất** | QCVN 03-MT:2015/BTNMT | Nông nghiệp, Dân cư, CN | `qcvn_03_soil.json` |
| **Tiếng ồn** | QCVN 26:2010/BTNMT | Ngày, Đêm | `qcvn_26_noise.json` |

**Thêm QCVN tùy chỉnh:**
1. Copy file JSON từ `qcvn_data/defaults/` làm template
2. Chỉnh sửa theo QCVN mới
3. Lưu vào `qcvn_data/custom/`
4. Restart app

📖 **Chi tiết:** [qcvn_data/README.md](qcvn_data/README.md)*QCVN mới đã sẵn sàng!**

### Phương pháp 2: JSON File

Tạo file JSON theo cấu trúc:

```json
{
  "name": "QCVN 99:2024/BTNMT",
  "description": "Quy chuẩn tùy chỉnh",
  "category": "water",
  "unit": "mg/L",
  "columns": ["A", "B"],
  "column_descriptions": {
    "A": "Loại A",
    "B": "Loại B"
  },
  "parameters": {
    "pH": {
      "A": [6, 9],
      "B": [5.5, 9],
      "type": "range"
    },
    "BOD5": {
      "A": 30,
      "B": 50,
      "type": "max"
    }
  }
}
```

Upload file JSON tương tự như Excel.

### 📂 Quản lý QCVN

```
qcvn_data/
├── defaults/       # QCVN mặc định (6 quy chuẩn)
├── custom/         # QCVN tùy chỉnh của bạn
├── qcvn_template.xlsx
├── qcvn_template.json
└── README.md
```

**Xem chi tiết:** [`HUONG_DAN_EXCEL_TEMPLATE.md`](HUONG_DAN_EXCEL_TEMPLATE.md)

---

##p sẽ mở tại: **http://127.0.0.1:3838**

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
### R Packages
```r
shiny, shinyjs, bslib, thematic, tidyverse, 
gt, DT, shinyWidgets, rhandsontable, writexl, 
scales, readxl, jsonlite
```
� Tài Liệu

- 📖 [Hướng dẫn Excel Template](HUONG_DAN_EXCEL_TEMPLATE.md) - Chi tiết cách tạo QCVN
- 📋 [Hướng dẫn QCVN](qcvn_data/HUONG_DAN_SU_DUNG.md) - Quản lý QCVN toàn diện
- 📝 [README QCVN](qcvn_data/README.md) - Tổng quan thư mục QCVN

## ❓ FAQ

**Q: Làm sao thêm QCVN riêng?**  
A: Download template Excel, điền thông tin, upload lại. Xem [hướng dẫn chi tiết](HUONG_DAN_EXCEL_TEMPLATE.md).

**Q: Excel hay JSON tốt hơn?**  
A: Excel dễ hơn, trực quan hơn. JSON phù hợp nếu bạn quen code.

**Q: Electron hay Browser mode?**  
A: Electron = app Windows bình thường. Browser = mở trong trình duyệt. Cả 2 đều hoạt động giống nhau.

**Q: Port conflict khi chạy?**  
A: Electron tự động tìm port trống. Browser mode dùng port 3838 cố định.

## 📄 License

MIT License - Xem [LICENSE](LICENSE)

## 👤 Author

Last Night

---

⭐ **Star repo này nếu hữu ích!**

🐛 **Báo lỗi:** [Issues](https://github.com/lastnight030506/enviroanalyzer-pro/issues)

📧 **Liên hệ:** [GitHub Profile](https://github.com/lastnight030506)
3. **Nhập dữ liệu** hoặc import từ Excel
4. **Xem kết quả** đánh giá tuân thủ
5. **Xuất báo cáo** Excel/PDF

## 📦 Dependencies

```r
shiny, shinyjs, bslib, thematic, tidyverse, 
gt, DT, shinyWidgets, rhandsontable, writexl, 
scales, readxl, jsonlite, httr, plumber, markdown
```

**Cho AI features:** n8n + OpenAI API key

---

## 🤖 AI Assistant - Plug & Play!

### 👤 Người dùng: Chỉ cần bật lên là dùng!

1. Mở app → Click ⚙️ Settings
2. Bật **"Enable AI Analysis"** 
3. Đợi 3 giây → Thấy "✅ AI is online"
4. Xong! Dùng AI ngay:
   - 🔍 Phân tích kết quả
   - 💡 Gợi ý khắc phục
   - 📖 Giải thích dễ hiểu
   - 📄 Tạo báo cáo tự động

## 🤖 AI Assistant

### 👤 Dành cho người dùng

**Bật AI trong 3 bước:**
1. Click ⚙️ Settings
2. Bật toggle **"Enable AI Analysis"**
3. Đợi kiểm tra kết nối → Thấy ✅ "AI Assistant đã sẵn sàng!"

**Yêu cầu:** Chỉ cần Internet! (n8n endpoint đã được config sẵn)

**Tính năng AI:**
- 🔍 Phân tích kết quả đánh giá
- 💡 Đưa ra khuyến nghị
- 📝 Giải thích dễ hiểu
- ⚠️ Cảnh báo rủi ro

**Lưu ý:**
- Nếu không có mạng → App thông báo "❌ Không thể kết nối"
- AI tự động tắt nếu mất kết nối
- Toggle lại để thử kết nối lại

### 👨‍💻 Dành cho Developer

Setup AI service với n8n:
1. Tạo workflow trong n8n (Cloud hoặc self-hosted)
2. Config endpoint trong `src/n8n_config.R`:
```r
DEFAULT_N8N_ENDPOINT <- "https://your-n8n.com/webhook/..."
```
3. Build app → User dùng ngay

📖 **Hướng dẫn chi tiết:** [docs/n8n_workflows/SETUP_GUIDE.md](docs/n8n_workflows/SETUP_GUIDE.md)

---

## 📦 Dependencies

### R Packages
```r
shiny, shinyjs, bslib, tidyverse, gt, DT, 
shinyWidgets, rhandsontable, writexl, readxl, 
scales, colourpicker, jsonlite, httr
```

**Cài đặt tự động:** File `run.R` sẽ tự kiểm tra và cài packages thiếu

### Optional: Electron (Native Windows App)
```bash
cd electron
npm install
npm start
```

---

## 🎓 Tài liệu

| File | Nội dung |
|------|----------|
| **[config/README.md](config/README.md)** | Hướng dẫn quản lý cài đặt |
| **[qcvn_data/README.md](qcvn_data/README.md)** | Quản lý QCVN, thêm QCVN mới |
| **[docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** | Cấu trúc chi tiết project |
| **[docs/n8n_workflows/SETUP_GUIDE.md](docs/n8n_workflows/SETUP_GUIDE.md)** | Setup AI với n8n |

---

## ❓ FAQ

**Q: File config ở đâu?**  
A: `config/user_config.json` - Tự động tạo khi chạy lần đầu.

**Q: Làm sao backup cài đặt?**  
A: Copy file `config/user_config.json` ra ngoài để backup.

**Q: Reset về cài đặt mặc định?**  
A: Xóa file `config/user_config.json` hoặc dùng nút "Reset to Defaults" trong Settings.

**Q: Làm sao thêm QCVN mới?**  
A: Copy file JSON từ `qcvn_data/defaults/`, chỉnh sửa, lưu vào `qcvn_data/custom/`.

**Q: AI không kết nối được?**  
A: Kiểm tra Internet. Nếu vẫn lỗi, liên hệ developer để kiểm tra n8n endpoint.

**Q: App không khởi chạy?**  
A: 
- Kiểm tra R đã cài đúng version >= 4.0
- Chạy `Rscript run.R` trong terminal để xem lỗi chi tiết
- Port 3838 có thể bị chiếm - đóng app khác đang dùng port này

---