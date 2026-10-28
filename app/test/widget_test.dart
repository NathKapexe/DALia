import 'package:dalia/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/diagnosis/presentation/fakes.dart';

void main() {
  testWidgets('the app starts on the home page', (tester) async {
    final controller = buildController(
      photoSource: FakePhotoSource(),
      analyzer: FakeAnalyzer(),
    );

    await tester.pumpWidget(DaliaApp(controller: controller));

    expect(find.text('¿Qué le pasa a tu planta?'), findsOneWidget);
  });
}
