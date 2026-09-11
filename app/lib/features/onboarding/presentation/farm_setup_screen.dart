import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/crop_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/utils/location_service.dart';
import '../../../providers/farm_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/language_selector_button.dart';

/// Farm Setup Screen with dynamic GPS Location integration.
class FarmSetupScreen extends ConsumerStatefulWidget {
  final LocationService? locationService;

  const FarmSetupScreen({
    super.key,
    this.locationService,
  });

  @override
  ConsumerState<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends ConsumerState<FarmSetupScreen> {
  CropType _selectedCrop = CropType.paddy;
  final TextEditingController _varietyController = TextEditingController(text: 'Indrayani');
  final TextEditingController _regionController = TextEditingController(text: 'Nashik');
  String _selectedGrowthStage = 'tillering';
  bool _isLoading = false;
  String? _errorMessage;

  late final LocationService _locationService;
  bool _isDetectingLocation = false;
  LocationResult? _locationResult;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? LocationService();
    _detectLocation();
  }

  @override
  void dispose() {
    _varietyController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isDetectingLocation = true;
      _errorMessage = null;
    });

    final result = await _locationService.getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _isDetectingLocation = false;
      _locationResult = result;
      if (!result.isSuccess && result.errorMessage != null) {
        _errorMessage = result.errorMessage;
      }
    });
  }

  void _onCropChanged(CropType newCrop) {
    final strings = ref.read(stringsProvider);
    final stages = newCrop.getGrowthStages(strings);
    setState(() {
      _selectedCrop = newCrop;
      _selectedGrowthStage = stages.isNotEmpty ? stages.first.key : 'vegetative';
      // Suggest common variety if default is still active
      if (_varietyController.text == 'Indrayani' ||
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
        }
      }
    });
  }

  Future<void> _handleSaveFarm() async {
    final region = _regionController.text.trim();
    if (region.isEmpty) {
      setState(() => _errorMessage = 'Please enter your region / district');
      return;
    }

    final location = _locationResult?.location;
    if (location == null) {
      final strings = ref.read(stringsProvider);
      setState(() => _errorMessage = strings.locationPermissionRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final farmRepo = ref.read(farmRepositoryProvider);
      final farm = await farmRepo.createFarm(
        crop: _selectedCrop.key,
        variety: _varietyController.text.trim().isNotEmpty
            ? _varietyController.text.trim()
            : 'Indrayani',
        growthStage: _selectedGrowthStage,
        region: region,
        location: location,
      );

      // Set active farm ID in token storage and provider
      await ref.read(activeFarmIdProvider.notifier).setActiveFarmId(farm.id);

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      final strings = ref.read(stringsProvider);
      setState(() {
        _isLoading = false;
        _errorMessage = strings.genericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final hasLocation = _locationResult?.isSuccess ?? false;
    final growthStages = _selectedCrop.getGrowthStages(strings);

    return Scaffold(
      backgroundColor: AppColors.ricePaper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          strings.farmSetupTitle,
          style: AppTypography.subheading.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crop Selection Dropdown Card (Strictly CLAUDE.md crops)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.cropLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.soilCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l16),
                      decoration: BoxDecoration(
                        color: AppColors.warmSurface,
                        borderRadius: AppRadius.input,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CropType>(
                          value: _selectedCrop,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.forest),
                          items: CropType.values.map((crop) {
                            return DropdownMenuItem<CropType>(
                              value: crop,
                              child: Row(
                                children: [
                                  const Icon(Icons.grass_rounded, color: AppColors.forest, size: 20),
                                  const SizedBox(width: AppSpacing.s10),
                                  Text(
                                    crop.getLocalizedName(strings),
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m16),

              // Variety Input
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.varietyLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.soilCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AppTextField(
                      controller: _varietyController,
                      hintText: strings.varietyHint,
                      prefixIcon: const Icon(Icons.eco_outlined, color: AppColors.fieldSlate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m16),

              // Growth Stage Dropdown Card (Dynamic to Selected Crop)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.growthStageLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.soilCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l16),
                      decoration: BoxDecoration(
                        color: AppColors.warmSurface,
                        borderRadius: AppRadius.input,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: growthStages.any((s) => s.key == _selectedGrowthStage)
                              ? _selectedGrowthStage
                              : (growthStages.isNotEmpty ? growthStages.first.key : null),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.forest),
                          items: growthStages.map((stage) {
                            return DropdownMenuItem<String>(
                              value: stage.key,
                              child: Text(stage.name, style: AppTypography.body),
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m16),

              // Region Input
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.regionLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.soilCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AppTextField(
                      controller: _regionController,
                      hintText: strings.regionHint,
                      prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.fieldSlate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m16),

              // Location Status Card (Real Device Geolocation)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l16),
                backgroundColor: hasLocation
                    ? AppColors.warmSurface
                    : AppColors.turmeric.withValues(alpha: 0.08),
                border: Border.all(
                  color: hasLocation ? AppColors.border : AppColors.turmeric,
                  width: hasLocation ? 1.0 : 1.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          strings.locationLabel,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.soilCharcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_isDetectingLocation)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.forest,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    if (_isDetectingLocation)
                      Text(
                        strings.locationDetecting,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.fieldSlate,
                        ),
                      )
                    else if (hasLocation)
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              '${strings.locationSet}: Lat ${_locationResult!.location!.lat.toStringAsFixed(4)}, Lng ${_locationResult!.location!.lng.toStringAsFixed(4)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.forest,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.turmeric, size: 20),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              _locationResult?.isDeniedForever == true
                                  ? strings.locationDeniedForever
                                  : (_locationResult?.isDisabled == true
                                      ? strings.locationServicesDisabled
                                      : (_locationResult?.isTimeout == true
                                          ? strings.locationTimeoutError
                                          : strings.locationPermissionRequired)),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.soilCharcoal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s6,
                        children: [
                          TextButton.icon(
                            onPressed: _detectLocation,
                            icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.forest),
                            label: Text(
                              strings.retryLocation,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.forest,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (_locationResult?.isDeniedForever == true)
                            TextButton.icon(
                              onPressed: () => _locationService.openAppSettings(),
                              icon: const Icon(Icons.settings_outlined, size: 18, color: AppColors.forest),
                              label: Text(
                                strings.openSettingsButton,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else if (_locationResult?.isDisabled == true)
                            TextButton.icon(
                              onPressed: () => _locationService.openLocationSettings(),
                              icon: const Icon(Icons.settings_outlined, size: 18, color: AppColors.forest),
                              label: Text(
                                strings.openSettingsButton,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl28),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.m16),
              ],

              // Save Button
              AppButton.primary(
                label: strings.saveFarmButton,
                size: AppButtonSize.large,
                isLoading: _isLoading,
                onPressed: _isLoading || !hasLocation ? null : _handleSaveFarm,
                leadingIcon: const Icon(Icons.check_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
