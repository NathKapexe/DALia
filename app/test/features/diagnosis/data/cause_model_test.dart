import 'dart:convert';
import 'dart:io';

import 'package:dalia/features/diagnosis/data/models/cause_model.dart';
import 'package:dalia/features/diagnosis/domain/entities/context_answers.dart';
import 'package:flutter_test/flutter_test.dart';

const _modelLabels = <String>{
  'Tomato___Bacterial_spot',
  'Tomato___Early_blight',
  'Tomato___Late_blight',
  'Tomato___Leaf_Mold',
  'Tomato___Septoria_leaf_spot',
  'Tomato___Spider_mites Two-spotted_spider_mite',
  'Tomato___Target_Spot',
  'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
  'Tomato___Tomato_mosaic_virus',
  'Tomato___healthy',
};

void main() {
  late List<CauseModel> causes;

  setUpAll(() {
    // `flutter test` runs from the project root, so the asset is on disk.
    final raw = File('assets/knowledge/tomato.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    causes = (json['causes'] as List<dynamic>)
        .map((cause) => CauseModel.fromJson(cause as Map<String, dynamic>))
        .toList();
  });

  test('the tomato knowledge base parses and has unique ids', () {
    expect(causes, isNotEmpty);
    expect(causes.map((c) => c.id).toSet().length, causes.length);
  });

  test('every cause has a name, a summary and treatment steps', () {
    for (final cause in causes) {
      expect(cause.name, isNotEmpty, reason: cause.id);
      expect(cause.summary, isNotEmpty, reason: cause.id);
      expect(cause.treatmentSteps, isNotEmpty, reason: cause.id);
    }
  });

  test('every class of the image model maps to a cause', () {
    final covered = causes.expand((c) => c.modelLabels).toSet();
    expect(covered, _modelLabels);
  });

  test('indicators use signals the domain can produce', () {
    final valid = <String>{
      for (final s in SoilState.values) 'soil:${s.name}',
      for (final l in LightLevel.values) 'light:${l.name}',
      for (final s in Symptom.values) 'symptom:${s.name}',
    };
    for (final cause in causes) {
      for (final signal in cause.indicators.keys) {
        expect(valid, contains(signal), reason: '${cause.id}: $signal');
      }
    }
  });

  test('an unknown category is rejected', () {
    expect(
      () => CauseModel.fromJson({
        'id': 'x',
        'name': 'x',
        'category': 'not-a-category',
        'summary': 'x',
        'treatmentSteps': ['x'],
      }),
      throwsFormatException,
    );
  });
}
