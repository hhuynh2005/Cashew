# TÀI LIỆU KỸ THUẬT: TÍCH HỢP FIREBASE CLOUD STORAGE CHO HỆ THỐNG QUẢN LÝ TÀI LIỆU (STUDYDOCS DMS)

* **Sinh viên phụ trách:** Nguyễn Văn Huỳnh
* **MSSV:** 2351170599
* **Lớp:** 65KTPM - Nhóm 16 (CSE441 - Kiến trúc Hệ thống Phân tán & Mobile)
* **Vai trò:** Nhóm trưởng (Team Lead) & Kỹ sư Cloud Storage
* **Nhánh phát triển Git:** `huynh-cloud-storage`

---

## 1. Mục tiêu và Nhiệm vụ Triển khai

Trong hệ thống Quản lý Tài liệu Học tập theo Kiến trúc Cashew (**StudyDocs DMS**), việc lưu trữ tệp tài liệu gốc (PDF giáo trình, Slide bài giảng PPTX, Đề cương DOCX, Bài tập mẫu) trực tiếp trong SQLite hoặc nội bộ bộ nhớ thiết bị sẽ gây quá tải tài nguyên (bloat DB), khó chia sẻ liên thiết bị và rủi ro mất mát dữ liệu khi xóa ứng dụng.

Nhiệm vụ của Nhóm trưởng gồm 4 nội dung cốt lõi:
1. **Khởi tạo và thiết lập Firebase Storage Bucket:** Bucket chuẩn `cashew-study-docs.firebasestorage.app`.
2. **Thiết lập Quy tắc An toàn & Phân quyền (Security Rules):** Đảm bảo tính riêng tư, chống truy cập trái phép và giới hạn dung lượng tệp tối đa 50MB.
3. **Triển khai Tầng Dịch vụ `FirebaseStorageService`:** Độc lập, phân tầng theo kiến trúc Cashew (tầng `struct/`), hỗ trợ Upload kèm Stream theo dõi tiến trình (0% - 100%), sinh Download URL, xóa tệp và cơ chế Mock/Offline fallback tự động.
4. **Tích hợp giao diện UI:** Bổ sung Card điều khiển Cloud Storage vào màn hình Chi tiết Tài liệu ([`DocumentDetailPage`](study_docs_app/lib/pages/document_detail_page.dart)) và viết bộ kiểm thử tự động 7 kịch bản (100% PASS).

---

## 2. Kiến trúc Cây Thư mục Lưu trữ Phân cấp (Storage Hierarchy)

Nhằm tối ưu hóa khả năng lập chỉ mục (index) và phân quyền bảo mật, toàn bộ tệp tin được tổ chức theo cây phân cấp sau:

```
cashew-study-docs.firebasestorage.app/
│
├── documents/                                  <-- Thư mục tài liệu cá nhân
│   └── {uploaderUid}/                          <-- Firebase Auth UID của sinh viên
│       └── {documentId}/                       <-- UUID v4 của tài liệu trong hệ thống
│           └── {sanitizedFileName}             <-- Tệp tin gốc (Ví dụ: BaiGiang_KienTruc.pdf)
│
└── public_docs/                                <-- Thư mục tài nguyên chung khoa/trường
    └── {subjectCode}/                          <-- Mã môn học (Ví dụ: CSE441)
        └── {sanitizedFileName}                 <-- Đề cương, giáo trình công khai
```

* **Quy chuẩn mã hóa tên tệp:** Tự động loại bỏ khoảng trắng và các ký tự đặc biệt nguy hiểm để phòng chống Path Traversal (`../`).
* **Metadata gắn kèm mỗi tệp:**
  * `contentType`: MIME type tự động phát hiện (PDF, Word, Excel, Slide, Image, Zip).
  * `customMetadata`: `uploaderId`, `documentId`, `originalName`, `uploadedAt`, `appSource: 'StudyDocs-Cashew-Group16'`.

---

## 3. Cấu hình Quy tắc Bảo mật (Firebase Storage Security Rules)

