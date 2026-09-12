import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../models/advisory_models.dart';
import '../../models/alert_models.dart';
import '../../models/asset_models.dart';
import '../../models/auth_models.dart';
import '../../models/diagnosis_models.dart';
import '../../models/farm_models.dart';
import '../../models/farmer_profile_models.dart';
import '../../models/followup_models.dart';
import '../../models/health_models.dart';
import '../../models/label_check_models.dart';
import '../../models/problem_models.dart';
import '../../models/referral_models.dart';
import '../../models/timeline_models.dart';
import '../../models/voice_models.dart';
import '../../repositories/advisory_repository.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/asset_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/diagnosis_repository.dart';
import '../../repositories/doubt_doctor_repository.dart';
import '../../repositories/farm_repository.dart';
import '../../repositories/farmer_profile_repository.dart';
import '../../repositories/followup_repository.dart';
import '../../repositories/health_repository.dart';
import '../../repositories/label_check_repository.dart';
import '../../repositories/problem_repository.dart';
import '../../repositories/referral_repository.dart';
import '../../repositories/timeline_repository.dart';
import '../../repositories/voice_repository.dart';
import '../config/demo_config.dart';
import '../constants/audit_demo_fixtures.dart';
import '../error/app_exception.dart';
import '../storage/token_storage.dart';
import 'demo_store.dart';

Future<void> _demoDelay(String operation) async {
  if (DemoConfig.shouldSimulate(operation) ||
      DemoConfig.shouldSimulate('network')) {
    throw const NetworkException(message: 'Demo simulation: request failed.');
  }
  if (DemoConfig.latencyMs > 0) {
    await Future<void>.delayed(Duration(milliseconds: DemoConfig.latencyMs));
  }
}

/// Local OTP/session implementation used only when [AppModeConfig.isDemo].
class DemoAuthRepository implements AuthRepository {
  static const _accessToken = 'demo_access_arun_kumar';
  static const _refreshToken = 'demo_refresh_arun_kumar';
  final TokenStorage _tokenStorage;
  final DemoStore _store;

  DemoAuthRepository({
    required TokenStorage tokenStorage,
    required DemoStore store,
  })  : _tokenStorage = tokenStorage,
        _store = store;

  @override
  Future<OtpRequestResponse> requestOtp({required String phone}) async {
    await _demoDelay('login');
    return const OtpRequestResponse(
      requestId: 'demo_otp_arun_001',
      expiresIn: 300,
    );
  }

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String requestId,
    required String otp,
  }) async {
    await _demoDelay('login');
    if (otp != DemoConfig.demoOtp) {
      throw const ValidationException(
        message: 'Invalid demo OTP. Please enter 123456.',
        code: 'INVALID_OTP',
      );
    }
    return _createSession();
  }

  @override
  Future<OtpVerifyResponse> loginAsDemo() async {
    await _demoDelay('login');
    return _createSession();
  }

  Future<OtpVerifyResponse> _createSession() async {
    await _store.ensureSeeded();
    const user = AuditDemoFixtures.farmerUser;
    await _tokenStorage.saveTokens(
      accessToken: _accessToken,
      refreshToken: _refreshToken,
    );
    await _tokenStorage.saveUserData(user.toJson());
    await _tokenStorage.saveActiveFarmId(DemoConfig.demoFarmId);
    return const OtpVerifyResponse(
      accessToken: _accessToken,
      refreshToken: _refreshToken,
      user: user,
    );
  }

  @override
  Future<void> logout() => _tokenStorage.clearSession();

  @override
  Future<bool> isAuthenticated() async =>
      await _tokenStorage.getAccessToken() == _accessToken;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!await isAuthenticated()) return null;
    final data = await _tokenStorage.getUserData();
    return data == null ? null : UserModel.fromJson(data);
  }
}

class DemoFarmRepository implements FarmRepository {
  final DemoStore _store;

  DemoFarmRepository({required DemoStore store}) : _store = store;

