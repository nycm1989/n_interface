import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:n_interface_example/main.dart';

void main() {
  setUpAll(() async => await initializeDateFormatting());

  testWidgets('renders the widget showcase', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    // Let the async loaders (NResponsiveBuilder / NAsyncLoader) finish.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('n_interface'), findsWidgets);
    expect(find.text('NButton'), findsOneWidget);
  });
}
