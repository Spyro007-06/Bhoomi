import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/app_spacing.dart';
import 'core/localization/app_strings.dart';
import 'core/localization/locale_provider.dart';
import 'core/constants/audit_demo_fixtures.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/token_storage.dart';
import 'core/utils/audio_playback_service.dart';
import 'core/utils/camera_service.dart';
import 'models/asset_models.dart';
import 'models/auth_models.dart';
import 'models/farm_models.dart';
import 'models/farmer_profile_models.dart';
import 'models/alert_models.dart';
import 'models/followup_models.dart';
import 'models/timeline_models.dart';
import 'models/referral_models.dart';
import 'models/diagnosis_models.dart';
import 'models/problem_models.dart';
import 'providers/storage_providers.dart';
import 'providers/repository_providers.dart';
import 'repositories/auth_repository.dart';
import 'repositories/farm_repository.dart';
import 'repositories/farmer_profile_repository.dart';
import 'repositories/alert_repository.dart';
import 'repositories/timeline_repository.dart';
import 'repositories/referral_repository.dart';
import 'repositories/followup_repository.dart';
import 'repositories/diagnosis_repository.dart';
import 'repositories/doubt_doctor_repository.dart';
import 'repositories/problem_repository.dart';
import 'repositories/asset_repository.dart';

import 'features/splash/presentation/splash_screen.dart';
import 'features/landing/presentation/landing_screen.dart';
import 'features/onboarding/presentation/phone_auth_screen.dart';
import 'features/onboarding/presentation/otp_verify_screen.dart';
import 'features/onboarding/presentation/farmer_farm_setup_screen.dart';
import 'features/shell/presentation/main_app_shell.dart';
import 'features/diagnose/presentation/camera_capture_screen.dart';
import 'features/diagnose/presentation/image_preview_screen.dart';
import 'features/diagnose/presentation/diagnosis_loading_screen.dart';
import 'features/diagnose/presentation/advisory_result_screen.dart';
import 'features/diagnose/presentation/escalation_status_screen.dart';
import 'features/doubt_doctor/presentation/doubt_doctor_screen.dart';
import 'features/alerts/presentation/alerts_placeholder_screen.dart';
import 'features/timeline/presentation/history_placeholder_screen.dart';
import 'features/timeline/presentation/problem_detail_screen.dart';
import 'features/followup/presentation/followups_screen.dart';
import 'features/referrals/presentation/referrals_screen.dart';
import 'features/showcase/design_showcase_screen.dart';
import 'widgets/voice/bhoomi_voice_state.dart';

// ---------------------------------------------------------------------------
// MOCK STORAGE & REPOSITORIES
// ---------------------------------------------------------------------------

class DemoSecureStorage extends SecureStorage {
  final Map<String, String> _data = {
    'access_token': 'demo_token_arun',
    'refresh_token': 'demo_refresh_arun',
    'user_id': 'u_arun_01',
    'active_farm_id': 'f_green_valley',
    'farmer_name': 'Arun Kumar',
    'app_language': 'en',
  };

  @override
  Future<void> write({required String key, required String value}) async =>
      _data[key] = value;
  @override
  Future<String?> read({required String key}) async => _data[key];
  @override
  Future<void> delete({required String key}) async => _data.remove(key);
}

class DemoAuthRepository extends AuthRepository {
  bool isAuthed = true;
  UserModel? user = AuditDemoFixtures.farmerUser;

  @override
  Future<OtpRequestResponse> requestOtp({required String phone}) async {
    return const OtpRequestResponse(requestId: 'req_arun_01', expiresIn: 300);
  }

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String requestId,
    required String otp,
  }) async {
    isAuthed = true;
    user = AuditDemoFixtures.farmerUser;
    return const OtpVerifyResponse(
      accessToken: 'demo_token_arun',
      refreshToken: 'demo_refresh_arun',
      user: AuditDemoFixtures.farmerUser,
    );
  }

  @override
  Future<OtpVerifyResponse> loginAsDemo() async {
    isAuthed = true;
    user = AuditDemoFixtures.farmerUser;
    return const OtpVerifyResponse(
      accessToken: 'demo_token_arun',
      refreshToken: 'demo_refresh_arun',
      user: AuditDemoFixtures.farmerUser,
    );
  }

  @override
  Future<void> logout() async {
    isAuthed = false;
    user = null;
  }

  @override
  Future<bool> isAuthenticated() async => isAuthed;

  @override
  Future<UserModel?> getCurrentUser() async => user;
}

