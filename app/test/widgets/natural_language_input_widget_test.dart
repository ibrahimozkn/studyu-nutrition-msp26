import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/natural_language_input_widget.dart';

Widget setup(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('NaturalLanguageInputWidget displays placeholder text', (tester) async {
    await tester.pumpWidget(
      setup(const NaturalLanguageInputWidget()),
    );

    expect(
      find.text('e.g., Oatmeal with berries and coffee'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('NaturalLanguageInputWidget captures onChanged input', (tester) async {
    String? changedValue;

    await tester.pumpWidget(
      setup(
        NaturalLanguageInputWidget(
          onChanged: (value) => changedValue = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'oatmeal');
    await tester.pump();

    expect(changedValue, 'oatmeal');
  });

  testWidgets('NaturalLanguageInputWidget triggers onSubmitted', (tester) async {
    String? submittedValue;

    await tester.pumpWidget(
      setup(
        NaturalLanguageInputWidget(
          onSubmitted: (value) => submittedValue = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submittedValue, 'coffee');
  });
}
