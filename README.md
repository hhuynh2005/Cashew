# 📱 ĐỒ ÁN MÔN HỌC: XÂY DỰNG ỨNG DỤNG QUẢN LÝ CHI TIÊU CASHEW

> **Dự án:** Triển khai, kiểm thử và tùy chỉnh ứng dụng quản lý chi tiêu cá nhân dựa trên mã nguồn mở **Cashew**  
> **Repository:** [https://github.com/hhuynh2005/Cashew](https://github.com/hhuynh2005/Cashew) *(Forked from [jameskokoska/Cashew](https://github.com/jameskokoska/Cashew))*  
> **Công nghệ sử dụng:** Flutter, Dart, SQLite (Drift), Material You Design

---

## 👥 1. Danh Sách Thành Viên & Phân Công Vai Trò

| STT | Mã Sinh Viên | Họ và Tên | Vai Trò | Trách Nhiệm Chính | Tiền Tố Nhánh Git (Tên) |
|:---:|:---:|:---|:---:|:---|:---:|
| **1** | **2351170599** | **Nguyễn Văn Huỳnh** | **Nhóm trưởng** | • Quản lý chung dự án & phân công nhiệm vụ cho các thành viên<br>• Fork & cấu hình GitHub Repository, quản lý Git flow (nhánh, PR, merge)<br>• Hỗ trợ kỹ thuật, review code & giải quyết xung đột (conflict)<br>• Đóng gói sản phẩm (Build APK/Release), tổng hợp báo cáo & nộp bài | `huynh-` |
| **2** | **2151060296** | **Lê Anh Tuấn** | **Thành viên** | • Cài đặt các gói phụ thuộc (dependencies) và chuẩn hóa môi trường local<br>• Xây dựng kịch bản kiểm thử (Test Cases)<br>• Thực hiện kiểm thử toàn diện các chức năng cơ bản (CRUD: Thêm/Sửa/Xóa chi tiêu, tài khoản, danh mục)<br>• Ghi chép nhật ký kiểm thử và chụp ảnh màn hình minh chứng kết quả | `letuan-` |
| **3** | **2251172394** | **NGUYỄN TRUNG KIÊN** | **Thành viên** | • Nghiên cứu cấu trúc UI/UX và hệ thống Theme (Material You) của Cashew<br>• Thực hiện tùy chỉnh giao diện (UI): Cá nhân hóa logo/banner nhóm, tùy biến màn hình About/Thông tin nhóm, tinh chỉnh bảng màu sắc (Theme Colors)<br>• Chụp ảnh đối chứng giao diện Trước và Sau khi thay đổi (Before/After) | `kien-` |
| **4** | **2351170629** | **Trần Anh Tuấn** | **Thành viên** | • Nghiên cứu luồng xử lý dữ liệu và logic nghiệp vụ của ứng dụng<br>• Thực hiện tùy chỉnh / bổ sung tính năng (Feature): Tối ưu hóa đơn vị tiền tệ VNĐ mặc định, thêm bộ danh mục chi tiêu đặc thù cho sinh viên, tùy biến bộ lọc thống kê chi tiêu<br>• Kiểm thử độ ổn định tính năng mới và chụp ảnh minh chứng hoạt động | `trantuan-` |

---

## 📋 2. Bảng Phân Chia Công Việc Chi Tiết Theo Checklist 5 Mục

| Mục | Yêu Cầu Checklist | Người Phụ Trách | Người Phối Hợp | Chi Tiết Công Việc & Sản Phẩm Bàn Giao | Tên Nhánh Git (Tên + Chức năng) | Trạng Thái |
|:---:|:---|:---:|:---:|:---|:---|:---:|
| **1** | **Fork và Clone mã nguồn Cashew từ GitHub** | **Nguyễn Văn Huỳnh** | Cả nhóm | • Fork repo `jameskokoska/Cashew` sang `hhuynh2005/Cashew`<br>• Cấu hình collaborators & phân quyền nhánh<br>• Hướng dẫn các thành viên clone mã nguồn về local | `huynh-setup-repo` | ✅ Hoàn thành |
| **2** | **Cài đặt dependencies & cấu hình môi trường** | **Lê Anh Tuấn** | Nguyễn Văn Huỳnh | • Kiểm tra Flutter SDK, Dart SDK tương thích<br>• Chạy `flutter pub get` trong thư mục `budget`<br>• Khắc phục cảnh báo/lỗi thư viện & viết hướng dẫn setup | `letuan-setup-dependencies` | 🔄 Đang triển khai |
| **3** | **Khởi chạy local & kiểm tra chức năng cơ bản (CRUD)** | **Lê Anh Tuấn** | NGUYỄN TRUNG KIÊN, Trần Anh Tuấn | • Chạy ứng dụng trên Emulator / thiết bị thật / Web<br>• Kiểm thử chức năng: Thêm, Sửa, Xóa chi tiêu<br>• Kiểm thử số dư, danh mục và biểu đồ báo cáo<br>• Chụp ảnh minh chứng lưu tại `screenshots/crud/` | `letuan-test-crud` | 🔄 Đang triển khai |
| **4** | **Tùy chỉnh tính năng hoặc thay đổi giao diện (UI)** | **NGUYỄN TRUNG KIÊN** (UI)<br>**Trần Anh Tuấn** (Tính năng) | Nguyễn Văn Huỳnh (Review & Merge) | • **UI (Kiên):** Tùy chỉnh thông tin nhóm tại Settings/About, đổi màu sắc chủ đạo, đổi logo/banner nhận diện nhóm.<br>• **Tính năng (Tuấn):** Bổ sung danh mục chi tiêu sinh viên, định dạng tiền VNĐ, tối ưu hóa bộ lọc chi tiêu.<br>• Chụp ảnh minh chứng lưu tại `screenshots/customization/` | `kien-custom-ui-branding`<br>`trantuan-custom-features` | 🔄 Đang triển khai |
| **5** | **Đóng gói sản phẩm & Nộp bài** | **Nguyễn Văn Huỳnh** | Lê Anh Tuấn, NGUYỄN TRUNG KIÊN, Trần Anh Tuấn | • Đóng gói ứng dụng thành file APK release (`flutter build apk --release`)<br>• Tổng hợp toàn bộ ảnh chụp màn hình minh chứng kết quả<br>• Hoàn thiện README và nộp link GitHub đúng hạn | `huynh-build-release` | 🔄 Đang triển khai |

---

## 🌿 3. Quy Định Đặt Tên Nhánh Git & Quy Trình Push Code (Git Workflow)

> ⚠️ **QUY TẮC BẮT BUỘC DÀNH CHO TẤT CẢ THÀNH VIÊN:**  
> - **TUYỆT ĐỐI KHÔNG** commit hoặc push code trực tiếp lên nhánh `main`.  
> - Mỗi thành viên khi làm bất kỳ nhiệm vụ nào **BẮT BUỘC PHẢI TẠO MỘT NHÁNH MỚI** chứa cú pháp: **`<tên_thành_viên>-<tên_chức_năng>`**.  
> - Sau khi hoàn thành và kiểm thử ở local, push nhánh đó lên GitHub và tạo **Pull Request (PR)** để Nhóm trưởng review, giải quyết xung đột (nếu có) và merge vào `main`.

### 📌 Bảng Quy Định Tên Nhánh Chi Tiết Cho Từng Thành Viên:

| Thành Viên | Tiền Tố Tên | Tên Nhánh Khi Push Code | Mục Đích / Chức Năng Phụ Trách |
|---|:---:|:---|:---|
| **Nguyễn Văn Huỳnh** | `huynh-` | `huynh-setup-repo`<br>`huynh-build-release` | • Cấu hình dự án, quản lý repo<br>• Đóng gói APK và hoàn thiện tài liệu nộp bài |
| **Lê Anh Tuấn** | `letuan-` | `letuan-setup-dependencies`<br>`letuan-test-crud` | • Thiết lập thư viện và tài liệu môi trường<br>• Thực hiện và ghi log kiểm thử Thêm/Sửa/Xóa giao dịch |
| **NGUYỄN TRUNG KIÊN** | `kien-` | `kien-custom-ui-branding`<br>`kien-custom-theme` | • Tùy chỉnh giao diện: màn hình giới thiệu nhóm, logo, banner<br>• Tùy biến màu sắc, theme theo nhận diện nhóm |
| **Trần Anh Tuấn** | `trantuan-` | `trantuan-custom-currency-vnd`<br>`trantuan-custom-features` | • Tùy chỉnh tiền tệ VNĐ mặc định, format số tiền<br>• Thêm danh mục chi tiêu sinh viên & cải tiến bộ lọc |

*(Lưu ý: Để tránh nhầm lẫn giữa 2 bạn tên Tuấn, quy ước dùng tiền tố `letuan-` cho Lê Anh Tuấn và `trantuan-` cho Trần Anh Tuấn).*

---

### 🚀 Hướng Dẫn Các Bước Tạo Nhánh & Push Code Chi Tiết:

Mỗi khi bắt đầu làm một tính năng, thành viên thực hiện tuần tự theo các lệnh sau trong terminal:

```bash
# Bước 1: Chuyển về nhánh main và kéo code mới nhất về máy
git checkout main
git pull origin main

# Bước 2: Tạo nhánh mới với quy tắc: <tên>-<tên-chức-năng>
# Ví dụ thành viên Kiên làm giao diện:
git checkout -b kien-custom-ui-branding

# Ví dụ thành viên Trần Anh Tuấn làm tính năng tiền tệ:
# git checkout -b trantuan-custom-currency-vnd

# Bước 3: Thực hiện code, chỉnh sửa và kiểm thử ứng dụng chạy ổn định ở local

# Bước 4: Kiểm tra các file đã thay đổi
git status

# Bước 5: Thêm file và commit với cú pháp rõ ràng
git add .
git commit -m "[Kien] Tùy chỉnh logo và thông tin nhóm trong trang Settings"

# Bước 6: Push nhánh mới lên remote GitHub
git push origin kien-custom-ui-branding

# Bước 7: Mở GitHub repository, chọn 'Compare & pull request' để gửi yêu cầu merge vào nhánh main.
# Nhóm trưởng sẽ review code và duyệt merge.
```

---

## 🛠️ 4. Hướng Dẫn Cài Đặt Và Khởi Chạy Ứng Dụng (Quick Start)

### Yêu cầu tiên quyết:
- **Flutter SDK:** `>= 3.0.0` (Khuyên dùng Flutter 3.x stable)
- **Dart SDK:** Đi kèm với Flutter
- **Công cụ:** Android Studio / VS Code, Android Emulator hoặc thiết bị thật (hoặc trình duyệt Chrome/Edge)

### Các bước thực hiện:

1. **Clone mã nguồn dự án:**
   ```bash
   git clone https://github.com/hhuynh2005/Cashew.git
   cd Cashew/budget
   ```

2. **Cài đặt các gói phụ thuộc (Dependencies):**
   ```bash
   flutter pub get
   ```

3. **Khởi chạy ứng dụng (Debug Mode):**
   ```bash
   flutter run
   ```

4. **Đóng gói bản cài đặt Android APK (Release Mode):**
   ```bash
   flutter build apk --release
   ```
   *File APK sau khi build nằm tại:* `budget/build/app/outputs/flutter-apk/app-release.apk`

---

## 📸 5. Cấu Trúc Thư Mục Ảnh Minh Chứng (Screenshots)

Tất cả ảnh chụp màn hình kết quả chạy và kiểm thử ứng dụng được lưu trữ theo cấu trúc:
- `screenshots/crud/`: Ảnh chụp minh chứng kiểm thử các chức năng cơ bản: Thêm, Sửa, Xóa chi tiêu, tính toán số dư.
- `screenshots/customization/`: Ảnh chụp minh chứng các phần đã tùy chỉnh UI và tính năng:
  - `defaultmoney.png`: Format tiền tệ mặc định VNĐ (Trần Anh Tuấn)
  - `student_categories.png`: Danh mục chi tiêu đặc thù cho sinh viên (Trần Anh Tuấn)
  - `kien_ui_settings_banner.png`: Banner nhận diện thương hiệu nhóm trên trang Cài đặt (Nguyễn Trung Kiên)
  - `kien_ui_about_team.png`: Màn hình About hiển thị thông tin đồ án & danh sách thành viên nhóm (Nguyễn Trung Kiên)
  - `kien_theme_colors.png`: Tinh chỉnh bảng màu sắc và màu chủ đạo nhận diện Emerald Teal (Nguyễn Trung Kiên)
- `screenshots/build/`: Ảnh chụp minh chứng ứng dụng khởi chạy thành công trên máy và thông tin đóng gói bản APK.

---

# 📖 TÀI LIỆU GỐC DỰ ÁN CASHEW (ORIGINAL CASHEW DOCUMENTATION)

<h1 align="center" style="font-size:28px; line-height:1"><b>Cashew</b></h1>


<div align="center">
  <a href="https://cashewapp.web.app/">
    <img alt="Icon" src="promotional/icons/icon.png" width="150px" >
  </a>
</div>


<br />

<div align="center">
  <a href="https://apps.apple.com/us/app/cashew-expense-budget-tracker/id6463662930">
    <img alt="iOS App Store Badge" src="promotional/store-banners/app-store-badge.png" height="60px">
  </a>
  <a href="https://play.google.com/store/apps/details?id=com.budget.tracker_app">
    <img alt="Google Play Badge" src="promotional/store-banners/google-play-badge.png" height="60px">
  </a>
  <a href="https://github.com/jameskokoska/Cashew/releases/">
    <img alt="GitHub Badge" src="promotional/store-banners/github-badge.png" height="60px">
  </a>
  <a href="https://budget-track.web.app/">
    <img alt="PWA Badge" src="promotional/store-banners/pwa-badge.png" height="60px">
  </a>
</div>

<h3 align="center" style="font-size:28px; line-height:1">
  <a href="https://github.com/jameskokoska/Cashew/issues/725">🚀 Cashew Beta Testing</a>
</h3>

---

<br />

<a href="https://cashewapp.web.app/">
  <div align="center">
    <img width="95%" src="promotional/GitHub/SocialPreviewGitHub.png" alt="Promo banner">
  </div>
</a>

<br />

Cashew is a full-fledged, feature-rich application designed to empower users in managing their finances effectively. Built using Flutter - with Drift's SQL package, and Firebase - this app offers a seamless and intuitive user experience across various devices. Development started in September 2021.

---

## Features

<a href="https://www.youtube.com/watch?v=Oar9pkc7BSc&t=235s">
  <div align="center">
    <img width="80%" src="promotional/youtube-promo/thumbnail-oss.png" alt="Review Video">
  </div>
</a>
<p align="center">
  Cashew was featured on <a href="https://www.youtube.com/watch?v=Oar9pkc7BSc&t=235s">YouTube</a> on 'The Best Free and Open Source Apps in 2024!' (and in the thumbnail!)
</p>

<br />

<a href="https://www.youtube.com/watch?v=NYZd7IKn1oY&t=536s">
  <div align="center">
    <img width="80%" src="promotional/youtube-promo/thumbnail-year-best.png" alt="Review Video">
  </div>
</a>
<p align="center">
  Cashew was featured on <a href="https://www.youtube.com/watch?v=NYZd7IKn1oY&t=536s">YouTube</a> on 'The Best Apps of 2023!'
</p>

<br>

<a href="https://www.youtube.com/watch?v=2MwWmqcn--s&t=261s">
  <div align="center">
    <img width="80%" src="promotional/youtube-promo/thumbnail.png" alt="Review Video">
  </div>
</a>
<p align="center">
  Cashew was featured on <a href="https://www.youtube.com/watch?v=2MwWmqcn--s&t=261s">YouTube</a> on 'Top Android Apps! (November 2023)'
</p>

<br>

<div align="center">
  <img width="80%" src="promotional/play-store-feature/play-store-feature.png" alt="Play Store Feature">
</div>
<p align="center">
  Cashew was featured on <a href="https://play.google.com/store/apps/editorial?id=mc_apps_new_on_play_fcp">Google Play's Editorial 'New Apps We Love'</a> (November 2023)!
</p>

<br>

<a href="https://github.com/nyas1/Material-You-app-list?tab=readme-ov-file#-economy:~:text=MDY%20Celenganku-,MDY%20Cashew,-MDY%20Allowance%20FOSS">
  <div align="center">
    <img width="80%" src="promotional/material-apps-feature/material-apps-feature.png" alt="Material Apps List Feature">
  </div>
</a>
<p align="center">
  Cashew was featured in the <a href="https://github.com/nyas1/Material-You-app-list?tab=readme-ov-file#-economy:~:text=MDY%20Celenganku-,MDY%20Cashew,-MDY%20Allowance%20FOSS">Material You Apps List</a>!
</p>

## Release

Check out the [official website](https://cashewapp.web.app/)!

This application is available on the [App Store](https://apps.apple.com/us/app/cashew-expense-budget-tracker/id6463662930), [Google Play](https://play.google.com/store/apps/details?id=com.budget.tracker_app), [GitHub](https://github.com/jameskokoska/Cashew/releases/) and as a [Web App (PWA)](https://budget-track.web.app/).

### Changelog

Changes and progress about development is all heavily documented in GitHub [commits](https://github.com/jameskokoska/Cashew/commits/main) and in the [changelog](https://github.com/jameskokoska/Cashew/blob/main/budget/lib/widgets/showChangelog.dart)

## Key Features

### 💸 Budget Management

- Custom Budgets and Time Periods: Set up personalized budgets with flexible time periods, such as monthly, weekly, daily, or any custom time period that suits your financial planning needs. A custom time period is useful if you plan on setting a one-time travel budget!
- Added Budgets: Selectively add transactions to specific budgets, allowing you to focus on specific expense categories.
- Category Spending Limits per Budget: Set limits for each category within a budget, ensuring responsible spending.
- Past Budget History Viewing: Analyze your spending habits over time by accessing past budget history, enabling comparison and tracking of financial progress.
- Goals: Create spending and saving goals and put transactions towards different purchases or savings. Track your progress towards achieving your financial goals.

### 💰 Transaction Management

- Support for Different Transaction Types: Categorize transactions effectively based on types such as upcoming, subscription, repeating, debts (borrowed), and credit (lent). Each type behaves in certain ways in the interface. Pay your upcoming transactions when you're ready, or mark your lent out transactions as collected.
- Custom Categories: Create personalized categories to organize transactions according to your unique spending habits. Search through multiple icons and select the default option as expenses or income when adding transactions.
- Custom Titles: Automatically assign transactions with the same name to specific categories, saving time and ensuring consistency. These titles are stored in memory and popup when you add another transaction with a similar name.
- Search and Filters: Easily search and filter transactions based on various criteria such as date, category, amount, or custom tags, enabling quick access to information.
- Easy Editing: Long-press and swipe to select multiple budgets, edit accordingly as needed or delete multiple at once.

### 💱 Financial Flexibility

- Multiple Currencies and Accounts: Manage finances across different currencies and accounts with up-to-date conversion rates for accurate calculations and effortless currency conversions. The interface shows the original amount added and the converted amount to the selected account.
- Switch Accounts and Currencies with Ease: On the homepage, easily select a different account and currency and everything will be converted automatically in an instant.

### 🔒 Enhanced Security and Accessibility

- Biometric Lock: Secure budget data using biometric authentication, adding an extra layer of privacy.
- Google Login: Conveniently log in to the app using your Google account, ensuring a streamlined and hassle-free authentication process.

### 🎨 User Experience and Design

- Material You Design: Enjoy a visually appealing and modern interface, following the principles of Material You design for a delightful user experience.
- Custom Accent Color: Personalize the app by selecting a custom accent color that suits your style, or follow that of the system.
- Light and Dark Mode: Seamlessly switch between light and dark themes to optimize visibility and reduce eye strain.
- Customizable Home Screen: Tailor the home screen layout and widgets to display the financial information that matters most to you, providing a personalized and efficient dashboard.
- Detailed Graph Visuals: Gain valuable insights into spending patterns through detailed and interactive graphs, visualizing financial data at a glance.
- Beautiful Adaptive UI: A responsive user interface that adapts flawlessly to both web and mobile platforms, providing an immersive and consistent user experience across devices.

### ☁ Backup and Syncing

- Cross-Device Sync: Keep budget data synchronized across all devices, ensuring access to financial information wherever you go.
- Google Drive Backup: Safeguard budget data by utilizing Google Drive's backup functionality, allowing easy restoration of data if needed.

### 💿 Smart Automation

- Notifications: Stay informed about important financial events and receive timely reminders for budget goals, transactions, and upcoming due dates.
- Import CSV Files: Seamlessly import financial data by uploading CSV files, facilitating a smooth transition from other applications or platforms.
- Import Google Sheets: Seamlessly import Google Sheets tables, quickly importing many transactions from a spreadsheet.
- App Links: Automatically create transactions with pre-filled data using app linking (documentation below)

## Automation

See the `Automation` section on the FAQ website for information on how to add transactions automatically: https://cashewapp.web.app/faq.html#automation

## Bundled Packages

This repository contains, bundled in, modified versions of the discontinued packages listed below. They can be found in the folder `/budget/packages`

- https://pub.dev/packages/implicitly_animated_reorderable_list
- https://pub.dev/packages/sliding_sheet

## Translations

The translations are available here: https://docs.google.com/spreadsheets/d/1QQqt28cmrby6JqxLm-oxUXCuM3alniLJ6IRhcPJDOtk/edit?usp=sharing. If you would like to help translate, please reach out on email: dapperappdeveloper@gmail.com

### To Update Translations

1. Run `budget\assets\translations\generate-translations.py`
2. Restart the application

## Developer Notes

### Pull Requests and Contributions

Unfortunately, I am currently not accepting contributions due to licensing and credits. Since this application turns some profits, I want to avoid any muddy water when it comes to compensation for contributions. You are free to submit an [issue](https://github.com/jameskokoska/Cashew/issues) and I can consider it!

### Android Release

- To build an app-bundle Android release, run `flutter build appbundle --release`

Note: required Android SDK.

### iOS Release

- To build an IPA iOS release, run `flutter build ipa`

Note: requires MacOS.

### Firebase Deployment

- To deploy to firebase, run `firebase deploy`

Note: required Firebase.

### GitHub release

- Create a tag for the current version specified in `pubspec.yaml`
- `git tag <version>`
- Push the tag
- `git push origin <version>`
- Create the release and upload binaries
- https://github.com/jameskokoska/Cashew/releases/new

### Scripts

`deploy_and_build_windows.bat`

- Deploy to Firebase and build the apk and appbundle

`open_release_builds.bat`

- Opens the location of the built apk and appbundle

`update_translations.bat`

- Downloads the latest version of Cashew translations. Runs `budget\assets\translations\generate-translations.py`

### Develop Wirelessly on Android

- `adb tcpip 5555`
- `adb connect <IP>`
- Get the phone's IP by going to `About Phone` > `Status Information` > `IP Address`

### Migrate Database

1. Make any database changes to the schema and tables
2. Bump the schema version
   - Change `int schemaVersionGlobal = ...+1` in `tables.dart`
3. Make sure you are in application root directory
   - `cd .\budget\`
4. Generate database code
   - Run `dart run build_runner build`
5. Export the new schema
   - Generate schema dump for the newly created schema
   - Replace `[schemaVersion]` in the command below with the value of `schemaVersionGlobal`
   - Run `dart run drift_dev schema dump lib\database\tables.dart drift_schemas//drift_schema_v[schemaVersion].json`
   - Read more: https://drift.simonbinder.eu/docs/advanced-features/migrations/#exporting-the-schema
6. Generate step-by-step migrations
   - Run `dart run drift_dev schema steps drift_schemas/ lib\database\schema_versions.dart`
7. Implement migration strategy
   - Edit `await stepByStep(...)` function in `tables.dart` and add the migration strategy for the new version migration

### Get Platform

- Use `getPlatform()` from `functions.dart`
- Since `Platform` is not supported on web, we must create a wrapper and always use this to determine the current platform

### Push Route

- If we want to navigate to a new page, stick to `pushRoute(context, page)` function from `functions.dart`
- It handles the platform routing and `PageRouteBuilder`

### Wallets vs. Accounts

- `Wallets` have been been renamed to `Accounts` on the front-end but internally, the name `Wallet` is still used.

### Objectives vs. Goals

- `Objectives` have been been renamed to `Goals` on the front-end but internally, the name `Objectives` is still used.

### Long Term Loans

- Long term loans create a goal. However, the goals total is not used. Instead the total of the goal is calculated by totalling the proper polarity of transactions of the opposite type. For example, if it was a loan of 100$ lent out, the initial transaction would be 100$ of negative polarity (expense) and that would be the total of the goal. When a payment is made, it is made in the opposite (positive) polarity (income) and added to the total 'paid back'. We can easily find how much is remaining by taking the difference (or the addition including polarities).