class DemoFarmRepository extends FarmRepository {
  @override
  Future<FarmSummaryModel> getFarmSummary(String farmId) async =>
      AuditDemoFixtures.farmSummary;

  @override
  Future<FarmModel> getFarm(String farmId) async => AuditDemoFixtures.farm;

  @override
  Future<FarmModel> createFarm({
    required String crop,
    String? variety,
    required String growthStage,
    required String region,
    required GeoPoint location,
  }) async =>
      AuditDemoFixtures.farm;

  @override
  Future<FarmModel> updateFarm(
    String farmId,
    Map<String, dynamic> updates,
  ) async =>
      AuditDemoFixtures.farm;
}

class DemoFarmerProfileRepository extends FarmerProfileRepository {
  FarmerProfile profile = AuditDemoFixtures.farmerProfile;

  @override
  Future<FarmerProfile?> getProfile(String userId) async => profile;

  @override
  Future<FarmerProfile> saveProfile(FarmerProfile newProfile) async {
    profile = newProfile;
    return profile;
  }

  @override
  Future<void> deleteProfile(String userId) async {}
}

class DemoAlertRepository extends AlertRepository {
  final bool isEmpty;
  DemoAlertRepository({this.isEmpty = false});

  @override
  Future<AlertsResponse> getAlerts({
    required String farmId,
    int? limit = 20,
    String? cursor,
  }) async {
    return AlertsResponse(
      alerts: isEmpty ? [] : AuditDemoFixtures.riskAlerts,
    );
  }

  @override
  Future<AlertRespondResponse> respondToAlert({
    required String alertId,
    required String outcome,
    String? imageAssetId,
  }) async {
    return AlertRespondResponse(alertId: alertId, outcome: outcome);
  }
}

class DemoTimelineRepository extends TimelineRepository {
  final bool isEmpty;
  DemoTimelineRepository({this.isEmpty = false});

  @override
  Future<TimelineResponse> getTimeline({
    required String farmId,
    int limit = 20,
    String? cursor,
  }) async {
    return TimelineResponse(
      events: isEmpty ? [] : AuditDemoFixtures.timelineEvents,
    );
  }
}

class DemoReferralRepository extends ReferralRepository {
  @override
  Future<ReferralsResponse> getReferrals(String farmId) async =>
      AuditDemoFixtures.referrals;
}

class DemoFollowUpRepository extends FollowUpRepository {
  final bool isEmpty;
  DemoFollowUpRepository({this.isEmpty = false});

  @override
  Future<PendingFollowUpsResponse> getPendingFollowUps(String farmId) async {
    return PendingFollowUpsResponse(
      followups: isEmpty ? [] : AuditDemoFixtures.pendingFollowUps,
    );
  }

  @override
  Future<FollowUpResultModel> respondToFollowUp({
    required String followUpId,
    required String response,
    String? imageAssetId,
  }) async {
    return const FollowUpResultModel(
      problemId: 'p_tomato_blight_01',
    );
  }
}

class DemoDiagnosisRepository extends DiagnosisRepository {
  @override
  Future<DiagnoseResponse> diagnose({
    required String farmId,
    required String imageAssetId,
    String? descriptionAssetId,
    String? descriptionText,
    String lang = 'en-IN',
  }) async =>
      AuditDemoFixtures.earlyBlightDiagnosis;
}

