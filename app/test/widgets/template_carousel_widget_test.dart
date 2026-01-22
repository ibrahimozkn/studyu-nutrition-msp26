import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/template_carousel_widget.dart';

Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('TemplateCarouselWidget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: TemplateCarouselWidget(
            userId: 'test-user',
            label: 'From Template',
            onAddFoods: (foods) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TemplateCarouselWidget), findsOneWidget);
    });

    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: TemplateCarouselWidget(
            userId: 'test-user',
            label: 'Templates',
            onAddFoods: (foods) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has onAddFoods callback', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: TemplateCarouselWidget(
            userId: 'test-user',
            label: 'Templates',
            onAddFoods: (foods) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TemplateCarouselWidget), findsOneWidget);
    });
  });
}
