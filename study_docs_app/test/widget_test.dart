import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_app/pages/about_app_page.dart';
import 'package:study_docs_app/theme.dart';
import 'package:study_docs_app/widgets/empty_state_view.dart';
import 'package:study_docs_app/widgets/stat_summary_card.dart';

void main() {
  group('Presentation Layer: Widget Tests', () {
    testWidgets('StatSummaryCard hiển thị đúng tiêu đề, số lượng và icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Row(
              children: [
                StatSummaryCard(
                  title: 'Tổng tài liệu',
                  value: '12',
                  icon: Icons.folder_rounded,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tổng tài liệu'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
    });

    testWidgets('EmptyStateView hiển thị đúng thông điệp và nút hành động', (WidgetTester tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: EmptyStateView(
              title: 'Không có tài liệu',
              message: 'Hãy thử thêm tài liệu mới',
              actionText: 'Tạo mới',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Không có tài liệu'), findsOneWidget);
      expect(find.text('Hãy thử thêm tài liệu mới'), findsOneWidget);
      expect(find.text('Tạo mới'), findsOneWidget);

      await tester.tap(find.text('Tạo mới'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });

    testWidgets('AboutAppPage hiển thị đầy đủ thông tin sinh viên và kiến trúc Cashew', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AboutAppPage(),
        ),
      );

      expect(find.text('Báo Cáo Kiến Trúc & Tác Giả'), findsOneWidget);
      expect(find.text('BÀI THỰC HÀNH TH1'), findsOneWidget);
      expect(find.text('Nguyễn Văn Huỳnh'), findsOneWidget);
      expect(find.text('2351170599'), findsOneWidget);
    });
  });
}
