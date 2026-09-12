import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/crop_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/utils/location_service.dart';
import '../../../models/farm_models.dart';
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
  final TextEditingController _regionController = TextEditingController(text: 'Nashik, Maharashtra');
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  String _selectedGrowthStage = 'tillering';
  bool _isLoading = false;
  bool _isManualLocation = false;
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
    _latController.dispose();
    _lngController.dispose();
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
      if (result.isSuccess && result.location != null) {
        _latController.text = result.location!.lat.toStringAsFixed(4);
        _lngController.text = result.location!.lng.toStringAsFixed(4);
      } else if (!result.isSuccess && result.errorMessage != null) {
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

  Future<void> _handleSaveFarm() async {
    final strings = ref.read(stringsProvider);
    final region = _regionController.text.trim();
    if (region.isEmpty) {
      setState(() => _errorMessage = strings.farmRegionError);
      return;
    }

    GeoPoint? location;
    if (_isManualLocation) {
      final latText = _latController.text.trim();
      final lngText = _lngController.text.trim();
      if (latText.isNotEmpty && lngText.isNotEmpty) {
        final latVal = double.tryParse(latText);
        final lngVal = double.tryParse(lngText);
        if (latVal != null && lngVal != null) {
          location = GeoPoint(lat: latVal, lng: lngVal);
        }
      }
      location ??= LocationService.estimateCoordinatesForRegion(region);
    } else {
      location = _locationResult?.location;
    }

    if (location == null) {
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

              // Location & Region Card (GPS Auto-detect or Manual Entry)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l16),
                backgroundColor: AppColors.warmSurface,
                border: Border.all(
                  color: (hasLocation || _isManualLocation)
                      ? AppColors.border
                      : AppColors.turmeric,
                  width: 1.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Selector (GPS vs Manual)
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
                                  _errorMessage = null;
                                });
                                if (_locationResult?.location == null) {
                                  _detectLocation();
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
                                  _errorMessage = null;
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

                    if (!_isManualLocation) ...[
                      // GPS Auto-detect Mode
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
                      else if (_locationResult?.isSuccess == true && _locationResult?.location != null)
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
                      const SizedBox(height: AppSpacing.s8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isManualLocation = true;
                              _errorMessage = null;
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
                      // Manual Location Mode
                      Text(
                        strings.manualLocationSubtitle,
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.fieldSlate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Text(
                        strings.farmRegionLabel,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.soilCharcoal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      AppTextField(
                        controller: _regionController,
                        hintText: strings.farmRegionHint,
                        prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.fieldSlate),
                        onChanged: (val) {
                          if (_latController.text.trim().isEmpty) {
                            final est = LocationService.estimateCoordinatesForRegion(val);
                            _latController.text = est.lat.toStringAsFixed(4);
                            _lngController.text = est.lng.toStringAsFixed(4);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      // Suggestion Chips
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
                                _latController.text = est.lat.toStringAsFixed(4);
                                _lngController.text = est.lng.toStringAsFixed(4);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.m12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.latitudeOptionalLabel,
                                  style: AppTypography.captionSmall.copyWith(
                                    color: AppColors.soilCharcoal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s6),
                                AppTextField(
                                  controller: _latController,
                                  hintText: '19.9975',
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  prefixIcon: const Icon(Icons.explore_outlined, color: AppColors.fieldSlate, size: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.longitudeOptionalLabel,
                                  style: AppTypography.captionSmall.copyWith(
                                    color: AppColors.soilCharcoal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s6),
                                AppTextField(
                                  controller: _lngController,
                                  hintText: '73.7898',
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  prefixIcon: const Icon(Icons.explore_outlined, color: AppColors.fieldSlate, size: 18),
                                ),
                              ],
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
                onPressed: _isLoading || (!hasLocation && !_isManualLocation)
                    ? null
                    : _handleSaveFarm,
                leadingIcon: const Icon(Icons.check_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
