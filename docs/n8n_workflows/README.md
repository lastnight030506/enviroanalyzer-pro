# N8N Workflows cho EnviroAnalyzer Pro

## 📁 Các Workflow có sẵn

### 1. **enviroanalyzer_ai_workflow.json**
Workflow chính để tích hợp AI vào EnviroAnalyzer Pro.

**Chức năng:**
- ✅ Phân tích kết quả đánh giá bằng AI
- 💡 Gợi ý hành động khắc phục
- 📖 Giải thích kết quả bằng ngôn ngữ đơn giản
- 📄 Tạo báo cáo tự động
- 🔌 Test connection endpoint

**Nodes sử dụng:**
- Webhook (trigger)
- OpenAI GPT-4
- Code (JavaScript)
- IF conditions
- Response webhook

---

## 🚀 Hướng dẫn Setup

### Bước 1: Cài đặt n8n

#### Option A: n8n Cloud (Recommended)
1. Đăng ký tài khoản tại: https://n8n.io
2. Tạo workspace mới
3. Skip bước 2-3, đi thẳng đến Bước 4

#### Option B: Self-hosted (Docker)
```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

#### Option C: Self-hosted (npm)
```bash
npm install n8n -g
n8n start
```

### Bước 2: Truy cập n8n
- n8n Cloud: https://app.n8n.cloud
- Self-hosted: http://localhost:5678

### Bước 3: Import Workflow
1. Mở n8n dashboard
2. Click **Workflows** → **Import from File**
3. Chọn file `enviroanalyzer_ai_workflow.json`
4. Click **Import**

### Bước 4: Cấu hình OpenAI
1. Lấy API key từ: https://platform.openai.com/api-keys
2. Trong n8n, click vào node **OpenAI - Analyze Results**
3. Click **Credentials** → **Create New**
4. Nhập API key
5. Save credentials
6. Áp dụng credentials cho tất cả OpenAI nodes khác

### Bước 5: Activate Webhook
1. Click vào node **Webhook** đầu tiên
2. Chọn **Test URL** hoặc **Production URL**
3. Copy webhook URL (dạng: `https://your-n8n.com/webhook/enviroanalyzer`)
4. Click **Listen for Test Event**

### Bước 6: Kết nối với EnviroAnalyzer Pro
1. Mở EnviroAnalyzer Pro
2. Click biểu tượng ⚙️ Settings (góc trên bên phải)
3. Scroll xuống phần **AI Assistant (n8n)**
4. Paste webhook URL vào ô **N8N Webhook URL**
5. Click **Test Connection**
6. Nếu thấy ✓ Connected → thành công!

### Bước 7: Activate Workflow
1. Quay lại n8n
2. Toggle **Active** ở góc trên để bật workflow
3. Xong! Workflow đã sẵn sàng nhận requests

---

## 🎯 Sử dụng AI trong EnviroAnalyzer Pro

### 1. Phân tích tự động
1. Nhập dữ liệu và chạy đánh giá trong EnviroAnalyzer Pro
2. Section **AI Analysis** sẽ xuất hiện (màu tím gradient)
3. Click **Analyze with AI**
4. Đợi 5-10 giây → nhận phân tích chi tiết

### 2. Giải thích kết quả
- Click **Explain Results** để nhận giải thích dễ hiểu cho người không chuyên

### 3. Gợi ý hành động
- Click **Suggest Actions** để nhận gợi ý khắc phục các thông số vượt ngưỡng

### 4. Tạo báo cáo
- Click **Generate Report** để AI tạo báo cáo đầy đủ dạng Markdown

---

## 🔧 Tùy chỉnh Workflow

### Thay đổi AI Model
Mặc định sử dụng GPT-4. Để đổi sang model khác:
1. Click vào OpenAI node
2. Đổi **Model** từ `gpt-4o` sang:
   - `gpt-3.5-turbo` (nhanh hơn, rẻ hơn)
   - `gpt-4-turbo` (cân bằng)
   - `gpt-4o` (mạnh nhất, chậm hơn)

### Thay đổi Prompt
Để AI phân tích theo style riêng:
1. Click OpenAI node
2. Edit nội dung trong **Messages** → **Content**
3. Thêm/bớt instructions theo ý muốn
4. Save

### Thêm chức năng mới
Ví dụ: Gửi email khi có thông số vượt ngưỡng nghiêm trọng

1. Thêm node **IF** sau "Format Analysis Response"
2. Điều kiện: `{{$json.data.summary.fail > 3}}`
3. Nếu True → thêm node **Gmail** hoặc **Send Email**
4. Cấu hình email với nội dung từ AI analysis

---

## 💰 Chi phí

### n8n Cloud
- Free tier: 5,000 workflow executions/tháng
- Pro: $20/tháng (50,000 executions)
- Self-hosted: Miễn phí (trừ chi phí server)

### OpenAI API
- GPT-4o: ~$0.03 per request (phân tích ngắn)
- GPT-3.5-turbo: ~$0.002 per request
- Dự tính: 1000 phân tích/tháng = $5-30 tùy model

**💡 Tip**: Dùng GPT-3.5-turbo cho explain/suggest, GPT-4 cho report để tiết kiệm

---

## 🐛 Troubleshooting

### Không kết nối được
- ✅ Check internet connection
- ✅ Workflow đã Active chưa?
- ✅ Webhook URL có đúng không?
- ✅ n8n Cloud: check firewall/VPN
- ✅ Self-hosted: port 5678 có mở không?

### AI response chậm
- Bình thường: 5-15 giây cho GPT-4
- Nếu >30 giây: check OpenAI API status
- Đổi sang GPT-3.5-turbo để nhanh hơn

### OpenAI API Error
- Check API key còn valid không
- Check balance tại: https://platform.openai.com/usage
- Rate limit: đợi 1 phút rồi thử lại

### "Connection failed"
- Test bằng curl:
```bash
curl -X POST https://your-n8n.com/webhook/enviroanalyzer \
  -H "Content-Type: application/json" \
  -d '{"action":"ping"}'
```
- Nếu trả về `{"success":true}` → webhook OK
- Nếu không → check n8n logs

---

## 📚 Tài liệu thêm

- n8n Docs: https://docs.n8n.io
- OpenAI API: https://platform.openai.com/docs
- EnviroAnalyzer API: xem file `API_DOCUMENTATION.md`

---

## 🎓 Ví dụ nâng cao

### Workflow 2: Auto-save phân tích vào Google Sheets
```
Webhook → AI Analysis → Google Sheets
```

### Workflow 3: Alert qua Telegram khi vượt ngưỡng
```
Webhook → Check Failed > 0 → Telegram Bot
```

### Workflow 4: Lưu history vào Database
```
Webhook → AI Analysis → PostgreSQL/MySQL
```

**Tham khảo n8n template library để có thêm ý tưởng!**

---

**Chúc bạn tích hợp thành công! 🎉**
