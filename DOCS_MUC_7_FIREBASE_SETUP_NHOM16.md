# BÁO CÁO CHUYÊN ĐỀ MỤC 7: TÌM HIỂU VỀ FIREBASE VÀ HƯỚNG DẪN THIẾT LẬP VỚI TÀI KHOẢN NHÓM

> **Học phần:** Phát triển Ứng dụng Di động (CSE441)  
> **Đồ án / Bài tập:** Phân tích và Lập phương án tích hợp Cloud cho Hệ thống Quản lý Tài liệu (DMS)  
> **Đơn vị thực hiện:** **Nhóm 16** — Lớp **65KTPM** — Khoa Công nghệ Thông tin — Trường Đại học Thủy Lợi  
> **Thành viên nhóm:**  
> 1. **Nguyễn Văn Huỳnh (Nhóm trưởng)** — MSSV: 2351170599 (`hha140860@gmail.com`)  
> 2. **Lê Anh Tuấn** — MSSV: 2151060296 (`chotommt123@gmail.com`)  
> 3. **Trần Anh Tuấn** — MSSV: 2351170605 (`anhtuan160205@gmail.com`)  
> 4. **Nguyễn Trung Kiên** — MSSV: 2351170570 (`trungkienn10a6@gmail.com`)  

---

## 📋 1. BẢNG ĐỐI SOÁT HOÀN THÀNH TOÀN DIỆN CHECKLIST 7 MỤC ĐỀ BÀI

Hệ thống Quản lý Tài liệu Học tập theo Kiến trúc Cashew (**StudyDocs DMS**) đã hoàn thành toàn diện **7/7 mục checklist** theo đúng yêu cầu đề bài của giảng viên:

| STT | Mục Checklist Yêu Cầu | Minh Chứng & Sản Phẩm Đã Hoàn Thành | Tỷ Lệ Đạt |
|:---:|:---|:---|:---:|
| **1** | **Liệt kê và phân tích các thành phần cốt lõi của ứng dụng Quản lý tài liệu** *(Frontend, Backend, Database, File Storage)* | • Đã phân tích chi tiết 4 phân hệ trong tài liệu [`BAO_CAO_TICH_HOP_CLOUD_DMS.docx`](BAO_CAO_TICH_HOP_CLOUD_DMS.docx).<br>• Phân tích kiến trúc 4 lớp Cashew: Presentation (UI), Domain/Logic, Data Access (Repository), Persistence (SQLite). | **100% Hoàn thành** |
| **2** | **Xác định các điểm nghẽn hoặc hạn chế của hệ thống hiện tại trên hạ tầng truyền thống** | • Đã chỉ rõ 5 điểm nghẽn nghiêm trọng: Giới hạn Disk I/O, Khó Scale-up phần cứng vật lý, Rủi ro Single Point of Failure (SPOF), Đứt gãy kết nối khi dùng VPN từ xa, Gánh nặng chi phí CapEx/OpEx. | **100% Hoàn thành** |
| **3** | **Lựa chọn mô hình triển khai Cloud phù hợp** *(Public, Private hoặc Hybrid Cloud)* **và các dịch vụ cụ thể** | • So sánh đa tiêu chí 3 mô hình Cloud; luận cứ lựa chọn mô hình **Public Cloud kết hợp Hybrid Client (Offline-first)**.<br>• Đối chiếu các dịch vụ lưu trữ đám mây hàng đầu: AWS S3, Azure Blob Storage, Google Cloud Storage / Firebase Storage. | **100% Hoàn thành** |
| **4** | **Thiết kế sơ đồ kiến trúc tích hợp Cloud và mô tả luồng dữ liệu giữa ứng dụng và đám mây** | • Sơ đồ kiến trúc tổng thể tích hợp Cloud.<br>• Sơ đồ tuần tự (Sequence Diagram) luồng Direct Upload và đồng bộ hai chiều (Two-way Sync) giữa SQLite cục bộ và Cloud Storage / Firestore. | **100% Hoàn thành** |
| **5** | **Đánh giá các tác động về bảo mật, chi phí và hiệu suất sau khi tích hợp** | • Phân tích 3 trụ cột: Bảo mật (Mã hóa AES-256, TLS 1.3, Security Rules, RBAC), Chi phí (TCO 3 năm tiết kiệm ~40%), Hiệu suất (Độ trễ thấp, SLA 99.99%).<br>• Bảng so sánh 8 khía cạnh giữa On-Premises và Cloud DMS. | **100% Hoàn thành** |
| **6** | **Sử dụng Firebase để tích hợp đăng nhập với Google và lưu trữ** *(Auth & Storage)* | • Đã code hoàn chỉnh trên Flutter (`study_docs_app`):<br>  - Google Sign-In một chạm (`GoogleAuthService`, `LoginPage`).<br>  - Tầng dịch vụ Cloud Storage (`FirebaseStorageService`, `storage.rules`).<br>  - Tầng đồng bộ Cloud Firestore (`CloudSyncService`, `CloudSyncPanel`).<br>  - UI hiển thị Profile, Cloud Sync Badge, Progress bar.<br>• Đã cấu hình Firebase Console thực tế (Project: `cashew-study-docs-d5b15`). | **100% Hoàn thành** |
| **7** | **Tạo Slide tìm hiểu về Firebase cũng như cách setup với tài khoản của nhóm** | • File trình chiếu PowerPoint chuyên sâu: [`SLIDE_MUC_7_FIREBASE_SETUP_NHOM16.pptx`](SLIDE_MUC_7_FIREBASE_SETUP_NHOM16.pptx).<br>• Tài liệu văn bản hướng dẫn chi tiết đính kèm: [`DOCS_MUC_7_FIREBASE_SETUP_NHOM16.docx`](DOCS_MUC_7_FIREBASE_SETUP_NHOM16.docx). | **100% Hoàn thành** |

