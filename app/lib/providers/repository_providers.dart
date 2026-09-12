import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_mode.dart';
import '../core/demo/demo_repositories.dart';
import '../repositories/auth_repository.dart';
import '../repositories/farm_repository.dart';
import '../repositories/asset_repository.dart';
import '../repositories/voice_repository.dart';
import '../repositories/diagnosis_repository.dart';
import '../repositories/doubt_doctor_repository.dart';
import '../repositories/problem_repository.dart';
import '../repositories/advisory_repository.dart';
import '../repositories/label_check_repository.dart';
import '../repositories/alert_repository.dart';
import '../repositories/followup_repository.dart';
import '../repositories/timeline_repository.dart';
import '../repositories/referral_repository.dart';
import '../repositories/health_repository.dart';
import '../repositories/farmer_profile_repository.dart';
import 'network_providers.dart';
import 'storage_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  if (AppModeConfig.isDemo) {
    return DemoAuthRepository(
      tokenStorage: tokenStorage,
      store: ref.watch(demoStoreProvider),
    );
  }
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
});

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoFarmRepository(store: ref.watch(demoStoreProvider));
  }
  final apiClient = ref.watch(apiClientProvider);
  return FarmRepositoryImpl(apiClient: apiClient);
});

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  if (AppModeConfig.isDemo) return DemoAssetRepository();
  final apiClient = ref.watch(apiClientProvider);
  return AssetRepositoryImpl(apiClient: apiClient);
});

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  if (AppModeConfig.isDemo) return DemoVoiceRepository();
  final apiClient = ref.watch(apiClientProvider);
  return VoiceRepositoryImpl(apiClient: apiClient);
});

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoDiagnosisRepository(store: ref.watch(demoStoreProvider));
  }
  final apiClient = ref.watch(apiClientProvider);
  return DiagnosisRepositoryImpl(apiClient: apiClient);
});

final doubtDoctorRepositoryProvider = Provider<DoubtDoctorRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoDoubtDoctorRepository(store: ref.watch(demoStoreProvider));
  }
  final apiClient = ref.watch(apiClientProvider);
  return DoubtDoctorRepositoryImpl(apiClient: apiClient);
});

final problemRepositoryProvider = Provider<ProblemRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoProblemRepository(store: ref.watch(demoStoreProvider));
  }
  final apiClient = ref.watch(apiClientProvider);
  return ProblemRepositoryImpl(apiClient: apiClient);
});

final advisoryRepositoryProvider = Provider<AdvisoryRepository>((ref) {
  if (AppModeConfig.isDemo) return DemoAdvisoryRepository();
  final apiClient = ref.watch(apiClientProvider);
  return AdvisoryRepositoryImpl(apiClient: apiClient);
});

final labelCheckRepositoryProvider = Provider<LabelCheckRepository>((ref) {
  if (AppModeConfig.isDemo) return DemoLabelCheckRepository();
  final apiClient = ref.watch(apiClientProvider);
  return LabelCheckRepositoryImpl(apiClient: apiClient);
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoAlertRepository(store: ref.watch(demoStoreProvider));
  }
  final apiClient = ref.watch(apiClientProvider);
  return AlertRepositoryImpl(apiClient: apiClient);
});

final followUpRepositoryProvider = Provider<FollowUpRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoFollowUpRepository(store: ref.watch(demoStoreProvider));
  }
  final apiClient = ref.watch(apiClientProvider);
  return FollowUpRepositoryImpl(apiClient: apiClient);
});

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoTimelineRepository(store: ref.watch(demoStoreProvider));
  }
  final apiClient = ref.watch(apiClientProvider);
  return TimelineRepositoryImpl(apiClient: apiClient);
});

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  if (AppModeConfig.isDemo) return DemoReferralRepository();
  final apiClient = ref.watch(apiClientProvider);
  return ReferralRepositoryImpl(apiClient: apiClient);
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  if (AppModeConfig.isDemo) return DemoHealthRepository();
  final apiClient = ref.watch(apiClientProvider);
  return HealthRepositoryImpl(apiClient: apiClient);
});

final farmerProfileRepositoryProvider = Provider<FarmerProfileRepository>((ref) {
  if (AppModeConfig.isDemo) {
    return DemoFarmerProfileRepository(store: ref.watch(demoStoreProvider));
  }
  final tokenStorage = ref.watch(tokenStorageProvider);
  final farmRepository = ref.watch(farmRepositoryProvider);
  return FarmerProfileRepositoryImpl(
    tokenStorage: tokenStorage,
    farmRepository: farmRepository,
  );
});
