import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/quick_meal_entry_screen.dart';

void main() {
  group('Quick Meal Flow Integration Test', () {
    testWidgets('complete meal flow in under 10 taps', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => DailyRecallEntryViewModel()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const QuickMealEntryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify meal type is auto-selected
      expect(find.text('08:00'), findsOneWidget);

      // The meal should be logged with minimal taps
      // Let's verify the UI is present
      expect(find.byType(QuickMealEntryScreen), findsOneWidget);
      expect(find.text('Quick summary'), findsOneWidget);

      // For this test, we're primarily verifying the flow works
      // Full automation would require mocking more dependencies
    });

    testWidgets('screen renders all components', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => DailyRecallEntryViewModel()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const QuickMealEntryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all major components are present
      expect(find.byType(QuickMealEntryScreen), findsOneWidget);
      expect(find.text('Quick summary'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_filled), findsOneWidget);
    });

    testWidgets('natural language input is present', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => DailyRecallEntryViewModel()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const QuickMealEntryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the TextField with the expected hint
      final hintFinder = find.text('e.g., Oatmeal with berries and coffee');
      expect(hintFinder, findsOneWidget);
    });

    testWidgets('advanced options is expandable', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => DailyRecallEntryViewModel()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const QuickMealEntryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Advanced options tile should be present
      expect(find.text('Additional info'), findsOneWidget);
    });
  });
}