---

## 🔍 2. TỔNG QUAN HỆ SINH THÁI GOOGLE FIREBASE & FLUTTERFIRE

### 2.1. Bản chất kiến trúc Backend-as-a-Service (BaaS)
Google Firebase là nền tảng điện toán đám mây cung cấp giải pháp **Backend-as-a-Service (BaaS)** hàng đầu thế giới dành cho ứng dụng di động và web. Thay vì phải tự xây dựng, cấu hình máy chủ vật lý, duy trì hệ điều hành và viết hàng nghìn dòng mã API xử lý xác thực hay lưu trữ tệp, Firebase cung cấp sẵn các bộ SDK tối ưu hóa cho Flutter (**FlutterFire**), cho phép ứng dụng client kết nối trực tiếp đến hạ tầng đám mây của Google với độ tin cậy và bảo mật cấp doanh nghiệp.

### 2.2. Ba dịch vụ cốt lõi Nhóm 16 ứng dụng cho StudyDocs DMS:
1. **Firebase Authentication (Xác thực người dùng):**
   - Hỗ trợ cơ chế **Google Sign-In một chạm** (One-tap Google Authentication) dựa trên chuẩn OpenID Connect và OAuth 2.0.
   - Quản lý phiên đăng nhập (Auth State) tự động qua Reactive Stream `authStateChanges()`.
   - Nhận diện và cấp phát đặc quyền cho tài khoản sinh viên Thủy Lợi (tên miền `@e.tlu.edu.vn`).
2. **Cloud Firestore (Cơ sở dữ liệu NoSQL đám mây):**
   - Lưu trữ metadata tài liệu (ID, tiêu đề, mã môn, đường dẫn tệp, thời gian cập nhật, checksum hash).
   - Cơ chế đồng bộ dữ liệu thời gian thực (Real-time data synchronization) qua WebSockets/gRPC.
   - Tích hợp khả năng Offline Persistence tự động, phục vụ kiến trúc Offline-First.
3. **Firebase Cloud Storage (Lưu trữ Đối tượng Tệp tin):**
   - Lưu trữ các tệp nhị phân kích thước lớn (PDF giáo trình, Word đề cương, Slide bài giảng, ảnh minh họa).
   - Hạ tầng phía sau là Google Cloud Storage Bucket với độ bền dữ liệu 99.999999999% (11 số 9).
   - Kiểm soát truy cập và bảo vệ tệp tin thông qua bộ quy tắc bảo mật khai báo (**Firebase Storage Security Rules**).

---

## 🛠️ 3. QUY TRÌNH THIẾT LẬP THỰC TẾ VỚI TÀI KHOẢN NHÓM 16

### 3.1. Thông tin Firebase Project của Nhóm
* **Tên hiển thị:** `cashew-study-docs` (Tài liệu nghiên cứu hạt điều)
* **Project ID:** `cashew-study-docs-d5b15`
* **Project Number (Sender ID):** `825188339992`
* **Storage Bucket:** `cashew-study-docs-d5b15.firebasestorage.app`
* **Gói cước:** Spark Plan (Miễn phí 100% chi phí học tập)

### 3.2. Cấu hình phân quyền thành viên (Users & Permissions)
Nhóm trưởng Nguyễn Văn Huỳnh đã mời và phân quyền cho toàn bộ 4 thành viên trong nhóm trên Firebase Console:
* `hha140860@gmail.com` (Nguyễn Văn Huỳnh) — **Owner (Chủ sở hữu dự án)**
* `chotommt123@gmail.com` (Lê Anh Tuấn) — **Editor (Người chỉnh sửa)**
* `anhtuan160205@gmail.com` (Trần Anh Tuấn) — **Editor (Người chỉnh sửa)**
* `trungkienn10a6@gmail.com` (Nguyễn Trung Kiên) — **Editor (Người chỉnh sửa)**

