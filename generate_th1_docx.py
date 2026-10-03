import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, color_hex):
    tcPr = cell._element.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._element.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def create_report_docx():
    doc = docx.Document()

    # Thiết lập lề trang
    for section in doc.sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.9)
        section.right_margin = Inches(0.9)

    # Màu sắc chủ đạo: Cashew Emerald
    PRIMARY_COLOR = RGBColor(0, 121, 107)    # #00796B
    SECONDARY_COLOR = RGBColor(0, 77, 64)    # #004D40
    DARK_NEUTRAL = RGBColor(33, 33, 33)      # #212121
    GRAY_TEXT = RGBColor(117, 117, 117)

    # Title
    title_p = doc.add_paragraph()
    title_p.paragraph_format.space_before = Pt(0)
    title_p.paragraph_format.space_after = Pt(4)
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_t1 = title_p.add_run("BÁO CÁO BÀI THỰC HÀNH 1 (TH1)\n")
    run_t1.font.name = "Arial"
    run_t1.font.size = Pt(14)
    run_t1.font.bold = True
    run_t1.font.color.rgb = GRAY_TEXT

    run_t2 = title_p.add_run("XÂY DỰNG ỨNG DỤNG QUẢN LÝ TÀI LIỆU HỌC TẬP\nTHEO KIẾN TRÚC CASHEW")
    run_t2.font.name = "Arial"
    run_t2.font.size = Pt(20)
    run_t2.font.bold = True
    run_t2.font.color.rgb = PRIMARY_COLOR

    sub_p = doc.add_paragraph()
    sub_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sub_p.paragraph_format.space_after = Pt(18)
    sub_run = sub_p.add_run("Môn học: Lập trình Thiết bị Di động (CSE441) — Khoa CNTT, Đại học Thủy Lợi")
    sub_run.font.name = "Arial"
    sub_run.font.size = Pt(11)
    sub_run.font.italic = True
    sub_run.font.color.rgb = GRAY_TEXT

    # 1. Bảng Thông tin Sinh viên
    info_table = doc.add_table(rows=6, cols=2)
    info_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    info_data = [
        ("Họ và tên sinh viên:", "Nguyễn Văn Huỳnh"),
        ("Mã sinh viên (MSSV):", "2351170599"),
        ("Lớp chuyên ngành:", "65KTPM"),
        ("Học viện / Trường:", "Trường Đại học Thủy Lợi (TLU)"),
        ("Đề tài thực hành:", "TH1: Quản lý Tài liệu Học tập theo Kiến trúc Cashew"),
        ("Sản phẩm bàn giao:", "study_docs_app/ & StudyDocs-Cashew-Release.zip (Web Release)")
    ]

    for i, (label, val) in enumerate(info_data):
        row = info_table.rows[i]
        c0, c1 = row.cells[0], row.cells[1]
        c0.width = Inches(2.2)
        c1.width = Inches(4.5)
        set_cell_background(c0, "E0F2F1")
        set_cell_background(c1, "FAFAFA")
        set_cell_margins(c0, 60, 60, 100, 100)
        set_cell_margins(c1, 60, 60, 100, 100)

        p0 = c0.paragraphs[0]
        p0.paragraph_format.space_after = Pt(0)
        r0 = p0.add_run(label)
        r0.font.name = "Arial"
        r0.font.size = Pt(10)
        r0.font.bold = True
        r0.font.color.rgb = SECONDARY_COLOR

        p1 = c1.paragraphs[0]
        p1.paragraph_format.space_after = Pt(0)
        r1 = p1.add_run(val)
        r1.font.name = "Arial"
        r1.font.size = Pt(10)
        r1.font.bold = (i < 2)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # 2. Bảng Đối soát Checklist 5 mục
    h1 = doc.add_heading(level=1)
    h1_run = h1.add_run("I. BẢNG ĐỐI SOÁT HOÀN THÀNH CHECKLIST 5 MỤC")
    h1_run.font.name = "Arial"
    h1_run.font.color.rgb = PRIMARY_COLOR
    h1.paragraph_format.space_before = Pt(14)
    h1.paragraph_format.space_after = Pt(6)

    chk_table = doc.add_table(rows=6, cols=3)
    chk_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Mục", "Yêu Cầu Checklist", "Minh Chứng Triển Khai & Kết Quả"]
    for j, h in enumerate(headers):
        cell = chk_table.rows[0].cells[j]
        set_cell_background(cell, "00796B")
        set_cell_margins(cell, 80, 80, 100, 100)
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        r = p.add_run(h)
        r.font.name = "Arial"
        r.font.size = Pt(10)
        r.font.bold = True
        r.font.color.rgb = RGBColor(255, 255, 255)

    checklist_items = [
        ("Mục 1", "Phân tích yêu cầu chức năng và thiết kế sơ đồ luồng dữ liệu cho ứng dụng", "• Phân tích 5 nhóm chức năng (CRUD, Search, Filter, Stats, Subjects)\n• Thiết kế Sơ đồ luồng dữ liệu DFD mức 0 và mức 1\n• Sơ đồ tuần tự (Sequence Diagram) luồng Thêm/Sửa/Xóa và Reactive Watcher"),
        ("Mục 2", "Thiết lập cấu trúc thư mục và phân lớp hệ thống theo chuẩn kiến trúc Cashew", "• Cấu trúc thư mục: database/ (Data Access), struct/ (Domain & Business Logic), pages/ (Screens), widgets/ (UI Components), functions.dart\n• Nguyên lý Local-first, Client-centric, Loose Coupling, Module hóa độc lập"),
        ("Mục 3", "Triển khai các chức năng cốt lõi: Thêm, sửa, xóa và tìm kiếm tài liệu học tập", "• Thêm mới (AddEditDocumentPage) kèm validation chặt chẽ\n• Cập nhật thông tin & Chuyển đổi trạng thái học tập (Chưa học, Đang học, Hoàn thành)\n• Xóa tài liệu ghi nhận vào delete_logs (chuẩn Cashew audit & tombstone)\n• Tìm kiếm tức thì bỏ dấu tiếng Việt, lọc đa tiêu chí"),
        ("Mục 4", "Kiểm thử tính đúng đắn của việc phân tách logic giữa các lớp trong kiến trúc", "• 29/29 bài test tự động chạy bằng flutter test đạt 100% PASS\n• Phân tách kiểm thử: Unit Test (Functions, Models), Integration Test (Database -> Repository -> Provider -> UI), Widget Test\n• Phân tích mã nguồn tĩnh flutter analyze đạt 0 lỗi (No issues found)"),
        ("Mục 5", "Đóng gói mã nguồn và viết báo cáo giải trình về cách áp dụng kiến trúc Cashew", "• Đóng gói thành công bản Web Release (study_docs_app/build/web/)\n• Tạo tệp nén phát hành StudyDocs-Cashew-Release.zip (~14 MB)\n• Báo cáo giải trình đầy đủ BAO_CAO_TH1_KIEN_TRUC_CASHEW.docx và .md")
    ]

    for idx, (m, req, res) in enumerate(checklist_items, start=1):
        row = chk_table.rows[idx]
        row.cells[0].width = Inches(0.8)
        row.cells[1].width = Inches(2.5)
        row.cells[2].width = Inches(3.4)

        bg = "F5F5F5" if idx % 2 == 1 else "FFFFFF"
        for c in row.cells:
            set_cell_background(c, bg)
            set_cell_margins(c, 70, 70, 90, 90)

        p0 = row.cells[0].paragraphs[0]
        p0.paragraph_format.space_after = Pt(0)
        r0 = p0.add_run(m)
        r0.font.name = "Arial"
        r0.font.bold = True
        r0.font.size = Pt(9.5)

        p1 = row.cells[1].paragraphs[0]
        p1.paragraph_format.space_after = Pt(0)
        r1 = p1.add_run(req)
        r1.font.name = "Arial"
        r1.font.size = Pt(9.5)

        p2 = row.cells[2].paragraphs[0]
        p2.paragraph_format.space_after = Pt(0)
        r2 = p2.add_run(res)
        r2.font.name = "Arial"
        r2.font.size = Pt(9.5)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # 3. Phân tích Yêu cầu & Thiết kế Sơ đồ Luồng dữ liệu (Checklist 1)
    h2 = doc.add_heading(level=1)
    h2_run = h2.add_run("II. PHÂN TÍCH YÊU CẦU & THIẾT KẾ SƠ ĐỒ LUỒNG DỮ LIỆU (CHECKLIST 1)")
    h2_run.font.name = "Arial"
    h2_run.font.color.rgb = PRIMARY_COLOR

    p = doc.add_paragraph()
    p.add_run("1. Bối cảnh và Yêu cầu chức năng:\n").bold = True
    p.add_run(
        "Ứng dụng Quản lý Tài liệu Học tập được xây dựng phục vụ sinh viên trường Đại học Thủy Lợi lưu trữ, phân loại và theo dõi tiến độ học tập các học phần (bài giảng, bài tập lớn, tài liệu tham khảo, đề thi trắc nghiệm, ghi chú).\n"
        "Các nhóm chức năng nghiệp vụ trọng tâm bao gồm:\n"
        "• Quản lý tài liệu (CRUD): Thêm mới tài liệu với đầy đủ metadata; xem chi tiết tệp đính kèm và đường dẫn; chỉnh sửa nội dung; chuyển đổi nhanh 3 trạng thái tiến độ (Chưa học, Đang học, Hoàn thành); ghim tài liệu yêu thích; xóa tài liệu an toàn.\n"
        "• Tìm kiếm & Bộ lọc: Tìm kiếm tức thì (live search) hỗ trợ tiếng Việt không dấu; lọc đa tiêu chí theo môn học, định dạng tệp (PDF, DOCX, PPTX...), mức ưu tiên và hạn nộp (Deadline).\n"
        "• Quản lý môn học: Thêm, sửa, xóa môn học (kèm màu sắc nhận diện và icon); thống kê tự động số lượng tài liệu theo môn.\n"
        "• Dashboard thống kê: Bảng điều khiển trực quan tổng hợp số liệu thời gian thực."
    )

    p_d = doc.add_paragraph()
    p_d.add_run("2. Thiết kế Luồng dữ liệu (DFD Mức 0 & Mức 1):\n").bold = True
    p_d.add_run(
        "• DFD Mức 0: Sinh viên tương tác trực tiếp với giao diện Client Flutter ➔ Ứng dụng xử lý cục bộ ➔ Đọc/Ghi dữ liệu SQLite (study_documents.db) mà không phụ thuộc vào Internet (Local-First).\n"
        "• DFD Mức 1: Khi có yêu cầu Tạo/Sửa/Xóa tài liệu, luồng đi qua 3 bước nghiêm ngặt:\n"
        "  (1) Tầng Repository tiếp nhận và kiểm tra quy tắc nghiệp vụ (tiêu đề không rỗng, URL hợp lệ, môn học tồn tại).\n"
        "  (2) Tầng Database thực hiện ghi vào SQLite trong Transaction an toàn. Đặc biệt, thao tác xóa sẽ ghi nhận vào bảng delete_logs để audit và đồng bộ delta sau này.\n"
        "  (3) Cơ chế Reactive Stream Watcher phát tín hiệu broadcast cập nhật dữ liệu mới tới State Provider, giúp UI tự động render lại tức thì."
    )

    # 4. Cấu trúc Thư mục & Phân lớp Hệ thống theo Kiến trúc Cashew (Checklist 2)
    h3 = doc.add_heading(level=1)
    h3_run = h3.add_run("III. THIẾT LẬP CẤU TRÚC THƯ MỤC & PHÂN LỚP KIẾN TRÚC CASHEW (CHECKLIST 2)")
    h3_run.font.name = "Arial"
    h3_run.font.color.rgb = PRIMARY_COLOR

    p_arch = doc.add_paragraph()
    p_arch.add_run("Kiến trúc Cashew là kiến trúc Client-Centric, Local-First Monolith được phân tách thành 4 tầng rành mạch:\n\n")

    layers_info = [
        ("Tầng 1: Data Access & Persistence Layer (Thư mục database/)", 
         "• app_database.dart: SQLite Singleton, quản lý kết nối, CRUD, Transaction, StreamController Watchers.\n"
         "• tables.dart: Khai báo DDL các bảng documents, subjects, delete_logs, app_settings và B-Tree Indexes.\n"
         "• mock_data.dart: Dữ liệu khởi tạo mẫu sinh động gồm 5 môn học và 8 tài liệu học tập thực tế."),
        ("Tầng 2: Domain & Business Logic Layer (Thư mục struct/)", 
         "• document_model.dart & subject_model.dart: Các thực thể dữ liệu bất biến (Immutable Data Classes) hỗ trợ toMap(), fromMap(), copyWith(). Khóa chính dùng UUID v4 chuẩn.\n"
         "• document_enums.dart: Định nghĩa các Enum phân loại (DocumentType, DocumentFormat, DocumentStatus, Priority).\n"
         "• document_repository.dart: Lớp trung gian thực thi quy tắc kiểm tra tính hợp lệ dữ liệu (Business Validation).\n"
         "• document_state_provider.dart: Quản lý State toàn cục bằng Provider/ChangeNotifier, kết nối reactive stream lên UI."),
        ("Tầng 3: Presentation - Screens Layer (Thư mục pages/)", 
         "• home_dashboard_page.dart: Màn hình tổng quan Dashboard chỉ số thống kê, carousel môn học và tài liệu gần đây.\n"
         "• document_list_page.dart: Danh sách tài liệu đầy đủ với TabBar phân loại và menu sắp xếp A-Z / Hạn nộp.\n"
         "• add_edit_document_page.dart: Form nhập liệu Thêm / Sửa tài liệu chuẩn Material 3 kèm Form Validation.\n"
         "• document_detail_page.dart: Chi tiết tài liệu, chuyển đổi trạng thái học tập nhanh, nút Sửa / Xóa.\n"
         "• search_document_page.dart: Tìm kiếm trực tiếp bỏ dấu tiếng Việt kết hợp lọc đa tiêu chí.\n"
         "• subjects_manage_page.dart: Quản lý danh mục môn học (Thêm, Sửa, Xóa cascade tài liệu).\n"
         "• about_app_page.dart: Màn hình giới thiệu đồ án TH1, thông tin sinh viên và mô hình kiến trúc."),
        ("Tầng 4: Presentation - Reusable Widgets Layer (Thư mục widgets/)", 
         "• document_card.dart: Thẻ hiển thị tài liệu phong cách Material 3.\n"
         "• stat_summary_card.dart: Thẻ chỉ số thống kê Dashboard.\n"
         "• filter_chip_bar.dart: Thanh lọc nhanh dạng chip cuộn ngang.\n"
         "• empty_state_view.dart: Giao diện thông báo danh sách trống kèm nút tạo mới.\n"
         "• confirm_dialog.dart: Hộp thoại xác nhận thao tác nguy hiểm (Xóa tài liệu / Môn học).")
    ]

    for title, desc in layers_info:
        p_l = doc.add_paragraph()
        r_t = p_l.add_run(f"• {title}:\n")
        r_t.bold = True
        r_t.font.color.rgb = SECONDARY_COLOR
        p_l.add_run(desc)
        p_l.paragraph_format.space_after = Pt(6)

    # 5. Triển khai Chức năng Cốt lõi (Checklist 3)
    h4 = doc.add_heading(level=1)
    h4_run = h4.add_run("IV. TRIỂN KHAI CÁC CHỨC NĂNG CỐT LÕI (CHECKLIST 3)")
    h4_run.font.name = "Arial"
    h4_run.font.color.rgb = PRIMARY_COLOR

    p_f = doc.add_paragraph()
    p_f.add_run(
        "1. Thêm mới tài liệu (Create): Giao diện AddEditDocumentPage cung cấp các trường nhập liệu tiêu đề, môn học, phân loại, định dạng tệp, đường dẫn file/URL, hạn nộp, ghi chú và tags. Dữ liệu được kiểm tra hợp lệ trước khi gửi xuống Repository.\n\n"
        "2. Chỉnh sửa và Cập nhật tiến độ (Update): Người dùng có thể sửa đổi bất kỳ thông tin nào của tài liệu hoặc chuyển trạng thái học tập nhanh chỉ bằng một chạm giữa Chưa học ➔ Đang học ➔ Hoàn thành.\n\n"
        "3. Xóa tài liệu & Audit Log (Delete): Áp dụng đúng nguyên lý của Cashew Architecture, khi xóa một tài liệu, hệ thống thực thi trong một Transaction SQLite: xóa bản ghi khỏi bảng documents và đồng thời ghi nhận một bản ghi mới vào bảng delete_logs (gồm ID, tên bảng, thời điểm xóa). Cơ chế này giúp audit dữ liệu và sẵn sàng cho đồng bộ delta hai chiều.\n\n"
        "4. Tìm kiếm tức thì (Live Search): Thuật toán trong functions.dart chuẩn hóa chuỗi và loại bỏ dấu tiếng Việt (ví dụ: tìm 'lap trinh' sẽ tìm thấy 'Lập trình Di động'), kết hợp lọc đồng thời theo Môn học, Loại tài liệu và Mục yêu thích."
    )

    # 6. Kiểm thử Tính đúng đắn của việc Phân tách Logic (Checklist 4)
    h5 = doc.add_heading(level=1)
    h5_run = h5.add_run("V. KIỂM THỬ TÍNH ĐÚNG ĐẮN CỦA VIỆC PHÂN TÁCH LOGIC (CHECKLIST 4)")
    h5_run.font.name = "Arial"
    h5_run.font.color.rgb = PRIMARY_COLOR

    p_test = doc.add_paragraph()
    p_test.add_run(
        "Để đảm bảo việc phân tách logic giữa các tầng hoạt động hoàn toàn độc lập và chính xác, dự án đã xây dựng bộ kiểm thử tự động gồm 29 kịch bản test (100% PASS):\n\n"
        "• Unit Test Tiện ích (test/unit_test/functions_test.dart - 5 tests): Kiểm tra tính đúng đắn của việc format ngày, format dung lượng KB/MB/GB, thuật toán bỏ dấu tiếng Việt và validation URL.\n"
        "• Unit Test Domain (test/unit_test/model_test.dart - 6 tests): Kiểm tra tính toàn vẹn khi chuyển đổi toMap/fromMap, tính bất biến của copyWith và các extension phân giải Enum.\n"
        "• Integration Test Phân Tầng (test/integration_test/architecture_layers_test.dart - 15 tests):\n"
        "  - Kiểm thử Tầng Database: Thao tác CRUD trực tiếp trên SQLite in-memory, kiểm tra cơ chế ghi log vào delete_logs khi xóa, kiểm tra reactive stream phát dữ liệu mới.\n"
        "  - Kiểm thử Tầng Repository: Kiểm tra các quy tắc nghiệp vụ từ chối tiêu đề rỗng, từ chối thiếu mã môn, từ chối URL không hợp lệ.\n"
        "  - Kiểm thử Tầng State Provider: Kiểm tra việc lọc theo môn học, lọc theo loại tài liệu, lọc theo mục yêu thích, tìm kiếm không dấu tiếng Việt và sắp xếp A-Z.\n"
        "• Widget Test UI (test/widget_test.dart - 3 tests): Kiểm thử render các component StatSummaryCard, EmptyStateView và AboutAppPage.\n\n"
        "Kết quả phân tích tĩnh mã nguồn:\n"
        "$ flutter analyze ➔ No issues found! (0 lỗi, 0 cảnh báo).\n"
        "$ flutter test ➔ 29/29 tests passed (100% thành công trong 6 giây)."
    )

    # 7. Đóng gói Mã nguồn & Hướng dẫn Khởi chạy (Checklist 5)
    h6 = doc.add_heading(level=1)
    h6_run = h6.add_run("VI. ĐÓNG GÓI MÃ NGUỒN & HƯỚNG DẪN KHỞI CHẠY (CHECKLIST 5)")
    h6_run.font.name = "Arial"
    h6_run.font.color.rgb = PRIMARY_COLOR

    p_run = doc.add_paragraph()
    p_run.add_run(
        "1. Hướng dẫn chạy ứng dụng ở môi trường cục bộ:\n"
        "   $ cd study_docs_app\n"
        "   $ flutter pub get\n"
        "   $ flutter run -d chrome        (Chạy trên trình duyệt Web)\n"
        "   $ flutter test                 (Chạy bộ 29 bài kiểm thử tự động)\n\n"
        "2. Đóng gói phát hành (Release Build):\n"
        "   $ flutter build web --release  (Biên dịch bản Web/PWA)\n"
        "   • Thư mục bản dựng phát hành: study_docs_app/build/web/\n"
        "   • Tệp tin gói nén nộp bài: StudyDocs-Cashew-Release.zip dung lượng ~14 MB được lưu trực tiếp tại thư mục gốc của repository, chứa trọn vẹn bản phát hành sẵn sàng chạy ngay trên bất kỳ trình duyệt nào."
    )

    # 8. Kết luận
    h7 = doc.add_heading(level=1)
    h7_run = h7.add_run("VII. KẾT LUẬN")
    h7_run.font.name = "Arial"
    h7_run.font.color.rgb = PRIMARY_COLOR

    p_c = doc.add_paragraph()
    p_c.add_run(
        "Bài thực hành TH1 đã hoàn thành trọn vẹn 100% cả 5 mục trong Checklist yêu cầu của môn học. Ứng dụng 'Quản lý Tài liệu Học tập' được thiết kế tinh gọn, chuẩn mực theo Kiến trúc Cashew: phân tách 4 lớp độc lập (Presentation, Domain/Logic, Data Access, Persistence), dữ liệu Local-First phản hồi tức thì và an toàn, cơ chế Reactive Stream Watchers mượt mà cùng lịch sử xóa delete_logs đầy đủ. Mã nguồn hoàn chỉnh, sạch sẽ và sẵn sàng mở rộng trong thực tế."
    )

    # Lưu file DOCX
    docx_path = "D:/Nam_4/Mobile/Cashew/BAO_CAO_TH1_KIEN_TRUC_CASHEW.docx"
    doc.save(docx_path)
    print(f"Successfully generated DOCX at {docx_path}")

if __name__ == "__main__":
    create_report_docx()