  @override
  Future<FarmModel> createFarm({
    required String crop,
    String? variety,
    required String growthStage,
    required String region,
    required GeoPoint location,
  }) async {
    await _demoDelay('farm');
    final farm = FarmModel(
      id: DemoConfig.demoFarmId,
      farmerId: DemoConfig.demoFarmerId,
      crop: crop,
      variety: variety,
      growthStage: growthStage,
      region: region,
      location: location,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    await _store.saveFarm(farm);
    return farm;
  }

  @override
  Future<FarmModel> getFarm(String farmId) async {
    await _demoDelay('farm');
    return _store.getFarm();
  }

  @override
  Future<FarmModel> updateFarm(
    String farmId,
    Map<String, dynamic> updates,
  ) async {
    await _demoDelay('farm');
    final current = await _store.getFarm();
    final updated = FarmModel.fromJson({
      ...current.toJson(),
      ...updates,
      'id': current.id,
    });
    await _store.saveFarm(updated);
    return updated;
  }

  @override
  Future<FarmSummaryModel> getFarmSummary(String farmId) async {
    await _demoDelay('farm');
    final farm = await _store.getFarm();
    final followUps = await _store.getFollowUps();
    final alerts = await _store.getAlerts();
    return FarmSummaryModel(
      farm: farm,
      health: AuditDemoFixtures.farmSummary.health,
      openProblems: 1,
      pendingFollowups: followUps.where((item) => item.response == null).length,
      activeAlerts: alerts.where((item) => item.outcome == null).length,
      spokenSummary: 'Green Valley Farm is ready for a crop health check.',
    );
  }
}

class DemoFarmerProfileRepository implements FarmerProfileRepository {
  final DemoStore _store;

  DemoFarmerProfileRepository({required DemoStore store}) : _store = store;

  @override
  Future<FarmerProfile?> getProfile(String userId) async {
    await _demoDelay('profile');
    return _store.getProfile();
  }

  @override
  Future<FarmerProfile> saveProfile(FarmerProfile profile) async {
    await _demoDelay('profile');
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await _store.saveProfile(updated);

    final currentFarm = await _store.getFarm();
    await _store.saveFarm(FarmModel(
      id: updated.farmId ?? currentFarm.id,
      farmerId: updated.farmerId,
      crop: updated.currentCrop,
      variety: updated.variety,
      growthStage: updated.growthStage,
      region: updated.region ?? currentFarm.region,
      location: updated.location ?? currentFarm.location,
      createdAt: currentFarm.createdAt,
    ));
    return updated;
  }

  @override
  Future<void> deleteProfile(String userId) => _store.reset();
}

/// Simulates the presign + upload contract without contacting cloud storage.
class DemoAssetRepository implements AssetRepository {
  static const _imageAssetId = 'demo_asset_tomato_001';
  static const _audioAssetId = 'demo_asset_voice_001';

  @override
  Future<PresignedAssetModel> presignAsset({
    required String kind,
    required String contentType,
    String? farmId,
  }) async {
    await _demoDelay('upload');
    final assetId = kind == 'audio' ? _audioAssetId : _imageAssetId;
    return PresignedAssetModel(
      assetId: assetId,
      uploadUrl: 'demo://assets/$assetId',
    );
  }

  @override
  Future<void> uploadBinary({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
    ProgressCallback? onProgress,
  }) async {
    await _demoDelay('upload');
    onProgress?.call(bytes.length, bytes.length);
  }

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    String? farmId,
    ProgressCallback? onProgress,
  }) async {
    final presigned = await presignAsset(
      kind: 'image',
      contentType: contentType,
      farmId: farmId,
    );
    await uploadBinary(
      uploadUrl: presigned.uploadUrl,
      bytes: bytes,
      contentType: contentType,
      onProgress: onProgress,
    );
    return presigned.assetId;
  }

  @override
  Future<String> uploadAudio({
    required Uint8List bytes,
    String contentType = 'audio/wav',
    String? farmId,
    ProgressCallback? onProgress,
  }) async {
    final presigned = await presignAsset(
      kind: 'audio',
      contentType: contentType,
      farmId: farmId,
    );
    await uploadBinary(
      uploadUrl: presigned.uploadUrl,
      bytes: bytes,
      contentType: contentType,
      onProgress: onProgress,
    );
    return presigned.assetId;
  }
}

class DemoDiagnosisRepository implements DiagnosisRepository {
  final DemoStore _store;

  DemoDiagnosisRepository({required DemoStore store}) : _store = store;

  @override
  Future<DiagnoseResponse> diagnose({
    required String farmId,
    required String imageAssetId,
    String? descriptionAssetId,
    String? descriptionText,
    String lang = 'mr-IN',
  }) async {
    await _demoDelay('diagnosis');
    final source = AuditDemoFixtures.doubtDoctorClarification;
    final response = DiagnoseResponse(
      gate: source.gate,
      problemId: AuditDemoFixtures.problemDetail.id,
      problemType: 'disease',
      clarification: source.clarification,
      spokenSummary: 'Tomato leaf symptoms need one quick field check.',
    );
    await _store.addTimelineEvent(
      TimelineEventModel(
        id: 'tl_demo_submit_${DateTime.now().millisecondsSinceEpoch}',
        type: 'diagnosis',
        title: 'Crop image submitted',
        description: 'Tomato image uploaded as $imageAssetId for diagnosis.',
        timestamp: DateTime.now().toUtc().toIso8601String(),
        problemId: response.problemId,
        severity: 'moderate',
      ),
    );
    return response;
  }
}

