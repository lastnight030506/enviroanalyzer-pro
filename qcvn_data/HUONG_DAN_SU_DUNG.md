# Hệ Thống Quản Lý QCVN - EnviroAnalyzer Pro

## 📋 Tổng Quan

Phiên bản 3.1 của EnviroAnalyzer Pro đã được nâng cấp với hệ thống quản lý QCVN linh hoạt, cho phép người dùng dễ dàng thêm và quản lý các quy chuẩn tùy chỉnh.

## 🗂️ Cấu Trúc Thư Mục

```
qcvn_data/
├── defaults/           # QCVN mặc định (không nên chỉnh sửa)
│   ├── qcvn_08_surface_water.json
│   ├── qcvn_40_industrial_wastewater.json
│   ├── qcvn_14_domestic_wastewater.json
│   ├── qcvn_05_ambient_air.json
│   ├── qcvn_03_soil.json
│   └── qcvn_26_noise.json
├── custom/             # QCVN tùy chỉnh của người dùng
│   └── README.txt
├── qcvn_template.json  # Template để tạo QCVN mới
└── qcvn_template_schema.json  # JSON Schema để validate
```

## ✨ Tính Năng Mới

### 1. Download Template QCVN
- Click nút **⬇️** bên cạnh "QCVN Standard" trong sidebar
- Tải về file `qcvn_template.json` để làm mẫu

### 2. Upload QCVN Tùy Chỉnh
- Click nút **📤 Upload** 
- Chọn file JSON đã chỉnh sửa
- QCVN sẽ được thêm vào hệ thống ngay lập tức

### 3. Tự Động Load QCVN
- App tự động load tất cả QCVN từ `qcvn_data/defaults/`
- Sau đó load thêm QCVN từ `qcvn_data/custom/`
- Custom QCVN sẽ ghi đè defaults nếu trùng tên

## 📝 Hướng Dẫn Tạo QCVN Mới

### Bước 1: Download Template
```json
{
  "name": "QCVN XX:YYYY/BTNMT",
  "description": "Mô tả quy chuẩn",
  "category": "water",  // water, air, soil, noise, other
  "unit": "mg/L",
  "columns": ["A", "B"],
  "column_descriptions": {
    "A": "Mô tả cột A",
    "B": "Mô tả cột B"
  },
  "parameters": {
    "pH": {
      "A": [6, 9],      // Range: [min, max]
      "B": [5.5, 9],
      "type": "range"
    },
    "BOD5": {
      "A": 30,          // Max value
      "B": 50,
      "type": "max"
    }
  }
}
```

### Bước 2: Chỉnh Sửa Template

#### Các trường bắt buộc:
- **name**: Tên QCVN (string)
- **description**: Mô tả chi tiết (string)
- **category**: `"water"`, `"air"`, `"soil"`, `"noise"`, hoặc `"other"`
- **unit**: Đơn vị đo (ví dụ: `"mg/L"`, `"µg/m³"`, `"dBA"`)
- **columns**: Mảng tên các cột
- **column_descriptions**: Mô tả cho từng cột
- **parameters**: Object chứa các thông số

#### Loại kiểm tra (type):
1. **"max"** - Giá trị tối đa cho phép
   ```json
   "BOD5": { "A": 30, "B": 50, "type": "max" }
   ```

2. **"min"** - Giá trị tối thiểu yêu cầu
   ```json
   "DO": { "A": 6, "B": 4, "type": "min" }
   ```

3. **"range"** - Khoảng giá trị cho phép [min, max]
   ```json
   "pH": { "A": [6, 9], "B": [5.5, 9], "type": "range" }
   ```

### Bước 3: Validate JSON
Sử dụng https://jsonlint.com/ để kiểm tra cú pháp JSON

### Bước 4: Upload vào App
- Mở EnviroAnalyzer Pro
- Click nút **📤 Upload** trong phần QCVN Standard
- Chọn file JSON của bạn
- Hệ thống sẽ tự động validate và load QCVN mới

## 🔄 Quản Lý QCVN

### Load Lại QCVN
```r
# Trong R console hoặc app
reload_qcvn_standards()
```

### Xóa QCVN Tùy Chỉnh
Xóa file JSON tương ứng trong `qcvn_data/custom/` và khởi động lại app