### 3.3. Các bước thiết lập trên Firebase Console
1. **Kích hoạt Google Sign-In Provider:**
   - Điều hướng: *Authentication -> Sign-in method -> Google*.
   - Gạt công tắc sang trạng thái **Bật (Enabled)**.
   - Chọn Email hỗ trợ dự án: `hha140860@gmail.com`.
   - Đặt tên hiển thị ứng dụng: `StudyDocs DMS`.
2. **Khởi tạo cơ sở dữ liệu Cloud Firestore:**
   - Điều hướng: *Firestore Database -> Create database*.
   - Chọn phiên bản: *Standard Edition*, vị trí: `nam5 (Hoa Kỳ)`.
   - Chế độ bảo mật: *Start in test mode* (cho phép sinh viên đọc/ghi dữ liệu thực hành).
3. **Thiết lập Quy tắc Bảo mật Lưu trữ (Storage Security Rules):**
   - Cấu hình file `storage.rules`: Ràng buộc người dùng đã đăng nhập Google mới được đọc/ghi, kiểm tra đúng UID chủ sở hữu tệp và giới hạn dung lượng tối đa 50MB.

### 3.4. Tích hợp FlutterFire Client vào Mã nguồn Flutter
1. Cài đặt các thư viện chính trong `study_docs_app/pubspec.yaml`:
   ```yaml
   firebase_core: ^3.6.0
   firebase_auth: ^5.3.1
   google_sign_in: ^6.2.1
   firebase_storage: ^12.3.4
   cloud_firestore: ^5.4.4
   connectivity_plus: ^6.0.5
   ```
2. Cấu hình tệp `study_docs_app/lib/firebase_options.dart` tự động trỏ vào Project `cashew-study-docs-d5b15` với đầy đủ khóa API cho Web, Android, iOS.
3. Đặt tệp cấu hình Android `google-services.json` vào thư mục `study_docs_app/android/app/`.

---

## 📊 4. KẾT QUẢ TRIỂN KHAI & BẰNG CHỨNG KIỂM THỬ TỰ ĐỘNG

Dự án đã triển khai tích hợp thành công trên nhánh `main` với sự đóng góp của cả 4 thành viên:
1. **Nguyễn Văn Huỳnh:** Tầng lưu trữ `FirebaseStorageService`, `storage.rules`, widget `_CloudStorageCard`.
2. **Lê Anh Tuấn:** Giao diện `LoginPage`, tầng xác thực `GoogleAuthService`.
3. **Trần Anh Tuấn:** Tầng đồng bộ `CloudSyncService`, widget `CloudSyncPanel`, `firestore.rules`.
4. **Nguyễn Trung Kiên:** Widget `UserProfileHeader`, `OfflineModeIndicator`, `CloudSyncBadge`, `CloudTransferProgress`.

Toàn bộ **54/54 kịch bản kiểm thử tự động (100% PASS)** đã được kiểm chứng thành công qua lệnh `flutter test`.

---

## 📁 5. DANH MỤC TÀI LIỆU VÀ SLIDE BÀN GIAO MỤC 7

1. **Tài liệu văn bản Microsoft Word chuyên đề:**  
   👉 [DOCS_MUC_7_FIREBASE_SETUP_NHOM16.docx](file:///D:/Nam_4/Mobile/Cashew/DOCS_MUC_7_FIREBASE_SETUP_NHOM16.docx)
2. **Slide trình chiếu thuyết trình PowerPoint:**  
   👉 [SLIDE_MUC_7_FIREBASE_SETUP_NHOM16.pptx](file:///D:/Nam_4/Mobile/Cashew/SLIDE_MUC_7_FIREBASE_SETUP_NHOM16.pptx)
3. **Báo cáo phân tích Cloud tổng hợp:**  
   👉 [BAO_CAO_TICH_HOP_CLOUD_DMS.docx](file:///D:/Nam_4/Mobile/Cashew/BAO_CAO_TICH_HOP_CLOUD_DMS.docx)
4. **Mã nguồn ứng dụng tích hợp hoàn chỉnh:**  
   👉 Thư mục [study_docs_app/](file:///D:/Nam_4/Mobile/Cashew/study_docs_app/) trên nhánh `main` của repository GitHub: [https://github.com/hhuynh2005/Quan_ly_quan_ly_DMS](https://github.com/hhuynh2005/Quan_ly_quan_ly_DMS).
