import 'package:flutter_test/flutter_test.dart';
import 'package:otterlock/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const OtterLockApp());
    await tester.pump();
    
    // Vérifie que l'app démarre sans erreur
    expect(find.byType(OtterLockApp), findsOneWidget);
  });
}
