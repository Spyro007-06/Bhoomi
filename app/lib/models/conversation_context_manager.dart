import 'inspection_target.dart';

/// Structured Active Context capturing semantic details of the farmer's current conversation.
class FarmerConversationContext {
  String? activeCrop;
  String? currentIssue;
  String? diagnosisSummary;
  InspectionTarget inspectionTarget;
  String? advisoryTopic;
  final List<String> boundedTurns;

  FarmerConversationContext({
    this.activeCrop,
    this.currentIssue,
    this.diagnosisSummary,
    this.inspectionTarget = InspectionTarget.unknown,
    this.advisoryTopic,
    List<String>? boundedTurns,
  }) : boundedTurns = boundedTurns != null ? List.from(boundedTurns) : [];

  /// Factory creating context from an initial string or query.
  factory FarmerConversationContext.fromInitial(String? initial) {
    final ctx = FarmerConversationContext();
    if (initial != null && initial.trim().isNotEmpty) {
      ctx.processTurn(initial.trim());
    }
    return ctx;
  }

  /// Known crop keywords mapped to standard canonical names across Marathi, Hindi, and English.
  static const Map<String, List<String>> cropKeywords = {
    'soybean': ['soybean', 'soya', 'सोयाबीन'],
    'cotton': ['cotton', 'कापूस', 'कापसा', 'कपास'],
    'paddy': ['paddy', 'rice', 'भात', 'भाता', 'धान', 'तांदूळ', 'तांदळा', 'चावल'],
    'wheat': ['wheat', 'गहू', 'गव्हा', 'गेहूं'],
    'tomato': ['tomato', 'टोमॅटो', 'टमाटर'],
    'onion': ['onion', 'कांदा', 'कांद्या', 'प्याज'],
    'chilli': ['chilli', 'chili', 'pepper', 'मिरची', 'मिरच्या', 'मिर्च'],
    'sugarcane': ['sugarcane', 'cane', 'ऊस', 'उसा', 'गन्ना'],
    'maize': ['maize', 'corn', 'मका', 'मक्या', 'मक्का'],
    'gram': ['gram', 'chana', 'हरभरा', 'हरभऱ्या', 'चना', 'चने'],
    'groundnut': ['groundnut', 'peanut', 'भुईमूग', 'भुईमुगा', 'मूंगफली'],
  };

  /// Explicit transition phrases indicating the farmer wants to SWITCH to a different crop.
  static const List<String> explicitSwitchPhrases = [
    'now tell me about',
    'switch to',
    'let\'s talk about',
    'what about',
    'how about',
    'now check my',
    'now for',
    'आता मला',
    'बद्दल सांगा',
    'विषयी सांगा',
    'विषयी बोला',
    'आता माझे',
    'आता पाहू',
    'अब मुझे',
    'के बारे में बताओ',
    'पर बात करते हैं',
    'अब मेरी',
    'अब देखो',
  ];

  /// Comparison phrases indicating the query is comparing or asking about disease spread across crops.
  static const List<String> comparisonPhrases = [
    'also affect',
    'spread to',
    'in both',
    'compared to',
    'and also',
    'तुलना',
    'वर पण',
    'वर सुद्धा',
    'पसरतो का',
    'तसेच',
    'पर भी',
    'में भी',
    'फैलता है क्या',
    'तुलना में',
  ];

  /// Common agricultural issue keywords to detect and store semantically.
  static const Map<String, List<String>> issueKeywords = {
    'leaf spots': ['spot', 'spots', 'blight', 'डाग', 'ठिपके', 'धब्बे', 'करपा'],
    'yellowing': ['yellow', 'yellowing', 'पिवळे', 'पिवळेपणा', 'पीला', 'पीले'],
    'pest attack': ['insect', 'pest', 'worm', 'caterpillar', 'कीड', 'किडा', 'किडे', 'अळी', 'कीट', 'कीड़े', 'इल्ली'],
    'wilting': ['wilt', 'wilting', 'वाळणे', 'सुका', 'मुरझाना', 'मुरझा'],
    'fruit rot': ['rot', 'rotting', 'कुजणे', 'सडन', 'सड़ना'],
    'rust': ['rust', 'तांबेरा', 'गेरुआ', 'रतुआ'],
  };