class DemoDoubtDoctorRepository extends DoubtDoctorRepository {
  @override
  Future<DoubtDoctorAnswerResult> submitAnswer({
    required String problemId,
    required String cueId,
    required String answer,
  }) async {
    return DoubtDoctorAnswerResult(
      resolved: true,
      diagnosis: AuditDemoFixtures.earlyBlightDiagnosis.diagnosis,
      advisory: AuditDemoFixtures.earlyBlightDiagnosis.advisory,
      spokenSummary: AuditDemoFixtures.earlyBlightDiagnosis.spokenSummary,
    );
  }
}

class DemoProblemRepository extends ProblemRepository {
  @override
  Future<ProblemDetailModel> getProblemDetail(String problemId) async =>
      AuditDemoFixtures.problemDetail;

  @override
  Future<ProblemsResponse> getProblems({
    required String farmId,
    String? status,
    String? type,
    int limit = 20,
    String? cursor,
  }) async {
    return ProblemsResponse(
      problems: [AuditDemoFixtures.problemDetail.problem],
    );
  }

  @override
  Future<EscalationModel> escalateProblem(String problemId) async {
    return AuditDemoFixtures.escalationResponse.escalation!;
  }
}

class DemoAssetRepository extends AssetRepository {
  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    String? farmId,
    dynamic onProgress,
  }) async =>
      'asset_tomato_early_blight_01';

  @override
  Future<String> uploadAudio({
    required Uint8List bytes,
    String contentType = 'audio/wav',
    String? farmId,
    dynamic onProgress,
  }) async =>
      'asset_audio_arun_01';

  @override
  Future<PresignedAssetModel> presignAsset({
    required String kind,
    required String contentType,
    String? farmId,
  }) async =>
      const PresignedAssetModel(
        assetId: 'asset_tomato_early_blight_01',
        uploadUrl: 'http://localhost:8080/upload',
      );

  @override
  Future<void> uploadBinary({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
    dynamic onProgress,
  }) async {}
}

class MockAudioPlaybackService extends AudioPlaybackService {
  MockAudioPlaybackService() : super(player: MockAudioPlayerWrapper());
}

class MockAudioPlayerWrapper implements AudioPlayerWrapper {
  @override
  Future<void> play(Source source) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Stream<PlayerState> get onPlayerStateChanged => const Stream.empty();
  @override
  Stream<Duration> get onPositionChanged => const Stream.empty();
  @override
  Stream<Duration> get onDurationChanged => const Stream.empty();
  @override
  Stream<void> get onPlayerComplete => const Stream.empty();
  @override
  PlayerState get state => PlayerState.stopped;
  @override
  Future<void> dispose() async {}
}

// ---------------------------------------------------------------------------
// DETERMINISTIC CAMERA CONTROLLER & PREVIEW
// ---------------------------------------------------------------------------

class DemoViewfinderCameraController extends CameraController {
  DemoViewfinderCameraController()
      : super(
          const CameraDescription(
            name: 'bhoomi_inspection_cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
          ResolutionPreset.high,
          enableAudio: false,
        ) {
    value = CameraValue.uninitialized(
      const CameraDescription(
        name: 'bhoomi_inspection_cam',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
    ).copyWith(
      isInitialized: true,
      previewSize: const Size(1280, 960),
      flashMode: FlashMode.auto,
    );
  }

  @override
  Future<void> initialize() async {}

  @override
  Widget buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/crop_tomato_early_blight.jpg',
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  @override
  Future<XFile> takePicture() async {
    return XFile('assets/images/crop_tomato_early_blight.jpg');
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    value = value.copyWith(flashMode: mode);
  }


}

class DemoCameraPlatformWrapper implements CameraPlatformWrapper {
  final bool hasCamera;
  const DemoCameraPlatformWrapper({this.hasCamera = true});

  @override
  Future<bool> requestCameraPermission() async => hasCamera;

  @override
  Future<bool> isCameraPermissionGranted() async => hasCamera;

  @override
  Future<bool> isCameraPermissionPermanentlyDenied() async => false;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    if (!hasCamera) return [];
    return [
      const CameraDescription(
        name: 'bhoomi_inspection_cam',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      )
    ];
  }

  @override
  CameraController createController({
    required CameraDescription camera,
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
    bool enableAudio = false,
  }) {
    return DemoViewfinderCameraController();
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    return XFile('assets/images/crop_tomato_early_blight.jpg');
  }
}

// ---------------------------------------------------------------------------
// AUTO-SCROLL WRAPPER
// ---------------------------------------------------------------------------

class AutoScrollToBottom extends StatefulWidget {
  final Widget child;
  const AutoScrollToBottom({super.key, required this.child});