### Sửa QCVN
1. Tìm file JSON trong `qcvn_data/custom/`
2. Chỉnh sửa trực tiếp hoặc
3. Download lại, sửa, và upload lại

## 📖 Ví Dụ QCVN Đầy Đủ

### QCVN Nước Thải (2 Cột)
```json
{
  "name": "QCVN 99:2024/BTNMT",
  "description": "Quy chuẩn tùy chỉnh về nước thải",
  "category": "water",
  "unit": "mg/L",
  "columns": ["A", "B"],
  "column_descriptions": {
    "A": "Loại A - Nghiêm ngặt",
    "B": "Loại B - Ít nghiêm ngặt"
  },
  "parameters": {
    "pH": {
      "A": [6, 8.5],
      "B": [5.5, 9],
      "type": "range"
    },
    "DO": {
      "A": 6,
      "B": 4,
      "type": "min"
    },
    "BOD5": {
      "A": 30,
      "B": 50,
      "type": "max"
    },
    "COD": {
      "A": 75,
      "B": 150,
      "type": "max"
    },
    "TSS": {
      "A": 50,
      "B": 100,
      "type": "max"
    },
    "NH4_N": {
      "A": 5,
      "B": 10,
      "type": "max"
    },
    "Fe": {
      "A": 1,
      "B": 5,
      "type": "max"
    }
  }
}
```

### QCVN Không Khí (4 Cột)
```json
{
  "name": "QCVN Air Custom:2024/BTNMT",
  "description": "Quy chuẩn không khí tùy chỉnh",
  "category": "air",
  "unit": "µg/m³",
  "columns": ["TB1h", "TB8h", "TB24h", "TBnam"],
  "column_descriptions": {
    "TB1h": "Trung bình 1 giờ",
    "TB8h": "Trung bình 8 giờ",
    "TB24h": "Trung bình 24 giờ",
    "TBnam": "Trung bình năm"
  },
  "parameters": {
    "PM2_5": {
      "TB24h": 50,
      "TBnam": 25,
      "type": "max"
    },
    "PM10": {
      "TB24h": 100,
      "TBnam": 50,
      "type": "max"
    },
    "SO2": {
      "TB1h": 350,
      "TB24h": 125,
      "TBnam": 50,
      "type": "max"
    },
    "NO2": {
      "TB1h": 200,
      "TB24h": 100,
      "TBnam": 40,
      "type": "max"
    }
  }
}
```

## 🛠️ Troubleshooting

### Lỗi: "File JSON thiếu các trường"
✅ Kiểm tra tất cả trường bắt buộc đã có đầy đủ

### Lỗi: "Could not parse JSON"
✅ Validate JSON tại https://jsonlint.com/

### QCVN không hiển thị sau khi upload
✅ Kiểm tra category có đúng không (water/air/soil/noise/other)
✅ Reload lại trang hoặc khởi động lại app

### Giá trị không khớp với type
✅ `"range"` cần mảng: `[min, max]`
✅ `"max"` và `"min"` cần số đơn: `30`

## 🔐 Bảo Mật & Backup

### Backup QCVN Tùy Chỉnh
Sao chép toàn bộ thư mục `qcvn_data/custom/` ra nơi an toàn

### Khôi Phục Mặc Định
Xóa tất cả file trong `qcvn_data/custom/` và khởi động lại app

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra file JSON có đúng cú pháp không
2. Đọc kỹ hướng dẫn trong `qcvn_data/README.md`
3. Xem ví dụ trong `qcvn_data/defaults/`
4. Liên hệ support team

## 🎯 Lưu Ý Quan Trọng

⚠️ **KHÔNG** chỉnh sửa trực tiếp file trong `qcvn_data/defaults/`
⚠️ Luôn backup QCVN tùy chỉnh trước khi update app
⚠️ Mỗi parameter phải có giá trị cho TẤT CẢ các columns
⚠️ JSON phải tuân thủ cú pháp nghiêm ngặt (dấu phẩy, ngoặc, etc.)

---

**EnviroAnalyzer Pro v3.1** - Hệ thống quản lý QCVN linh hoạt & dễ sử dụng
