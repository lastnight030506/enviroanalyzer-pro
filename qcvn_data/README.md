# ============================================================================ #
#                 README - HƯỚNG DẪN TẠO QCVN TÙY CHỈNH                         #
# ============================================================================ #

## Giới thiệu

Thư mục này chứa các file QCVN tùy chỉnh của bạn. Bạn có thể thêm các quy chuẩn 
mới bằng cách tạo file JSON theo template mẫu.

## Cách thêm QCVN mới

### Bước 1: Download Template
Trong ứng dụng, click nút **"Download Template QCVN"** để tải file mẫu.

### Bước 2: Chỉnh sửa Template
Mở file `qcvn_template.json` và điền thông tin:

```json
{
  "name": "QCVN 99:2024/BTNMT",
  "description": "Quy chuẩn của tôi",
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

### Bước 3: Lưu file
Lưu file với tên mới (VD: `qcvn_99_2024.json`) vào thư mục `qcvn_data/custom/`

### Bước 4: Tải lên ứng dụng
Trong app, dùng nút **"Upload QCVN"** để tải file lên.

## Cấu trúc File JSON

### Các trường bắt buộc:

- **name**: Tên QCVN (string)
- **description**: Mô tả (string)
- **category**: Loại ("water", "air", "soil", "noise", "other")
- **unit**: Đơn vị đo (string)
- **columns**: Mảng tên cột (array)
- **column_descriptions**: Mô tả các cột (object)
- **parameters**: Các thông số và giới hạn (object)

### Loại kiểm tra (type):

- **"max"**: Giá trị phải ≤ ngưỡng
  ```json
  "BOD5": { "A": 30, "B": 50, "type": "max" }
  ```

- **"min"**: Giá trị phải ≥ ngưỡng
  ```json
  "DO": { "A": 6, "B": 4, "type": "min" }
  ```

- **"range"**: Giá trị trong khoảng [min, max]
  ```json
  "pH": { "A": [6, 9], "B": [5.5, 9], "type": "range" }
  ```

## Ví dụ QCVN Đầy đủ

Xem file `examples/qcvn_example_full.json` để tham khảo.

## Lưu ý

1. File JSON phải tuân thủ cú pháp đúng
2. Tất cả parameters phải có giá trị cho tất cả các columns
3. Với type="range", giá trị phải là mảng [min, max]
4. Với type="max" hoặc "min", giá trị là số đơn

## Hỗ trợ

Nếu gặp lỗi khi tải QCVN, kiểm tra:
- Cú pháp JSON có đúng không (dùng jsonlint.com)
- Tất cả trường bắt buộc đã có chưa
- Type và giá trị có khớp nhau không
