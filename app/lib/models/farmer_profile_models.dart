import 'farm_models.dart';

/// Supported soil types for agricultural profiling.
enum SoilType {
  sandy('sandy', 'वालुकामय / Sandy'),
  clay('clay', 'चिकणमाती / Clay'),
  loamy('loamy', 'गाळाची / Loamy'),
  black('black', 'काळी माती / Black Soil'),
  red('red', 'तांबडी माती / Red Soil'),
  redLoamy('red_loamy', 'लाल गाळाची माती / Red loamy soil'),
  alluvial('alluvial', 'पॉलिदार / Alluvial'),
  other('other', 'इतर / Other'),
  unknown('unknown', 'माहित नाही / Unknown');

  final String key;
  final String label;
  const SoilType(this.key, this.label);

  String localizedLabel(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'mr':
        switch (this) {
          case SoilType.sandy: return 'वालुकामय माती';
          case SoilType.clay: return 'चिकणमाती';
          case SoilType.loamy: return 'गाळाची जमीन';
          case SoilType.black: return 'काळी माती';
          case SoilType.red: return 'तांबडी माती';
          case SoilType.redLoamy: return 'लाल गाळाची माती';
          case SoilType.alluvial: return 'पॉलिदार माती';
          case SoilType.other: return 'इतर';
          case SoilType.unknown: return 'माहित नाही';
        }
      case 'hi':
        switch (this) {
          case SoilType.sandy: return 'रेतीली मिट्टी';
          case SoilType.clay: return 'चिकनी मिट्टी';
          case SoilType.loamy: return 'दोमट मिट्टी';
          case SoilType.black: return 'काली मिट्टी';
          case SoilType.red: return 'लाल मिट्टी';
          case SoilType.redLoamy: return 'लाल दोमट मिट्टी';
          case SoilType.alluvial: return 'जलोढ़ मिट्टी';
          case SoilType.other: return 'अन्य';
          case SoilType.unknown: return 'अज्ञात';
        }
      default:
        switch (this) {
          case SoilType.sandy: return 'Sandy Soil';
          case SoilType.clay: return 'Clay Soil';
          case SoilType.loamy: return 'Loamy Soil';
          case SoilType.black: return 'Black Soil';
          case SoilType.red: return 'Red Soil';
          case SoilType.redLoamy: return 'Red loamy soil';
          case SoilType.alluvial: return 'Alluvial Soil';
          case SoilType.other: return 'Other';
          case SoilType.unknown: return 'Unknown';
        }
    }
  }

  static SoilType fromKey(String? key) {
    if (key == null) return SoilType.black;
    return SoilType.values.firstWhere(
      (s) => s.key == key.toLowerCase().trim(),
      orElse: () => SoilType.other,
    );
  }
}

/// Supported irrigation types for farm profiling.
enum IrrigationType {
  rainfed('rainfed', 'कोरडवाहू / Rain-fed'),
  borewell('borewell', 'बोअरवेल / Borewell'),
  openwell('openwell', 'विहीर / Open Well'),
  canal('canal', 'कालवा / Canal'),
  drip('drip', 'ठिबक सिंचन / Drip Irrigation'),
  sprinkler('sprinkler', 'तुषार सिंचन / Sprinkler'),
  other('other', 'इतर / Other');

  final String key;
  final String label;
  const IrrigationType(this.key, this.label);

  String localizedLabel(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'mr':
        switch (this) {
          case IrrigationType.rainfed: return 'कोरडवाहू';
          case IrrigationType.borewell: return 'बोअरवेल';
          case IrrigationType.openwell: return 'विहीर';
          case IrrigationType.canal: return 'कालवा';
          case IrrigationType.drip: return 'ठिबक सिंचन';
          case IrrigationType.sprinkler: return 'तुषार सिंचन';
          case IrrigationType.other: return 'इतर';
        }
      case 'hi':
        switch (this) {
          case IrrigationType.rainfed: return 'बारानी (वर्षा आधारित)';
          case IrrigationType.borewell: return 'बोरवेल';
          case IrrigationType.openwell: return 'कुआं';
          case IrrigationType.canal: return 'नहर';
          case IrrigationType.drip: return 'टपक सिंचाई';
          case IrrigationType.sprinkler: return 'फव्वारा सिंचाई';
          case IrrigationType.other: return 'अन्य';
        }
      default:
        switch (this) {
          case IrrigationType.rainfed: return 'Rain-fed';
          case IrrigationType.borewell: return 'Borewell';
          case IrrigationType.openwell: return 'Open Well';
          case IrrigationType.canal: return 'Canal';
          case IrrigationType.drip: return 'Drip Irrigation';
          case IrrigationType.sprinkler: return 'Sprinkler';
          case IrrigationType.other: return 'Other';
        }
    }
  }

  static IrrigationType fromKey(String? key) {
    if (key == null) return IrrigationType.rainfed;
    return IrrigationType.values.firstWhere(
      (i) => i.key == key.toLowerCase().trim(),
      orElse: () => IrrigationType.other,
    );
  }
}

/// Canonical farm area units.
enum FarmAreaUnit {
  acres('Acres', 'एकरा / Acres'),
  hectares('Hectares', 'हेक्टर / Hectares'),
  cents('Cents', 'गुंठा-सेंट / Cents');

  final String key;
  final String label;
  const FarmAreaUnit(this.key, this.label);