class DemoDoubtDoctorRepository implements DoubtDoctorRepository {
  final DemoStore _store;

  DemoDoubtDoctorRepository({required DemoStore store}) : _store = store;

  @override
  Future<DoubtDoctorAnswerResult> submitAnswer({
    required String problemId,
    required String cueId,
    required String answer,
  }) async {
    await _demoDelay('doubt_doctor');
    await _store.recordDoubtDoctorAnswer(cueId: cueId, answer: answer);
    final diagnosis = AuditDemoFixtures.earlyBlightDiagnosis;
    return DoubtDoctorAnswerResult(
      resolved: true,
      observationId: 'obs_demo_tomato_001',
      diagnosis: diagnosis.diagnosis,
      advisory: diagnosis.advisory,
      citations: diagnosis.citations,
      spokenSummary: diagnosis.spokenSummary,
    );
  }
}

class DemoAlertRepository implements AlertRepository {
  final DemoStore _store;

  DemoAlertRepository({required DemoStore store}) : _store = store;

  @override
  Future<AlertsResponse> getAlerts({
    required String farmId,
    int limit = 20,
    String? cursor,
  }) async {
    await _demoDelay('alerts');
    if (DemoConfig.shouldSimulate('empty_alerts')) {
      return const AlertsResponse(alerts: []);
    }
    final alerts = await _store.getAlerts();
    return AlertsResponse(alerts: alerts.take(limit).toList());
  }

  @override
  Future<AlertRespondResponse> respondToAlert({
    required String alertId,
    required String outcome,
    String? imageAssetId,
  }) async {
    await _demoDelay('alerts');
    final alerts = await _store.getAlerts();
    await _store.saveAlerts(alerts.map((alert) {
      if (alert.id != alertId) return alert;
      return AlertModel.fromJson({...alert.toJson(), 'outcome': outcome});
    }).toList());
    await _store.addTimelineEvent(TimelineEventModel(
      id: 'tl_demo_alert_${DateTime.now().millisecondsSinceEpoch}',
      type: 'alert',
      title: 'Risk alert acknowledged',
      description: 'Field response recorded: $outcome.',
      timestamp: DateTime.now().toUtc().toIso8601String(),
    ));
    return AlertRespondResponse(
      alertId: alertId,
      outcome: outcome,
      diagnoseSuggested: outcome == 'found',
      recordedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }
}

class DemoFollowUpRepository implements FollowUpRepository {
  final DemoStore _store;

  DemoFollowUpRepository({required DemoStore store}) : _store = store;

  @override
  Future<PendingFollowUpsResponse> getPendingFollowUps(String farmId) async {
    await _demoDelay('followup');
    final followUps = await _store.getFollowUps();
    return PendingFollowUpsResponse(
      followups: followUps.where((item) => item.response == null).toList(),
    );
  }

  @override
  Future<FollowUpResultModel> respondToFollowUp({
    required String followUpId,
    required String response,
    String? imageAssetId,
  }) async {
    await _demoDelay('followup');
    final items = await _store.getFollowUps();
    final item = items.firstWhere(
      (candidate) => candidate.id == followUpId,
      orElse: () => items.isNotEmpty
          ? items.first
          : AuditDemoFixtures.pendingFollowUps.first,
    );
    await _store.saveFollowUps(items.map((candidate) {
      if (candidate.id != followUpId) return candidate;
      return FollowUpModel(
        id: candidate.id,
        problemId: candidate.problemId,
        dueAt: candidate.dueAt,
        response: response,
        imageAssetId: imageAssetId,
        respondedAt: DateTime.now().toUtc().toIso8601String(),
        farmId: candidate.farmId,
        target: candidate.target,
        question: candidate.question,
      );
    }).toList());
    final severity = response == 'improved'
        ? const SeverityChangeModel(from: 'moderate', to: 'early')
        : const SeverityChangeModel(from: 'moderate', to: 'moderate');
    await _store.addTimelineEvent(TimelineEventModel(
      id: 'tl_demo_followup_${DateTime.now().millisecondsSinceEpoch}',
      type: 'follow_up',
      title: 'Follow-up response recorded',
      description: 'Tomato Early Blight follow-up marked $response.',
      timestamp: DateTime.now().toUtc().toIso8601String(),
      problemId: item.problemId,
      severity: severity.to,
    ));
    return FollowUpResultModel(
      problemId: item.problemId,
      severityChange: severity,
      health: const HealthModel(
        sentence: 'Tomato crop health is under active monitoring.',
        trend: 'improving',
      ),
      escalated: response == 'got_worse',
      caseId: response == 'got_worse' ? 'CASE-TN-2026-0984' : null,
    );
  }
}

class DemoTimelineRepository implements TimelineRepository {
  final DemoStore _store;

