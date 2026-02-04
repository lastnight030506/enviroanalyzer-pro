# Setup n8n AI Service cho EnviroAnalyzer Pro

## 🎯 Mục tiêu

Người dùng cuối **CHỈ CẦN BẬT AI LÊN** là dùng được ngay - không cần setup, config, hay hiểu gì về n8n!

---

## 👨‍💻 Dành cho Developer (Setup 1 lần)

### Bước 1: Setup n8n Workflow

#### Option A: n8n Cloud (Recommended - Miễn phí 5000 executions/tháng)
1. Đăng ký: https://n8n.io
2. Tạo workflow mới
3. Import file: `n8n_workflows/enviroanalyzer_ai_workflow.json`
4. Cấu hình OpenAI credentials (API key)
5. **Activate workflow** → lấy **Production Webhook URL**

#### Option B: Self-hosted (Cho production lớn)
```bash
# Docker
docker run -d --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Hoặc npm
npm install n8n -g
n8n start
```

### Bước 2: Cấu hình Webhook URL

Mở file: **`n8n_config.R`**

```r
# Thay đổi dòng này:
DEFAULT_N8N_ENDPOINT <- "https://your-n8n.com/webhook/enviroanalyzer"
```

**Ví dụ thực tế:**
```r
DEFAULT_N8N_ENDPOINT <- "https://n8n.yourdomain.com/webhook/enviroanalyzer"
# hoặc n8n Cloud:
DEFAULT_N8N_ENDPOINT <- "https://app.n8n.cloud/webhook/abc123xyz"
```

### Bước 3: Test

```r
# Test trong R Console
source("n8n_config.R")
source("ai_helper.R")

# Kiểm tra
is_ai_available()  # Phải TRUE

# Test connection
test_n8n_connection(DEFAULT_N8N_ENDPOINT)  # Phải TRUE
```

### Bước 4: Build & Distribute

```bash
# Build Electron app
cd electron
npm run build

# Hoặc tạo installer
cd ..
./build_installers.ps1
```

**✅ XONG!** App đã có sẵn AI, người dùng chỉ việc bật lên!

---

## 👤 Dành cho End Users (Plug & Play)

### Cách dùng AI

1. **Mở app** → Click icon ⚙️ Settings (góc trên phải)

2. **Bật AI lên**:
   - Tìm phần "🤖 AI Assistant"
   - Bật switch "Enable AI Analysis"
   - Đợi 2-3 giây → thấy "✅ AI is online and ready"

3. **Sử dụng**:
   - Nhập dữ liệu và chạy đánh giá
   - Section màu tím **"AI Analysis"** xuất hiện
   - Click **"Analyze with AI"**
   - Chờ 5-10 giây → nhận phân tích

4. **Các chức năng AI**:
   - 🔍 **Analyze**: Phân tích tổng quan kết quả
   - 📖 **Explain**: Giải thích dễ hiểu cho người không chuyên
   - 💡 **Suggest**: Gợi ý hành động khắc phục
   - 📄 **Generate Report**: Tạo báo cáo chi tiết

### Yêu cầu

- ✅ Kết nối Internet (WiFi/4G)
- ✅ Chỉ vậy thôi!

### Không cần

- ❌ Tài khoản n8n
- ❌ API key
- ❌ Cài thêm software
- ❌ Config gì cả

---

## 🔧 Advanced (Optional)

### Custom n8n URL (cho power users)

Nếu người dùng muốn dùng n8n instance riêng:

1. Bật AI trong Settings
2. Click **"Advanced: Custom n8n URL"**
3. Nhập URL webhook riêng
4. AI sẽ dùng URL này thay vì mặc định

### Disable Custom URL Option

Trong file `n8n_config.R`:

```r
N8N_CONFIG <- list(
  allow_custom_endpoint = FALSE,  # Đổi thành FALSE
  # ...
)
```

---

## 💰 Chi phí Ước tính

### n8n Cloud (Free tier)
- 5,000 workflow executions/tháng **MIỄN PHÍ**
- 1 user: ~50 phân tích/ngày = **1,500/tháng** → còn dư 3,500

### OpenAI API
| Model | Cost/Request | 1000 phân tích/tháng |
|-------|--------------|----------------------|
| GPT-3.5-turbo | $0.002 | **$2** |
| GPT-4o | $0.03 | **$30** |

**Khuyến nghị cho production:**
- Dùng GPT-3.5-turbo cho explain/suggest: nhanh + rẻ
- Dùng GPT-4o chỉ cho generate report: chất lượng cao

**→ Chi phí thực tế: ~$5-15/tháng** cho 1000 users/tháng

---

## 🐛 Troubleshooting

### Developer: "is_ai_available() = FALSE"
→ Check `DEFAULT_N8N_ENDPOINT` có URL chưa

### Developer: "test_n8n_connection() = FALSE"
→ n8n workflow chưa active hoặc URL sai

### End User: "AI service is not configured"
→ Developer chưa setup `DEFAULT_N8N_ENDPOINT`

### End User: "Cannot connect to AI service"
→ Check internet, hoặc n8n server down

### End User: AI chậm (>30 giây)
→ Bình thường với GPT-4, đổi sang GPT-3.5 để nhanh hơn

---

## 📊 Monitoring (Optional)

### Track n8n Usage

n8n Cloud dashboard:
- Executions count
- Success/fail rate
- Average execution time

### OpenAI Usage

https://platform.openai.com/usage
- Token usage
- Cost tracking
- Set billing alerts

---

## 🚀 Scaling

### Khi user base lớn (>10,000 phân tích/tháng):

1. **Upgrade n8n Cloud** ($20/month → 50k executions)
2. **Cache AI responses**:
   - Lưu responses phổ biến
   - Giảm calls đến OpenAI
3. **Rate limiting**:
   - Max 10 AI calls/user/day
   - Hoặc premium feature

### Self-hosted Production Setup:

```yaml
# docker-compose.yml
version: '3'
services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_password
    volumes:
      - ~/.n8n:/home/node/.n8n
```

---

## 📝 Summary

**Setup flow:**

1. Developer setup n8n workflow (1 lần) ✅
2. Developer config `DEFAULT_N8N_ENDPOINT` ✅
3. Developer build & distribute app ✅
4. End user tải app về ✅
5. End user bật AI → Dùng ngay! 🎉

**Không có bước 6!** Đó là plug & play! 🔌⚡

---

**Need help?** Open an issue on GitHub or contact developer.
