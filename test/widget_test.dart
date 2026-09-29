import 'package:flutter_test/flutter_test.dart';
import 'package:theme_craft_app/main.dart';

void main() {
  testWidgets('App loads cleanly test', (WidgetTester tester) async {
    await tester.pumpWidget(const DepthCraftApp());
    expect(find.text('DepthCraft'), findsNothing); // smoke test
  });
}