File cấu hình: [`storage.rules`](storage.rules)

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // 1. Phân quyền thư mục tài liệu cá nhân của người dùng
    match /documents/{userId}/{documentId}/{fileName} {
      // Cho phép tất cả người dùng trong hệ thống đã đăng nhập Google được đọc/tải
      allow read: if request.auth != null;

      // Chỉ chính chủ tài khoản mới có quyền tải lên hoặc cập nhật
      // Ràng buộc bảo mật:
      // - Đúng UID người tạo: request.auth.uid == userId
      // - Dung lượng không vượt quá 50MB (52.428.800 bytes)
      // - Định dạng tệp tin hợp lệ (PDF, Word, PPT, Excel, Ảnh, Text, Zip)
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size <= 50 * 1024 * 1024
                   && (
                     request.resource.contentType.matches('application/pdf') ||
                     request.resource.contentType.matches('application/.*word.*') ||
                     request.resource.contentType.matches('application/.*presentation.*') ||
                     request.resource.contentType.matches('application/.*sheet.*') ||
                     request.resource.contentType.matches('image/.*') ||
                     request.resource.contentType.matches('text/.*') ||
                     request.resource.contentType.matches('application/zip')
                   );

      // Chỉ chủ sở hữu mới có quyền xóa tệp
      allow delete: if request.auth != null && request.auth.uid == userId;
    }

    // 2. Thư mục kho tài liệu chung của trường Đại học Thủy Lợi
    match /public_docs/{subjectCode}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.auth.token.email.matches('.*@e\\.tlu\\.edu\\.vn')
                   && request.resource.size <= 100 * 1024 * 1024;
    }
  }
}
```

---

## 4. Tầng Dịch vụ `FirebaseStorageService`

File nguồn: [`study_docs_app/lib/struct/firebase_storage_service.dart`](study_docs_app/lib/struct/firebase_storage_service.dart)

### Các API chính:
1. `buildStoragePath(...)`: Sinh đường dẫn phân cấp chuẩn và loại bỏ ký tự lạ.
2. `detectMimeType(fileName)`: Xác định MIME Type chuẩn RFC cho tệp học tập.
3. `uploadDocumentFile(...)`: 
   - Kiểm tra ràng buộc tiền điều kiện (tên không rỗng, dung lượng > 0 và <= 50MB).
   - Truyền stream tiến trình tải lên thông qua callback `onProgress(progress)` (từ 0.0 đến 1.0).
   - Trả về đối tượng `CloudStorageUploadResult` chứa đầy đủ `downloadUrl`, `storagePath`, `fileSizeBytes`, `contentType`.
4. `getDownloadUrl(storagePath)`: Truy xuất link tải công khai có chữ ký số (Signed URL) từ Firebase.
5. `downloadFileBytes(storagePath)`: Tải mảng byte tệp tin từ Cloud về phục vụ đọc offline.
6. `deleteDocumentFile(storagePath)`: Xóa tệp vĩnh viễn trên Cloud Storage khi tài liệu bị hủy.
7. **Cơ chế In-memory Mock Storage:** Tự động kích hoạt khi chạy Unit Test độc lập hoặc khi thiết bị mất mạng, bảo đảm 100% test cases luôn chạy nhanh, tin cậy mà không phụ thuộc vào hạ tầng mạng bên ngoài.

---

## 5. Tích hợp Giao diện Người dùng (UI Presentation)

File cập nhật: [`study_docs_app/lib/pages/document_detail_page.dart`](study_docs_app/lib/pages/document_detail_page.dart)

* **Thẻ `_CloudStorageCard`:**
  * Hiển thị trạng thái đám mây: `OFFLINE` (Cam) hoặc `ĐÃ ĐỒNG BỘ` (Xanh ngọc).
  * **Nút "Tải lên Cloud Storage":** Tự động đóng gói dữ liệu và đẩy lên bucket, cập nhật thanh tiến trình chạy theo thời gian thực (Progress Bar).
  * **Liên kết tải xuống (Download URL):** Hiển thị URL Cloud Storage rút gọn, hỗ trợ nút bấm **Sao chép URL** vào Clipboard một chạm.
  * **Nút "Xóa tệp khỏi Cloud Storage":** Cho phép thu hồi tài nguyên trên đám mây khi không còn nhu cầu chia sẻ.

---

## 6. Kết quả Kiểm thử Tự động (Automated Test Suite)

File kịch bản: [`study_docs_app/test/unit_test/firebase_storage_test.dart`](study_docs_app/test/unit_test/firebase_storage_test.dart)

Toàn bộ **7 kịch bản kiểm thử** thuộc nhiệm vụ của Nhóm trưởng đều đạt chuẩn 100% PASS:

| Kịch bản | Mục tiêu kiểm thử | Kết quả |
|:---|:---|:---:|
| **Test 1** | Chuẩn hóa đường dẫn lưu trữ Storage Path theo kiến trúc phân tầng | ✅ PASS |
| **Test 2** | Tự động nhận diện MIME Type cho các định dạng tài liệu học tập | ✅ PASS |
| **Test 3** | Upload tài liệu lên Cloud Storage thành công và nhận Download URL | ✅ PASS |
| **Test 4** | Kiểm tra tải lại nội dung tệp (Download) và lấy URL đã upload | ✅ PASS |
| **Test 5** | Xóa tệp tài liệu trên Cloud Storage thành công | ✅ PASS |
| **Test 6** | Validation từ chối khi tên tệp rỗng hoặc dữ liệu byte 0 bytes | ✅ PASS |
| **Test 7** | Từ chối tệp vượt quá kích thước bảo mật quy định (50MB) | ✅ PASS |

> **Tổng thể ứng dụng:** **40/40 tests passed (100% PASS)** (Bao gồm kiểm thử 4 lớp kiến trúc Cashew + Google Auth + Cloud Storage).
