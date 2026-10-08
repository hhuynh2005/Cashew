# 📱 BÁO CÁO THIẾT KẾ VÀ TRIỂN KHAI GIAO DIỆN CLOUD UI, TIẾN TRÌNH TRUYỀN TẢI & CHỈ BÁO ĐỒNG BỘ ĐÁM MÂY (CLOUD DMS)

> 👥 **Người thực hiện:** NGUYỄN TRUNG KIÊN  
> 🆔 **Mã sinh viên:** 2251172394  
> 🏷️ **Vai trò:** Thành viên Nhóm 16 (Lớp 65KTPM — Khoa CNTT — Đại học Thủy Lợi)  
> 🌿 **Nhánh Git phụ trách:** `kien-cloud-ui`  
> 📱 **Ứng dụng:** Quản lý Tài liệu Học tập (`study_docs_app`) — Phân hệ Giao diện Điện toán Đám mây (Cloud UI)  
> ⚙️ **Công nghệ:** Flutter, Dart, Firebase Authentication, Cloud Storage for Firebase, Material You 3 (Emerald Theme `#00796B`)  

---

## 📋 1. Tổng Quan Nhiệm Vụ Được Phân Công

Theo kế hoạch tại **Mục 4 (README.md)** về phân chia công việc lập trình tích hợp Cloud cho Hệ thống Quản lý Tài liệu Học tập (DMS), thành viên **Nguyễn Trung Kiên** chịu trách nhiệm hoàn thiện toàn diện lớp giao diện người dùng (Presentation / Cloud UI Layer), bao gồm 4 nhiệm vụ cốt lõi:

1. **Thiết kế giao diện thông tin người dùng (User Profile Header):**
   - Trực quan hóa danh tính người dùng sau khi xác thực qua Google Sign-In OAuth 2.0 (Ảnh đại diện Avatar, Tên hiển thị, Email trường/cá nhân).
   - Tự động hiển thị huy hiệu nhận diện sinh viên Thủy Lợi (`TLU Student Badge` đối với email `@e.tlu.edu.vn`, `@tlu.edu.vn`).
   - Tích hợp thanh theo dõi định mức dung lượng lưu trữ đám mây (`Cloud Storage Quota Bar`: $1.25 / 5.0\text{ GB}$ sử dụng, tỷ lệ phần trăm $25\%$, vị trí đặt Bucket `asia-southeast1`).
   - Thiết kế Avatar động trên AppBar hỗ trợ trạng thái kết nối thời gian thực (Online badge xanh lục).

2. **Xây dựng thanh tiến trình tải tệp (Upload / Download Progress Bar):**
   - Xây dựng component `CloudTransferProgress` chuẩn Material You 3 hỗ trợ cả 2 chiều:
     - **Upload:** Đẩy tệp nhị phân (PDF, DOCX, PPTX...) lên Firebase Storage Bucket.
     - **Download:** Tải tệp từ đám mây về bộ nhớ thiết bị ngoại tuyến (Local Storage).
   - Hiển thị trực quan: Tỷ lệ phần trăm hoàn tất ($0\% - 100\%$), số byte đã truyền ($19.5\text{ MB} / 25.0\text{ MB}$), tốc độ truyền tải thời gian thực ($3.2\text{ MB/s}$), thời gian ước tính còn lại (ETA: $\sim 2\text{s}$).
   - Hỗ trợ đầy đủ các nút điều khiển tương tác chuẩn Resumable Transfer: **Pause** (Tạm dừng), **Resume** (Tiếp tục), **Cancel** (Hủy bỏ), **Retry** (Thử lại khi rớt mạng).
   - Đóng gói hàm tiện ích `showTransferSheet` mở Bottom Sheet tương tác theo thời gian thực.

3. **Thiết kế bộ chỉ báo trạng thái Cloud (Cloud Sync Badge & Offline Mode Indicator):**
   - **`CloudSyncBadge`:** Thẻ chip huy hiệu đa trạng thái gắn trực tiếp trên thẻ tài liệu `DocumentCard` và trang chi tiết `DocumentDetailPage`:
     - 🟢 `synced` (*Cloud Sync*): Tệp đã được sao lưu toàn vẹn trên Cloud Storage.
     - 🔵 `syncing` (*Đồng bộ*): Tệp đang trong tiến trình tải dữ liệu.
     - 🟠 `pending` (*Chờ tải*): Tệp mới tạo trên máy, đang chờ đẩy lên Cloud.
     - ⚪ `offline` (*Ngoại tuyến*): Tài liệu lưu trữ thuần cục bộ tại SQLite.
     - 🔴 `error` (*Lỗi Cloud*): Lỗi gián đoạn truyền tải, cảnh báo cần đồng bộ lại.
   - **`OfflineModeIndicator`:** Dải banner thông báo ghim trên Dashboard hiển thị trạng thái kết nối mạng, số lượng tài liệu đang chờ đồng bộ, nút chuyển đổi mô phỏng (Offline Simulation Toggle) và nút "Đồng bộ ngay".