  String localizedLabel(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'mr':
        switch (this) {
          case FarmAreaUnit.acres: return 'एकर';
          case FarmAreaUnit.hectares: return 'हेक्टर';
          case FarmAreaUnit.cents: return 'गुंठा';
        }
      case 'hi':
        switch (this) {
          case FarmAreaUnit.acres: return 'एकड़';
          case FarmAreaUnit.hectares: return 'हेक्टेयर';
          case FarmAreaUnit.cents: return 'गुंठा / सेंट';
        }
      default:
        switch (this) {
          case FarmAreaUnit.acres: return 'Acres';
          case FarmAreaUnit.hectares: return 'Hectares';
          case FarmAreaUnit.cents: return 'Cents';
        }
    }
  }

  static FarmAreaUnit fromKey(String? key) {
    if (key == null) return FarmAreaUnit.acres;
    return FarmAreaUnit.values.firstWhere(
      (u) => u.key.toLowerCase() == key.toLowerCase().trim(),
      orElse: () => FarmAreaUnit.acres,
    );
  }
}

/// Farmer & Farm persistent profile model.
/// Isolated per authenticated farmer user ID.
class FarmerProfile {
  final String farmerId;
  final String name;
  final String? mobileNumber;
  final String preferredLanguage; // 'mr', 'hi', 'en'
  final String? farmId;
  final String? farmName;
  final double? latitude;
  final double? longitude;
  final String? region;
  final double? farmArea;
  final String farmAreaUnit; // 'Acres', 'Hectares', 'Cents'
  final String soilType;
  final String irrigationType;
  final List<String> crops;
  final String currentCrop; // 'paddy', 'cotton', 'soybean', 'jowar'
  final String? variety;
  final String growthStage;
  final DateTime? sowingDate;
  final DateTime? updatedAt;

  const FarmerProfile({
    required this.farmerId,
    required this.name,
    this.mobileNumber,
    this.preferredLanguage = 'mr',
    this.farmId,
    this.farmName,
    this.latitude,
    this.longitude,
    this.region,
    this.farmArea,
    this.farmAreaUnit = 'Acres',
    this.soilType = 'black',
    this.irrigationType = 'rainfed',
    this.crops = const ['paddy'],
    this.currentCrop = 'paddy',
    this.variety,
    this.growthStage = 'tillering',
    this.sowingDate,
    this.updatedAt,
  });

  /// Check if all mandatory fields required for active farm advice exist.
  bool get isComplete {
    return name.trim().isNotEmpty &&
        preferredLanguage.isNotEmpty &&
        latitude != null &&
        longitude != null &&
        farmArea != null &&
        farmArea! > 0 &&
        currentCrop.isNotEmpty;
  }

  GeoPoint? get location => (latitude != null && longitude != null)
      ? GeoPoint(lat: latitude!, lng: longitude!)
      : null;

  FarmerProfile copyWith({
    String? farmerId,
    String? name,
    String? mobileNumber,
    String? preferredLanguage,
    String? farmId,
    String? farmName,
    double? latitude,
    double? longitude,
    String? region,
    double? farmArea,
    String? farmAreaUnit,
    String? soilType,
    String? irrigationType,
    List<String>? crops,
    String? currentCrop,
    String? variety,
    String? growthStage,
    DateTime? sowingDate,
    DateTime? updatedAt,
  }) {
    return FarmerProfile(
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      region: region ?? this.region,
      farmArea: farmArea ?? this.farmArea,
      farmAreaUnit: farmAreaUnit ?? this.farmAreaUnit,
      soilType: soilType ?? this.soilType,
      irrigationType: irrigationType ?? this.irrigationType,
      crops: crops ?? this.crops,
      currentCrop: currentCrop ?? this.currentCrop,
      variety: variety ?? this.variety,
      growthStage: growthStage ?? this.growthStage,
      sowingDate: sowingDate ?? this.sowingDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      farmerId: json['farmer_id'] as String,
      name: json['name'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'mr',
      farmId: json['farm_id'] as String?,
      farmName: json['farm_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      region: json['region'] as String?,
      farmArea: (json['farm_area'] as num?)?.toDouble(),
      farmAreaUnit: json['farm_area_unit'] as String? ?? 'Acres',
      soilType: json['soil_type'] as String? ?? 'black',
      irrigationType: json['irrigation_type'] as String? ?? 'rainfed',
      crops: (json['crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['paddy'],
      currentCrop: json['current_crop'] as String? ?? 'paddy',
      variety: json['variety'] as String?,
      growthStage: json['growth_stage'] as String? ?? 'tillering',
      sowingDate: json['sowing_date'] != null
          ? DateTime.tryParse(json['sowing_date'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'farmer_id': farmerId,
        'name': name,
        if (mobileNumber != null) 'mobile_number': mobileNumber,
        'preferred_language': preferredLanguage,
        if (farmId != null) 'farm_id': farmId,
        if (farmName != null) 'farm_name': farmName,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (region != null) 'region': region,
        if (farmArea != null) 'farm_area': farmArea,
        'farm_area_unit': farmAreaUnit,
        'soil_type': soilType,
        'irrigation_type': irrigationType,
        'crops': crops,
        'current_crop': currentCrop,
        if (variety != null) 'variety': variety,
        'growth_stage': growthStage,
        if (sowingDate != null)
          'sowing_date':
              '${sowingDate!.year.toString().padLeft(4, '0')}-${sowingDate!.month.toString().padLeft(2, '0')}-${sowingDate!.day.toString().padLeft(2, '0')}',
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}
