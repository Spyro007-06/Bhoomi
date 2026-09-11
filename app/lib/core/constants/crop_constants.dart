import '../localization/app_strings.dart';

/// The four canonical crops supported in Bhoomi v3 (CLAUDE.md & API_CONTRACT §1).
enum CropType {
  paddy('paddy'),
  cotton('cotton'),
  soybean('soybean'),
  jowar('jowar');

  final String key;
  const CropType(this.key);

  static CropType fromKey(String? key) {
    if (key == null) return CropType.paddy;
    final normalized = key.trim().toLowerCase();
    return CropType.values.firstWhere(
      (c) => c.key == normalized,
      orElse: () => CropType.paddy,
    );
  }

  String getLocalizedName(AppStrings strings) {
    switch (this) {
      case CropType.paddy:
        return strings.cropPaddy;
      case CropType.cotton:
        return strings.cropCotton;
      case CropType.soybean:
        return strings.cropSoybean;
      case CropType.jowar:
        return strings.cropJowar;
    }
  }

  /// Ordered phenological growth stages valid for this crop (seed/growth_stages.py).
  List<GrowthStageItem> getGrowthStages(AppStrings strings) {
    switch (this) {
      case CropType.paddy:
        return [
          GrowthStageItem(key: 'nursery', name: strings.growthStageNursery),
          GrowthStageItem(key: 'vegetative', name: strings.growthStageVegetative),
          GrowthStageItem(key: 'tillering', name: strings.growthStageTillering),
          GrowthStageItem(key: 'booting', name: strings.growthStageBooting),
          GrowthStageItem(key: 'flowering', name: strings.growthStageFlowering),
          GrowthStageItem(key: 'maturity', name: strings.growthStageMaturity),
        ];
      case CropType.cotton:
        return [
          GrowthStageItem(key: 'germination', name: strings.growthStageGermination),
          GrowthStageItem(key: 'vegetative', name: strings.growthStageVegetative),
          GrowthStageItem(key: 'squaring', name: strings.growthStageSquaring),
          GrowthStageItem(key: 'flowering', name: strings.growthStageFlowering),
          GrowthStageItem(key: 'boll_formation', name: strings.growthStageBollFormation),
          GrowthStageItem(key: 'boll_opening', name: strings.growthStageBollOpening),
        ];
      case CropType.soybean:
        return [
          GrowthStageItem(key: 'emergence', name: strings.growthStageEmergence),
          GrowthStageItem(key: 'vegetative', name: strings.growthStageVegetative),
          GrowthStageItem(key: 'flowering', name: strings.growthStageFlowering),
          GrowthStageItem(key: 'pod_formation', name: strings.growthStagePodFormation),
          GrowthStageItem(key: 'seed_filling', name: strings.growthStageSeedFilling),
          GrowthStageItem(key: 'maturity', name: strings.growthStageMaturity),
        ];
      case CropType.jowar:
        return [
          GrowthStageItem(key: 'emergence', name: strings.growthStageEmergence),
          GrowthStageItem(key: 'vegetative', name: strings.growthStageVegetative),
          GrowthStageItem(key: 'panicle_initiation', name: strings.growthStagePanicle),
          GrowthStageItem(key: 'flowering', name: strings.growthStageFlowering),
          GrowthStageItem(key: 'grain_filling', name: strings.growthStageGrainFilling),
          GrowthStageItem(key: 'maturity', name: strings.growthStageMaturity),
        ];
    }
  }
}

class GrowthStageItem {
  final String key;
  final String name;

  const GrowthStageItem({
    required this.key,
    required this.name,
  });
}
