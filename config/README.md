# Config Folder

Thư mục này chứa các file cấu hình của ứng dụng.

## Files

### `user_config.json`
File cấu hình cá nhân của người dùng. Tự động tạo khi chạy app lần đầu.

**Nội dung:**
- `theme`: Cài đặt giao diện (màu sắc, dark/light mode)
- `ai`: Cài đặt AI Assistant (bật/tắt, endpoint)
- `display`: Hiển thị (số thập phân, số dòng/trang)
- `qcvn`: QCVN đã chọn gần nhất
- `export`: Cài đặt xuất file

**⚠️ Lưu ý:**
- File này được gitignore để bảo vệ cài đặt cá nhân
- Nếu xóa file, app sẽ tự tạo lại với cài đặt mặc định
- Không cần chỉnh sửa thủ công - dùng Settings Modal trong app

## Backup & Restore

### Backup
```bash
# Copy file config ra ngoài để lưu
copy config\user_config.json config\user_config.backup.json
```

### Restore
```bash
# Khôi phục từ backup
copy config\user_config.backup.json config\user_config.json
```

## Reset về mặc định

Xóa file `user_config.json` và restart app:
```bash
del config\user_config.json
```

Hoặc dùng nút "Reset to Defaults" trong Settings Modal.