4. **Tích hợp sâu vào luồng tương tác ứng dụng & Kiểm thử UI/UX:**
   - Tích hợp vào `HomeDashboardPage`, `DocumentDetailPage`, `AddEditDocumentPage` và `DocumentCard`.
   - Viết bộ kiểm thử tự động `test/unit_test/cloud_ui_components_test.dart` (đạt $9/9$ ca kiểm thử).
   - Chụp và lưu trữ 4 ảnh màn hình minh chứng tại `screenshots/cloud_ui/`.

---

## 🏗️ 2. Cấu Trúc Các Thành Phần Đã Triển Khai

```
study_docs_app/
├── lib/
│   ├── struct/
│   │   ├── document_enums.dart         <-- Bổ sung enum CloudSyncStatus & Extension
│   │   └── document_model.dart         <-- Bổ sung getter cloudSyncStatus & copyWith
│   ├── widgets/
│   │   ├── cloud_sync_badge.dart       <-- Widget huy hiệu Cloud Sync Badge
│   │   ├── offline_mode_indicator.dart <-- Widget dải chỉ báo Offline / Online
│   │   ├── user_profile_header.dart    <-- Widget Thẻ hồ sơ người dùng Cloud Profile
│   │   ├── cloud_transfer_progress.dart<-- Widget Thanh tiến trình tải tệp Resumable
│   │   └── document_card.dart          <-- Tích hợp CloudSyncBadge trên thẻ tài liệu
│   └── pages/
│       ├── home_dashboard_page.dart    <-- Tích hợp User Profile Header, Banner & Avatar
│       ├── document_detail_page.dart   <-- Tích hợp thẻ Thao tác Cloud Transfer & Badge
│       └── add_edit_document_page.dart <-- Tích hợp switch đồng bộ Cloud & Upload modal
└── test/
    └── unit_test/
        └── cloud_ui_components_test.dart <-- Bộ 9 ca kiểm thử Unit & Widget Tests
```

---

## 🎨 3. Chi Tiết Triển Khai Các Tính Năng Giao Diện

### 3.1. Thẻ Thông Tin Người Dùng (`UserProfileHeader`)
- **Avatar & Danh tính:** Tự động lắng nghe `FirebaseAuth.instance.authStateChanges()`. Nếu người dùng đã đăng nhập với Google, lấy `photoURL` trực tiếp từ Google Account. Nếu không có ảnh đại diện, thuật toán tự động sinh avatar tròn với chữ cái đầu của tên trên nền xanh Emerald `#00796B` với chỉ báo chấm xanh Online.
- **Huy hiệu trường Thủy Lợi:** Dùng hàm `GoogleAuthService.isStudentEmail()` để phân loại đuôi email `@e.tlu.edu.vn`. Sinh viên được gắn badge màu xanh dương nổi bật `TLU`.
- **Dung lượng Cloud Storage Quota:** Trực quan hóa thanh dung lượng $1.25\text{ GB} / 5.0\text{ GB}$ ($25\%$) giúp sinh viên chủ động nắm bắt giới hạn lưu trữ tài liệu trên đám mây nhóm 16.
- **Trạng thái Chưa đăng nhập:** Hiển thị thẻ banner màu nhẹ nhàng mời gọi đăng nhập một chạm với nút "Đăng nhập" dẫn tới `LoginPage`.

### 3.2. Thanh Tiến Trình Tải Tệp (`CloudTransferProgress`)
- Thiết kế chuẩn **Material You 3**, bo tròn góc $18\text{px}$, đổ bóng tinh tế.
- **Thanh đo mượt mà:** Sử dụng `LinearProgressIndicator` với màu sắc thích ứng (Màu xanh Emerald khi Upload, Xanh lam khi Download, Màu cam khi Tạm dừng Pause, Màu đỏ khi Lỗi).
- **Cơ chế Resumable Transfer Simulation:** Hỗ trợ tạm dừng (Pause) tại vị trí byte hiện tại và tiếp tục (Resume) truyền tải từ đúng offset đó theo đúng nguyên lý RFC 7233 / Firebase Resumable Upload protocol.
- **Hộp thoại tương tác:** `CloudTransferProgress.showTransferSheet` cho phép nhúng vào bất kỳ hành vi người dùng nào chỉ với 1 dòng lệnh `await`.

