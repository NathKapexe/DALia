import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/cause_model.dart';

/// Reads the text of an asset. Injectable so tests do not need a Flutter bundle.
typedef AssetLoader = Future<String> Function(String path);

abstract class KnowledgeLocalDataSource {
  Future<List<CauseModel>> getCauses(String plantId);
}

/// Loads `assets/knowledge/<plantId>.json`.
class AssetKnowledgeDataSource implements KnowledgeLocalDataSource {
  AssetKnowledgeDataSource({AssetLoader? loader})
      : _loader = loader ?? ((path) => rootBundle.loadString(path));

  final AssetLoader _loader;

  @override
  Future<List<CauseModel>> getCauses(String plantId) async {
    final raw = await _loader('assets/knowledge/$plantId.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final causes = json['causes'] as List<dynamic>;
    return causes
        .map((cause) => CauseModel.fromJson(cause as Map<String, dynamic>))
        .toList();
  }
}
