# Ứng Dụng Quản Lý Tài Liệu Học Tập (Cashew Architecture)
### Học phần: Phát triển ứng dụng di động (CSE441) - Bài Thực Hành 1 (TH1)

- **Sinh viên:** Nguyễn Văn Huỳnh
- **MSSV:** 2351170599
- **Lớp:** 65KTPM
- **Trường:** Đại học Thủy Lợi (TLU)
- **GitHub Repository:** [https://github.com/hhuynh2005/cse441_TH1](https://github.com/hhuynh2005/cse441_TH1)
- **Báo cáo Google Docs:** [Xem Báo Cáo Google Docs](https://docs.google.com/document/d/18xAiB17bQfPPKuv4BUYTlD_U0brH_L7sXH0vrDvLkhQ/edit?tab=t.0)

---

## 1. Giới thiệu tổng quan
Ứng dụng **Quản lý Tài liệu Học tập** được thiết kế và triển khai tuân thủ nghiêm ngặt các nguyên lý của **Kiến trúc Cashew** (Local-first, kiến trúc phân tầng rõ ràng, cơ chế Reactive Watcher Streams và Audit tombstone `delete_logs`).

## 2. Cấu trúc phân tầng (Cashew Architecture)
- **`lib/database/` (Data Access Layer)**: Khởi tạo SQLite singleton `AppDatabase`, định nghĩa DDL Schema `tables.dart`, nạp dữ liệu mẫu ban đầu `mock_data.dart`, quản lý reactive stream controller phát tín hiệu thay đổi dữ liệu thời gian thực.
- **`lib/struct/` (Domain & Business Logic Layer)**: Các Data Model bất biến (`Document`, `Subject`), Enums, `DocumentRepository` thực hiện validation nghiệp vụ, `DocumentStateProvider` quản lý trạng thái bằng `Provider`/`ChangeNotifier`.
- **`lib/pages/` & `lib/widgets/` (Presentation Layer)**: Giao diện người dùng Material You tông màu Emerald (#00796B), hỗ trợ Dark/Light mode, tìm kiếm bỏ dấu tiếng Việt, lọc đa tiêu chí.

## 3. Hướng dẫn chạy ứng dụng

### Chạy trên Web (Chrome / Edge):
```bash
flutter run -d chrome
```

### Chạy bộ kiểm thử tự động (29/29 tests pass 100%):
```bash
flutter test
```

### Build bản phát hành Web:
```bash
flutter build web --release
```