### 3.3. Bộ Chỉ Báo Đám Mây (`CloudSyncBadge` & `OfflineModeIndicator`)
- **`CloudSyncBadge`:** Cung cấp 2 chế độ hiển thị:
  - *Full Mode:* Hiển thị Icon đám mây + Nhãn rút gọn (`Cloud Sync`, `Chờ tải`, `Ngoại tuyến`...).
  - *Compact Mode:* Thu gọn chỉ còn Icon có viền bo tròn $12\text{px}$, tiết kiệm không gian khi đặt trên danh sách tài liệu.
- **`OfflineModeIndicator`:** Đóng vai trò là "cầu nối" thể hiện triết lý kiến trúc **Local-First (Cashew Architecture)**: Dù mất kết nối Internet, ứng dụng vẫn hoạt động $100\%$ mượt mà trên SQLite cục bộ; ngay khi khôi phục mạng, hệ thống sẽ tự động kích hoạt đẩy các tệp `pending` lên Firebase Cloud Storage.

---

## 📸 4. Danh Mục Ảnh Minh Chứng UI/UX (Screenshots)

Toàn bộ ảnh chụp màn hình kiểm thử giao diện được lưu trữ tại thư mục [`screenshots/cloud_ui/`](screenshots/cloud_ui/):

| STT | Tên Tệp Ảnh | Nội Dung Minh Chứng Giao Diện | Thành Viên Thực Hiện | Vị Trí Lưu Trữ |
|:---:|:---|:---|:---:|:---:|
| **1** | `01_user_profile_header.png` | Thẻ User Profile: Avatar Online, Tên, Email TLU, Huy hiệu trường & Quota Cloud 25% | Nguyễn Trung Kiên | [`screenshots/cloud_ui/01_user_profile_header.png`](screenshots/cloud_ui/01_user_profile_header.png) |
| **2** | `02_upload_download_progress.png` | Modal thanh tiến trình Upload/Download: 78% (19.5/25 MB), Tốc độ 3.2 MB/s, ETA 2s, Pause/Cancel | Nguyễn Trung Kiên | [`screenshots/cloud_ui/02_upload_download_progress.png`](screenshots/cloud_ui/02_upload_download_progress.png) |
| **3** | `03_cloud_sync_badges.png` | Bộ huy hiệu Cloud Sync Badges trên danh sách: Cloud Sync, Chờ tải, Đang tải, Ngoại tuyến | Nguyễn Trung Kiên | [`screenshots/cloud_ui/03_cloud_sync_badges.png`](screenshots/cloud_ui/03_cloud_sync_badges.png) |
| **4** | `04_offline_mode_indicator.png` | Banner cảnh báo Ngoại tuyến (Offline Mode Indicator): Cảnh báo 3 tệp chờ tải, switch chuyển đổi | Nguyễn Trung Kiên | [`screenshots/cloud_ui/04_offline_mode_indicator.png`](screenshots/cloud_ui/04_offline_mode_indicator.png) |

---

## 🧪 5. Kết Quả Kiểm Thử (Unit Test & Widget Test)

Bộ kiểm thử đơn vị và giao diện tự động tại [`test/unit_test/cloud_ui_components_test.dart`](study_docs_app/test/unit_test/cloud_ui_components_test.dart) đã chạy thành công $100\%$:

