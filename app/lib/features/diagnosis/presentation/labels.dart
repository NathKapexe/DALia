import '../domain/entities/cause.dart';
import '../domain/entities/context_answers.dart';
import '../domain/entities/diagnosis.dart';

/// User-facing Spanish texts for the domain enums and evidence codes.

String soilLabel(SoilState soil) => switch (soil) {
      SoilState.waterlogged => 'Encharcada',
      SoilState.moist => 'Húmeda',
      SoilState.dry => 'Seca',
      SoilState.veryDry => 'Muy seca, se separa de la maceta',
    };

String lightLabel(LightLevel light) => switch (light) {
      LightLevel.fullSun => 'Sol directo (6 horas o más)',
      LightLevel.partial => 'Sol parcial',
      LightLevel.low => 'Poca luz o interior',
    };

String symptomLabel(Symptom symptom) => switch (symptom) {
      Symptom.yellowLeaves => 'Hojas amarillas',
      Symptom.dryTips => 'Puntas o bordes secos',
      Symptom.spots => 'Manchas en las hojas',
      Symptom.wilting => 'Hojas caídas o marchitas',
      Symptom.moldOrPowder => 'Moho o polvo blanco o gris',
      Symptom.visibleInsects => 'Insectos visibles',
      Symptom.curledOrDeformed => 'Hojas enrolladas o deformes',
    };

String categoryLabel(CauseCategory category) => switch (category) {
      CauseCategory.disease => 'Enfermedad',
      CauseCategory.pest => 'Plaga',
      CauseCategory.watering => 'Riego',
      CauseCategory.light => 'Luz',
      CauseCategory.nutrition => 'Nutrición',
      CauseCategory.none => 'Sin síntomas claros',
    };

String levelMessage(ConfidenceLevel level) => switch (level) {
      ConfidenceLevel.high => 'Estas son las causas más probables.',
      ConfidenceLevel.medium =>
        'Hay varias causas posibles. Revisa la lista y compárala con tu planta.',
      ConfidenceLevel.low =>
        'No estoy seguro. Prueba con una foto más cercana de una hoja y completa las preguntas.',
    };

const String emptyResultMessage =
    'No hay suficiente información. Marca los síntomas que ves o prueba con otra foto.';

const String disclaimer = 'Orientación general: no sustituye a un especialista.';

/// Turns an evidence code (`image:...`, `context:soil:waterlogged`) into text.
String evidenceLabel(String code) {
  if (code.startsWith('image:')) return 'La foto apunta a esta causa';

  if (code.startsWith('context:soil:')) {
    final name = code.substring('context:soil:'.length);
    for (final soil in SoilState.values) {
      if (soil.name == name) return 'Tierra: ${soilLabel(soil).toLowerCase()}';
    }
  }
  if (code.startsWith('context:light:')) {
    final name = code.substring('context:light:'.length);
    for (final light in LightLevel.values) {
      if (light.name == name) return 'Luz: ${lightLabel(light).toLowerCase()}';
    }
  }
  if (code.startsWith('context:symptom:')) {
    final name = code.substring('context:symptom:'.length);
    for (final symptom in Symptom.values) {
      if (symptom.name == name) return 'Marcaste: ${symptomLabel(symptom).toLowerCase()}';
    }
  }
  return code;
}