  DemoTimelineRepository({required DemoStore store}) : _store = store;

  @override
  Future<TimelineResponse> getTimeline({
    required String farmId,
    int limit = 20,
    String? cursor,
  }) async {
    await _demoDelay('timeline');
    final events = await _store.getTimeline();
    return TimelineResponse(events: events.take(limit).toList());
  }
}

class DemoProblemRepository implements ProblemRepository {
  final DemoStore _store;

  DemoProblemRepository({required DemoStore store}) : _store = store;

  @override
  Future<ProblemsResponse> getProblems({
    required String farmId,
    String? status,
    String? type,
    int limit = 20,
    String? cursor,
  }) async {
    await _demoDelay('problems');
    final problem = (await _store.getProblemDetail()).problem;
    final matchesStatus = status == null || status == problem.status;
    final matchesType = type == null || type == problem.problemType;
    return ProblemsResponse(
      problems: matchesStatus && matchesType ? [problem] : const [],
    );
  }

  @override
  Future<ProblemDetailModel> getProblemDetail(String problemId) async {
    await _demoDelay('problems');
    return _store.getProblemDetail();
  }

  @override
  Future<EscalationModel> escalateProblem(String problemId) async {
    await _demoDelay('problems');
    return AuditDemoFixtures.escalationResponse.escalation!;
  }
}

class DemoAdvisoryRepository implements AdvisoryRepository {
  @override
  Future<AdvisoryQueryResult> queryAdvisory({
    required String farmId,
    required String queryText,
    String lang = 'mr-IN',
  }) async {
    await _demoDelay('advisory');
    final diagnosis = AuditDemoFixtures.earlyBlightDiagnosis;
    return AdvisoryQueryResult(
      retrieved: true,
      advisory: diagnosis.advisory,
      citations: diagnosis.citations,
      spokenSummary:
          'Check field drainage, avoid unnecessary irrigation, inspect leaves for fungal symptoms, and monitor standing water around the crop.',
    );
  }
}

class DemoVoiceRepository implements VoiceRepository {
  @override
  Future<VoiceTranscribeResult> transcribe({
    required String assetId,
    String lang = 'mr-IN',
    String? context,
  }) async {
    await _demoDelay('voice');
    return VoiceTranscribeResult(
      text: 'Why are the leaves of my tomato plant turning yellow?',
      confidence: 0.96,
      lang: lang,
      needsConfirmation: false,
    );
  }

  @override
  Future<VoiceSynthesizeResult> synthesize({
    required String text,
    String lang = 'mr-IN',
  }) async {
    await _demoDelay('voice');
    // Empty deliberately means the UI displays its local text fallback without
    // attempting a network audio URL in offline APKs.
    return const VoiceSynthesizeResult(audioUrl: '', expiresIn: 0);
  }
}

class DemoLabelCheckRepository implements LabelCheckRepository {
  @override
  Future<LabelCheckResponse> checkLabel({
    required String problemId,
    required String imageAssetId,
    int? daysToHarvest,
  }) async {
    await _demoDelay('label_check');
    return const LabelCheckResponse(
      extracted: LabelExtractModel(
        activeIngredient: 'Mancozeb',
        concentration: '75%',
        formulation: 'WP',
        ocrConfidence: 0.94,
      ),
      verdict: LabelVerdictModel(
        code: 'NO_OBJECTION_FOUND',
        message: 'No objection found. Follow the printed label for dosage.',
      ),
      spokenSummary: 'The label was read successfully. Follow its printed dosage and safety instructions.',
    );
  }
}

class DemoHealthRepository implements HealthRepository {
  @override
  Future<SystemHealthModel> getHealth() async {
    await _demoDelay('health');
    return const SystemHealthModel(
      status: 'ok',
      version: 'demo-local',
      visionModel: 'mock',
      isStub: false,
    );
  }
}

class DemoReferralRepository implements ReferralRepository {
  @override
  Future<ReferralsResponse> getReferrals(String farmId) async {
    await _demoDelay('referrals');
    return AuditDemoFixtures.referrals;
  }
}