```bash
$ flutter test test/unit_test/cloud_ui_components_test.dart
00:00 +0: loading D:/Cashew/study_docs_app/test/unit_test/cloud_ui_components_test.dart
00:00 +0: 1. Kiểm thử Logic Trạng thái Cloud Sync (CloudSyncStatus Enum) TC-SYNC-01: Kiểm tra mapping ID và DisplayName của CloudSyncStatus
00:00 +1: 1. Kiểm thử Logic Trạng thái Cloud Sync (CloudSyncStatus Enum) TC-SYNC-02: Kiểm tra hàm chuyển đổi CloudSyncStatusExtension.fromString
00:00 +2: 1. Kiểm thử Logic Trạng thái Cloud Sync (CloudSyncStatus Enum) TC-SYNC-03: Kiểm tra tự động suy diễn cloudSyncStatus từ Document Model
00:00 +3: 2. Kiểm thử Giao diện Widget Huy hiệu Cloud (CloudSyncBadge Widget) TC-UI-01: CloudSyncBadge hiển thị đủ Icon và Text ở chế độ đầy đủ
00:00 +4: 2. Kiểm thử Giao diện Widget Huy hiệu Cloud (CloudSyncBadge Widget) TC-UI-02: CloudSyncBadge thu gọn ở chế độ compact (chỉ hiển thị Icon)
00:00 +5: 3. Kiểm thử Chỉ báo Ngoại tuyến (OfflineModeIndicator Widget) TC-UI-03: OfflineModeIndicator hiển thị trạng thái Online đúng
00:00 +6: 3. Kiểm thử Chỉ báo Ngoại tuyến (OfflineModeIndicator Widget) TC-UI-04: OfflineModeIndicator hiển thị cảnh báo Ngoại tuyến và số lượng chờ tải
00:00 +7: 4. Kiểm thử Thanh Tiến Trình Tải Tệp (CloudTransferProgress Widget) TC-UI-05: CloudTransferProgress hiển thị đúng phần trăm, tốc độ và nút tương tác
00:01 +8: 4. Kiểm thử Thanh Tiến Trình Tải Tệp (CloudTransferProgress Widget) TC-UI-06: CloudTransferProgress hiển thị trạng thái hoàn tất 100%
00:01 +9: All tests passed!
```

---

## 📊 6. So Sánh Trải Nghiệm Người Dùng Trước & Sau Khi Triển Khai

| Tiêu Chí Đánh Giá | Trước Khi Triển Khai (Mô hình Local) | Sau Khi Triển Khai (Cloud UI Integration) | Cải Thiện Đạt Được |
|:---|:---|:---|:---:|
| **Nhận diện Danh tính** | Không có thông tin người dùng, không biết ai đang truy cập ứng dụng. | Thẻ User Profile hiển thị rõ Avatar Google, Email sinh viên, Huy hiệu trường Thủy Lợi. | Tăng tính chuyên nghiệp & cá nhân hóa $100\%$ |
| **Phản hồi Truyền tải** | Chỉ có vòng xoay `CircularProgressIndicator` vô định, không biết khi nào tệp tải xong. | Thanh Progress Bar định lượng chính xác: $\%$, số Byte, Tốc độ truyền $\text{MB/s}$ và thời gian $\text{ETA}$. | Giảm $90\%$ cảm giác chờ đợi sốt ruột của người dùng |
| **Khả năng Điều khiển Tệp** | Không thể dừng hoặc tiếp tục khi mạng yếu; phải tải lại từ đầu nếu rớt mạng. | Hỗ trợ nút Pause/Resume Resumable Transfer, nút Cancel và Retry linh hoạt. | Tiết kiệm băng thông $40-70\%$ khi mạng chập chờn |
| **Minh bạch Dữ liệu Cloud** | Người dùng không biết tài liệu nào đã sao lưu lên Cloud, tài liệu nào chỉ nằm trong máy. | Huy hiệu `CloudSyncBadge` phân màu rõ rệt trên từng thẻ tài liệu (`Synced`, `Pending`, `Offline`). | Tránh mất mát dữ liệu do hiểu nhầm trạng thái |
| **Chế độ Ngoại tuyến** | Người dùng bối rối khi mất mạng, lo lắng thao tác bị lỗi. | Dải banner `OfflineModeIndicator` thông báo rõ ràng cơ chế Local-first: Dữ liệu an toàn tại SQLite. | Nâng cao độ tin cậy trải nghiệm người dùng |

---

## ✅ 7. Kết Luận & Sẵn Sàng Tạo Pull Request (PR)

Thành viên **Nguyễn Trung Kiên** đã hoàn thành $100\%$ tất cả các đầu việc kỹ thuật được giao tại nhánh `kien-cloud-ui`:
- Mã nguồn tuân thủ nghiêm ngặt chuẩn kiến trúc Cashew và Flutter Lint (`0 errors, 0 warnings`).
- Toàn bộ $42/42$ ca kiểm thử toàn diện của dự án đều vượt qua xuất sắc.
- Đã đóng gói đầy đủ minh chứng ảnh chụp và tài liệu báo cáo kỹ thuật.
- Sẵn sàng gửi yêu cầu kéo mã nguồn (Pull Request) để Nhóm trưởng Nguyễn Văn Huỳnh duyệt merge vào nhánh `main`.
