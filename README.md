# claude-khoi-phuc

Script dựng lại môi trường làm việc Claude Code trên một máy mới tinh.

```bash
bash <(curl -sL https://raw.githubusercontent.com/zeroxsg85/claude-khoi-phuc/main/khoi-phuc.sh)
```

Repo này **cố ý để public** vì máy mới chưa đăng nhập GitHub thì không tải được repo
private — script cứu hộ mà nằm trong két đã khoá thì vô dụng. Ở đây không có bí mật
nào: không token, không khoá giải mã, không địa chỉ máy chủ. Nội dung thật nằm trong
một repo riêng tư khác và vẫn được mã hoá bằng git-crypt.

Cần chuẩn bị trước hai thứ, không có thì script không chạy tiếp được:

1. **Quyền vào GitHub** — `gh auth login`, hoặc một Personal Access Token có quyền `repo`.
2. **File khoá `brain-sync.key`** (148 byte) — cất sẵn ở trình quản lý mật khẩu dạng
   base64 một dòng, và/hoặc trên máy chủ riêng.

Mất khoá là không ai giải mã lại được, kể cả chủ tài khoản GitHub.
