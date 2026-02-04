# EnviroAnalyzer Pro - API Documentation for n8n Integration

## 🔌 Base URL
```
http://localhost:3839
```

## 📚 Available Endpoints

### 1. Health Check
```http
GET /health
```
Kiểm tra API server có hoạt động không.

**Response:**
```json
{
  "status": "ok",
  "version": "3.1.0",
  "timestamp": "2026-02-04T10:30:00Z",
  "message": "EnviroAnalyzer Pro API is running"
}
```

---

### 2. List QCVN Standards
```http
GET /api/qcvn/list
```
Lấy danh sách tất cả QCVN có sẵn.

**Response:**
```json
{
  "success": true,
  "count": 6,
  "data": [
    {
      "id": "Surface_Water",
      "name": "QCVN 08-MT:2015/BTNMT",
      "description": "Quy chuẩn chất lượng nước mặt",
      "category": "water",
      "unit": "mg/L",
      "columns": ["A1", "A2", "B1", "B2"],
      "parameter_count": 15
    }
  ]
}
```

---

### 3. Get QCVN Details
```http
GET /api/qcvn/{id}
```
Lấy chi tiết một QCVN cụ thể.

**Parameters:**
- `id` - ID của QCVN (VD: `Surface_Water`, `Industrial_Wastewater`)

**Response:**
```json
{
  "success": true,
  "data": {
    "name": "QCVN 08-MT:2015/BTNMT",
    "description": "...",
    "unit": "mg/L",
    "columns": ["A1", "A2", "B1", "B2"],
    "parameters": {
      "pH": {
        "A1": [6, 8.5],
        "type": "range"
      }
    }
  }
}
```

---

### 4. Upload QCVN
```http
POST /api/qcvn/upload
Content-Type: application/json
```
Upload QCVN mới vào hệ thống.

**Request Body:**
```json
{
  "qcvn_data": {
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
}
```

**Response:**
```json
{
  "success": true,
  "message": "QCVN uploaded: QCVN 99:2024/BTNMT",
  "file": "qcvn_data/custom/n8n_QCVN_99_2024_BTNMT.json"
}
```

---

### 5. Assess Data (Full)
```http
POST /api/assess
Content-Type: application/json
```
Đánh giá đầy đủ một bộ dữ liệu theo QCVN.

**Request Body:**
```json
{
  "data": {
    "qcvn_id": "Surface_Water",
    "column": "A1",
    "samples": [
      {"parameter": "pH", "value": 7.5},
      {"parameter": "BOD5", "value": 25},
      {"parameter": "DO", "value": 5.2},
      {"parameter": "TSS", "value": 45}
    ]
  }
}
```

**Response:**
```json
{
  "success": true,
  "qcvn": "QCVN 08-MT:2015/BTNMT",
  "column": "A1",
  "summary": {
    "total": 4,
    "pass": 3,
    "warning": 1,
    "fail": 0,
    "compliance_rate": 75.0
  },
  "results": [
    {
      "Parameter": "pH",
      "Value": 7.5,
      "Limit": "6 - 8.5",
      "Status": "Đạt",
      "Percentage": 0
    },
    {
      "Parameter": "BOD5",
      "Value": 25,
      "Limit": "4",
      "Status": "Không đạt",
      "Percentage": 625
    }
  ]
}
```

---

### 6. Assess Single Parameter
```http
POST /api/assess/single
Content-Type: application/json
```
Đánh giá nhanh một thông số đơn lẻ.

**Request Body:**
```json
{
  "data": {
    "qcvn_id": "Surface_Water",
    "column": "A1",
    "parameter": "pH",
    "value": 7.5,
    "warning_threshold": 0.8
  }
}
```

**Response:**
```json
{
  "success": true,
  "qcvn": "Surface_Water",
  "parameter": "pH",
  "column": "A1",
  "value": 7.5,
  "result": {
    "status": "Đạt",
    "percentage": 0,
    "limit": "6 - 8.5",
    "message": "Giá trị nằm trong giới hạn cho phép"
  }
}
```

---

### 7. Batch Assessment
```http
POST /api/batch/assess
Content-Type: application/json
```
Xử lý đánh giá hàng loạt nhiều samples cùng lúc.

