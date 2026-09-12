import '../../models/auth_models.dart';
import '../../models/farm_models.dart';
import '../../models/farmer_profile_models.dart';
import '../../models/alert_models.dart';
import '../../models/followup_models.dart';
import '../../models/timeline_models.dart';
import '../../models/referral_models.dart';
import '../../models/diagnosis_models.dart';
import '../../models/gate_models.dart';
import '../../models/advisory_models.dart';
import '../../models/problem_models.dart';

/// Centralized realistic mock fixtures for the Bhoomi visual audit.
/// Strictly adheres to the evaluation requirements:
/// - Farmer: Arun Kumar (9876543210, Tamil Nadu, English)
/// - Farm: Green Valley Farm (4.5 acres, Red loamy soil, Drip irrigation, Tamil Nadu)
/// - Crops: Tomato, Paddy, Banana, Chilli, Groundnut
/// - Diagnosis: Tomato / Early Blight (92% confidence)
abstract final class AuditDemoFixtures {
  // Farmer Identity
  static const UserModel farmerUser = UserModel(
    id: 'u_arun_01',
    phone: '+919876543210',
    name: 'Arun Kumar',
    role: 'farmer',
  );

  // Farmer Profile
  static final FarmerProfile farmerProfile = FarmerProfile(
    farmerId: 'u_arun_01',
    name: 'Arun Kumar',
    mobileNumber: '+919876543210',
    farmId: 'f_green_valley',
    farmName: 'Green Valley Farm',
    farmArea: 4.5,
    farmAreaUnit: 'Acres',
    crops: const ['tomato', 'paddy', 'banana', 'chilli', 'groundnut'],
    currentCrop: 'tomato',
    variety: 'Arka Rakshak',
    growthStage: 'flowering',
    soilType: 'red_loamy',
    irrigationType: 'drip',
    sowingDate: DateTime(2026, 7, 15),
    region: 'Tamil Nadu',
    latitude: 11.1271,
    longitude: 78.6569,
    preferredLanguage: 'en',
    updatedAt: DateTime(2026, 9, 1),
  );

  // Farm Model
  static const FarmModel farm = FarmModel(
    id: 'f_green_valley',
    crop: 'tomato',
    variety: 'Arka Rakshak',
    growthStage: 'flowering',
    region: 'Tamil Nadu',
    location: GeoPoint(
      lat: 11.1271,
      lng: 78.6569,
    ),
  );

  // Farm Summary
  static const FarmSummaryModel farmSummary = FarmSummaryModel(
    farm: farm,
    health: HealthModel(
      sentence: 'Field health is stable with targeted monitoring for Early Blight.',
      trend: 'stable',
    ),
    activeProblemsCount: 1,
    pendingFollowUpsCount: 1,
    activeAlertsCount: 3,
  );

  // Crop Diagnosis Response (High Confidence - 92% Early Blight)
  static const DiagnoseResponse earlyBlightDiagnosis = DiagnoseResponse(
    gate: GateDecision(
      outcome: 'advise',
      confidence: 0.92,
      thresholdApplied: 0.70,
      reasonCode: 'ABOVE_GATE',
      alternatives: [
        Prediction(label: 'early_blight', confidence: 0.92),
        Prediction(label: 'septoria_leaf_spot', confidence: 0.08),
      ],
      isStub: false,
    ),
    problemId: 'p_tomato_blight_01',
    problemType: 'disease',
    diagnosis: DiagnosisDetail(
      label: 'Early Blight (Alternaria solani)',
      severity: 'moderate',
      confidence: 0.92,
    ),
    advisory: AdvisoryModel(
      possibleIssue: 'Early Blight (Alternaria solani)',
      whatToAvoid: 'Avoid overhead sprinkler irrigation and excessive chemical nitrogen fertilization which accelerates fungal spread.',
      whatToCheck: 'Check lower foliage for brown circular spots with concentric target rings and yellow halo borders.',
      ladder: [
        LadderRungModel(
          tier: 'cultural',
          action: 'Cultural: Remove and safely dispose of infected lower leaves. Ensure 60cm row spacing for adequate air circulation.',
          dosage: 'N/A',
        ),
        LadderRungModel(
          tier: 'biological',
          action: 'Biological: Spray Trichoderma harzianum or Bacillus subtilis suspension on foliage during early morning.',
          dosage: '5g / Litre water',
        ),
        LadderRungModel(
          tier: 'chemical',
          action: 'Chemical: Foliar spray of Copper Oxychloride 50% WP or Mancozeb 75% WP targeted at lower leaf undersides.',
          dosage: '2.5g / Litre water',
          phiDays: 7,
          reentryHours: 24,
        ),
      ],
    ),
    citations: [
      CitationModel(
        docId: 'TNAU-CPPS-TOM-04',
        title: 'Tamil Nadu Agricultural University — Integrated Disease Management in Tomato',
        reviewedOn: '2026-06-15',
      ),
      CitationModel(
        docId: 'ICAR-IIHR-EB-12',
        title: 'ICAR-IIHR Technical Bulletin: Management of Alternaria solani in Solanaceous Crops',
        reviewedOn: '2026-05-20',
      ),
    ],
    spokenSummary: 'Early blight detected on Tomato with 92% confidence. Remove infected lower leaves and apply recommended bio-fungicide spray.',
  );

