# 📊 HƯỚNG DẪN SỬ DỤNG TEMPLATE QCVN (EXCEL)

## ✨ Tính Năng Mới: Template Excel Trực Quan

EnviroAnalyzer Pro v3.1 đã nâng cấp hệ thống QCVN với template **Excel** thay vì JSON - dễ nhìn, dễ sửa như bảng tính thông thường!

---

## 📥 DOWNLOAD TEMPLATE

1. Mở EnviroAnalyzer Pro
2. Trong sidebar, phần **"QCVN Standard"**
3. Click nút **⬇️** (Download)
4. Lưu file `qcvn_template_YYYYMMDD.xlsx`

---

## 📝 CẤU TRÚC FILE EXCEL

File template có 7 sheets:

### 1️⃣ **Thong_Tin** - Thông tin cơ bản
| Field | Value | Description |
|-------|-------|-------------|
| name | QCVN XX:YYYY/BTNMT | Tên quy chuẩn |
| description | Mô tả... | Mô tả chi tiết |
| category | water/air/soil/noise | Loại quy chuẩn |
| unit | mg/L | Đơn vị đo |

### 2️⃣ **Cot** - Định nghĩa các cột
| Column_ID | Column_Name | Description |
|-----------|-------------|-------------|
| A | Loại A | Xả vào nguồn nước sinh hoạt |
| B | Loại B | Xả vào nguồn nước khác |

### 3️⃣ **Thong_So** - Các thông số và giới hạn
| Parameter | Type | A_Min | A_Max | B_Min | B_Max | Unit | Description |
|-----------|------|-------|-------|-------|-------|------|-------------|
| pH | range | 6 | 9 | 5.5 | 9 | | Độ pH |
| BOD5 | max | | 30 | | 50 | mg/L | BOD5 |
| DO | min | | 6 | | 4 | mg/L | Oxy hòa tan |

### 4️⃣ **Huong_Dan** - Hướng dẫn chi tiết

### 5️⃣-7️⃣ **Vi_Du_*** - Ví dụ hoàn chỉnh

---

## 🔧 CÁCH CHỈNH SỬA

### Bước 1: Mở Excel Template
- Mở file `.xlsx` vừa download bằng Excel

### Bước 2: Điền Sheet "Thong_Tin"
```
name:        QCVN 99:2024/BTNMT
description: Quy chuẩn nước thải dệt nhuộm
category:    water
unit:        mg/L
```

### Bước 3: Khai báo cột trong "Cot"
```
Column_ID | Column_Name | Description
A         | Loại A      | Nghiêm ngặt
B         | Loại B      | Ít nghiêm ngặt
```

💡 **Thêm nhiều cột:** Chỉ cần thêm hàng mới với Column_ID khác

### Bước 4: Nhập thông số vào "Thong_So"

#### 📌 Loại "max" - Giá trị tối đa
```
Parameter | Type | A_Max | B_Max
BOD5      | max  | 30    | 50
COD       | max  | 75    | 150
TSS       | max  | 50    | 100
```
→ Chỉ điền cột **_Max**

#### 📌 Loại "min" - Giá trị tối thiểu
```
Parameter | Type | A_Max | B_Max
DO        | min  | 6     | 4
```
→ Chỉ điền cột **_Max** (tên column hơi misleading nhưng đúng!)

#### 📌 Loại "range" - Khoảng giá trị
```
Parameter | Type  | A_Min | A_Max | B_Min | B_Max
pH        | range | 6     | 9     | 5.5   | 9
```
→ Điền cả **_Min** và **_Max**

### Bước 5: Lưu file Excel

---

## 📤 UPLOAD VÀO APP

1. Trong EnviroAnalyzer Pro
2. Click nút **📤 Upload** (bên cạnh nút Download)
3. Chọn file Excel đã chỉnh sửa
4. App sẽ tự động:
   - Validate format
   - Chuyển sang JSON
   - Lưu vào `qcvn_data/custom/`
   - Load QCVN mới ngay lập tức

✅ **Thành công!** QCVN mới đã sẵn sàng để sử dụng

---

## 🎯 VÍ DỤ HOÀN CHỈNH

Xem các sheet **Vi_Du_*** trong template để có ví dụ:
- **Vi_Du_Info**: Thông tin QCVN nước thải dệt nhuộm
- **Vi_Du_Cot**: 2 cột A, B
- **Vi_Du_Params**: 7 thông số với các loại khác nhau

---

## ⚠️ LƯU Ý QUAN TRỌNG

✔️ **Column_ID phải khớp** giữa sheet "Cot" và "Thong_So"
   - Nếu khai báo `Column_ID = "A"`, phải có cột `A_Min` và `A_Max`

✔️ **Mỗi thông số cần đủ giá trị** cho tất cả các cột
   - Ví dụ: Có 2 cột A, B → BOD5 phải có giá trị cho cả A và B

✔️ **Type phải đúng:**
   - `max`: Chỉ điền _Max
   - `min`: Chỉ điền _Max (yes, _Max!)  
   - `range`: Điền cả _Min và _Max

✔️ **Có thể thêm nhiều cột** bằng cách:
   - Thêm hàng mới trong sheet "Cot"
   - Thêm cột mới `X_Min`, `X_Max` trong sheet "Thong_So"

---

## 🚀 CHẠY APP

### Electron Mode (Ứng dụng Windows)
```bash
cd electron
npm start
```
→ Mở như app bình thường (không có thanh URL)

### Browser Mode (Truyền thống)
```bash
Rscript run.R
```
→ Mở trong trình duyệt tại http://127.0.0.1:3838

---

## 🔄 QUẢN LÝ QCVN

### Xem QCVN hiện có
- File defaults: `qcvn_data/defaults/*.json`
- File custom: `qcvn_data/custom/*.json`

### Xóa QCVN tùy chỉnh
- Xóa file trong `qcvn_data/custom/`
- Khởi động lại app

### Backup
- Sao chép toàn bộ thư mục `qcvn_data/custom/`

---

## 💡 TIPS & TRICKS

🔹 **Excel > JSON**: Dễ chỉnh sửa, trực quan, ít lỗi cú pháp

🔹 **Copy-Paste**: Copy hàng trong Excel để tạo thông số mới nhanh

🔹 **Ví dụ có sẵn**: Luôn tham khảo sheet Vi_Du_* khi không chắc

🔹 **Test nhỏ**: Upload 1 QCVN đơn giản trước khi làm phức tạp

🔹 **Port động**: Electron tự tìm port trống → không lo conflict

---

## ❓ TROUBLESHOOTING

**Q: Upload bị lỗi "File thiếu các trường"?**  
A: Kiểm tra sheet "Thong_Tin" có đủ 4 trường: name, description, category, unit

**Q: Thông số không hiển thị?**  
A: Column_ID trong "Cot" phải khớp với tên cột trong "Thong_So"

**Q: Cache errors khi chạy Electron?**  
A: Bỏ qua, không ảnh hưởng chức năng

**Q: Port 3838 conflict?**  
A: Electron mode tự động tìm port khác (3839, 3840, ...)

---

**📞 Support:** Xem thêm trong `qcvn_data/HUONG_DAN_SU_DUNG.md`

**🎉 Enjoy your streamlined QCVN management!**
