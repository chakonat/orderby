import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Orderby app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const OrderbyApp());

    expect(find.text('Кіру'), findsWidgets);
  });
}
