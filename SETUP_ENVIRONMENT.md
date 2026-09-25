# Báo Cáo Cài Đặt Môi Trường & Dependencies

**Người thực hiện:** Lê Anh Tuấn  
**Nhánh:** letuan-setup-dependencies  

---

### 1. Thông số môi trường thực tế (flutter doctor)
- **Flutter SDK:** Version 3.47.5 (Channel stable)
- **Dart SDK:** Tích hợp sẵn theo Flutter SDK
- **Hệ điều hành:** Windows 11
- **Android SDK:** Version 36.0.0
- **Trạng thái:** Toàn bộ tiêu chí đạt yêu cầu (`No issues found!`)

---

### 2. Các bước triển khai
1. Chuyển vào thư mục mã nguồn: `cd budget`
2. Làm sạch cache dự án: `flutter clean`
3. Cài đặt các gói phụ thuộc: `flutter pub get`
4. Mã sinh tự động (Database Drift & Serialization): Sử dụng các file generated (`*.g.dart`) có sẵn trong repo.

---

### 3. Xử lý cảnh báo & lỗi phát sinh
- **Cảnh báo nền tảng plugin:** `file_picker` và `flutter_local_notifications` cảnh báo thiếu inline implementation cho Linux/macOS. Không ảnh hưởng đến nền tảng đích (Android/Web/Windows).
- **Lỗi frontend_server.dart.snapshot của build_runner:** Do phiên bản `build_runner` 2.4.9 cũ không khớp đường dẫn snapshot trên các bản Dart SDK mới. Toàn bộ mã Drift model đã được commit sẵn trong source nên dự án khởi chạy trực tiếp mà không cần chạy lại builder.