  // Doubt Doctor Clarification Response
  static const DiagnoseResponse doubtDoctorClarification = DiagnoseResponse(
    gate: GateDecision(
      outcome: 'clarify',
      confidence: 0.58,
      thresholdApplied: 0.20,
      reasonCode: 'AMBIGUOUS_SYMPTOMS',
      alternatives: [
        Prediction(label: 'early_blight', confidence: 0.58),
        Prediction(label: 'late_blight', confidence: 0.52),
      ],
      isStub: false,
    ),
    problemId: 'p_tomato_clarify_01',
    clarification: ClarificationModel(
      cueId: 'cue_tomato_leaf_spots_01',
      question: 'Are the brown spots mainly appearing on the older lower leaves?',
      questionLocalized: 'तपकिरी डाग प्रामुख्याने जुन्या खालच्या पानांवर दिसत आहेत का?',
      candidates: [
        CandidateModel(
          label: 'early_blight',
          signature: 'Concentric dark rings (target spots) primarily on older lower leaves',
        ),
        CandidateModel(
          label: 'septoria_leaf_spot',
          signature: 'Small circular spots with grey centres and dark margins across canopy',
        ),
      ],
      answers: [
        'yes',
        'no',
        'unknown',
      ],
    ),
  );

  // Escalation Response
  static const DiagnoseResponse escalationResponse = DiagnoseResponse(
    gate: GateDecision(
      outcome: 'escalate',
      confidence: 0.41,
      thresholdApplied: 0.70,
      reasonCode: 'LOW_CONFIDENCE_NOVEL_SYMPTOM',
      alternatives: [],
      isStub: false,
    ),
    problemId: 'p_tomato_esc_01',
    escalation: EscalationModel(
      caseId: 'CASE-TN-2026-0984',
      status: 'assigned',
      assignedTo: 'Krishi Vigyan Kendra (KVK) Plant Pathology Panel',
      etaMinutes: 240,
      queuePosition: 2,
    ),
    spokenSummary: 'Case escalated to Krishi Vigyan Kendra agronomists for expert review. You will receive an update within 4 hours.',
  );

  // Risk Alerts (Heavy rainfall, Pest risk, Disease risk)
  static const List<AlertModel> riskAlerts = [
    AlertModel(
      id: 'alt_rain_01',
      triggerType: 'weather',
      target: 'heavy_rainfall',
      riskLevel: 'high',
      reason: 'heavy_precipitation_forecast',
      inspectionTasks: [
        'Heavy rainfall is expected. Ensure proper field drainage and avoid unnecessary irrigation.',
        'Open drainage trenches at field boundaries to prevent standing water.',
      ],
      issuedAt: '2026-09-12T06:00:00Z',
      spokenSummary: 'Heavy rainfall is expected. Ensure proper field drainage and avoid unnecessary irrigation.',
      farmId: 'f_green_valley',
    ),
    AlertModel(
      id: 'alt_disease_02',
      triggerType: 'disease',
      target: 'early_blight',
      riskLevel: 'medium',
      reason: 'favorable_temperature_humidity',
      inspectionTasks: [
        'High humidity may increase fungal disease risk in tomato crops.',
        'Check bottom canopy foliage for yellowing and target ring lesions.',
      ],
      issuedAt: '2026-09-11T09:30:00Z',
      spokenSummary: 'High humidity may increase fungal disease risk in tomato crops.',
      farmId: 'f_green_valley',
    ),
    AlertModel(
      id: 'alt_pest_03',
      triggerType: 'pest',
      target: 'fruit_borer',
      riskLevel: 'medium',
      reason: 'fruit_borer_cluster_surge',
      inspectionTasks: [
        'Monitor the underside of leaves for early signs of pest activity.',
        'Inspect flowering nodes and small green tomato fruits for entry pinholes.',
      ],
      issuedAt: '2026-09-10T14:00:00Z',
      spokenSummary: 'Monitor the underside of leaves for early signs of pest activity.',
      farmId: 'f_green_valley',
    ),
  ];

