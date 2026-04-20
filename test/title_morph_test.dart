import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titlemorph/titlemorph.dart';

void main() {
  group('TitleMorph', () {
    testWidgets('renders initial title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const TitleMorph(title: 'Hello')),
          ),
        ),
      );

      // Each character is a separate Text widget
      expect(find.text('H'), findsOneWidget);
      expect(find.text('e'), findsOneWidget);
      expect(find.text('l'), findsNWidgets(2));
      expect(find.text('o'), findsOneWidget);
    });

    testWidgets('updates when title prop changes', (tester) async {
      String title = 'Home';

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(title: TitleMorph(title: title)),
                body: ElevatedButton(
                  onPressed: () => setState(() => title = 'Profile'),
                  child: const Text('Change'),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('H'), findsOneWidget);

      await tester.tap(find.text('Change'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('P'), findsOneWidget);
    });

    testWidgets('TitleMorphController.morph triggers transition',
        (tester) async {
      final controller = TitleMorphController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: TitleMorph(title: 'Home', controller: controller),
            ),
          ),
        ),
      );

      expect(find.text('H'), findsOneWidget);

      controller.morph('Settings');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('S'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('handles spaces correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const TitleMorph(title: 'My App')),
          ),
        ),
      );

      // Space is rendered as non-breaking space \u00a0
      expect(find.text('\u00a0'), findsOneWidget);
    });

    testWidgets('respects custom style', (tester) async {
      const style = TextStyle(fontSize: 24, color: Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const TitleMorph(title: 'Hi', style: style),
            ),
          ),
        ),
      );

      final textWidget = tester.widgetList<Text>(find.byType(Text)).first;
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.color, Colors.red);
    });
  });
}
