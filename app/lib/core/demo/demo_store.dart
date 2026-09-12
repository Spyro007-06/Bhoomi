import 'dart:convert';

import '../../models/alert_models.dart';
import '../../models/farm_models.dart';
import '../../models/farmer_profile_models.dart';
import '../../models/followup_models.dart';
import '../../models/problem_models.dart';
import '../../models/timeline_models.dart';
import '../constants/audit_demo_fixtures.dart';
import '../storage/secure_storage.dart';

/// Small persistent local database used only by the Demo repository set.
///
/// It stores existing wire models as JSON, allowing demo interactions to
/// survive restarts without creating a second model hierarchy or touching the
/// production API client.
class DemoStore {
  static const _farmKey = 'bhoomi_demo_farm';
  static const _profileKey = 'bhoomi_demo_profile';
  static const _alertsKey = 'bhoomi_demo_alerts';
  static const _followUpsKey = 'bhoomi_demo_followups';
  static const _timelineKey = 'bhoomi_demo_timeline';
  static const _problemDetailKey = 'bhoomi_demo_problem_detail';

  final SecureStorage _storage;

  DemoStore({required SecureStorage storage}) : _storage = storage;

  Future<void> ensureSeeded() async {
    await _writeIfMissing(_farmKey, AuditDemoFixtures.farm.toJson());
    await _writeIfMissing(_profileKey, AuditDemoFixtures.farmerProfile.toJson());
    await _writeIfMissing(
      _alertsKey,
      AuditDemoFixtures.riskAlerts.map((alert) => alert.toJson()).toList(),
    );
    await _writeIfMissing(
      _followUpsKey,
      AuditDemoFixtures.pendingFollowUps.map((item) => item.toJson()).toList(),
    );
    await _writeIfMissing(
      _timelineKey,
      AuditDemoFixtures.timelineEvents.map((event) => event.toJson()).toList(),
    );
    await _writeIfMissing(_problemDetailKey, AuditDemoFixtures.problemDetail.toJson());
  }

  /// Restores only the demo records. The current login remains valid so a
  /// presenter can reset a walkthrough without re-entering credentials.
  Future<void> reset() async {
    for (final key in [
      _farmKey,
      _profileKey,
      _alertsKey,
      _followUpsKey,
      _timelineKey,
      _problemDetailKey,
    ]) {
      await _storage.delete(key: key);
    }
    await ensureSeeded();
  }

  Future<FarmModel> getFarm() async {
    await ensureSeeded();
    return FarmModel.fromJson(await _readMap(_farmKey));
  }

  Future<void> saveFarm(FarmModel farm) => _write(_farmKey, farm.toJson());

  Future<FarmerProfile> getProfile() async {
    await ensureSeeded();
    return FarmerProfile.fromJson(await _readMap(_profileKey));
  }

  Future<void> saveProfile(FarmerProfile profile) =>
      _write(_profileKey, profile.toJson());

  Future<List<AlertModel>> getAlerts() async {
    await ensureSeeded();
    return _readList(_alertsKey, AlertModel.fromJson);
  }

  Future<void> saveAlerts(List<AlertModel> alerts) =>
      _write(_alertsKey, alerts.map((item) => item.toJson()).toList());

  Future<List<FollowUpModel>> getFollowUps() async {
    await ensureSeeded();
    return _readList(_followUpsKey, FollowUpModel.fromJson);
  }

  Future<void> saveFollowUps(List<FollowUpModel> followUps) =>
      _write(_followUpsKey, followUps.map((item) => item.toJson()).toList());

  Future<List<TimelineEventModel>> getTimeline() async {
    await ensureSeeded();
    return _readList(_timelineKey, TimelineEventModel.fromJson);
  }

  Future<void> addTimelineEvent(TimelineEventModel event) async {
    final events = await getTimeline();
    await _write(
      _timelineKey,
      [event, ...events].map((item) => item.toJson()).toList(),
    );
  }

  Future<ProblemDetailModel> getProblemDetail() async {
    await ensureSeeded();
    return ProblemDetailModel.fromJson(await _readMap(_problemDetailKey));
  }

  Future<void> recordDoubtDoctorAnswer({
    required String cueId,
    required String answer,
  }) async {
    final detail = await getProblemDetail();
    final observations = [
      ...detail.observations,
      ObservationModel(
        id: 'obs_demo_${DateTime.now().millisecondsSinceEpoch}',
        problemId: detail.id,
        kind: 'doubt_doctor',
        question: AuditDemoFixtures.doubtDoctorClarification.clarification!.question,
        answer: answer,
        cueId: cueId,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    ];
    final updated = ProblemDetailModel(
      problem: detail.problem,
      observations: observations,
      advisory: detail.advisory,
      imageUrls: detail.imageUrls,
      escalation: detail.escalation,
    );
    await _write(_problemDetailKey, updated.toJson());
    await addTimelineEvent(
      TimelineEventModel(
        id: 'tl_demo_doubt_${DateTime.now().millisecondsSinceEpoch}',
        type: 'observation',
        title: 'Doubt Doctor clarification completed',
        description: 'Field observation recorded for Tomato Early Blight.',
        timestamp: DateTime.now().toUtc().toIso8601String(),
        problemId: detail.id,
        severity: detail.severity,
      ),
    );
  }

  Future<void> _writeIfMissing(String key, Object value) async {
    final existing = await _storage.read(key: key);
    if (existing == null || existing.isEmpty) {
      await _write(key, value);
    }
  }

  Future<void> _write(String key, Object value) =>
      _storage.write(key: key, value: jsonEncode(value));

  Future<Map<String, dynamic>> _readMap(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) {
      throw StateError('Missing demo record: $key');
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<List<T>> _readList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) return const [];
    final value = jsonDecode(raw) as List<dynamic>;
    return value
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
