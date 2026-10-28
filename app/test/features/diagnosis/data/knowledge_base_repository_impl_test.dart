import 'package:dalia/features/diagnosis/data/datasources/knowledge_local_data_source.dart';
import 'package:dalia/features/diagnosis/data/repositories/knowledge_base_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

const _json = """
{
  "causes": [
    {
      "id": "a",
      "name": "A",
      "category": "disease",
      "summary": "s",
      "treatmentSteps": ["t"],
      "precautions": [],
      "modelLabels": ["L"],
      "indicators": {"symptom:spots": 1}
    }
  ]
}
""";

void main() {
  test('maps the JSON to causes and caches the result', () async {
    var calls = 0;
    final repository = KnowledgeBaseRepositoryImpl(
      AssetKnowledgeDataSource(loader: (path) async {
        calls++;
        expect(path, 'assets/knowledge/tomato.json');
        return _json;
      }),
    );

    final first = await repository.getCauses('tomato');
    final second = await repository.getCauses('tomato');

    expect(first.single.id, 'a');
    expect(first.single.indicators['symptom:spots'], 1.0);
    expect(identical(first, second), isTrue);
    expect(calls, 1);
  });

  test('propagates the error when the plant has no knowledge file', () async {
    final repository = KnowledgeBaseRepositoryImpl(
      AssetKnowledgeDataSource(loader: (path) async => throw Exception('missing')),
    );

    await expectLater(repository.getCauses('banana'), throwsException);
  });
}
