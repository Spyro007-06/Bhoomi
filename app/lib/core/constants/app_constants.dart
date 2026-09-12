/// Frozen wire enums, gate constants, and verbatim verdict strings for Bhoomi v2.
/// Reference: docs/API_CONTRACT.md and docs/DESIGN.md.
abstract final class AppConstants {
  // Gate Threshold Constants (docs/DESIGN.md §6)
  static const double gateThreshold = 0.70;
  static const double floorThreshold = 0.45;
  static const double marginThreshold = 0.15;

  // Gate Outcomes (API_CONTRACT §1)
  static const String outcomeAdvise = 'advise';
  static const String outcomeClarify = 'clarify';
  static const String outcomeEscalate = 'escalate';

  // Gate Reason Codes (API_CONTRACT §1)
  static const String reasonAboveGate = 'ABOVE_GATE';
  static const String reasonAmbiguous = 'AMBIGUOUS';
  static const String reasonBelowFloor = 'BELOW_FLOOR';
  static const String reasonOutOfScope = 'OUT_OF_SCOPE';
  static const String reasonNoRelevantSource = 'NO_RELEVANT_SOURCE';

  // Fixed Server Verdict Strings (docs/DESIGN.md §9, API_CONTRACT §9)
  // Non-negotiable: Rendered verbatim. No string contains "safe" or endorsement phrasing.
  static const Map<String, String> verdictMessages = {
    'NO_OBJECTION_FOUND':
        'No objection found. Follow the printed label for dosage.',
    'NOT_REGISTERED_FOR_TARGET':
        'This product is not registered for this pest. Do not use it here.',
    'WRONG_CROP': 'This product is not registered for paddy.',
    'WRONG_CLASS': 'This is a fungicide. Your problem is an insect pest.',
    'PHI_CONFLICT':
        'Harvest is too close. This product needs more days before harvest.',
    'NOT_IN_RECORDS':
        'I do not have a record of this product. Ask an expert before using it.',
  };

  // Supported Locales
  static const String langMarathi = 'mr-IN';
  static const String langHindi = 'hi-IN';
  static const String langEnglish = 'en-IN';

  // Target Labels display mapping
  static const Map<String, Map<String, String>> targetDisplayNames = {
    'blast': {
      'en': 'Paddy Blast',
      'mr': 'भातावरील करपा',
      'hi': 'धान का झुलसा रोग',
    },
    'brown_spot': {
      'en': 'Brown Spot',
      'mr': 'तपकिरी ठिपके',
      'hi': 'भूरा धब्बा रोग',
    },
    'bacterial_leaf_blight': {
      'en': 'Bacterial Leaf Blight (BLB)',
      'mr': 'जीवाणूजन्य करपा',
      'hi': 'जीवाणु पत्ती झुलसा',
    },
    'sheath_blight': {
      'en': 'Sheath Blight',
      'mr': 'पर्णकोष करपा',
      'hi': 'शीथ ब्लाइट',
    },
    'false_smut': {
      'en': 'False Smut',
      'mr': 'काजळी रोग',
      'hi': 'झूठा कंड',
    },
    'yellow_stem_borer': {
      'en': 'Yellow Stem Borer',
      'mr': 'खोडकिडा',
      'hi': 'तने का पीला छेदक',
    },
    'stem_borer': {
      'en': 'Stem Borer',
      'mr': 'खोडकिडा',
      'hi': 'तना छेदक',
    },
    'brown_planthopper': {
      'en': 'Brown Planthopper (BPH)',
      'mr': 'तुडतुडे (तपकिरी मावा)',
      'hi': 'भूरा माहू / फुदका',
    },
    'leaf_folder': {
      'en': 'Leaf Folder',
      'mr': 'पाने गुंडाळणारी अळी',
      'hi': 'पत्ता लपेटक कीट',
    },
    'gall_midge': {
      'en': 'Gall Midge',
      'mr': 'गादमाशी',
      'hi': 'गाल मिज',
    },
    'early_blight': {
      'en': 'Early Blight',
      'mr': 'अर्ली ब्लाइट (करपा)',
      'hi': 'अगेती झुलसा',
    },
    'late_blight': {
      'en': 'Late Blight',
      'mr': 'लेट ब्लाइट (करपा)',
      'hi': 'पछेती झुलसा',
    },
    'septoria_leaf_spot': {
      'en': 'Septoria Leaf Spot',
      'mr': 'सेप्टोरिया पानांवरील ठिपके',
      'hi': 'सेप्टोरिया पत्ती धब्बा',
    },
    'fruit_borer': {
      'en': 'Fruit Borer',
      'mr': 'फळ पोखरणारी अळी',
      'hi': 'फल छेदक कीट',
    },
    'heavy_rainfall': {
      'en': 'Heavy Rainfall',
      'mr': 'मुसळधार पाऊस',
      'hi': 'भारी वर्षा',
    },
    'treatment': {
      'en': 'Crop Treatment',
      'mr': 'पीक उपचार',
      'hi': 'फसल उपचार',
    },
  };