  @override
  State<AutoScrollToBottom> createState() => _AutoScrollToBottomState();
}

class _AutoScrollToBottomState extends State<AutoScrollToBottom> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _scrollAllChildren(context);
      });
      Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        _scrollAllChildren(context);
      });
    });
  }

  void _scrollAllChildren(BuildContext ctx) {
    void visit(Element element) {
      if (element.widget is Scrollable) {
        final state = (element as StatefulElement).state;
        if (state is ScrollableState) {
          try {
            state.position.jumpTo(state.position.maxScrollExtent);
          } catch (_) {}
        }
      }
      element.visitChildren(visit);
    }
    (ctx as Element).visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ---------------------------------------------------------------------------
// MAIN DEMO RUNNER
// ---------------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final uri = Uri.base;
  final screenParam = uri.queryParameters['screen'] ?? 'default';

  Uint8List sampleImageBytes = Uint8List(0);
  try {
    final byteData =
        await rootBundle.load('assets/images/crop_tomato_early_blight.jpg');
    sampleImageBytes = byteData.buffer.asUint8List();
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(
          TokenStorage(storage: DemoSecureStorage()),
        ),
        authRepositoryProvider.overrideWithValue(DemoAuthRepository()),
        farmRepositoryProvider.overrideWithValue(DemoFarmRepository()),
        farmerProfileRepositoryProvider
            .overrideWithValue(DemoFarmerProfileRepository()),
        alertRepositoryProvider.overrideWithValue(
          DemoAlertRepository(isEmpty: screenParam == '27_alerts_screen_empty'),
        ),
        timelineRepositoryProvider.overrideWithValue(
          DemoTimelineRepository(
              isEmpty: screenParam == '29_history_screen_empty'),
        ),
        referralRepositoryProvider.overrideWithValue(DemoReferralRepository()),
        followUpRepositoryProvider.overrideWithValue(
          DemoFollowUpRepository(
              isEmpty: screenParam == '32_followups_screen_empty'),
        ),
        diagnosisRepositoryProvider.overrideWithValue(DemoDiagnosisRepository()),
        doubtDoctorRepositoryProvider
            .overrideWithValue(DemoDoubtDoctorRepository()),
        problemRepositoryProvider.overrideWithValue(DemoProblemRepository()),
        assetRepositoryProvider.overrideWithValue(DemoAssetRepository()),
        audioPlaybackServiceProvider
            .overrideWithValue(MockAudioPlaybackService()),
      ],
      child: BhoomiDemoHarness(
        screen: screenParam,
        imageBytes: sampleImageBytes,
      ),
    ),
  );
}

class BhoomiDemoHarness extends ConsumerWidget {
  final String screen;
  final Uint8List imageBytes;

