import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Pet Store app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PetStoreApp());

    expect(find.text('Pet Store'), findsOneWidget);
  });
}
