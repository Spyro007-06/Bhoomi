import 'package:flutter/material.dart';
import '../core/localization/app_strings.dart';

/// Semantic representation of what part of the crop the farmer should inspect or photograph.
enum InspectionTarget {
  leaf,
  insect,
  wholePlant,
  stem,
  fruit,
  root,
  soil,
  unknown;

  /// Resolves an [InspectionTarget] by semantically analyzing the farmer's query and optional context.
  /// Supports Marathi, Hindi, and English agricultural terms.
  static InspectionTarget resolveFromQuery(String query, [String? context]) {
    final text = '$query ${context ?? ''}'.toLowerCase();

    // 1. Leaf / foliage checks
    if (text.contains('leaf') ||
        text.contains('leaves') ||
        text.contains('foliage') ||
        text.contains('पान') ||
        text.contains('पाने') ||
        text.contains('पानांवर') ||
        text.contains('डाग') ||
        text.contains('ठिपके') ||
        text.contains('पत्ता') ||
        text.contains('पत्ते') ||
        text.contains('पत्तों') ||
        text.contains('धब्बे') ||
        text.contains('blight') ||
        text.contains('spot') ||
        text.contains('rust')) {
      return InspectionTarget.leaf;
    }

    // 2. Insects / pests / larvae
    if (text.contains('insect') ||
        text.contains('pest') ||
        text.contains('bug') ||
        text.contains('worm') ||
        text.contains('caterpillar') ||
        text.contains('aphid') ||
        text.contains('borer') ||
        text.contains('कीड') ||
        text.contains('किडा') ||
        text.contains('किडे') ||
        text.contains('किडी') ||
        text.contains('कीटक') ||
        text.contains('माशी') ||
        text.contains('मावा') ||
        text.contains('तुडतुडे') ||
        text.contains('अळी') ||
        text.contains('कीट') ||
        text.contains('कीड़ा') ||
        text.contains('कीड़े') ||
        text.contains('इल्ली') ||
        text.contains('सुंडी')) {
      return InspectionTarget.insect;
    }

    // 3. Fruits / pods / grains
    if (text.contains('fruit') ||
        text.contains('pod') ||
        text.contains('grain') ||
        text.contains('tomato') ||
        text.contains('फळ') ||
        text.contains('फळे') ||
        text.contains('शेंग') ||
        text.contains('शेंगा') ||
        text.contains('दाणे') ||
        text.contains('फल') ||
        text.contains('टमाटर') ||
        text.contains('फली') ||
        text.contains('दाने')) {
      return InspectionTarget.fruit;
    }

    // 4. Stem / shoot
    if (text.contains('stem') ||
        text.contains('shoot') ||
        text.contains('stalk') ||
        text.contains('branch') ||
        text.contains('खोड') ||
        text.contains('काडी') ||
        text.contains('फांदी') ||
        text.contains('तना') ||
        text.contains('शाखा')) {
      return InspectionTarget.stem;
    }

    // 5. Roots
    if (text.contains('root') ||
        text.contains('roots') ||
        text.contains('मूळ') ||
        text.contains('मुळे') ||
        text.contains('मुळ्या') ||
        text.contains('जड़') ||
        text.contains('जड़ें')) {
      return InspectionTarget.root;
    }

    // 6. Soil / ground
    if (text.contains('soil') ||
        text.contains('ground') ||
        text.contains('माती') ||
        text.contains('जमीन') ||
        text.contains('शेतात') ||
        text.contains('मिट्टी')) {
      return InspectionTarget.soil;
    }

    // 7. Whole plant / general crop
    if (text.contains('whole') ||
        text.contains('plant') ||
        text.contains('crop') ||
        text.contains('field') ||
        text.contains('growth') ||
        text.contains('झाड') ||
        text.contains('झाडे') ||
        text.contains('रोप') ||
        text.contains('पीक') ||
        text.contains('वाढ') ||
        text.contains('पौधा') ||
        text.contains('पौधे') ||
        text.contains('पेड़') ||
        text.contains('फसल')) {
      return InspectionTarget.wholePlant;
    }

    return InspectionTarget.unknown;
  }

  /// Converts the semantic target into a natural, localized guidance prompt.
  String getLocalizedPrompt(AppStrings strings) {
    switch (this) {
      case InspectionTarget.leaf:
        return strings.voiceShowLeavesContextual;
      case InspectionTarget.insect:
        return strings.voiceShowInsectsContextual;
      case InspectionTarget.wholePlant:
        return strings.voiceShowPlantContextual;
      case InspectionTarget.unknown:
        return strings.voiceShowUnknownContextual;
      case InspectionTarget.fruit:
        return strings.voiceShowFruitContextual;
      case InspectionTarget.stem:
        return strings.voiceShowStemContextual;
      case InspectionTarget.root:
        return strings.voiceShowRootContextual;
      case InspectionTarget.soil:
        return strings.voiceShowSoilContextual;
    }
  }

  /// Returns a visual framing icon for camera guidance.
  IconData get framingIcon {
    switch (this) {
      case InspectionTarget.leaf:
        return Icons.eco_rounded;
      case InspectionTarget.insect:
        return Icons.pest_control_rounded;
      case InspectionTarget.wholePlant:
        return Icons.nature_rounded;
      case InspectionTarget.fruit:
        return Icons.agriculture_rounded;
      case InspectionTarget.stem:
      case InspectionTarget.root:
      case InspectionTarget.soil:
        return Icons.grass_rounded;
      case InspectionTarget.unknown:
        return Icons.center_focus_strong_rounded;
    }
  }
}
