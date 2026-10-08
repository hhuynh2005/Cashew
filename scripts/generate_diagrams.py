import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import os

os.makedirs('scripts/output', exist_ok=True)

def generate_architecture_diagram():
    fig, ax = plt.subplots(figsize=(12, 7.5), dpi=300)
    ax.set_facecolor('#F8FAFC')
    fig.patch.set_facecolor('#FFFFFF')
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Title
    ax.text(50, 97, 'SƠ ĐỒ KIẾN TRÚC TỔNG THỂ HỆ THỐNG DMS TÍCH HỢP CLOUD (AWS)', 
            fontsize=14, fontweight='bold', ha='center', va='top', color='#1E293B', fontfamily='sans-serif')
    ax.text(50, 93.5, 'Kiến trúc Phân tách Control Plane & Data Plane kết hợp Event-Driven Serverless Ingestion',
            fontsize=10, ha='center', va='top', color='#64748B', fontfamily='sans-serif', style='italic')

    def draw_box(x, y, w, h, title, subtitle, bg_color, border_color, title_color='#0F172A', text_color='#334155'):
        rect = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.5,rounding_size=1.5",
                                     linewidth=1.5, edgecolor=border_color, facecolor=bg_color)
        ax.add_patch(rect)
        if subtitle:
            ax.text(x + w/2, y + h*0.65, title, fontsize=9.5, fontweight='bold', ha='center', va='center', color=title_color)
            ax.text(x + w/2, y + h*0.32, subtitle, fontsize=8, ha='center', va='center', color=text_color)
        else:
            ax.text(x + w/2, y + h/2, title, fontsize=9.5, fontweight='bold', ha='center', va='center', color=title_color)

    def draw_group(x, y, w, h, label, color='#E2E8F0', border='#94A3B8'):
        rect = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.8,rounding_size=2.0",
                                     linewidth=1.2, linestyle='--', edgecolor=border, facecolor=color, alpha=0.5)
        ax.add_patch(rect)
        ax.text(x + 2, y + h - 2.5, label, fontsize=9, fontweight='bold', ha='left', va='top', color='#475569')

    # Draw Groups
    # 1. Client Layer
    draw_group(2, 10, 16, 78, "1. CLIENT LAYER")
    draw_box(4, 60, 12, 12, "Web Client", "React / Vue SPA", "#EFF6FF", "#3B82F6")
    draw_box(4, 40, 12, 12, "Mobile App", "Flutter (iOS/Android)", "#EFF6FF", "#3B82F6")
    draw_box(4, 20, 12, 12, "Desktop App", "Windows / macOS", "#EFF6FF", "#3B82F6")

    # 2. Edge & Security Layer
    draw_group(21, 10, 18, 78, "2. EDGE & SECURITY")
    draw_box(23, 66, 14, 11, "Route 53 & WAF", "DNS & DDoS Shield", "#FEF3C7", "#D97706")
    draw_box(23, 44, 14, 14, "Amazon CloudFront", "CDN Edge Caching\nSigned URLs / Cookies", "#FEF3C7", "#D97706")
    draw_box(23, 18, 14, 13, "Amazon Cognito", "OAuth2 / OIDC / JWT\nUser Authentication", "#FEF3C7", "#D97706")

    # 3. Application & Compute Layer
    draw_group(42, 10, 24, 78, "3. COMPUTE & BACKEND")
    draw_box(44, 68, 20, 10, "Application Load Balancer", "ALB (SSL Termination)", "#F3E8FF", "#8B5CF6")
    draw_box(44, 42, 20, 18, "ECS Fargate (Backend)", "Stateless REST API Containers\nDocument Metadata Engine\nAuth & RBAC Enforcement", "#F3E8FF", "#8B5CF6")
    draw_box(44, 16, 20, 14, "AWS KMS & Secrets", "Envelope Encryption\nKMS Keys / Secrets Manager", "#F3E8FF", "#8B5CF6")

    # 4. Storage & Processing Layer
    draw_group(69, 10, 29, 78, "4. DATA & SERVERLESS STORAGE")
    draw_box(71, 64, 25, 20, "Amazon S3 (Document Store)", "• S3 Standard (Hot docs)\n• S3 Intelligent-Tiering\n• S3 Glacier Deep Archive\nSSE-KMS Encryption (AES-256)", "#ECFDF5", "#059669")
    draw_box(71, 38, 25, 17, "Amazon RDS (PostgreSQL)", "Multi-AZ Managed Cluster\nMetadata, Versions, Permissions\nAutomated Snapshot & Read Replica", "#ECFDF5", "#059669")
    draw_box(71, 14, 25, 16, "Event Processing Pipeline", "S3 Event -> SQS -> Lambda\nAsync OCR / Thumbnail Generator\nOpenSearch Full-text Indexing", "#ECFDF5", "#059669")

    # Connectors & Arrows
    # Client to Edge
    ax.annotate("", xy=(23, 51), xytext=(16, 51), arrowprops=dict(arrowstyle="->", color="#1E293B", lw=1.8))
    ax.text(19.5, 52.5, "HTTPS", fontsize=7.5, ha='center', color='#1E293B', fontweight='bold')

    # Edge to Compute
    ax.annotate("", xy=(44, 73), xytext=(37, 72), arrowprops=dict(arrowstyle="->", color="#1E293B", lw=1.5))
    ax.annotate("", xy=(44, 51), xytext=(37, 51), arrowprops=dict(arrowstyle="->", color="#1E293B", lw=1.5))

    # ALB to ECS
    ax.annotate("", xy=(54, 60), xytext=(54, 68), arrowprops=dict(arrowstyle="->", color="#8B5CF6", lw=1.5))

    # ECS to RDS
    ax.annotate("", xy=(71, 47), xytext=(64, 47), arrowprops=dict(arrowstyle="<->", color="#059669", lw=1.5))
    ax.text(67.5, 48.5, "SQL CRUD", fontsize=7, ha='center', color='#059669', fontweight='bold')

    # ECS to S3 (Presigned URL issuance)
    ax.annotate("", xy=(71, 74), xytext=(64, 56), arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.5, ls="--"))
    ax.text(67.5, 66, "Presigned\nURL Token", fontsize=7, ha='center', color='#0284C7', fontweight='bold')

    # Client DIRECT Upload to S3
    ax.annotate("", xy=(71, 78), xytext=(16, 70),
                arrowprops=dict(arrowstyle="->", color="#DC2626", lw=2, linestyle='solid',
                                connectionstyle="arc3,rad=-0.18"))
    ax.text(45, 87, "Direct Upload Payload to S3 via Presigned URL (Bypasses Backend)", 
            fontsize=8.5, ha='center', color='#DC2626', fontweight='bold', 
            bbox=dict(boxstyle="round,pad=0.2", fc="#FEE2E2", ec="#DC2626", lw=1))

    # S3 to Event pipeline
    ax.annotate("", xy=(83.5, 30), xytext=(83.5, 64), arrowprops=dict(arrowstyle="->", color="#D97706", lw=1.5))
    ax.text(85.5, 34, "S3 PutObject\nEvent Notification", fontsize=7, ha='left', color='#D97706')

    # Lambda back to RDS
    ax.annotate("", xy=(77, 38), xytext=(77, 30), arrowprops=dict(arrowstyle="->", color="#059669", lw=1.5))
    ax.text(75, 34, "Update OCR/Thumb", fontsize=6.8, ha='right', color='#059669')

    # CloudFront download from S3
    ax.annotate("", xy=(30, 58), xytext=(71, 71),
                arrowprops=dict(arrowstyle="<-", color="#0284C7", lw=1.5, linestyle="dotted",
                                connectionstyle="arc3,rad=0.15"))
    ax.text(48, 62, "Edge Cache Hit / S3 Read", fontsize=7.5, ha='center', color='#0284C7')

    plt.tight_layout()
    plt.savefig('scripts/output/cloud_dms_architecture.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("Architecture diagram generated successfully!")

def generate_flow_diagram():
    fig, ax = plt.subplots(figsize=(11, 6.5), dpi=300)
    ax.set_facecolor('#F8FAFC')
    fig.patch.set_facecolor('#FFFFFF')
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Title
    ax.text(50, 96, 'LUỒNG DỮ LIỆU TẢI LÊN TRỰC TIẾP (DIRECT UPLOAD) VÀ XỬ LÝ KHÔNG ĐỒNG BỘ', 
            fontsize=13, fontweight='bold', ha='center', va='top', color='#1E293B', fontfamily='sans-serif')
    ax.text(50, 92, 'Cơ chế Pre-signed URL kết hợp Event-Driven Serverless Pipeline tối ưu thông lượng & bảo mật',
            fontsize=9.5, ha='center', va='top', color='#64748B', fontfamily='sans-serif', style='italic')

    # Entities
    entities = [
        (10, "Client Device\n(Web / Flutter)"),
        (35, "API Gateway / Backend\n(ECS Fargate)"),
        (62, "Amazon S3\n(Object Storage)"),
        (90, "Worker / Lambda\n(Async OCR/Thumbnail)")
    ]

    for x, name in entities:
        rect = patches.FancyBboxPatch((x-9, 80), 18, 8, boxstyle="round,pad=0.3",
                                     linewidth=1.2, edgecolor='#1E3A8A', facecolor='#DBEAFE')
        ax.add_patch(rect)
        ax.text(x, 84, name, fontsize=8.5, fontweight='bold', ha='center', va='center', color='#1E3A8A')
        # Vertical lifeline
        ax.plot([x, x], [12, 80], color='#CBD5E1', linestyle='--', linewidth=1.2)

    # Sequence steps
    steps = [
        (74, 10, 35, "1. Request Upload URL (File metadata, size, MIME)", "#2563EB", False),
        (67, 35, 10, "2. Validate Auth & Return Pre-signed Upload URL (TTL: 15m)", "#059669", True),
        (58, 10, 62, "3. PUT File Directly to S3 via Pre-signed URL (Binary Payload)", "#DC2626", False),
        (50, 62, 10, "4. 200 OK (S3 ETag confirmed directly to Client)", "#059669", True),
        (42, 62, 90, "5. S3 Trigger Event (ObjectCreated:Put -> SQS -> Lambda)", "#D97706", False),
        (34, 90, 62, "6. Lambda fetches file, runs OCR & creates thumbnail", "#7C3AED", True),
        (26, 90, 35, "7. Lambda updates RDS (Text content, metadata, ready=true)", "#2563EB", True),
        (18, 35, 10, "8. Push WebSocket / SSE Notification to Client: Document Ready", "#059669", True)
    ]

    for y, src, dst, label, col, is_left in steps:
        # arrow
        ax.annotate("", xy=(dst, y), xytext=(src, y),
                    arrowprops=dict(arrowstyle="->", color=col, lw=1.6))
        # label
        mid_x = (src + dst) / 2
        ax.text(mid_x, y + 1.8, label, fontsize=8, ha='center', va='bottom', color=col, fontweight='bold',
                bbox=dict(boxstyle="round,pad=0.15", fc="#FFFFFF", ec=col, lw=0.8, alpha=0.9))

    plt.tight_layout()
    plt.savefig('scripts/output/direct_upload_flow.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("Flow diagram generated successfully!")

def generate_cost_chart():
    fig, ax = plt.subplots(figsize=(8.5, 4.5), dpi=300)
    fig.patch.set_facecolor('#FFFFFF')
    ax.set_facecolor('#FAFAFA')

    categories = ['Năm 1\n(Khởi tạo & Setup)', 'Năm 2\n(Vận hành & Mở rộng)', 'Năm 3\n(Duy trì & Lưu trữ)', 'Tổng 3 Năm\n(TCO Tổng)']
    
    # Cost in USD (estimated for 50TB DMS enterprise scale)
    on_prem = [45000, 22000, 24000, 91000]
    cloud_aws = [16000, 18500, 20500, 55000]

    x = np.arange(len(categories))
    width = 0.35

    rects1 = ax.bar(x - width/2, on_prem, width, label='Mô hình Truyền thống (On-Premises)', color='#EF4444', edgecolor='#B91C1C')
    rects2 = ax.bar(x + width/2, cloud_aws, width, label='Mô hình Tích hợp Cloud (AWS)', color='#10B981', edgecolor='#047857')

    ax.set_ylabel('Chi phí ước tính (USD)', fontsize=10, fontweight='bold', color='#1E293B')
    ax.set_title('SO SÁNH TỔNG CHI PHÍ SỞ HỮU (TCO - 3 NĂM)\nOn-Premises Hardware/Infra vs. AWS Cloud DMS (50TB Storage Scale)', 
                 fontsize=11, fontweight='bold', color='#1E293B', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels(categories, fontsize=9.5, fontweight='bold', color='#334155')
    ax.legend(frameon=True, facecolor='#FFFFFF', edgecolor='#CBD5E1', fontsize=9)
    ax.grid(axis='y', linestyle='--', alpha=0.6)

    # Add values on top of bars
    def autolabel(rects):
        for rect in rects:
            height = rect.get_height()
            ax.annotate(f'${height:,}',
                        xy=(rect.get_x() + rect.get_width() / 2, height),
                        xytext=(0, 3),  # 3 points vertical offset
                        textcoords="offset points",
                        ha='center', va='bottom', fontsize=8.5, fontweight='bold')

    autolabel(rects1)
    autolabel(rects2)

    plt.tight_layout()
    plt.savefig('scripts/output/tco_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("Cost chart generated successfully!")

if __name__ == '__main__':
    generate_architecture_diagram()
    generate_flow_diagram()
    generate_cost_chart()