  // Follow-ups
  static const List<FollowUpModel> pendingFollowUps = [
    FollowUpModel(
      id: 'fu_tomato_01',
      problemId: 'p_tomato_blight_01',
      dueAt: '2026-09-17T10:00:00Z',
      target: 'early_blight',
      question: 'Check leaf spread after 7 days: have new lesions stopped appearing on younger leaves?',
      farmId: 'f_green_valley',
    ),
  ];

  // Timeline Events — pre-populated so History is meaningful before the
  // presenter performs a new diagnosis.
  static const List<TimelineEventModel> timelineEvents = [
    TimelineEventModel(
      id: 'tl_audit_00',
      type: 'diagnosis',
      title: 'Crop image submitted',
      description: 'Tomato leaf photo submitted for crop health analysis.',
      timestamp: '2026-09-10T08:00:00Z',
      problemId: 'p_tomato_blight_01',
      severity: 'moderate',
    ),
    TimelineEventModel(
      id: 'tl_audit_01',
      type: 'advisory',
      title: 'Treatment recommendation generated',
      description: 'Cultural pruning and Trichoderma application recommended for Early Blight.',
      timestamp: '2026-09-10T08:30:00Z',
      problemId: 'p_tomato_blight_01',
      severity: 'moderate',
    ),
    TimelineEventModel(
      id: 'tl_audit_02',
      type: 'diagnosis',
      title: 'Early Blight detected',
      description: 'High confidence detection (92%) of Early Blight (Alternaria solani) on Tomato foliage.',
      timestamp: '2026-09-10T08:15:00Z',
      problemId: 'p_tomato_blight_01',
      severity: 'moderate',
    ),
    TimelineEventModel(
      id: 'tl_audit_03',
      type: 'observation',
      title: 'Doubt Doctor clarification completed',
      description: 'Older lower-leaf symptoms confirmed for Tomato Early Blight.',
      timestamp: '2026-09-11T09:30:00Z',
      problemId: 'p_tomato_blight_01',
      severity: 'moderate',
    ),
    TimelineEventModel(
      id: 'tl_audit_04',
      type: 'follow_up',
      title: 'Field Follow-Up Scheduled',
      description: 'Scheduled post-treatment recovery verification for September 17.',
      timestamp: '2026-09-17T10:00:00Z',
      problemId: 'p_tomato_blight_01',
      severity: 'moderate',
    ),
  ];

  // Problem Detail Model
  static final ProblemDetailModel problemDetail = ProblemDetailModel(
    problem: const ProblemModel(
      id: 'p_tomato_blight_01',
      farmId: 'f_green_valley',
      problemType: 'disease',
      label: 'Early Blight (Alternaria solani)',
      severity: 'moderate',
      status: 'open',
      openedAt: '2026-09-10T08:15:00Z',
    ),
    advisory: earlyBlightDiagnosis.advisory,
    observations: const [
      ObservationModel(
        id: 'obs_01',
        problemId: 'p_tomato_blight_01',
        kind: 'field_observation',
        question: 'Concentric rings present on lower foliage?',
        answer: 'yes',
        createdAt: '2026-09-12T08:20:00Z',
      ),
    ],
    imageUrls: const [
      'assets/images/crop_tomato_early_blight.jpg',
    ],
  );

  // Referrals Directory
  static final ReferralsResponse referrals = ReferralsResponse(
    helpline: '1800-180-1551',
    kvk: const ReferralModel(
      kind: 'kvk',
      name: 'Krishi Vigyan Kendra (Tamil Nadu Agricultural University)',
      phone: '0422-6611200',
      address: 'TNAU Campus, Lawley Road, Coimbatore, Tamil Nadu - 641003',
      distanceKm: 3.2,
      acceptsSamples: true,
    ),
    districtLabs: const [
      ReferralModel(
        kind: 'lab',
        name: 'District Plant Health Clinic & Soil Testing Lab',
        phone: '0422-2438711',
        address: 'Department of Agriculture Complex, State Seeds Farm, Tamil Nadu',
        distanceKm: 5.8,
        acceptsSamples: true,
      ),
      ReferralModel(
        kind: 'lab',
        name: 'Regional Biological Control Laboratory',
        phone: '0422-2554900',
        address: 'Agricultural Research Station, Tamil Nadu',
        distanceKm: 9.4,
        acceptsSamples: true,
      ),
    ],
  );
}
