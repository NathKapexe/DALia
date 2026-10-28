import 'package:dalia/app.dart';
import 'package:dalia/features/diagnosis/domain/entities/visual_finding.dart';
import 'package:dalia/features/diagnosis/domain/repositories/image_analyzer.dart';
import 'package:dalia/features/diagnosis/presentation/state/diagnosis_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<void> pumpApp(WidgetTester tester, DiagnosisController controller) async {
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(DaliaApp(controller: controller));
}

Future<void> goToQuestions(WidgetTester tester) async {
  await tester.tap(find.text('Elegir una foto'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeAnalyzer analyzer;

  setUp(() {
    analyzer = FakeAnalyzer();
  });

  testWidgets('without a camera only the file option is shown', (tester) async {
    final controller = buildController(
      photoSource: FakePhotoSource(camera: false),
      analyzer: analyzer,
    );
    await pumpApp(tester, controller);

    expect(find.text('Elegir una foto'), findsOneWidget);
    expect(find.text('Tomar foto'), findsNothing);
  });

  testWidgets('with a camera both options are shown', (tester) async {
    final controller = buildController(
      photoSource: FakePhotoSource(),
      analyzer: analyzer,
    );
    await pumpApp(tester, controller);

    expect(find.text('Elegir una foto'), findsOneWidget);
    expect(find.text('Tomar foto'), findsOneWidget);
  });

  testWidgets('full flow: photo, questions and result', (tester) async {
    analyzer.findings = const [
      VisualFinding(label: 'Tomato___Late_blight', confidence: 0.8),
    ];
    final controller = buildController(
      photoSource: FakePhotoSource(),
      analyzer: analyzer,
    );
    await pumpApp(tester, controller);

    await goToQuestions(tester);
    expect(find.text('¿Cómo está la tierra?'), findsOneWidget);

    await tester.tap(find.text('Manchas en las hojas'));
    await tester.pump();
    await tester.tap(find.text('Analizar'));
    await tester.pumpAndSettle();

    expect(find.text('Estas son las causas más probables.'), findsOneWidget);
    expect(find.text('Tizón tardío'), findsOneWidget);
    expect(find.text('Hongo de prueba'), findsOneWidget);
    expect(find.text('1. Quita las hojas afectadas'), findsOneWidget);
  });

  testWidgets('offline result shows the banner and retry removes it', (tester) async {
    analyzer.error = const AnalyzerUnavailableException();
    final controller = buildController(
      photoSource: FakePhotoSource(),
      analyzer: analyzer,
    );
    await pumpApp(tester, controller);

    await goToQuestions(tester);
    await tester.tap(find.text('Analizar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sin conexión'), findsOneWidget);

    analyzer.error = null;
    analyzer.findings = const [
      VisualFinding(label: 'Tomato___Late_blight', confidence: 0.8),
    ];
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sin conexión'), findsNothing);
    expect(find.text('Tizón tardío'), findsOneWidget);
  });

  testWidgets('an invalid photo shows the message and stays on the questions',
      (tester) async {
    analyzer.error = const InvalidPhotoException('Formato no admitido.');
    final controller = buildController(
      photoSource: FakePhotoSource(),
      analyzer: analyzer,
    );
    await pumpApp(tester, controller);

    await goToQuestions(tester);
    await tester.tap(find.text('Analizar'));
    await tester.pumpAndSettle();

    expect(find.text('Formato no admitido.'), findsOneWidget);
    expect(find.text('¿Cómo está la tierra?'), findsOneWidget);
  });
}