  /// Safely resolves a raw backend identifier into a farmer-friendly localized display string.
  /// Never exposes raw snake_case or raw English technical identifiers without proper mapping.
  static String getLocalizedTarget(String? rawTarget, {String lang = 'mr'}) {
    if (rawTarget == null || rawTarget.isEmpty) {
      switch (lang) {
        case 'hi':
          return 'फसल की समस्या';
        case 'en':
          return 'Crop Issue';
        default:
          return 'पिकाची समस्या';
      }
    }

    final lower = rawTarget.toLowerCase().trim();

    // Check specific substring matches first (e.g. 'Early Blight (Alternaria solani)' or 'early_blight')
    if (lower.contains('early_blight') || lower.contains('early blight') || lower.contains('alternaria')) {
      final entry = targetDisplayNames['early_blight'];
      if (entry != null && entry.containsKey(lang)) return entry[lang]!;
    }
    if (lower.contains('late_blight') || lower.contains('late blight') || lower.contains('phytophthora')) {
      final entry = targetDisplayNames['late_blight'];
      if (entry != null && entry.containsKey(lang)) return entry[lang]!;
    }
    if (lower.contains('septoria')) {
      final entry = targetDisplayNames['septoria_leaf_spot'];
      if (entry != null && entry.containsKey(lang)) return entry[lang]!;
    }
    if (lower.contains('fruit_borer') || lower.contains('fruit borer')) {
      final entry = targetDisplayNames['fruit_borer'];
      if (entry != null && entry.containsKey(lang)) return entry[lang]!;
    }
    if (lower.contains('heavy_rainfall') || lower.contains('heavy rainfall') || lower.contains('rain')) {
      final entry = targetDisplayNames['heavy_rainfall'];
      if (entry != null && entry.containsKey(lang)) return entry[lang]!;
    }
    if (lower.contains('blast')) {
      final entry = targetDisplayNames['blast'];
      if (entry != null && entry.containsKey(lang)) return entry[lang]!;
    }
    if (lower.contains('brown_spot') || lower.contains('brown spot')) {
      final entry = targetDisplayNames['brown_spot'];
      if (entry != null && entry.containsKey(lang)) return entry[lang]!;
    }

    final normalized = lower.replaceAll(' ', '_');
    final entry = targetDisplayNames[normalized];
    if (entry != null && entry.containsKey(lang)) {
      return entry[lang]!;
    }
    if (entry != null && entry.containsKey('mr')) {
      return entry['mr']!;
    }

    // If string already contains localized Devanagari text, keep it
    final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(rawTarget);
    if (hasDevanagari) {
      if (lang == 'mr' || lang == 'hi') {
        // Strip English brackets if present, e.g. "Paddy Blast (भातावरील करपा)" -> "भातावरील करपा"
        final bracketMatch = RegExp(r'\(([\u0900-\u097F\s]+)\)').firstMatch(rawTarget);
        if (bracketMatch != null) {
          return bracketMatch.group(1)!.trim();
        }
      }
      return rawTarget;
    }

    // Clean word-case fallback without raw underscores
    final words = rawTarget
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
    return words.isNotEmpty ? words : (lang == 'mr' ? 'पिकाची समस्या' : (lang == 'hi' ? 'फसल की समस्या' : 'Crop Issue'));
  }
}