  /// Processes a new turn uttered by the farmer, updating active crop, issue, target, and bounded turns safely.
  void processTurn(String turnText) {
    final trimmed = turnText.trim();
    if (trimmed.isEmpty) return;

    final lower = trimmed.toLowerCase();

    // 1. Detect all crops mentioned in this turn
    final mentionedCrops = <String>[];
    for (final entry in cropKeywords.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) {
          mentionedCrops.add(entry.key);
          break;
        }
      }
    }

    // 2. Determine crop switching behavior
    if (mentionedCrops.isNotEmpty) {
      if (activeCrop == null) {
        // First crop mentioned becomes active crop
        activeCrop = mentionedCrops.first;
      } else if (mentionedCrops.length == 1 && mentionedCrops.first != activeCrop) {
        final newCrop = mentionedCrops.first;
        final isExplicitSwitch = explicitSwitchPhrases.any((phrase) => lower.contains(phrase));
        final isComparison = comparisonPhrases.any((phrase) => lower.contains(phrase));

        final isNewCropDeclaration = lower.contains('my $newCrop') ||
            lower.contains('in $newCrop') ||
            lower.contains('for $newCrop') ||
            lower.contains('$newCrop crop') ||
            lower.contains('माझे $newCrop') ||
            lower.contains('माझ्या $newCrop') ||
            lower.contains('मेरी $newCrop') ||
            lower.contains('मेरे $newCrop');

        if ((isExplicitSwitch || isNewCropDeclaration) && !isComparison) {
          // Explicit crop switch: purge old issue, diagnosis, and turns
          activeCrop = newCrop;
          currentIssue = null;
          diagnosisSummary = null;
          inspectionTarget = InspectionTarget.unknown;
          advisoryTopic = null;
          boundedTurns.clear();
        }
        // If it's a comparison or general mention without switch phrasing, keep activeCrop intact!
      } else if (mentionedCrops.length > 1) {
        // Multiple crops mentioned in one utterance (e.g., "My farm has soybean and cotton")
        // If no active crop yet, pick first; otherwise keep existing activeCrop
        activeCrop ??= mentionedCrops.first;
      }
    }

    // 3. Detect issue keywords in this turn
    for (final entry in issueKeywords.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) {
          currentIssue = entry.key;
          break;
        }
      }
    }

    // 4. Update inspection target if target cues exist
    final resolved = InspectionTarget.resolveFromQuery(trimmed);
    if (resolved != InspectionTarget.unknown) {
      inspectionTarget = resolved;
    }

    // 5. Append to bounded recent turns (max 3 turns sliding window)
    if (boundedTurns.isEmpty || boundedTurns.last != trimmed) {
      boundedTurns.add(trimmed);
      if (boundedTurns.length > 3) {
        boundedTurns.removeAt(0);
      }
    }
  }

  /// Sets diagnosis result after analysis
  void recordDiagnosis({
    required String diagnosis,
    String? issue,
    InspectionTarget? target,
    String? advice,
  }) {
    diagnosisSummary = diagnosis;
    if (issue != null) currentIssue = issue;
    if (target != null) inspectionTarget = target;
    if (advice != null) advisoryTopic = advice;
  }

  /// Assembles the complete context string combining structured context and recent turns.
  String toContextString() {
    final parts = <String>[];

    if (activeCrop != null) {
      parts.add('Crop: $activeCrop');
    }
    if (currentIssue != null) {
      parts.add('Issue: $currentIssue');
    }
    if (diagnosisSummary != null) {
      parts.add('Diagnosis: $diagnosisSummary');
    }
    if (inspectionTarget != InspectionTarget.unknown) {
      parts.add('Target: ${inspectionTarget.name}');
    }

    final structuredHeader = parts.isNotEmpty ? '[${parts.join(', ')}]' : '';
    final turnsHistory = boundedTurns.join(' -> ');

    if (structuredHeader.isNotEmpty && turnsHistory.isNotEmpty) {
      return '$structuredHeader $turnsHistory';
    } else if (structuredHeader.isNotEmpty) {
      return structuredHeader;
    } else {
      return turnsHistory;
    }
  }

  @override
  String toString() => toContextString();
}