**Request Body:**
```json
{
  "data": {
    "batches": [
      {
        "id": "sample_001",
        "qcvn_id": "Surface_Water",
        "column": "A1",
        "samples": [
          {"parameter": "pH", "value": 7.5},
          {"parameter": "BOD5", "value": 3.2}
        ]
      },
      {
        "id": "sample_002",
        "qcvn_id": "Surface_Water",
        "column": "A2",
        "samples": [
          {"parameter": "pH", "value": 8.0},
          {"parameter": "COD", "value": 12}
        ]
      }
    ]
  }
}
```

**Response:**
```json
{
  "success": true,
  "total_batches": 2,
  "results": [
    {
      "batch_id": "sample_001",
      "success": true,
      "qcvn": "Surface_Water",
      "column": "A1",
      "results": [...]
    },
    {
      "batch_id": "sample_002",
      "success": true,
      "qcvn": "Surface_Water",
      "column": "A2",
      "results": [...]
    }
  ]
}
```

---

### 8. Convert Data Format
```http
POST /api/convert
Content-Type: application/json
```
Chuyển đổi dữ liệu giữa các format.

**Request Body:**
```json
{
  "data": {
    "input_format": "json",
    "output_format": "dataframe",
    "data": [
      {"param": "pH", "val": 7.5},
      {"param": "BOD5", "val": 25}
    ]
  }
}
```

**Response:**
```json
{
  "success": true,
  "input_format": "json",
  "output_format": "dataframe",
  "data": {...}
}
```

---

### 9. Normalize Data
```http
POST /api/normalize
Content-Type: application/json
```
Chuẩn hóa dữ liệu đầu vào theo QCVN.

**Request Body:**
```json
{
  "data": {
    "qcvn_id": "Surface_Water",
    "data": {
      "pH": 7.5,
      "BOD5": 25,
      "InvalidParam": 999
    }
  }
}
```

**Response:**
```json
{
  "success": true,
  "qcvn": "Surface_Water",
  "valid_parameters": ["pH", "BOD5", "DO", "COD", ...],
  "normalized_data": {
    "pH": 7.5,
    "BOD5": 25
  }
}
```

---

### 10. Export Results
```http
POST /api/export/json
Content-Type: application/json
```
Export kết quả đánh giá ra JSON có cấu trúc.

**Request Body:**
```json
{
  "data": {
    "qcvn": "QCVN 08-MT:2015/BTNMT",
    "column": "A1",
    "results": [...],
    "summary": {...}
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "exported_at": "2026-02-04T10:30:00Z",
    "qcvn": "QCVN 08-MT:2015/BTNMT",
    "column": "A1",
    "results": [...],
    "summary": {...}
  }
}
```

---

## 🚀 Quick Start

### 1. Start API Server
```bash
Rscript run_api.R
```

API sẽ chạy tại: **http://localhost:3839**

### 2. Test với curl
```bash
# Health check
curl http://localhost:3839/health

# List QCVN
curl http://localhost:3839/api/qcvn/list

# Assess single parameter
curl -X POST http://localhost:3839/api/assess/single \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "qcvn_id": "Surface_Water",
      "column": "A1",
      "parameter": "pH",
      "value": 7.5
    }
  }'
```

---

## 🔧 n8n Integration Examples

### Workflow 1: Auto Assessment
```
HTTP Request (GET data) 
→ Function (format data) 
→ HTTP Request (POST /api/assess) 
→ IF (check compliance) 
→ Send Email/Alert
```

### Workflow 2: Batch Processing
```
Schedule Trigger 
→ Database Query 
→ Function (group by samples) 
→ HTTP Request (POST /api/batch/assess) 
→ Save to Database
```

### Workflow 3: QCVN Upload
```
Webhook (receive Excel) 
→ Function (convert to JSON) 
→ HTTP Request (POST /api/qcvn/upload) 
→ Notify success
```

---

## 📌 Notes

- API server chạy port **3839** (khác Shiny app port 3838)
- CORS đã enabled cho n8n
- Tất cả response đều dạng JSON
- Error responses có `success: false` và `error` message
- API docs tự động: `http://localhost:3839/__docs__/`

---

## 🛡️ Security Notes

⚠️ **Development Mode**: API này để development/internal use.

Để production:
- Thêm authentication (API key, JWT)
- Limit rate
- Validate input chặt chẽ hơn
- HTTPS
- Firewall rules

---

**Happy Automation with n8n! 🎉**
