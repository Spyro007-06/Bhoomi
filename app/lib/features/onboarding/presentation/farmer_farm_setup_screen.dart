import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/crop_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/location_service.dart';
import '../../../models/farmer_profile_models.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/farmer_profile_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/language_selector_button.dart';

/// Dedicated, production-ready Farmer Information & Farm Details setup screen.
/// Functions both as mandatory first-time onboarding and editable profile screen.
class FarmerFarmSetupScreen extends ConsumerStatefulWidget {
  final bool isFirstTimeOnboarding;
  final LocationService? locationService;

  const FarmerFarmSetupScreen({
    super.key,
    this.isFirstTimeOnboarding = false,
    this.locationService,
  });

  @override
  ConsumerState<FarmerFarmSetupScreen> createState() =>
      _FarmerFarmSetupScreenState();
}

class _FarmerFarmSetupScreenState
    extends ConsumerState<FarmerFarmSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _farmNameController;
  late final TextEditingController _areaController;
  late final TextEditingController _regionController;
  late final TextEditingController _varietyController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  // Selected state
  CropType _selectedCrop = CropType.paddy;
  String _selectedGrowthStage = 'tillering';
  SoilType _selectedSoil = SoilType.black;
  IrrigationType _selectedIrrigation = IrrigationType.rainfed;
  FarmAreaUnit _selectedAreaUnit = FarmAreaUnit.acres;
  DateTime? _sowingDate;

  // Location detection
  late final LocationService _locationService;
  bool _isDetectingLocation = false;
  bool _isManualLocation = false;
  LocationResult? _locationResult;
  double? _latitude;
  double? _longitude;

  // Form submission
  bool _isLoading = false;
  String? _errorMessage;
  String? _nameError;
  String? _areaError;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? LocationService();

    final currentProfile = ref.read(farmerProfileProvider).profile;
    final currentUser = ref.read(currentUserProvider);

    _nameController = TextEditingController(
      text: currentProfile?.name.isNotEmpty == true
          ? currentProfile!.name
          : (currentUser?.name ?? ''),
    );
    _farmNameController = TextEditingController(
      text: currentProfile?.farmName ?? '',
    );
    _areaController = TextEditingController(
      text: currentProfile?.farmArea != null
          ? currentProfile!.farmArea.toString()
          : '2.5',
    );
    _regionController = TextEditingController(
      text: currentProfile?.region ?? 'Nashik, Maharashtra',
    );
    _varietyController = TextEditingController(
      text: currentProfile?.variety ?? 'Indrayani',
    );

    if (currentProfile != null) {
      _selectedCrop = CropType.fromKey(currentProfile.currentCrop);
      _selectedGrowthStage = currentProfile.growthStage;
      _selectedSoil = SoilType.fromKey(currentProfile.soilType);
      _selectedIrrigation =
          IrrigationType.fromKey(currentProfile.irrigationType);
      _selectedAreaUnit = FarmAreaUnit.fromKey(currentProfile.farmAreaUnit);
      _sowingDate = currentProfile.sowingDate;
      _latitude = currentProfile.latitude;
      _longitude = currentProfile.longitude;
      if (_latitude != null && _longitude != null) {
        _locationResult = LocationResult(
          location: currentProfile.location,
          status: LocationServiceStatus.acquired,
        );
      }
    } else {
      _sowingDate = DateTime.now().subtract(const Duration(days: 30));
    }

    _latController = TextEditingController(
      text: _latitude != null ? _latitude!.toStringAsFixed(5) : '',
    );
    _lngController = TextEditingController(
      text: _longitude != null ? _longitude!.toStringAsFixed(5) : '',
    );

    if (_latitude == null || _longitude == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleAcquireLocation();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmNameController.dispose();
    _areaController.dispose();
    _regionController.dispose();
    _varietyController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleAcquireLocation() async {
    setState(() {
      _isDetectingLocation = true;
      _locationError = null;
      _errorMessage = null;
    });

    final result = await _locationService.getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _isDetectingLocation = false;
      _locationResult = result;
      if (result.isSuccess && result.location != null) {
        _latitude = result.location!.lat;
        _longitude = result.location!.lng;
        _latController.text = _latitude!.toStringAsFixed(5);
        _lngController.text = _longitude!.toStringAsFixed(5);
        _locationError = null;
        if (_regionController.text.trim().isEmpty) {
          _regionController.text = 'Maharashtra, India';
        }
      } else {
        _locationError = result.errorMessage ?? 'Unable to acquire location';
      }
    });
  }

  void _onCropChanged(CropType newCrop) {
    final strings = ref.read(stringsProvider);
    final stages = newCrop.getGrowthStages(strings);
    setState(() {
      _selectedCrop = newCrop;
      _selectedGrowthStage =
          stages.isNotEmpty ? stages.first.key : 'vegetative';
      if (_varietyController.text.isEmpty ||
          _varietyController.text == 'Indrayani' ||
          _varietyController.text == 'BT Cotton' ||
          _varietyController.text == 'JS-335' ||
          _varietyController.text == 'CSH-16') {
        switch (newCrop) {
          case CropType.paddy:
            _varietyController.text = 'Indrayani';
            break;
          case CropType.cotton:
            _varietyController.text = 'BT Cotton';
            break;
          case CropType.soybean:
            _varietyController.text = 'JS-335';
            break;
          case CropType.jowar:
            _varietyController.text = 'CSH-16';
            break;
          case CropType.tomato:
            _varietyController.text = 'Arka Rakshak';
            break;
          case CropType.banana:
            _varietyController.text = 'Grand Naine';
            break;
          case CropType.chilli:
            _varietyController.text = 'Guntur Sannam';
            break;
          case CropType.groundnut:
            _varietyController.text = 'TAG 24';
            break;
        }
      }
    });
  }

  Future<void> _selectSowingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sowingDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forest,
              onPrimary: Colors.white,
              onSurface: AppColors.soilCharcoal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _sowingDate = picked);
    }
  }

  bool _validateInputs(AppStrings strings) {
    bool isValid = true;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = strings.farmerFullNameError);
      isValid = false;
    } else {
      setState(() => _nameError = null);
    }

    final areaText = _areaController.text.trim();
    final areaVal = double.tryParse(areaText);
    if (areaVal == null || areaVal <= 0) {
      setState(() => _areaError = strings.farmAreaError);
      isValid = false;
    } else {
      setState(() => _areaError = null);
    }

    if (_isManualLocation) {
      final region = _regionController.text.trim();
      if (region.isEmpty) {
        setState(() => _locationError = strings.farmRegionError);
        isValid = false;
      } else {
        final latText = _latController.text.trim();
        final lngText = _lngController.text.trim();
        if (latText.isNotEmpty && lngText.isNotEmpty) {
          final latVal = double.tryParse(latText);
          final lngVal = double.tryParse(lngText);
          if (latVal == null || latVal < -90 || latVal > 90 ||
              lngVal == null || lngVal < -180 || lngVal > 180) {
            setState(() => _locationError = 'Please enter valid coordinates (-90 to 90, -180 to 180)');
            isValid = false;
          } else {
            _latitude = latVal;
            _longitude = lngVal;
            setState(() => _locationError = null);
          }
        } else {
          // Automatic coordinate estimation from entered region
          final est = LocationService.estimateCoordinatesForRegion(region);
          _latitude = est.lat;
          _longitude = est.lng;
          setState(() => _locationError = null);
        }
      }
    } else {
      if (_latitude == null || _longitude == null) {
        setState(() => _locationError = strings.locationPermissionRequired);
        isValid = false;
      } else {
        setState(() => _locationError = null);
      }
    }

    return isValid;
  }

  Future<void> _handleSave() async {
    final strings = ref.read(stringsProvider);
    if (!_validateInputs(strings)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      final farmerId = user?.id ?? 'u_farmer_default';
      final existingProfile = ref.read(farmerProfileProvider).profile;

      final updatedProfile = FarmerProfile(
        farmerId: farmerId,
        name: _nameController.text.trim(),
        mobileNumber: user?.phone ?? existingProfile?.mobileNumber,
        preferredLanguage: ref.read(appLanguageProvider).code,
        farmId: existingProfile?.farmId,
        farmName: _farmNameController.text.trim().isNotEmpty
            ? _farmNameController.text.trim()
            : null,
        latitude: _latitude,
        longitude: _longitude,
        region: _regionController.text.trim().isNotEmpty
            ? _regionController.text.trim()
            : 'Maharashtra, India',
        farmArea: double.tryParse(_areaController.text.trim()) ?? 2.5,
        farmAreaUnit: _selectedAreaUnit.key,
        soilType: _selectedSoil.key,
        irrigationType: _selectedIrrigation.key,
        crops: [_selectedCrop.key],
        currentCrop: _selectedCrop.key,
        variety: _varietyController.text.trim().isNotEmpty
            ? _varietyController.text.trim()
            : null,
        growthStage: _selectedGrowthStage,
        sowingDate: _sowingDate,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(farmerProfileProvider.notifier)
          .saveProfile(updatedProfile);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.profileSaveSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.isFirstTimeOnboarding) {
        // First-time onboarding complete -> pop directly to root (MainAppShell)
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        // Edit mode -> pop back to caller (e.g. More screen)
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      final strings = ref.read(stringsProvider);
      setState(() {
        _isLoading = false;
        _errorMessage = strings.profileSaveNetworkError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final currentUser = ref.watch(currentUserProvider);
    final growthStages = _selectedCrop.getGrowthStages(strings);
    final hasLocation = _latitude != null && _longitude != null;

    return Scaffold(
      backgroundColor: AppColors.ricePaper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isFirstTimeOnboarding
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.primaryDark),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: widget.isFirstTimeOnboarding
            ? null
            : Text(
                strings.editFarmProfile,
                style: AppTypography.subheading.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l20,
            vertical: AppSpacing.m16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l16),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: AppColors.forest.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: const BoxDecoration(
                          color: AppColors.forest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.farmerFarmSetupHeaderTitle,
                              style: AppTypography.sectionTitle.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.farmerFarmSetupHeaderSubtitle,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.fieldSlate,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l20),

                // =============================================================
                // SECTION 1 — FARMER INFORMATION
                // =============================================================
                _buildSectionHeader(
                  icon: Icons.person_rounded,
                  title: strings.farmerInfoSectionTitle,
                ),
                const SizedBox(height: AppSpacing.m12),

                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.l16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _buildFieldLabel(
                        label: strings.farmerFullNameLabel,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextField(
                        controller: _nameController,
                        hintText: strings.farmerFullNameHint,
                        prefixIcon: const Icon(Icons.badge_rounded,
                            color: AppColors.fieldSlate),
                        errorText: _nameError,
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Mobile Number (Read-only / Auto-populated)
                      _buildFieldLabel(
                        label: strings.farmerMobileLabel,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l16,
                          vertical: AppSpacing.m12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.35),
                          borderRadius: AppRadius.input,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_locked_rounded,
                                color: AppColors.forest, size: 20),
                            const SizedBox(width: AppSpacing.m12),
                            Expanded(
                              child: Text(
                                currentUser?.phone ??
                                    (ref.read(farmerProfileProvider).profile?.mobileNumber ??
                                        '+91 98765 43210'),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.soilCharcoal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.forest.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentLang.isMarathi
                                    ? 'सत्यापित'
                                    : (currentLang.isHindi ? 'सत्यापित' : 'Verified'),
                                style: AppTypography.captionSmall.copyWith(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Preferred Language Selection
                      _buildFieldLabel(
                        label: strings.preferredLanguageLabel,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Row(
                        children: AppLanguage.values.map((lang) {
                          final isSelected = lang == currentLang;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    lang.label,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.soilCharcoal,
                                    ),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.forest,
                                backgroundColor: AppColors.warmSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.forest
                                        : AppColors.border,
                                  ),
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    ref
                                        .read(appLanguageProvider.notifier)
                                        .setLanguage(lang);
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l24),

                // =============================================================
                // SECTION 2 — FARM DETAILS
                // =============================================================
                _buildSectionHeader(
                  icon: Icons.landscape_rounded,
                  title: strings.farmDetailsSectionTitle,
                ),
                const SizedBox(height: AppSpacing.m12),

                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.l16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farm Name (Optional)
                      _buildFieldLabel(
                        label: strings.farmNameOptionalLabel,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextField(
                        controller: _farmNameController,
                        hintText: strings.farmNamePlaceholder,
                        prefixIcon: const Icon(Icons.home_work_rounded,
                            color: AppColors.fieldSlate),
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Location Action & Display Card
                      _buildFieldLabel(
                        label: strings.farmLocationCardHeader,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      _buildLocationSection(strings, hasLocation),
                      if (_locationError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _locationError!,
                          style: AppTypography.captionSmall
                              .copyWith(color: AppColors.danger),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.m16),

                      // Total Farm Area & Unit Selector
                      _buildFieldLabel(
                        label: strings.farmAreaLabel,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              controller: _areaController,
                              hintText: strings.farmAreaHint,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              prefixIcon: const Icon(Icons.straighten_rounded,
                                  color: AppColors.fieldSlate),
                              errorText: _areaError,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s10),
                              decoration: BoxDecoration(
                                color: AppColors.warmSurface,
                                borderRadius: AppRadius.input,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<FarmAreaUnit>(
                                  value: _selectedAreaUnit,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: AppColors.forest),
                                  items: FarmAreaUnit.values.map((unit) {
                                    return DropdownMenuItem<FarmAreaUnit>(
                                      value: unit,
                                      child: Text(
                                        unit.localizedLabel(currentLang.code),
                                        style: AppTypography.bodySmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedAreaUnit = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Soil Type
                      _buildFieldLabel(
                        label: strings.soilTypeSectionLabel,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l16),
                        decoration: BoxDecoration(
                          color: AppColors.warmSurface,
                          borderRadius: AppRadius.input,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SoilType>(
                            value: _selectedSoil,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: AppColors.forest),
                            items: SoilType.values.map((soil) {
                              return DropdownMenuItem<SoilType>(
                                value: soil,
                                child: Text(
                                  soil.localizedLabel(currentLang.code),
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSoil = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Irrigation Type
                      _buildFieldLabel(
                        label: strings.irrigationTypeSectionLabel,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l16),
                        decoration: BoxDecoration(
                          color: AppColors.warmSurface,
                          borderRadius: AppRadius.input,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<IrrigationType>(
                            value: _selectedIrrigation,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: AppColors.forest),
                            items: IrrigationType.values.map((irrig) {
                              return DropdownMenuItem<IrrigationType>(
                                value: irrig,
                                child: Text(
                                  irrig.localizedLabel(currentLang.code),
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedIrrigation = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Main / Current Crop Dropdown
                      _buildFieldLabel(
                        label: strings.currentCropLabel,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l16),
                        decoration: BoxDecoration(
                          color: AppColors.warmSurface,
                          borderRadius: AppRadius.input,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CropType>(
                            value: _selectedCrop,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: AppColors.forest),
                            items: CropType.values.map((crop) {
                              return DropdownMenuItem<CropType>(
                                value: crop,
                                child: Row(
                                  children: [
                                    const Icon(Icons.grass_rounded,
                                        color: AppColors.forest, size: 20),
                                    const SizedBox(width: AppSpacing.s10),
                                    Text(
                                      crop.getLocalizedName(strings),
                                      style: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _onCropChanged(val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Variety
                      _buildFieldLabel(
                        label: strings.varietyLabel,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextField(
                        controller: _varietyController,
                        hintText: strings.varietyHint,
                        prefixIcon: const Icon(Icons.eco_outlined,
                            color: AppColors.fieldSlate),
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Growth Stage Dropdown (Dynamic)
                      _buildFieldLabel(
                        label: strings.growthStageLabel,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l16),
                        decoration: BoxDecoration(
                          color: AppColors.warmSurface,
                          borderRadius: AppRadius.input,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: growthStages
                                    .any((s) => s.key == _selectedGrowthStage)
                                ? _selectedGrowthStage
                                : (growthStages.isNotEmpty
                                    ? growthStages.first.key
                                    : null),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: AppColors.forest),
                            items: growthStages.map((stage) {
                              return DropdownMenuItem<String>(
                                value: stage.key,
                                child: Text(stage.name,
                                    style: AppTypography.body),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedGrowthStage = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m16),

                      // Sowing Date Picker
                      _buildFieldLabel(
                        label: strings.sowingDateLabel,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      InkWell(
                        onTap: _selectSowingDate,
                        borderRadius: AppRadius.input,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l16,
                            vertical: AppSpacing.m12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warmSurface,
                            borderRadius: AppRadius.input,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: AppColors.forest, size: 20),
                              const SizedBox(width: AppSpacing.m12),
                              Expanded(
                                child: Text(
                                  _sowingDate != null
                                      ? '${_sowingDate!.day.toString().padLeft(2, '0')}/${_sowingDate!.month.toString().padLeft(2, '0')}/${_sowingDate!.year}'
                                      : strings.selectSowingDateAction,
                                  style: AppTypography.body.copyWith(
                                    fontWeight: _sowingDate != null
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: _sowingDate != null
                                        ? AppColors.soilCharcoal
                                        : AppColors.fieldSlate,
                                  ),
                                ),
                              ),
                              const Icon(Icons.edit_calendar_rounded,
                                  color: AppColors.fieldSlate, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l24),

                // Error Message Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.m12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.danger, size: 22),
                        const SizedBox(width: AppSpacing.s10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m16),
                ],

                // Action Button: Save & Continue / Save Changes
                AppButton.primary(
                  label: widget.isFirstTimeOnboarding
                      ? strings.saveAndContinueAction
                      : strings.saveChangesAction,
                  size: AppButtonSize.large,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSave,
                  leadingIcon: const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  trailingIcon: widget.isFirstTimeOnboarding
                      ? const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.forest, size: 22),
        const SizedBox(width: AppSpacing.s8),
        Text(
          title,
          style: AppTypography.sectionTitle.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel({
    required String label,
    required bool isRequired,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.soilCharcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection(AppStrings strings, bool hasLocation) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmSurface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: hasLocation || _isManualLocation
              ? AppColors.border
              : AppColors.turmeric,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.l16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segmented Mode Selector (GPS vs Manual)
          Container(
            decoration: BoxDecoration(
              color: AppColors.ricePaper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () {
                      setState(() {
                        _isManualLocation = false;
                        _locationError = null;
                      });
                      if (_latitude == null || _longitude == null) {
                        _handleAcquireLocation();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isManualLocation
                            ? AppColors.forest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 16,
                            color: !_isManualLocation
                                ? Colors.white
                                : AppColors.soilCharcoal,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              strings.useGpsLocation,
                              style: AppTypography.captionSmall.copyWith(
                                color: !_isManualLocation
                                    ? Colors.white
                                    : AppColors.soilCharcoal,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () {
                      setState(() {
                        _isManualLocation = true;
                        _locationError = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isManualLocation
                            ? AppColors.forest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_location_alt_rounded,
                            size: 16,
                            color: _isManualLocation
                                ? Colors.white
                                : AppColors.soilCharcoal,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              strings.enterLocationManually,
                              style: AppTypography.captionSmall.copyWith(
                                color: _isManualLocation
                                    ? Colors.white
                                    : AppColors.soilCharcoal,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m16),

          // Content based on selected mode
          if (!_isManualLocation) ...[
            // GPS Location Mode
            Row(
              children: [
                Icon(
                  hasLocation
                      ? Icons.location_on_rounded
                      : Icons.location_searching_rounded,
                  color: hasLocation ? AppColors.forest : AppColors.turmeric,
                  size: 26,
                ),
                const SizedBox(width: AppSpacing.m12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation
                            ? strings.gpsAcquiredLabel
                            : strings.locationLabel,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        _regionController.text.isNotEmpty
                            ? _regionController.text
                            : 'Maharashtra, India',
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.fieldSlate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isDetectingLocation)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.forest,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m12),
            if (hasLocation) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m12,
                  vertical: AppSpacing.s8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Lat: ${_latitude!.toStringAsFixed(5)}',
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Lon: ${_longitude!.toStringAsFixed(5)}',
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s10),
            ],
            if (_locationError != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
            ],
            AppButton.secondary(
              label: (hasLocation || _locationResult?.isFailure == true)
                  ? strings.retryLocation
                  : strings.useCurrentLocationAction,
              size: AppButtonSize.small,
              isLoading: _isDetectingLocation,
              onPressed: _isDetectingLocation ? null : _handleAcquireLocation,
              leadingIcon: Icon(
                (hasLocation || _locationResult?.isFailure == true)
                    ? Icons.refresh_rounded
                    : Icons.my_location_rounded,
                size: 18,
              ),
            ),
            if (_locationResult?.isDeniedForever == true) ...[
              const SizedBox(height: AppSpacing.s8),
              TextButton.icon(
                onPressed: () => _locationService.openAppSettings(),
                icon: const Icon(Icons.settings_outlined,
                    size: 18, color: AppColors.forest),
                label: Text(
                  strings.openSettingsButton,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else if (_locationResult?.isDisabled == true) ...[
              const SizedBox(height: AppSpacing.s8),
              TextButton.icon(
                onPressed: () => _locationService.openLocationSettings(),
                icon: const Icon(Icons.settings_outlined,
                    size: 18, color: AppColors.forest),
                label: Text(
                  strings.openSettingsButton,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s8),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isManualLocation = true;
                    _locationError = null;
                  });
                },
                child: Text(
                  strings.enterLocationManually,
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Manual Location Entry Mode
            Text(
              strings.manualLocationSubtitle,
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.fieldSlate,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s10),
            _buildFieldLabel(
              label: strings.farmRegionLabel,
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.s6),
            AppTextField(
              controller: _regionController,
              hintText: strings.farmRegionHint,
              prefixIcon: const Icon(
                Icons.location_city_rounded,
                color: AppColors.fieldSlate,
              ),
              onChanged: (val) {
                if (_latController.text.trim().isEmpty) {
                  final est = LocationService.estimateCoordinatesForRegion(val);
                  setState(() {
                    _latitude = est.lat;
                    _longitude = est.lng;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.s8),
            // Quick Region Suggestion Chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                'Nashik, Maharashtra',
                'Pune, Maharashtra',
                'Coimbatore, Tamil Nadu',
                'Dharwad, Karnataka',
              ].map((chip) {
                return ActionChip(
                  label: Text(
                    chip,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.ricePaper,
                  side: BorderSide(
                    color: AppColors.forest.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () {
                    setState(() {
                      _regionController.text = chip;
                      final est = LocationService.estimateCoordinatesForRegion(chip);
                      _latitude = est.lat;
                      _longitude = est.lng;
                      _latController.text = est.lat.toStringAsFixed(4);
                      _lngController.text = est.lng.toStringAsFixed(4);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.m12),
            // Coordinates Input Row (Optional)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(
                        label: strings.latitudeOptionalLabel,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      AppTextField(
                        controller: _latController,
                        hintText: '19.9975',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        prefixIcon: const Icon(
                          Icons.explore_outlined,
                          color: AppColors.fieldSlate,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(
                        label: strings.longitudeOptionalLabel,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      AppTextField(
                        controller: _lngController,
                        hintText: '73.7898',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        prefixIcon: const Icon(
                          Icons.explore_outlined,
                          color: AppColors.fieldSlate,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