  const BhoomiDemoHarness({
    super.key,
    required this.screen,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);

    return MaterialApp(
      title: 'Bhoomi Visual Audit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(language.code, 'IN'),
      supportedLocales: const [
        Locale('en', 'IN'),
        Locale('mr', 'IN'),
        Locale('hi', 'IN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _resolveScreen(context, ref),
    );
  }

  Widget _resolveScreen(BuildContext context, WidgetRef ref) {
    switch (screen) {
      case '01_splash':
        return const SplashScreen();

      case '02_landing':
        return const LandingScreen();

      case '03_language_selection_modal':
        return _buildModalOverlay(
          background: const LandingScreen(),
          modal: _buildLanguageSelectionSheet(context, ref),
        );

      case '04_phone_auth_empty':
        return const PhoneAuthScreen();

      case '05_phone_auth_filled':
        return _buildFilledPhoneAuthScreen();

      case '06_demo_confirmation_modal':
        return _buildModalOverlay(
          background: _buildFilledPhoneAuthScreen(),
          modal: _buildDemoConfirmationSheet(context, ref),
        );

      case '07_otp_verify_empty':
        return const OtpVerifyScreen(
          phoneNumber: '+91 98765 43210',
          requestId: 'req_arun_01',
          expiresInSeconds: 285,
        );

      case '08_otp_verify_filled':
        return _buildFilledOtpVerifyScreen();

      case '09_farmer_farm_setup_top':
        return const FarmerFarmSetupScreen(isFirstTimeOnboarding: true);

      case '10_farmer_farm_setup_bottom':
        return const AutoScrollToBottom(
          child: FarmerFarmSetupScreen(isFirstTimeOnboarding: true),
        );

      case '11_home_dashboard_top':
        return const MainAppShell(initialIndex: 0);

      case '12_home_dashboard_bottom':
        return const AutoScrollToBottom(
          child: MainAppShell(initialIndex: 0),
        );

      case '13_voice_assistant_listening':
        return _buildVoiceAssistantState(
          state: BhoomiVoiceState.listening,
          ref: ref,
        );

      case '14_voice_assistant_processing':
        return _buildVoiceAssistantState(
          state: BhoomiVoiceState.processing,
          ref: ref,
        );

      case '15_voice_assistant_response':
        return _buildVoiceAssistantState(
          state: BhoomiVoiceState.speaking,
          query: 'Why are there circular spots on my tomato leaves?',
          response:
              'Early blight fungal infection is likely due to high humidity. Prune infected bottom leaves and spray bio-fungicide.',
          ref: ref,
        );

      case '16_camera_capture_viewfinder':
        return CameraCaptureScreen(
          cameraControllerOverride: DemoViewfinderCameraController(),
          cameraPlatformWrapper:
              const DemoCameraPlatformWrapper(hasCamera: true),
        );

      case '17_camera_capture_fallback':
        return const CameraCaptureScreen(
          cameraPlatformWrapper: DemoCameraPlatformWrapper(hasCamera: false),
        );

      case '18_image_preview':
        return ImagePreviewScreen(imageBytes: imageBytes);

      case '19_diagnosis_loading':
        return const DiagnosisLoadingScreen();

      case '20_diagnosis_error_state':
        return _buildDiagnosisErrorScreen();

      case '21_advisory_result_top':
        return const AdvisoryResultScreen(
          response: AuditDemoFixtures.earlyBlightDiagnosis,
        );

      case '22_advisory_result_bottom':
        return const AutoScrollToBottom(
          child: AdvisoryResultScreen(
            response: AuditDemoFixtures.earlyBlightDiagnosis,
          ),
        );

      case '23_doubt_doctor_question':
        return const DoubtDoctorScreen(
          response: AuditDemoFixtures.doubtDoctorClarification,
        );

      case '24_doubt_doctor_answer_selected':
        return _buildDoubtDoctorAnsweredScreen();

      case '25_escalation_status':
        return const EscalationStatusScreen(
          response: AuditDemoFixtures.escalationResponse,
        );

      case '26_alerts_screen_populated':
        return const MainAppShell(initialIndex: 2);

      case '27_alerts_screen_empty':
        return const AlertsPlaceholderScreen();

      case '28_history_screen_populated':
        return const MainAppShell(initialIndex: 3);

      case '29_history_screen_empty':
        return const HistoryPlaceholderScreen();

      case '30_problem_detail':
        return ProblemDetailScreen(
          problemId: AuditDemoFixtures.problemDetail.id,
        );

      case '31_followups_screen_populated':
        return const FollowupsScreen();

      case '32_followups_screen_empty':
        return const FollowupsScreen();

      case '33_more_screen':
        return const MainAppShell(initialIndex: 4);

      case '34_more_language_dialog':
        return _buildModalOverlay(
          background: const MainAppShell(initialIndex: 4),
          modal: _buildLanguageDialog(context, ref),
        );

      case '35_more_about_dialog':
        return _buildModalOverlay(
          background: const MainAppShell(initialIndex: 4),
          modal: _buildAboutDialog(context, ref),
        );

      case '36_more_logout_dialog':
        return _buildModalOverlay(
          background: const MainAppShell(initialIndex: 4),
          modal: _buildLogoutDialog(context, ref),
        );

      case '37_referrals_screen':
        return const ReferralsScreen();

      case '38_design_showcase_top':
        return const DesignShowcaseScreen();

      case '39_design_showcase_bottom':
        return const AutoScrollToBottom(
          child: DesignShowcaseScreen(),
        );

      default:
        return const MainAppShell(initialIndex: 0);
    }
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGET BUILDERS FOR INTERACTIVE MODALS & DIALOGS
  // ---------------------------------------------------------------------------

  Widget _buildModalOverlay({
    required Widget background,
    required Widget modal,
  }) {
    return Stack(
      children: [
        background,
        Container(color: Colors.black54),
        Center(child: modal),
      ],
    );
  }

  Widget _buildFilledPhoneAuthScreen() {
    return const PhoneAuthScreen(
      initialPhoneNumber: '9876543210',
    );
  }

  Widget _buildFilledOtpVerifyScreen() {
    return const OtpVerifyScreen(
      phoneNumber: '+91 98765 43210',
      requestId: 'req_arun_01',
      expiresInSeconds: 270,
      initialOtp: '123456',
    );
  }

  Widget _buildDiagnosisErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.ricePaper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_rounded, color: AppColors.forest),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl28),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l20),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 56,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: AppSpacing.l20),
                Text(
                  'Diagnosis Service Timeout',
                  textAlign: TextAlign.center,
                  style: AppTypography.subheading.copyWith(
                    color: AppColors.soilCharcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'The neural confidence gate took longer than expected to respond. Please check your connectivity and retry.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fieldSlate,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl32),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: AppSpacing.m12),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.forest,
                    side: const BorderSide(color: AppColors.forest),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text('Retake Photograph',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoubtDoctorAnsweredScreen() {
    return const DoubtDoctorScreen(
      response: AuditDemoFixtures.doubtDoctorClarification,
    );
  }

  Widget _buildLanguageSelectionSheet(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.warmSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l24,
          vertical: AppSpacing.l20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.language_rounded,
                    color: AppColors.forest, size: 26),
                const SizedBox(width: AppSpacing.s10),
                Text(
                  'Select Language / भाषा निवडा',
                  style: AppTypography.subheading.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m16),
            ...AppLanguage.values.map((lang) {
              final isSelected = lang == AppLanguage.english;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.forest : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    lang.label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.forest
                          : AppColors.soilCharcoal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.forest)
                      : null,
                ),
              );
            }),
            const SizedBox(height: AppSpacing.m16),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoConfirmationSheet(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final currentLang = ref.watch(appLanguageProvider);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.ricePaper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l24,
          vertical: AppSpacing.l20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.forest.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.agriculture_rounded,
                    color: AppColors.forest,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.m12),
                Expanded(
                  child: Text(
                    currentLang.isMarathi
                        ? 'भूमी डेमो मोड सुरू करा'
                        : (currentLang.isHindi
                            ? 'भूमी डेमो मोड शुरू करें'
                            : 'Explore Bhoomi Demo Mode'),
                    style: AppTypography.sectionTitle.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m16),
            Text(
              currentLang.isMarathi
                  ? 'सक्रिय SMS पडताळणीशिवाय पूर्व-कॉन्फिगर केलेल्या शेतकरी प्रोफाइलसह संपूर्ण शेती सहाय्यकाचा अनुभव घ्या.'
                  : (currentLang.isHindi
                      ? 'सक्रिय SMS प्रमाणीकरण के बिना पूर्व-कॉन्फ़िगर किसान प्रोफ़ाइल के साथ संपूर्ण कृषि साथी अनुभव लें।'
                      : 'Explore the complete farmer companion experience with a pre-configured profile without requiring active SMS authentication.'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.soilCharcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.m16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m16),
              decoration: BoxDecoration(
                color: AppColors.warmSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          size: 18, color: AppColors.forest),
                      const SizedBox(width: 8),
                      Text(
                        currentLang.isMarathi
                            ? 'शेतकरी: अरुण कुमार (+९१ ९८७६५ ४३२१०)'
                            : (currentLang.isHindi
                                ? 'किसान: अरुण कुमार (+91 98765 43210)'
                                : 'Farmer: Arun Kumar (+91 98765 43210)'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.grass_rounded,
                          size: 18, color: AppColors.forest),
                      const SizedBox(width: 8),
                      Text(
                        currentLang.isMarathi
                            ? 'शेत: ग्रीन व्हॅली फार्म (४.५ एकर)'
                            : (currentLang.isHindi
                                ? 'खेत: ग्रीन वैली फार्म (4.5 एकड़)'
                                : 'Farm: Green Valley Farm (4.5 Acres)'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 18, color: AppColors.forest),
                      const SizedBox(width: 8),
                      Text(
                        currentLang.isMarathi
                            ? 'स्थान: तामिळनाडू'
                            : (currentLang.isHindi
                                ? 'स्थान: तमिलनाडु'
                                : 'Location: Tamil Nadu'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                currentLang.isMarathi
                    ? 'डेमो मोडमध्ये प्रवेश करा'
                    : (currentLang.isHindi
                        ? 'डेमो मोड में प्रवेश करें'
                        : 'Enter Demo Mode'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSpacing.s10),
            TextButton(
              onPressed: () {},
              child: Text(
                strings.cancel,
                style: const TextStyle(color: AppColors.fieldSlate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDialog(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return AlertDialog(
      backgroundColor: AppColors.warmSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        strings.selectLanguagePrompt,
        style: AppTypography.subheading.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((lang) {
          final isSelected = lang == ref.watch(appLanguageProvider);
          return ListTile(
            title: Text(
              lang.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.forest : AppColors.soilCharcoal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.forest)
                : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAboutDialog(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final strings = ref.watch(stringsProvider);

    return AlertDialog(
      backgroundColor: AppColors.warmSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Image.asset('assets/images/bhoomi_logo_mark.png',
              width: 36, height: 36),
          const SizedBox(width: 12),
          Text(
            currentLang.isMarathi
                ? 'भूमी शेती सल्लागार'
                : (currentLang.isHindi ? 'भूमी कृषि साथी' : 'Bhoomi Companion'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentLang.isMarathi
                ? 'आवृत्ती २.०.० (SIH26131)'
                : (currentLang.isHindi
                    ? 'संस्करण 2.0.0 (SIH26131)'
                    : 'Version 2.0.0 (SIH26131)'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            currentLang.isMarathi
                ? 'स्मार्ट इंडिया हॅकाथॉन २०२६ — अल्पभूधारक शेतकऱ्यांसाठी पीक रोगांचे जलद निदान आणि एकात्मिक व्यवस्थापन.'
                : (currentLang.isHindi
                    ? 'स्मार्ट इंडिया हैकाथॉन 2026 — छोटे किसानों के लिए फसल रोग निदान और एकीकृत प्रबंधन।'
                    : 'Smart India Hackathon 2026 — Early detection and IPM management of crop diseases for smallholder farmers.'),
            style: const TextStyle(color: AppColors.soilCharcoal, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            currentLang.isMarathi
                ? 'महाराष्ट्र व तामिळनाडू कृषी पुढाकार'
                : (currentLang.isHindi
                    ? 'महाराष्ट्र व तमिलनाडु कृषि पहल'
                    : 'Government of Tamil Nadu & Maharashtra Agricultural Initiatives'),
            style: const TextStyle(color: AppColors.fieldSlate, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            strings.close,
            style: const TextStyle(
                color: AppColors.forest, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutDialog(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return AlertDialog(
      backgroundColor: AppColors.warmSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        strings.logoutDialogTitle,
        style: AppTypography.subheading.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        strings.logoutDialogMessage,
        style: AppTypography.bodySmall.copyWith(color: AppColors.fieldSlate),
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            strings.cancel,
            style: const TextStyle(color: AppColors.fieldSlate),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            strings.logoutConfirm,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceAssistantState({
    required BhoomiVoiceState state,
    String? query,
    String? response,
    WidgetRef? ref,
  }) {
    final isMr = ref?.watch(appLanguageProvider).isMarathi ?? false;
    final isHi = ref?.watch(appLanguageProvider).isHindi ?? false;

    return Stack(
      children: [
        const MainAppShell(initialIndex: 0),
        Container(color: Colors.black54),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.warmSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l24,
              vertical: AppSpacing.l20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: AppSpacing.l20),
                if (state == BhoomiVoiceState.listening) ...[
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forest.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: AppSpacing.l16),
                  Text(
                    isMr
                        ? 'भूमी ऐकत आहे...'
                        : (isHi ? 'भूमी सुन रही है...' : 'Bhoomi is listening...'),
                    style: AppTypography.subheading.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    isMr
                        ? 'तुमच्या पिकांविषयी मराठीत बोला'
                        : (isHi
                            ? 'अपनी फसलों के बारे में हिन्दी में बोलें'
                            : 'Ask in English, Marathi, or Hindi about your crops'),
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.fieldSlate),
                  ),
                  const SizedBox(height: AppSpacing.l24),
                ] else if (state == BhoomiVoiceState.processing) ...[
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                        color: AppColors.forest, strokeWidth: 3),
                  ),
                  const SizedBox(height: AppSpacing.l16),
                  Text(
                    isMr
                        ? 'तुमचा प्रश्न समजावून घेत आहे...'
                        : (isHi
                            ? 'आपका प्रश्न समझा जा रहा है...'
                            : 'Understanding your question...'),
                    style: AppTypography.subheading.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l24),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.l16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.record_voice_over_rounded,
                                color: AppColors.forest, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isMr
                                  ? 'तुम्ही विचारले:'
                                  : (isHi ? 'आपने पूछा:' : 'You asked:'),
                              style: AppTypography.captionSmall.copyWith(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMr
                              ? 'टोमॅटोच्या पानांवर ठिपके का पडले आहेत?'
                              : (isHi
                                  ? 'टमाटर की पत्तियों पर धब्बे क्यों हैं?'
                                  : (query ?? 'Why are there spots on my tomato leaves?')),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m12),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.l16),
                    decoration: BoxDecoration(
                      color: AppColors.ricePaper,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.eco_rounded,
                                color: AppColors.forest, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isMr
                                  ? 'भूमीचा सल्ला:'
                                  : (isHi ? 'भूमी की सलाह:' : 'Bhoomi Advice:'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forest),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isMr
                              ? 'टोमॅटोवर अर्ली ब्लाइट (करपा) बुरशीजन्य रोग आढळला आहे. खालची बाधित पाने तोडून नष्ट करा आणि जैविक बुरशीनाशकाची फवारणी करा.'
                              : (isHi
                                  ? 'टमाटर पर अगेती झुलसा फफूंद रोग पाया गया है। निचली प्रभावित पत्तियों को तोड़कर नष्ट करें और जैविक फफूंदनाशक का छिड़काव करें।'
                                  : (response ??
                                      'Early blight fungal infection is detected. Remove lower affected leaves and spray bio-fungicide.')),
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.soilCharcoal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(
                      isMr
                          ? 'आवाजी सल्ला ऐका'
                          : (isHi ? 'आवाज़ में सलाह सुनें' : 'Listen to Spoken Advice'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
