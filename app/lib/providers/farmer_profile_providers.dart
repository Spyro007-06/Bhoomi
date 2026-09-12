import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farmer_profile_models.dart';
import 'farm_providers.dart';
import 'repository_providers.dart';

class FarmerProfileState {
  final FarmerProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  const FarmerProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isComplete => profile != null && profile!.isComplete;
  bool get hasProfile => profile != null;

  FarmerProfileState copyWith({
    FarmerProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FarmerProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FarmerProfileNotifier extends StateNotifier<FarmerProfileState> {
  final Ref _ref;

  FarmerProfileNotifier(this._ref) : super(const FarmerProfileState());

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(farmerProfileRepositoryProvider);
      final profile = await repo.getProfile(userId);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        errorMessage: null,
      );

      // If profile has an active farmId, synchronize with activeFarmIdProvider
      if (profile?.farmId != null && profile!.farmId!.isNotEmpty) {
        await _ref
            .read(activeFarmIdProvider.notifier)
            .setActiveFarmId(profile.farmId!);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<FarmerProfile> saveProfile(FarmerProfile profile) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(farmerProfileRepositoryProvider);
      final saved = await repo.saveProfile(profile);

      state = state.copyWith(
        profile: saved,
        isLoading: false,
        errorMessage: null,
      );

      // Synchronize active farmId in memory & storage
      if (saved.farmId != null && saved.farmId!.isNotEmpty) {
        await _ref
            .read(activeFarmIdProvider.notifier)
            .setActiveFarmId(saved.farmId!);
      }

      return saved;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void clearProfile() {
    state = const FarmerProfileState();
  }
}

final farmerProfileProvider =
    StateNotifierProvider<FarmerProfileNotifier, FarmerProfileState>((ref) {
  return FarmerProfileNotifier(ref);
});

final isProfileCompleteProvider = Provider<bool>((ref) {
  return ref.watch(farmerProfileProvider).isComplete;
});
