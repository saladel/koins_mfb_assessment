import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins_mfb_assessment/widgets/app_button.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
  );
}

void main() {
  group('PrimaryButton', () {
    testWidgets('shows its label and fires onPressed', (tester) async {
      int taps = 0;

      await tester.pumpWidget(
        wrap(PrimaryButton(label: 'Login', onPressed: () => taps++)),
      );

      expect(find.text('Login'), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('swaps the label for a spinner while loading', (tester) async {
      await tester.pumpWidget(
        wrap(PrimaryButton(label: 'Login', isLoading: true, onPressed: () {})),
      );

      expect(find.text('Login'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('cannot be tapped while loading', (tester) async {
      int taps = 0;

      await tester.pumpWidget(
        wrap(
          PrimaryButton(
            label: 'Login',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(taps, 0);
    });
  });
}
