import '../constants/app_constants.dart';

/// Multi-language localization dictionary for Bhoomi Farmer App.
/// Supports Marathi (Primary - mr-IN), Hindi (hi-IN), and Indian English (en-IN).

enum AppLanguage {
  marathi('mr', 'मराठी'),
  hindi('hi', 'हिंदी'),
  english('en', 'English');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);

  String get localeIdentifier => '$code-IN';
  bool get isMarathi => this == AppLanguage.marathi;
  bool get isHindi => this == AppLanguage.hindi;
  bool get isEnglish => this == AppLanguage.english;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.marathi,
    );
  }
}

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  // App Identity
  String get appName => language == AppLanguage.marathi
      ? 'भूमी'
      : (language == AppLanguage.hindi ? 'भूमी' : 'Bhoomi');

  String get appTagline => language == AppLanguage.marathi
      ? 'तुमचा डिजिटल शेती सहाय्यक'
      : (language == AppLanguage.hindi
          ? 'आपका डिजिटल कृषि सहायक'
          : 'Your digital field assistant');

  String get loading => language == AppLanguage.marathi
      ? 'लोड होत आहे...'
      : (language == AppLanguage.hindi ? 'लोड हो रहा है...' : 'Loading...');

  String get demoModeLabel => language == AppLanguage.marathi
      ? 'डेमो मोड'
      : (language == AppLanguage.hindi ? 'डेमो मोड' : 'Demo Mode');

  String get resetDemoData => language == AppLanguage.marathi
      ? 'डेमो माहिती रीसेट करा'
      : (language == AppLanguage.hindi ? 'डेमो डेटा रीसेट करें' : 'Reset Demo Data');

  String get demoOtpHint => language == AppLanguage.marathi
      ? 'डेमोसाठी OTP: 123456'
      : (language == AppLanguage.hindi ? 'डेमो OTP: 123456' : 'Demo OTP: 123456');

  String get demoPhotoButton => language == AppLanguage.marathi
      ? 'डेमो पीक फोटो वापरा'
      : (language == AppLanguage.hindi ? 'डेमो फसल फोटो उपयोग करें' : 'Use Demo Crop Photo');

  // Auth - Phone
  String get welcomeTitle => language == AppLanguage.marathi
      ? 'भूमीमध्ये आपले स्वागत आहे'
      : (language == AppLanguage.hindi
          ? 'भूमी में आपका स्वागत है'
          : 'Welcome to Bhoomi');

  String get phoneSubtitle => language == AppLanguage.marathi
      ? 'सुरू करण्यासाठी आपला मोबाईल नंबर प्रविष्ट करा'
      : (language == AppLanguage.hindi
          ? 'शुरू करने के लिए अपना मोबाइल नंबर दर्ज करें'
          : 'Enter your mobile number to get started');

  String get phoneLabel => language == AppLanguage.marathi
      ? 'मोबाईल नंबर'
      : (language == AppLanguage.hindi ? 'मोबाइल नंबर' : 'Mobile Number');

  String get phoneHint => '98765 43210';

  String get sendOtp => language == AppLanguage.marathi
      ? 'OTP पाठवा'
      : (language == AppLanguage.hindi ? 'OTP भेजें' : 'Send OTP');

  String get invalidPhoneError => language == AppLanguage.marathi
      ? 'कृपया योग्य १० अंकी मोबाईल नंबर टाका'
      : (language == AppLanguage.hindi
          ? 'कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें'
          : 'Please enter a valid 10-digit mobile number');

  // Auth - Demo Mode
  String get tryDemoAccount => language == AppLanguage.marathi
      ? 'डेमो खाते वापरून पहा'
      : (language == AppLanguage.hindi
          ? 'डेमो खाता आज़माएँ'
          : 'Try Demo Account');

  String get demoModalTitle => language == AppLanguage.marathi
      ? '🌾 भूमी डेमो'
      : (language == AppLanguage.hindi ? '🌾 भूमी डेमो' : '🌾 Bhoomi Demo');

  String get demoModalDesc => language == AppLanguage.marathi
      ? 'पूर्व-कॉन्फिगर केलेल्या शेतकरी प्रोफाइलसह भूमी ॲपचा अनुभव घ्या.'
      : (language == AppLanguage.hindi
          ? 'पहले से कॉन्फ़िगर की गई किसान प्रोफ़ाइल के साथ भूमी ऐप का अनुभव करें।'
          : 'Experience the Bhoomi Farmer App using a pre-configured demo farmer.');

  String get demoFarmerNameLabel => language == AppLanguage.marathi
      ? 'शेतकरी: रमेश पाटील'
      : (language == AppLanguage.hindi ? 'किसान: अरुण कुमार' : 'Farmer: Arun Kumar');

  String get demoFarmNameLabel => language == AppLanguage.marathi
      ? 'शेत: डेमो भात शेत'
      : (language == AppLanguage.hindi ? 'खेत: ग्रीन वैली फार्म' : 'Farm: Green Valley Farm');

  String get demoLocationLabel => language == AppLanguage.marathi
      ? 'स्थान: नाशिक, महाराष्ट्र'
      : (language == AppLanguage.hindi ? 'स्थान: तमिल नाडु' : 'Location: Tamil Nadu');

  String get enterDemoButton => language == AppLanguage.marathi
      ? 'डेमो मध्ये प्रवेश करा'
      : (language == AppLanguage.hindi ? 'डेमो में प्रवेश करें' : 'Enter Demo');

  // Auth - OTP
  String get verifyNumberTitle => language == AppLanguage.marathi
      ? 'नंबर पडताळणी करा'
      : (language == AppLanguage.hindi
          ? 'नंबर सत्यापित करें'
          : 'Verify your number');

  String otpSentTo(String phone) => language == AppLanguage.marathi
      ? '$phone वर OTP पाठवला आहे'
      : (language == AppLanguage.hindi
          ? '$phone पर OTP भेजा गया है'
          : 'OTP sent to $phone');

  String get enterOtpHint => language == AppLanguage.marathi
      ? '६ अंकी OTP टाका'
      : (language == AppLanguage.hindi
          ? '6 अंकों का OTP दर्ज करें'
          : 'Enter 6-digit OTP');

  String get verifyOtp => language == AppLanguage.marathi
      ? 'पडताळणी करा'
      : (language == AppLanguage.hindi ? 'सत्यापित करें' : 'Verify OTP');

  String get changeNumber => language == AppLanguage.marathi
      ? 'नंबर बदला'
      : (language == AppLanguage.hindi ? 'नंबर बदलें' : 'Change Number');

  String get didntReceiveOtp => language == AppLanguage.marathi
      ? 'OTP मिळाला नाही का?'
      : (language == AppLanguage.hindi
          ? 'OTP नहीं मिला?'
          : "Didn't receive the OTP?");

  String get resendOtp => language == AppLanguage.marathi
      ? 'पुन्हा OTP पाठवा'
      : (language == AppLanguage.hindi ? 'OTP पुनः भेजें' : 'Resend OTP');

  String resendIn(int seconds) => language == AppLanguage.marathi
      ? '$seconds सेकंदात पुन्हा पाठवा'
      : (language == AppLanguage.hindi
          ? '$seconds सेकंड में पुनः भेजें'
          : 'Resend in ${seconds}s');

  String get invalidOtpLength => language == AppLanguage.marathi
      ? 'कृपया ६ अंकी OTP टाका'
      : (language == AppLanguage.hindi
          ? 'कृपया 6 अंकों का OTP दर्ज करें'
          : 'Please enter 6-digit OTP');

  // Navigation
  String get navHome => language == AppLanguage.marathi
      ? 'मुख्य'
      : (language == AppLanguage.hindi ? 'मुख्य' : 'Home');

  String get navCheckCrop => language == AppLanguage.marathi
      ? 'पीक तपासा'
      : (language == AppLanguage.hindi ? 'फसल जांचें' : 'Check Crop');

  String get navAlerts => language == AppLanguage.marathi
      ? 'सतर्कता'
      : (language == AppLanguage.hindi ? 'सतर्कता' : 'Alerts');

  String get navHistory => language == AppLanguage.marathi
      ? 'इतिहास'
      : (language == AppLanguage.hindi ? 'इतिहास' : 'History');

  String get navMore => language == AppLanguage.marathi
      ? 'अधिक'
      : (language == AppLanguage.hindi ? 'अधिक' : 'More');

  // Home Screen
  String get greetingMorning => language == AppLanguage.marathi
      ? 'शुभ प्रभात'
      : (language == AppLanguage.hindi ? 'शुभ प्रभात' : 'Good Morning');

  String get greetingAfternoon => language == AppLanguage.marathi
      ? 'शुभ दुपार'
      : (language == AppLanguage.hindi ? 'शुभ दोपहर' : 'Good Afternoon');

  String get greetingEvening => language == AppLanguage.marathi
      ? 'शुभ संध्याकाळ'
      : (language == AppLanguage.hindi ? 'शुभ संध्या' : 'Good Evening');

  String get fieldAssistantTitle => language == AppLanguage.marathi
      ? 'तुमचा शेती सल्लागार'
      : (language == AppLanguage.hindi
          ? 'आपका कृषि सलाहकार'
          : 'Your Crop Assistant');

  String get checkCropBannerTitle => language == AppLanguage.marathi
      ? 'पिकावर काही रोग किंवा कीड दिसतेय?'
      : (language == AppLanguage.hindi
          ? 'फसल पर कोई रोग या कीट दिख रहा है?'
          : 'Spot any disease or pest on your crop?');

  String get checkCropBannerAction => language == AppLanguage.marathi
      ? 'आताच फोटो काढून तपासा'
      : (language == AppLanguage.hindi
          ? 'अभी फोटो खींचकर जांचें'
          : 'Take photo to check now');

  String get activeFarmTitle => language == AppLanguage.marathi
      ? 'तुमचे शेत (सक्रिय नोंद)'
      : (language == AppLanguage.hindi
          ? 'आपका खेत (सक्रिय विवरण)'
          : 'Your Active Farm');

  String get noFarmSetupTitle => language == AppLanguage.marathi
      ? 'तुमच्या शेताची नोंदणी करा'
      : (language == AppLanguage.hindi
          ? 'अपने खेत का विवरण जोड़ें'
          : 'Set up your farm profile');

  String get noFarmSetupDesc => language == AppLanguage.marathi
      ? 'अचूक रोग निदान आणि हवामान अलर्ट मिळवण्यासाठी पिकाची माहिती जोडा.'
      : (language == AppLanguage.hindi
          ? 'सटीक रोग निदान और मौसम अलर्ट पाने के लिए फसल की जानकारी जोड़ें।'
          : 'Add your crop and location details for accurate disease diagnosis.');

  String get setupFarmButton => language == AppLanguage.marathi
      ? 'शेत जोडा'
      : (language == AppLanguage.hindi ? 'खेत जोड़ें' : 'Add Farm');

  String get recentAlertsHeader => language == AppLanguage.marathi
      ? 'हवामान व कीड सतर्कता'
      : (language == AppLanguage.hindi
          ? 'मौसम और कीट अलर्ट'
          : 'Weather & Pest Alerts');

  String get noActiveAlerts => language == AppLanguage.marathi
      ? 'सध्या तुमच्या परिसरासाठी कोणतीही गंभीर सतर्कता नाही.'
      : (language == AppLanguage.hindi
          ? 'फिलहाल आपके क्षेत्र के लिए कोई गंभीर अलर्ट नहीं है।'
          : 'No active risk alerts for your region right now.');

  // Low-Literacy Farmer UX Helpers
  String get checkCropHeroTitle => language == AppLanguage.marathi
      ? 'पिकाची तपासणी करा'
      : (language == AppLanguage.hindi ? 'फसल की जांच करें' : 'Check My Crop');

  String get checkCropHeroSubtitle => language == AppLanguage.marathi
      ? 'फोटो काढून रोग ओळखा'
      : (language == AppLanguage.hindi ? 'फोटो खींचकर रोग पहचानें' : 'Take photo to identify issue');

  String get askVoiceQuickAction => language == AppLanguage.marathi
      ? 'बोलून विचारा'
      : (language == AppLanguage.hindi ? 'बोलकर पूछें' : 'Ask by Voice');

  String get historyQuickAction => language == AppLanguage.marathi
      ? 'मागील तपासणी'
      : (language == AppLanguage.hindi ? 'पिछली जांच' : 'Past Checks');

  String get helpQuickAction => language == AppLanguage.marathi
      ? 'शेतकरी मदत'
      : (language == AppLanguage.hindi ? 'किसान मदद' : 'Farmer Help');

  String get simpleConfidenceHigh => language == AppLanguage.marathi
      ? '🟢 जास्त खात्री'
      : (language == AppLanguage.hindi ? '🟢 पूरी खात्री' : '🟢 High Confidence');

  String get simpleConfidenceMedium => language == AppLanguage.marathi
      ? '🟡 थोडी खात्री'
      : (language == AppLanguage.hindi ? '🟡 थोड़ी खात्री' : '🟡 Check more');

  String get simpleConfidenceLow => language == AppLanguage.marathi
      ? '🔴 तज्ञांची मदत'
      : (language == AppLanguage.hindi ? '🔴 विशेषज्ञ मदद' : '🔴 Expert Needed');

  String get followupStatusImproved => language == AppLanguage.marathi
      ? '🙂 सुधारणा झाली'
      : (language == AppLanguage.hindi ? '🙂 सुधार हुआ' : '🙂 Improved');

  String get followupStatusSame => language == AppLanguage.marathi
      ? '😐 जैसे थे'
      : (language == AppLanguage.hindi ? '😐 कोई बदलाव नहीं' : '😐 Same / No change');

  String get followupStatusWorse => language == AppLanguage.marathi
      ? '😟 जास्त खराब'
      : (language == AppLanguage.hindi ? '😟 स्थिति बिगड़ी' : '😟 Worse');

  String get speakAnswer => language == AppLanguage.marathi
      ? 'बोलून सांगा'
      : (language == AppLanguage.hindi ? 'बोलकर बताएं' : 'Speak Answer');

  String get callNowButton => language == AppLanguage.marathi
      ? 'थेट कॉल करा'
      : (language == AppLanguage.hindi ? 'सीधे कॉल करें' : 'Call Now');

  String get listenSpokenAudio => language == AppLanguage.marathi
      ? '🔊 सल्ला ऐका'
      : (language == AppLanguage.hindi ? '🔊 सलाह सुनें' : '🔊 Listen to Advisory');

  String get todayStatusSafe => language == AppLanguage.marathi
      ? 'पीक सुरक्षित आहे'
      : (language == AppLanguage.hindi ? 'फसल सुरक्षित है' : 'Crop looks safe for now');

  String get todayStatusAlert => language == AppLanguage.marathi
      ? 'शेतात धोका आहे'
      : (language == AppLanguage.hindi ? 'खेत में खतरा है' : 'Active field alert');

  String get pendingFollowupsHeader => language == AppLanguage.marathi
      ? 'पुढील तपासणी (फॉलो-अप)'
      : (language == AppLanguage.hindi
          ? 'अगली जांच (फॉलो-अप)'
          : 'Pending Follow-ups');

  String get noPendingFollowups => language == AppLanguage.marathi
      ? 'सध्या कोणतीही तपासणी प्रलंबित नाही.'
      : (language == AppLanguage.hindi
          ? 'फिलहाल कोई जांच लंबित नहीं है।'
          : 'No pending follow-up check-ins at this moment.');

  // Farm Setup Screen
  String get farmSetupTitle => language == AppLanguage.marathi
      ? 'शेताची माहिती नोंदवा'
      : (language == AppLanguage.hindi
          ? 'खेत की जानकारी दर्ज करें'
          : 'Set up Farm Profile');

  String get cropLabel => language == AppLanguage.marathi
      ? 'पीक'
      : (language == AppLanguage.hindi ? 'फसल' : 'Crop');

  String get cropPaddy => language == AppLanguage.marathi
      ? 'भात'
      : (language == AppLanguage.hindi ? 'धान' : 'Paddy / Rice');

  String get cropCotton => language == AppLanguage.marathi
      ? 'कापूस'
      : (language == AppLanguage.hindi ? 'कपास' : 'Cotton');

  String get cropSoybean => language == AppLanguage.marathi
      ? 'सोयाबीन'
      : (language == AppLanguage.hindi ? 'सोयाबीन' : 'Soybean');

  String get cropJowar => language == AppLanguage.marathi
      ? 'ज्वारी'
      : (language == AppLanguage.hindi ? 'ज्वार' : 'Jowar / Sorghum');

  String get cropTomato => language == AppLanguage.marathi
      ? 'टोमॅटो'
      : (language == AppLanguage.hindi ? 'टमाटर' : 'Tomato');

  String get cropBanana => language == AppLanguage.marathi
      ? 'केळी'
      : (language == AppLanguage.hindi ? 'केला' : 'Banana');

  String get cropChilli => language == AppLanguage.marathi
      ? 'मिरची'
      : (language == AppLanguage.hindi ? 'मिर्च' : 'Chilli');

  String get cropGroundnut => language == AppLanguage.marathi
      ? 'भुईमूग'
      : (language == AppLanguage.hindi ? 'मूंगफली' : 'Groundnut');

  String get cropHint => language == AppLanguage.marathi
      ? 'उदा. भात / कापूस / सोयाबीन / ज्वारी'
      : (language == AppLanguage.hindi
          ? 'उदा. धान / कपास / सोयाबीन / ज्वार'
          : 'e.g. Paddy, Cotton, Soybean, Jowar');

  String get varietyLabel => language == AppLanguage.marathi
      ? 'वाण / प्रकार'
      : (language == AppLanguage.hindi ? 'किस्म' : 'Variety');

  String get varietyHint => language == AppLanguage.marathi
      ? 'उदा. इंद्रायणी, बासमती, कर्जत'
      : (language == AppLanguage.hindi
          ? 'उदा. बासमती, पूसा'
          : 'e.g. Indrayani, Karjat-4');

  String get growthStageLabel => language == AppLanguage.marathi
      ? 'पिकाची अवस्था'
      : (language == AppLanguage.hindi
          ? 'फसल की अवस्था'
          : 'Growth Stage');

  String get growthStageNursery => language == AppLanguage.marathi
      ? 'रोपवाटिका'
      : (language == AppLanguage.hindi ? 'नर्सरी' : 'Nursery');

  String get growthStageVegetative => language == AppLanguage.marathi
      ? 'शाकीय वाढ'
      : (language == AppLanguage.hindi ? 'वानस्पतिक वृद्धि' : 'Vegetative');

  String get growthStageTillering => language == AppLanguage.marathi
      ? 'फुटवे फुटण्याची अवस्था'
      : (language == AppLanguage.hindi
          ? 'कल्ले निकलने की अवस्था'
          : 'Tillering');

  String get growthStageBooting => language == AppLanguage.marathi
      ? 'पोटरी अवस्था'
      : (language == AppLanguage.hindi ? 'गाभ की अवस्था' : 'Booting');

  String get growthStagePanicle => language == AppLanguage.marathi
      ? 'पोटरी / लोंबी निघणे'
      : (language == AppLanguage.hindi
          ? 'बालियां निकलना'
          : 'Panicle Initiation');

  String get growthStageFlowering => language == AppLanguage.marathi
      ? 'फुलोरा'
      : (language == AppLanguage.hindi ? 'फूल आना' : 'Flowering');

  String get growthStageGrainFilling => language == AppLanguage.marathi
      ? 'दाणे भरणे'
      : (language == AppLanguage.hindi ? 'दाना भरना' : 'Grain Filling');

  String get growthStageMaturity => language == AppLanguage.marathi
      ? 'पक्वता'
      : (language == AppLanguage.hindi ? 'परिपक्वता' : 'Maturity');

  String get growthStageGermination => language == AppLanguage.marathi
      ? 'उगवण'
      : (language == AppLanguage.hindi ? 'अंकुरण' : 'Germination');

  String get growthStageSquaring => language == AppLanguage.marathi
      ? 'पात्या लागणे'
      : (language == AppLanguage.hindi ? 'चौकोर बनना' : 'Squaring');

  String get growthStageBollFormation => language == AppLanguage.marathi
      ? 'बोंड लागणे'
      : (language == AppLanguage.hindi ? 'गूलर बनना' : 'Boll Formation');

  String get growthStageBollOpening => language == AppLanguage.marathi
      ? 'बोंडे फुटणे'
      : (language == AppLanguage.hindi ? 'गूलर खुलना' : 'Boll Opening');

  String get growthStageEmergence => language == AppLanguage.marathi
      ? 'उगवण'
      : (language == AppLanguage.hindi ? 'अंकुरण' : 'Emergence');

  String get growthStagePodFormation => language == AppLanguage.marathi
      ? 'शेंगा भरणे'
      : (language == AppLanguage.hindi ? 'फली बनना' : 'Pod Formation');

  String get growthStageSeedFilling => language == AppLanguage.marathi
      ? 'दाणे भरणे'
      : (language == AppLanguage.hindi ? 'दाना भरना' : 'Seed Filling');

  String get regionLabel => language == AppLanguage.marathi
      ? 'जिल्हा / तालुका'
      : (language == AppLanguage.hindi ? 'जिला' : 'District / Region');

  String get regionHint => language == AppLanguage.marathi
      ? 'उदा. नाशिक, रायगड, ठाणे'
      : (language == AppLanguage.hindi
          ? 'उदा. नाशिक, पुणे'
          : 'e.g. Nashik, Raigad, Pune');

  String get locationLabel => language == AppLanguage.marathi
      ? 'शेताचे स्थान'
      : (language == AppLanguage.hindi
          ? 'खेत का स्थान'
          : 'Farm GPS Location');

  String get locationFetching => language == AppLanguage.marathi
      ? 'स्थान शोधत आहे...'
      : (language == AppLanguage.hindi
          ? 'स्थान खोजा जा रहा है...'
          : 'Detecting GPS location...');

  String get locationSet => language == AppLanguage.marathi
      ? 'स्थान निश्चित केले'
      : (language == AppLanguage.hindi ? 'स्थान तय हुआ' : 'GPS Location Set');

  String get saveFarmButton => language == AppLanguage.marathi
      ? 'शेत जतन करा'
      : (language == AppLanguage.hindi ? 'खेत सहेजें' : 'Save Farm Profile');

  // Dedicated Farmer & Farm Profile Setup (FarmerFarmSetupScreen)
  String get farmerFarmSetupHeaderTitle => language == AppLanguage.marathi
      ? 'आपल्या शेतीचे प्रोफाइल सेट करा'
      : (language == AppLanguage.hindi
          ? 'अपने खेत की प्रोफ़ाइल सेट करें'
          : 'Set Up Your Farm Profile');

  String get farmerFarmSetupHeaderSubtitle => language == AppLanguage.marathi
      ? 'आपल्या आणि शेतीबद्दल माहिती द्या, जेणेकरून भूमी अचूक सल्ला देऊ शकेल.'
      : (language == AppLanguage.hindi
          ? 'अपने और अपने खेत के बारे में बताएं, ताकि भूमी सटीक सलाह दे सके।'
          : 'Tell us a little about yourself and your farm so Bhoomi can provide more relevant advice.');

  String get farmerInfoSectionTitle => language == AppLanguage.marathi
      ? 'शेतकरी माहिती'
      : (language == AppLanguage.hindi
          ? 'किसान जानकारी'
          : 'Farmer Information');

  String get farmerFullNameLabel => language == AppLanguage.marathi
      ? 'पूर्ण नाव'
      : (language == AppLanguage.hindi ? 'पूरा नाम' : 'Full Name');

  String get farmerFullNameHint => language == AppLanguage.marathi
      ? 'आपले पूर्ण नाव प्रविष्ट करा'
      : (language == AppLanguage.hindi
          ? 'अपना पूरा नाम दर्ज करें'
          : 'Enter your full name');

  String get farmerFullNameError => language == AppLanguage.marathi
      ? 'कृपया आपले पूर्ण नाव प्रविष्ट करा'
      : (language == AppLanguage.hindi
          ? 'कृपया अपना पूरा नाम दर्ज करें'
          : 'Please enter your full name');

  String get farmerMobileLabel => language == AppLanguage.marathi
      ? 'मोबाईल नंबर'
      : (language == AppLanguage.hindi ? 'मोबाइल नंबर' : 'Mobile Number');

  String get preferredLanguageLabel => language == AppLanguage.marathi
      ? 'प्राधान्य दिलेली भाषा'
      : (language == AppLanguage.hindi
          ? 'पसंदीदा भाषा'
          : 'Preferred Language');

  String get farmDetailsSectionTitle => language == AppLanguage.marathi
      ? 'शेतीचे तपशील'
      : (language == AppLanguage.hindi
          ? 'खेत का विवरण'
          : 'Farm Details');

  String get farmNameOptionalLabel => language == AppLanguage.marathi
      ? 'शेताचे नाव (पर्यायी)'
      : (language == AppLanguage.hindi
          ? 'खेत का नाम (वैकल्पिक)'
          : 'Farm Name (Optional)');

  String get farmNamePlaceholder => language == AppLanguage.marathi
      ? 'उदा. माझे शेत'
      : (language == AppLanguage.hindi ? 'उदा. मेरा खेत' : 'e.g. My Farm');

  String get useCurrentLocationAction => language == AppLanguage.marathi
      ? 'सध्याचे स्थान वापरा'
      : (language == AppLanguage.hindi
          ? 'वर्तमान स्थान का उपयोग करें'
          : 'Use Current Location');

  String get farmLocationCardHeader => language == AppLanguage.marathi
      ? 'शेताचे स्थान'
      : (language == AppLanguage.hindi
          ? 'खेत का स्थान'
          : 'Farm Location');

  String get enterLocationManually => language == AppLanguage.marathi
      ? 'मॅन्युअली प्रविष्ट करा'
      : (language == AppLanguage.hindi
          ? 'मैन्युअल रूप से दर्ज करें'
          : 'Enter Manually');

  String get useGpsLocation => language == AppLanguage.marathi
      ? 'GPS स्थान वापरा'
      : (language == AppLanguage.hindi
          ? 'GPS स्थान का उपयोग करें'
          : 'Use GPS Location');

  String get farmRegionLabel => language == AppLanguage.marathi
      ? 'प्रदेश / जिल्हा / राज्य'
      : (language == AppLanguage.hindi
          ? 'क्षेत्र / ज़िला / राज्य'
          : 'Region / District / State');

  String get farmRegionHint => language == AppLanguage.marathi
      ? 'उदा. नाशिक, महाराष्ट्र किंवा तामिळनाडू'
      : (language == AppLanguage.hindi
          ? 'उदा. नाशिक, महाराष्ट्र या तमिलनाडु'
          : 'e.g. Coimbatore, Tamil Nadu or Nashik, Maharashtra');

  String get farmRegionError => language == AppLanguage.marathi
      ? 'कृपया शेताचा प्रदेश प्रविष्ट करा'
      : (language == AppLanguage.hindi
          ? 'कृपया खेत का क्षेत्र दर्ज करें'
          : 'Please enter farm region or district');

  String get latitudeOptionalLabel => language == AppLanguage.marathi
      ? 'अक्षांश / Latitude (पर्यायी)'
      : (language == AppLanguage.hindi
          ? 'अक्षांश / Latitude (वैकल्पिक)'
          : 'Latitude (Optional)');

  String get longitudeOptionalLabel => language == AppLanguage.marathi
      ? 'रेखांश / Longitude (पर्यायी)'
      : (language == AppLanguage.hindi
          ? 'रेखांश / Longitude (वैकल्पिक)'
          : 'Longitude (Optional)');

  String get gpsAcquiredLabel => language == AppLanguage.marathi
      ? 'GPS स्थान प्राप्त झाले'
      : (language == AppLanguage.hindi
          ? 'GPS स्थान प्राप्त हुआ'
          : 'GPS Location Acquired');

  String get manualLocationSubtitle => language == AppLanguage.marathi
      ? 'आपल्या शेताचा जिल्हा आणि राज्य प्रविष्ट करा'
      : (language == AppLanguage.hindi
          ? 'अपने खेत का ज़िला और राज्य दर्ज करें'
          : 'Enter your farm district, region, or state');

  String get farmAreaLabel => language == AppLanguage.marathi
      ? 'एकूण शेत क्षेत्र'
      : (language == AppLanguage.hindi
          ? 'कुल खेत क्षेत्र'
          : 'Total Farm Area');

  String get farmAreaHint => language == AppLanguage.marathi
      ? 'उदा. २.५'
      : (language == AppLanguage.hindi ? 'उदा. २.५' : 'e.g. 2.5');

  String get farmAreaError => language == AppLanguage.marathi
      ? 'कृपया वैध शेत क्षेत्र प्रविष्ट करा (> ०)'
      : (language == AppLanguage.hindi
          ? 'कृपया मान्य खेत क्षेत्र दर्ज करें (> ०)'
          : 'Please enter a valid farm area (> 0)');

  String get soilTypeSectionLabel => language == AppLanguage.marathi
      ? 'मातीचा प्रकार'
      : (language == AppLanguage.hindi
          ? 'मिट्टी का प्रकार'
          : 'Soil Type');

  String get irrigationTypeSectionLabel => language == AppLanguage.marathi
      ? 'सिंचनाचा प्रकार'
      : (language == AppLanguage.hindi
          ? 'सिंचाई का प्रकार'
          : 'Irrigation Type');

  String get currentCropLabel => language == AppLanguage.marathi
      ? 'चालू पीक / हंगाम'
      : (language == AppLanguage.hindi
          ? 'वर्तमान फसल / मौसम'
          : 'Current Crop / Season');

  String get sowingDateLabel => language == AppLanguage.marathi
      ? 'पेरणीची तारीख'
      : (language == AppLanguage.hindi
          ? 'बुवाई की तारीख'
          : 'Sowing Date');

  String get selectSowingDateAction => language == AppLanguage.marathi
      ? 'पेरणीची तारीख निवडा'
      : (language == AppLanguage.hindi
          ? 'बुवाई की तारीख चुनें'
          : 'Select Sowing Date');

  String get saveAndContinueAction => language == AppLanguage.marathi
      ? 'जतन करा आणि पुढे जा'
      : (language == AppLanguage.hindi
          ? 'सहेजें और आगे बढ़ें'
          : 'Save & Continue');

  String get saveChangesAction => language == AppLanguage.marathi
      ? 'बदल जतन करा'
      : (language == AppLanguage.hindi
          ? 'परिवर्तन सहेजें'
          : 'Save Changes');

  String get profileSaveSuccess => language == AppLanguage.marathi
      ? 'शेतीचे प्रोफाइल यशस्वीरीत्या जतन केले!'
      : (language == AppLanguage.hindi
          ? 'खेत की प्रोफ़ाइल सफलतापूर्वक सहेजी गई!'
          : 'Farm profile saved successfully!');

  String get profileSaveNetworkError => language == AppLanguage.marathi
      ? 'तुमचे शेत तपशील जतन करता आले नाही. कृपया इंटरनेट तपासून पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi
          ? 'आपके खेत का विवरण सहेजा नहीं जा सका। कृपया इंटरनेट जांचकर पुनः प्रयास करें।'
          : "We couldn't save your farm details. Please check your connection and try again.");

  String get profileLoadError => language == AppLanguage.marathi
      ? 'तुमचे शेत तपशील लोड करता आले नाही. कृपया पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi
          ? 'आपके खेत का विवरण लोड नहीं किया जा सका। कृपया पुनः प्रयास करें।'
          : "We couldn't load your farm details. Please try again.");

  String get editFarmProfile => language == AppLanguage.marathi
      ? 'शेत प्रोफाइल संपादित करा'
      : (language == AppLanguage.hindi
          ? 'खेत प्रोफ़ाइल संपादित करें'
          : 'Edit Farm Profile');

  // More Screen
  String get moreTitle => language == AppLanguage.marathi
      ? 'अधिक पर्याय'
      : (language == AppLanguage.hindi ? 'अन्य विकल्प' : 'More Options');

  String get profileSection => language == AppLanguage.marathi
      ? 'शेतकरी प्रोफाइल'
      : (language == AppLanguage.hindi
          ? 'किसान प्रोफ़ाइल'
          : 'Farmer Profile');

  String get selectLanguageTitle => language == AppLanguage.marathi
      ? 'भाषा निवडा'
      : (language == AppLanguage.hindi
          ? 'भाषा चुनें'
          : 'Select Language');

  String get languageOption => language == AppLanguage.marathi
      ? 'भाषा बदला'
      : (language == AppLanguage.hindi
          ? 'भाषा बदलें'
          : 'Language');

  String get referralsOption => language == AppLanguage.marathi
      ? 'कृषी विज्ञान केंद्र व मदत केंद्र'
      : (language == AppLanguage.hindi
          ? 'कृषि विज्ञान केंद्र और हेल्पलाइन'
          : 'KVK & Agricultural Helpline');

  String get aboutOption => language == AppLanguage.marathi
      ? 'भूमीबद्दल माहिती'
      : (language == AppLanguage.hindi ? 'भूमी के बारे में' : 'About Bhoomi');

  String get myFarmOption => language == AppLanguage.marathi
      ? 'माझे शेत व पीक माहिती'
      : (language == AppLanguage.hindi ? 'मेरा खेत और फसल' : 'My Farm & Crop Profile');

  String get historyOption => language == AppLanguage.marathi
      ? 'तपासणी व सल्ला इतिहास'
      : (language == AppLanguage.hindi ? 'जांच व सलाह इतिहास' : 'Check & Advisory History');

  String get logoutButton => language == AppLanguage.marathi
      ? 'बाहेर पडा'
      : (language == AppLanguage.hindi
          ? 'लॉग आउट करें'
          : 'Log Out');

  String get logoutConfirmTitle => language == AppLanguage.marathi
      ? 'तुम्हाला बाहेर पडायचे आहे का?'
      : (language == AppLanguage.hindi
          ? 'क्या आप लॉग आउट करना चाहते हैं?'
          : 'Are you sure you want to log out?');

  String get logoutConfirmDesc => language == AppLanguage.marathi
      ? 'तुमची सत्र माहिती या फोनवरून हटवली जाईल.'
      : (language == AppLanguage.hindi
          ? 'आपका सत्र विवरण इस फोन से हटा दिया जाएगा।'
          : 'Your active session will be cleared from this device.');

  String get cancel => language == AppLanguage.marathi
      ? 'रद्द करा'
      : (language == AppLanguage.hindi ? 'रद्द करें' : 'Cancel');

  String get confirmLogout => language == AppLanguage.marathi
      ? 'हो, बाहेर पडा'
      : (language == AppLanguage.hindi ? 'हां, लॉग आउट करें' : 'Yes, Log Out');

  // Error Messages
  String get genericError => language == AppLanguage.marathi
      ? 'काहीतरी त्रुटी आली. कृपया पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi
          ? 'कुछ गड़बड़ हुई। कृपया पुनः प्रयास करें।'
          : 'Something went wrong. Please try again.');

  String get networkError => language == AppLanguage.marathi
      ? 'इंटरनेट कनेक्शन उपलब्ध नाही. कृपया नेटवर्क तपासा.'
      : (language == AppLanguage.hindi
          ? 'इंटरनेट उपलब्ध नहीं है। कृपया नेटवर्क जांचें।'
          : 'Internet connection unavailable. Please check your connection.');

  String get invalidOtpError => language == AppLanguage.marathi
      ? 'दिलेला OTP चुकीचा आहे. कृपया तपासून पुन्हा टाका.'
      : (language == AppLanguage.hindi
          ? 'दर्ज किया गया OTP गलत है। कृपया पुनः प्रयास करें।'
          : 'The OTP is incorrect. Please check the code and try again.');

  // Camera & Image Capture (Step 4)
  String get backButton => language == AppLanguage.marathi
      ? 'मागे जा'
      : (language == AppLanguage.hindi ? 'पीछे जाएं' : 'Back');

  String get cameraTitle => language == AppLanguage.marathi
      ? 'पीक तपासा'
      : (language == AppLanguage.hindi ? 'फसल जांचें' : 'Check Crop');

  String get cameraInstruction => language == AppLanguage.marathi
      ? 'पिकाचा आणि बाधित भागाचा स्पष्ट फोटो घ्या.'
      : (language == AppLanguage.hindi
          ? 'फसल और प्रभावित हिस्से की साफ फोटो लें।'
          : 'Show the affected part of your crop clearly.');

  String get cameraFrameGuide => language == AppLanguage.marathi
      ? 'बाधित भाग चौकटीत ठेवा'
      : (language == AppLanguage.hindi
          ? 'प्रभावित हिस्सा फ्रेम में रखें'
          : 'Keep affected area inside frame');

  String get captureButton => language == AppLanguage.marathi
      ? 'फोटो काढा'
      : (language == AppLanguage.hindi ? 'फोटो खींचें' : 'Take photo');

  String get galleryButton => language == AppLanguage.marathi
      ? 'गॅलरीतून निवडा'
      : (language == AppLanguage.hindi ? 'गैलरी से चुनें' : 'Choose from Gallery');

  String get galleryShort => language == AppLanguage.marathi
      ? 'गॅलरी'
      : (language == AppLanguage.hindi ? 'गैलरी' : 'Gallery');

  String get flashButton => language == AppLanguage.marathi
      ? 'फ्लॅश'
      : (language == AppLanguage.hindi ? 'फ़्लैश' : 'Flash');

  String get choosePhotoButton => language == AppLanguage.marathi
      ? 'फोटो निवडा'
      : (language == AppLanguage.hindi ? 'फोटो चुनें' : 'Choose a photo');

  String get retakeButton => language == AppLanguage.marathi
      ? 'पुन्हा फोटो घ्या'
      : (language == AppLanguage.hindi ? 'दोबारा फोटो लें' : 'Retake');

  String get usePhotoButton => language == AppLanguage.marathi
      ? 'हा फोटो वापरा (तपासा)'
      : (language == AppLanguage.hindi ? 'यह फोटो उपयोग करें' : 'Use this Photo');

  String get previewTitle => language == AppLanguage.marathi
      ? 'फोटोची खात्री करा'
      : (language == AppLanguage.hindi ? 'फोटो की पुष्टि करें' : 'Confirm Photo');

  String get previewHint => language == AppLanguage.marathi
      ? 'रोग किंवा कीड स्पष्ट दिसत आहे का? नसल्यास पुन्हा फोटो घ्या.'
      : (language == AppLanguage.hindi
          ? 'क्या रोग या कीट साफ दिख रहा है? नहीं तो दोबारा फोटो लें।'
          : 'Is the affected area clearly visible? If not, retake.');

  String get cameraInitializing => language == AppLanguage.marathi
      ? 'कॅमेरा सुरू होत आहे...'
      : (language == AppLanguage.hindi ? 'कैमरा शुरू हो रहा है...' : 'Getting camera ready...');

  String get cameraPermissionRequired => language == AppLanguage.marathi
      ? 'कॅमेरा परवानगी द्या'
      : (language == AppLanguage.hindi
          ? 'कैमरा अनुमति दें'
          : 'Allow camera access');

  String get cameraPermissionRequiredDesc => language == AppLanguage.marathi
      ? 'कॅमेऱ्यामुळे भूमीला तुमच्या पिकाचा बाधित भाग पाहण्यास मदत होते.'
      : (language == AppLanguage.hindi
          ? 'कैमरे से भूमि को आपकी फसल का प्रभावित हिस्सा देखने में मदद मिलती है।'
          : 'Camera access helps Bhoomi see the affected part of your crop.');

  String get cameraPermissionDeniedForever => language == AppLanguage.marathi
      ? 'कॅमेरा परवानगी बंद आहे'
      : (language == AppLanguage.hindi
          ? 'कैमरा अनुमति बंद है'
          : 'Camera access is turned off');

  String get cameraPermissionDeniedForeverDesc => language == AppLanguage.marathi
      ? 'कृपया ॲप सेटिंग्जमधून कॅमेरा परवानगी चालू करा.'
      : (language == AppLanguage.hindi
          ? 'कृपया ऐप सेटिंग्स से कैमरा अनुमति चालू करें।'
          : 'Please enable camera access in app settings.');

  String get cameraUnavailable => language == AppLanguage.marathi
      ? 'कॅमेरा उपलब्ध नाही'
      : (language == AppLanguage.hindi ? 'कैमरा उपलब्ध नहीं है' : 'Camera unavailable');

  String get cameraUnavailableDesc => language == AppLanguage.marathi
      ? 'या डिव्हाइसवर कॅमेरा वापरता येत नाही.'
      : (language == AppLanguage.hindi ? 'इस डिवाइस पर कैमरा उपलब्ध नहीं है।' : "I can't access the camera on this device.");

  String get cameraError => language == AppLanguage.marathi
      ? 'कॅमेरा सुरू करता आला नाही'
      : (language == AppLanguage.hindi
          ? 'कैमरा शुरू नहीं हो सका'
          : "Couldn't start the camera");

  String get cameraErrorDesc => language == AppLanguage.marathi
      ? 'कृपया पुन्हा प्रयत्न करा किंवा गॅलरीतून फोटो निवडा.'
      : (language == AppLanguage.hindi
          ? 'कृपया पुनः प्रयास करें या गैलरी से फोटो चुनें।'
          : 'Please try again or choose a photo from gallery.');

  String get grantPermissionButton => language == AppLanguage.marathi
      ? 'परवानगी द्या'
      : (language == AppLanguage.hindi ? 'अनुमति दें' : 'Allow camera');

  String get notNowButton => language == AppLanguage.marathi
      ? 'आत्ता नको'
      : (language == AppLanguage.hindi ? 'अभी नहीं' : 'Not now');

  String get tryAgainButton => language == AppLanguage.marathi
      ? 'पुन्हा प्रयत्न करा'
      : (language == AppLanguage.hindi ? 'पुनः प्रयास करें' : 'Try again');

  String get photoCaptured => language == AppLanguage.marathi
      ? 'फोटो घेतला'
      : (language == AppLanguage.hindi ? 'फोटो ले लिया गया' : 'Photo captured');

  String get capturingPhoto => language == AppLanguage.marathi
      ? 'फोटो काढत आहे...'
      : (language == AppLanguage.hindi ? 'फोटो लिया जा रहा है...' : 'Capturing photo...');

  // Diagnosis Loading (Step 4)
  String get checkingPhotoTitle => language == AppLanguage.marathi
      ? 'धन्यवाद. मी आता फोटो तपासत आहे...'
      : (language == AppLanguage.hindi ? 'धन्यवाद। मैं अभी फ़ोटो की जाँच कर रही हूँ...' : "Thank you. I'm checking the photo now.");

  String get checkingPhotoSubtitle => language == AppLanguage.marathi
      ? 'कृपया थोडा वेळ थांबा, लक्षणे ओळखली जात आहेत.'
      : (language == AppLanguage.hindi
          ? 'कृपया थोड़ा इंतज़ार करें, लक्षणों की पहचान की जा रही है।'
          : 'Please wait a moment while symptoms are analyzed.');

  String get uploadingPhoto => language == AppLanguage.marathi
      ? 'फोटो सुरक्षित सर्व्हरवर पाठवत आहोत...'
      : (language == AppLanguage.hindi
          ? 'फोटो सुरक्षित सर्वर पर भेज रहे हैं...'
          : 'Uploading photo securely...');

  // Confidence Gate - Advise Outcome
  String get diagnosisResultTitle => language == AppLanguage.marathi
      ? 'निदान व सल्ला'
      : (language == AppLanguage.hindi ? 'निदान और सलाह' : 'Diagnosis & Advisory');

  String get highConfidence => language == AppLanguage.marathi
      ? 'उच्च अचूकता'
      : (language == AppLanguage.hindi ? 'उच्च सटीकता' : 'High Confidence');

  String get moderateConfidence => language == AppLanguage.marathi
      ? 'मध्यम अचूकता'
      : (language == AppLanguage.hindi ? 'मध्यम सटीकता' : 'Moderate Confidence');

  String get otherPossibilities => language == AppLanguage.marathi
      ? 'इतर शक्यता'
      : (language == AppLanguage.hindi ? 'अन्य संभावनाएं' : 'Other Possibilities');

  String get whatToAvoidHeader => language == AppLanguage.marathi
      ? 'हे अजिबात करू नका'
      : (language == AppLanguage.hindi ? 'यह बिल्कुल न करें' : 'WHAT TO AVOID FIRST (CRITICAL)');

  String get whatToCheckHeader => language == AppLanguage.marathi
      ? 'शेतात काय तपासावे'
      : (language == AppLanguage.hindi ? 'खेत में क्या जांचें' : 'WHAT TO CHECK (SYMPTOMS)');

  String get ipmLadderHeader => language == AppLanguage.marathi
      ? 'एकात्मिक कीड व्यवस्थापन पायऱ्या'
      : (language == AppLanguage.hindi ? 'एकीकृत कीट प्रबंधन के चरण' : 'INTEGRATED PEST MANAGEMENT (IPM)');

  String get culturalTier => language == AppLanguage.marathi
      ? '१. मशागतीय उपाय'
      : (language == AppLanguage.hindi ? '१. सस्यीय उपाय' : '1. Cultural Action');

  String get biologicalTier => language == AppLanguage.marathi
      ? '२. जैविक उपाय'
      : (language == AppLanguage.hindi ? '२. जैविक नियंत्रण' : '2. Biological Action');

  String get chemicalTier => language == AppLanguage.marathi
      ? '३. रासायनिक उपाय'
      : (language == AppLanguage.hindi ? '३. रासायनिक नियंत्रण' : '3. Chemical Action');

  String get showChemicalDetails => language == AppLanguage.marathi
      ? '+ रासायनिक औषधांचे तपशील पहा'
      : (language == AppLanguage.hindi ? '+ रासायनिक दवाओं का विवरण देखें' : '+ Show chemical details');

  String get hideChemicalDetails => language == AppLanguage.marathi
      ? '- रासायनिक तपशील लपवा'
      : (language == AppLanguage.hindi ? '- रासायनिक विवरण छुपाएं' : '- Hide chemical details');

  String get citationsHeader => language == AppLanguage.marathi
      ? 'सल्ल्याचा अधिकृत संदर्भ'
      : (language == AppLanguage.hindi ? 'सलाह का आधिकारिक स्रोत' : 'Why this advice? (Official Sources)');

  String get listenAudio => language == AppLanguage.marathi
      ? 'सल्ला ऐका'
      : (language == AppLanguage.hindi ? 'सलाह सुनें' : 'Listen to Advisory');

  // Confidence Gate - Doubt Doctor (Clarify Outcome)
  String get doubtDoctorTitle => language == AppLanguage.marathi
      ? 'थोडी अधिक माहिती हवी आहे'
      : (language == AppLanguage.hindi ? 'थोड़ी और जानकारी चाहिए' : "Let's check one more thing");

  String get doubtDoctorSubtitle => language == AppLanguage.marathi
      ? 'अचूक निदानासाठी शेतात प्रत्यक्ष पाहून खालील प्रश्नाचे उत्तर द्या.'
      : (language == AppLanguage.hindi
          ? 'सटीक निदान के लिए खेत में देखकर नीचे दिए गए प्रश्न का उत्तर दें।'
          : 'Check your field observation to confirm the diagnosis.');

  String get answerYes => language == AppLanguage.marathi
      ? 'होय'
      : (language == AppLanguage.hindi ? 'हाँ' : 'YES');

  String get answerNo => language == AppLanguage.marathi
      ? 'नाही'
      : (language == AppLanguage.hindi ? 'नहीं' : 'NO');

  String get answerUnknown => language == AppLanguage.marathi
      ? 'सांगता येत नाही'
      : (language == AppLanguage.hindi ? 'पता नहीं' : "CAN'T TELL");

  String get candidateOneTag => language == AppLanguage.marathi
      ? 'शक्यता १'
      : (language == AppLanguage.hindi ? 'संभावना १' : 'Option 1');

  String get candidateTwoTag => language == AppLanguage.marathi
      ? 'शक्यता २'
      : (language == AppLanguage.hindi ? 'संभावना २' : 'Option 2');

  String get fieldCheckPrompt => language == AppLanguage.marathi
      ? 'प्रत्यक्ष निरीक्षण प्रश्न:'
      : (language == AppLanguage.hindi ? 'प्रत्यक्ष निरीक्षण प्रश्न:' : 'Field Check:');

  String get listenQuestion => language == AppLanguage.marathi
      ? 'प्रश्न ऐका'
      : (language == AppLanguage.hindi ? 'प्रश्न सुनें' : 'Listen to Question');

  String get doubtDoctorStubBanner => language == AppLanguage.marathi
      ? 'डेमो मोड: संशय निराकरण चाचणी इंजिनद्वारे हाताळले जात आहे.'
      : (language == AppLanguage.hindi
          ? 'डेमो मोड: संशय समाधान परीक्षण इंजन द्वारा संचालित है।'
          : 'Demonstration Mode: Ambiguity gate resolution handled by mock engine.');

  String get doubtDoctorDefaultQuestion => language == AppLanguage.marathi
      ? 'पानाची मागची बाजू तपासा. तुम्हाला पानाच्या मागे करडी बुरशी दिसते का?'
      : (language == AppLanguage.hindi
          ? 'पत्ती को पलटें। क्या आपको नीचे धूसर फफूंद दिखाई दे रही है?'
          : 'Flip the leaf over. Do you see fuzzy grey growth on the underside?');

  String getLocalizedClarificationQuestion({
    String? cueId,
    String? question,
    String? questionLocalized,
  }) {
    final cue = (cueId ?? '').toLowerCase();
    final enQ = (question ?? '').toLowerCase();
    final mrQ = questionLocalized;

    if (cue.contains('leaf_underside') ||
        enQ.contains('underside') ||
        enQ.contains('grey mold') ||
        enQ.contains('fuzzy') ||
        (mrQ != null && mrQ.contains('बुरशी'))) {
      switch (language) {
        case AppLanguage.marathi:
          return mrQ ?? 'पानाच्या मागील बाजूस करडी बुरशी दिसते का?';
        case AppLanguage.hindi:
          return 'क्या पत्ती के नीचे धूसर/ग्रे फफूंद दिखाई देती है?';
        case AppLanguage.english:
          return (question != null && question.isNotEmpty)
              ? question
              : 'Do you see grey mold on underside?';
      }
    }

    switch (language) {
      case AppLanguage.marathi:
        return mrQ ?? question ?? doubtDoctorDefaultQuestion;
      case AppLanguage.hindi:
        return 'खेत में फसल की पत्तियां देखकर लक्षण जांचें।';
      case AppLanguage.english:
        return question ?? doubtDoctorDefaultQuestion;
    }
  }

  String getLocalizedCandidateSignature(String? label, String? signature) {
    final normLabel = (label ?? '').toLowerCase().trim();
    final normSig = (signature ?? '').toLowerCase().trim();

    if (normLabel.contains('blast') ||
        normSig.contains('diamond') ||
        normSig.contains('grey centre') ||
        normSig.contains('grey center')) {
      switch (language) {
        case AppLanguage.marathi:
          return 'करडा मध्यभाग असलेले हिऱ्याच्या आकाराचे ठिपके';
        case AppLanguage.hindi:
          return 'बीच में धूसर/ग्रे रंग वाले हीरे के आकार के धब्बे';
        case AppLanguage.english:
          return 'Diamond lesions with grey centre';
      }
    }

    if (normLabel.contains('brown_spot') ||
        normLabel.contains('brown spot') ||
        normSig.contains('round') ||
        normSig.contains('halo')) {
      switch (language) {
        case AppLanguage.marathi:
          return 'पिवळी कड असलेले गोल तपकिरी ठिपके';
        case AppLanguage.hindi:
          return 'पीले घेरे वाले गोल भूरे धब्बे';
        case AppLanguage.english:
          return 'Round spots with yellow halo';
      }
    }

    if (normLabel.contains('bacterial_leaf_blight') || normSig.contains('stripe')) {
      switch (language) {
        case AppLanguage.marathi:
          return 'पानांवर पिवळसर-पांढरे लांबट पट्टे';
        case AppLanguage.hindi:
          return 'पत्तियों पर पीले-सफेद धारियां';
        case AppLanguage.english:
          return 'Water-soaked stripes turning yellow/white';
      }
    }

    if (normLabel.contains('yellow_stem_borer') ||
        normSig.contains('dead heart') ||
        normSig.contains('white')) {
      switch (language) {
        case AppLanguage.marathi:
          return 'सुकलेला गाभा (डेड हार्ट) किंवा पांढरी लोंबी';
        case AppLanguage.hindi:
          return 'सूखा तना (डेड हार्ट) या सफेद बाली';
        case AppLanguage.english:
          return 'Dead heart or white head';
      }
    }

    if (normLabel.contains('brown_planthopper') || normSig.contains('hopper')) {
      switch (language) {
        case AppLanguage.marathi:
          return 'झाडे जळाल्यासारखी वाळणे (हॉपर बर्न)';
        case AppLanguage.hindi:
          return 'फसल का झुलसना या सूखना (हॉपर बर्न)';
        case AppLanguage.english:
          return 'Hopper burn or circular drying patches';
      }
    }

    // Fallback if unknown
    if (signature != null && signature.isNotEmpty) {
      if (language == AppLanguage.english) return signature;
      if (language == AppLanguage.marathi) return 'पानावरील रोगाची विशिष्ट लक्षणे';
      if (language == AppLanguage.hindi) return 'पत्ती पर रोग के विशिष्ट लक्षण';
    }

    switch (language) {
      case AppLanguage.marathi:
        return 'पानावरील ठिपके आणि लक्षणे';
      case AppLanguage.hindi:
        return 'पत्ती पर धब्बे और लक्षण';
      case AppLanguage.english:
        return 'Leaf spots and symptoms';
    }
  }

  String getCandidateImageSemanticLabel(String? label) {
    final normLabel = (label ?? '').toLowerCase().trim();
    if (normLabel.contains('blast')) {
      switch (language) {
        case AppLanguage.marathi:
          return 'भातावरील करपा रोगाचे हिऱ्याच्या आकाराचे ठिपके असलेले पानाचे छायाचित्र';
        case AppLanguage.hindi:
          return 'धान के झुलसा रोग के हीरे के आकार के धब्बों वाली पत्ती का चित्र';
        case AppLanguage.english:
          return 'Photograph of rice leaf with diamond-shaped blast lesions';
      }
    }
    if (normLabel.contains('brown_spot') || normLabel.contains('brown spot')) {
      switch (language) {
        case AppLanguage.marathi:
          return 'पिवळी कड असलेल्या गोल तपकिरी ठिपक्यांचे पानाचे छायाचित्र';
        case AppLanguage.hindi:
          return 'पीले घेरे वाले गोल भूरे धब्बों वाली पत्ती का चित्र';
        case AppLanguage.english:
          return 'Photograph of rice leaf with round brown spots with yellow halo';
      }
    }
    switch (language) {
      case AppLanguage.marathi:
        return 'पिकावरील रोगाचे लक्षण दर्शवणारे छायाचित्र';
      case AppLanguage.hindi:
        return 'फसल पर रोग के लक्षण दर्शाने वाला चित्र';
      case AppLanguage.english:
        return 'Photograph showing crop disease symptoms';
    }
  }

  // Confidence Gate - Escalate Outcome
  String get escalateTitle => language == AppLanguage.marathi
      ? 'तज्ञांकडे वर्ग केले'
      : (language == AppLanguage.hindi ? 'विशेषज्ञ को भेजा गया' : 'Referred to Agricultural Expert');

  String get escalateSubtitle => language == AppLanguage.marathi
      ? 'या समस्येची लक्षणे अस्पष्ट असल्याने आम्ही ही केस स्थानिक कृषी शास्त्रज्ञांकडे पाठवली आहे.'
      : (language == AppLanguage.hindi
          ? 'लक्षण अस्पष्ट होने के कारण यह मामला स्थानीय कृषि वैज्ञानिक को भेजा गया है।'
          : 'Symptoms could not be identified with certainty. An expert is reviewing your case.');

  String get caseIdLabel => language == AppLanguage.marathi
      ? 'केस क्रमांक'
      : (language == AppLanguage.hindi ? 'केस संख्या' : 'Case ID');

  String get assignedToLabel => language == AppLanguage.marathi
      ? 'नियुक्त केंद्र / तज्ञ'
      : (language == AppLanguage.hindi ? 'नियुक्त केंद्र / विशेषज्ञ' : 'Assigned Expert / KVK');

  String get queuePositionLabel => language == AppLanguage.marathi
      ? 'रांगेतील स्थान'
      : (language == AppLanguage.hindi ? 'कतार में स्थान' : 'Queue Position');

  String get etaMinutesLabel => language == AppLanguage.marathi
      ? 'अपेक्षित वेळ'
      : (language == AppLanguage.hindi ? 'अनुमानित समय' : 'Estimated Time');

  String get queueStatusSoon => language == AppLanguage.marathi
      ? '(लवकरच संपर्क होईल)'
      : (language == AppLanguage.hindi ? '(जल्द संपर्क होगा)' : '(Contacting shortly)');

  String minutesText(int minutes) => language == AppLanguage.marathi
      ? '$minutes मिनिटे'
      : (language == AppLanguage.hindi ? '$minutes मिनट' : '$minutes minutes');

  String get backToHome => language == AppLanguage.marathi
      ? 'मुख्य पृष्ठावर जा'
      : (language == AppLanguage.hindi ? 'मुख्य पृष्ठ पर जाएं' : 'Back to Home');

  // GPS Location Strings
  String get locationDetecting => language == AppLanguage.marathi
      ? 'GPS स्थान शोधत आहे...'
      : (language == AppLanguage.hindi ? 'GPS स्थान खोजा जा रहा है...' : 'Detecting GPS location...');

  String get locationPermissionRequired => language == AppLanguage.marathi
      ? 'शेताच्या हवामान अलर्ट आणि रोगांच्या अचूक निदानासाठी GPS स्थान आवश्यक आहे.'
      : (language == AppLanguage.hindi
          ? 'सटीक मौसम अलर्ट और रोग निदान के लिए GPS स्थान आवश्यक है।'
          : 'GPS location is required for local disease alerts and KVK routing.');

  String get locationDeniedError => language == AppLanguage.marathi
      ? 'स्थान परवानगी नाकारली. कृपया फोन सेटिंग्जमधून लोकेशन चालू करा.'
      : (language == AppLanguage.hindi
          ? 'स्थान की अनुमति अस्वीकृत। कृपया सेटिंग से लोकेशन चालू करें।'
          : 'Location permission denied. Please enable location services.');

  String get locationServicesDisabled => language == AppLanguage.marathi
      ? 'फोनचे GPS / स्थान बंद आहे. कृपया डिव्हाइस सेटिंग्जमधून लोकेशन चालू करा.'
      : (language == AppLanguage.hindi
          ? 'फ़ोन की GPS / लोकेशन सेवा बंद है। कृपया डिवाइस सेटिंग से चालू करें।'
          : 'Location services are disabled. Please enable GPS on your device.');

  String get locationDeniedForever => language == AppLanguage.marathi
      ? 'स्थान परवानगी कायमची नाकारली आहे. कृपया ॲप सेटिंग्जमधून परवानगी द्या.'
      : (language == AppLanguage.hindi
          ? 'स्थान की अनुमति स्थायी रूप से अस्वीकृत है। कृपया ऐप सेटिंग से अनुमति दें।'
          : 'Location permission permanently denied. Please enable in App Settings.');

  String get locationTimeoutError => language == AppLanguage.marathi
      ? 'GPS स्थान शोधण्यात वेळ संपला. कृपया पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi
          ? 'GPS स्थान खोजने का समय समाप्त हो गया। कृपया पुनः प्रयास करें।'
          : 'GPS location request timed out. Please try again.');

  String get retryLocation => language == AppLanguage.marathi
      ? 'स्थान पुन्हा शोधा'
      : (language == AppLanguage.hindi ? 'स्थान पुनः खोजें' : 'Retry Location');

  String get openSettingsButton => language == AppLanguage.marathi
      ? 'सेटिंग्ज उघडा'
      : (language == AppLanguage.hindi ? 'सेटिंग्स खोलें' : 'Open Settings');

  // Step 5: Alerts
  String get alertsTitle => language == AppLanguage.marathi
      ? 'कीड व रोग सतर्कता'
      : (language == AppLanguage.hindi ? 'कीट व रोग सतर्कता' : 'Risk Alerts');

  String get alertsSubtitle => language == AppLanguage.marathi
      ? 'स्थानिक हवामान आणि प्रादुर्भावावर आधारित सूचना'
      : (language == AppLanguage.hindi
          ? 'स्थानीय मौसम और प्रकोप पर आधारित अलर्ट'
          : 'Proactive alerts based on local weather and pest surveillance');

  String get illCheckButton => language == AppLanguage.marathi
      ? 'मी शेतात तपासतो (I\'ll Check)'
      : (language == AppLanguage.hindi ? 'मैं खेत में जाँचूँगा (I\'ll Check)' : 'I\'LL CHECK');

  String get alertResponseRecorded => language == AppLanguage.marathi
      ? 'प्रतिसाद नोंदवला गेला आहे. शेताचे निरीक्षण केल्याबद्दल धन्यवाद!'
      : (language == AppLanguage.hindi
          ? 'प्रतिक्रिया दर्ज की गई। निरीक्षण के लिए धन्यवाद!'
          : 'Response recorded. Thank you for checking your field!');

  String get noActiveAlertsTitle => language == AppLanguage.marathi
      ? 'सध्या कोणतीही सतर्कता नाही'
      : (language == AppLanguage.hindi ? 'वर्तमान में कोई अलर्ट नहीं है' : 'No active alerts');

  String get noActiveAlertsMessage => language == AppLanguage.marathi
      ? 'तुमच्या परिसरातील हवामान व पीक परिस्थिती सध्या सामान्य आहे.'
      : (language == AppLanguage.hindi
          ? 'आपके क्षेत्र में मौसम और फसल की स्थिति सामान्य है।'
          : 'Weather conditions and disease risk in your area are currently normal.');

  // Step 5: Follow-ups
  String get followupsTitle => language == AppLanguage.marathi
      ? 'उपाययोजना फॉलो-अप'
      : (language == AppLanguage.hindi ? 'उपाय फॉलो-अप' : 'Pending Follow-Ups');

  String get followupQuestionDefault => language == AppLanguage.marathi
      ? 'उपचारानंतर पिकाची स्थिती कशी आहे?'
      : (language == AppLanguage.hindi
          ? 'उपचार के बाद फसल की स्थिति कैसी है?'
          : 'How is the crop doing after treatment?');

  String get statusImproved => language == AppLanguage.marathi
      ? 'सुधारणा झाली'
      : (language == AppLanguage.hindi ? 'सुधार हुआ' : 'Improved');

  String get statusNoChange => language == AppLanguage.marathi
      ? 'बदल नाही'
      : (language == AppLanguage.hindi ? 'कोई बदलाव नहीं' : 'No Change');

  String get statusGotWorse => language == AppLanguage.marathi
      ? 'अधिक बिघडले'
      : (language == AppLanguage.hindi ? 'और बिगड़ गया' : 'Got Worse');

  String get followupSuccessMessage => language == AppLanguage.marathi
      ? 'फॉलो-अप प्रतिसाद जतन केला. शेताची सद्यस्थिती अद्यतनित झाली आहे.'
      : (language == AppLanguage.hindi
          ? 'फॉलो-अप सहेजा गया। खेत की स्थिति अद्यतन की गई है।'
          : 'Follow-up response recorded. Farm health status updated.');

  String get noPendingFollowupsTitle => language == AppLanguage.marathi
      ? 'कोणताही प्रलंबित फॉलो-अप नाही'
      : (language == AppLanguage.hindi ? 'कोई लंबित फॉलो-अप नहीं है' : 'No pending follow-ups');

  String get noPendingFollowupsMessage => language == AppLanguage.marathi
      ? 'सर्व उपचार पडताळणी पूर्ण झाली आहे.'
      : (language == AppLanguage.hindi
          ? 'सभी उपचार सत्यापन पूर्ण हो चुके हैं।'
          : 'All treatment check-ins are up to date.');

  // Step 5: Timeline / History
  String get timelineTitle => language == AppLanguage.marathi
      ? 'पीक इतिहास व नोंदी'
      : (language == AppLanguage.hindi ? 'फसल इतिहास व रिकॉर्ड' : 'Crop Timeline & History');

  String get noHistoryTitle => language == AppLanguage.marathi
      ? 'अजून कोणताही इतिहास नाही'
      : (language == AppLanguage.hindi ? 'अभी कोई इतिहास नहीं है' : 'No history yet');

  String get noHistoryMessage => language == AppLanguage.marathi
      ? 'निदान, सतर्कता किंवा उपचारानंतरच्या नोंदी येथे दिसतील.'
      : (language == AppLanguage.hindi
          ? 'निदान, अलर्ट या उपचार की प्रविष्टियां यहाँ दिखेंगी।'
          : 'Diagnoses, alerts, and treatment check-ins will appear here.');

  String get eventDiagnosis => language == AppLanguage.marathi
      ? 'रोग निदान'
      : (language == AppLanguage.hindi ? 'रोग निदान' : 'Diagnosis');

  String get eventObservation => language == AppLanguage.marathi
      ? 'प्रत्यक्ष निरीक्षण'
      : (language == AppLanguage.hindi ? 'खेत निरीक्षण' : 'Field Observation');

  String get eventTreatment => language == AppLanguage.marathi
      ? 'उपाययोजना'
      : (language == AppLanguage.hindi ? 'उपाययोजना' : 'Treatment');

  String get eventAlert => language == AppLanguage.marathi
      ? 'हवामान सतर्कता'
      : (language == AppLanguage.hindi ? 'मौसम अलर्ट' : 'Weather Alert');

  String get eventFollowup => language == AppLanguage.marathi
      ? 'फॉलो-अप तपासणी'
      : (language == AppLanguage.hindi ? 'फॉलो-अप जाँच' : 'Follow-up Check');

  String get viewDetails => language == AppLanguage.marathi
      ? 'तपशील पहा'
      : (language == AppLanguage.hindi ? 'विवरण देखें' : 'View Details');

  String get timelineAdvisoryTitle => language == AppLanguage.marathi
      ? 'एकात्मिक कीड व्यवस्थापन सल्ला जारी केला'
      : (language == AppLanguage.hindi
          ? 'एकीकृत कीट प्रबंधन सलाह जारी'
          : 'IPM Advisory Issued');

  String get timelineAdvisoryDesc => language == AppLanguage.marathi
      ? 'मशागतीय हवा खेळती राहण्याची शिफारस. बुरशीजन्य रोग आढळल्यामुळे रासायनिक कीटकनाशक टाळले.'
      : (language == AppLanguage.hindi
          ? 'वायु संचार के लिए कृषि पद्धतियों की सिफारिश। कवक रोग मिलने पर रासायनिक कीटनाशक वर्जित।'
          : 'Cultural aeration recommended. Chemical insecticide vetoed — fungal pathogen detected.');

  String get timelineDiagnosisTitle => language == AppLanguage.marathi
      ? 'पीक रोग निदान पूर्ण झाले'
      : (language == AppLanguage.hindi
          ? 'फसल रोग निदान पूर्ण हुआ'
          : 'Crop Diagnosis Completed');

  String get timelineDiagnosisDesc => language == AppLanguage.marathi
      ? 'भातावरील करपा रोगाची ९४% अचूकतेसह निश्चित ओळख.'
      : (language == AppLanguage.hindi
          ? 'धान के झुलसा रोग की 94% सटीकता के साथ पुष्टि।'
          : 'High confidence detection of Paddy Blast at 94% certainty.');

  String get timelineAlertTitle => language == AppLanguage.marathi
      ? 'प्रादेशिक हवामान सल्ला'
      : (language == AppLanguage.hindi
          ? 'क्षेत्रीय मौसम सलाह'
          : 'Regional Weather Advisory');

  String get timelineAlertDesc => language == AppLanguage.marathi
      ? 'नाशिक परिसरासाठी सलग जास्त आर्द्रतेचा रात्रीचा इशारा नोंदवला.'
      : (language == AppLanguage.hindi
          ? 'नासिक क्लस्टर के लिए लगातार उच्च आर्द्रता रात की चेतावनी दर्ज की गई।'
          : 'Consecutive high-humidity night alert registered for Nashik cluster.');

  // Step 5: Problem Detail
  String get problemDetailTitle => language == AppLanguage.marathi
      ? 'समस्या सविस्तर माहिती'
      : (language == AppLanguage.hindi ? 'समस्या का विवरण' : 'Problem Details');

  String get statusOpen => language == AppLanguage.marathi
      ? 'सक्रिय'
      : (language == AppLanguage.hindi ? 'सक्रिय' : 'Open');

  String get statusResolved => language == AppLanguage.marathi
      ? 'निवारण झाले'
      : (language == AppLanguage.hindi ? 'समाधान हुआ' : 'Resolved');

  String get openedOnLabel => language == AppLanguage.marathi
      ? 'नोंदणी दिनांक'
      : (language == AppLanguage.hindi ? 'दर्ज करने की तिथि' : 'Opened On');

  String get resolvedOnLabel => language == AppLanguage.marathi
      ? 'निवारण दिनांक'
      : (language == AppLanguage.hindi ? 'समाधान तिथि' : 'Resolved On');

  String get observationsHeader => language == AppLanguage.marathi
      ? 'नोंदवलेली लक्षणे व निरीक्षणे'
      : (language == AppLanguage.hindi ? 'दर्ज लक्षण और अवलोकन' : 'Field Observations');

  // Step 5: Referrals
  String get referralsTitle => language == AppLanguage.marathi
      ? 'कृषी मदत व संपर्क केंद्र'
      : (language == AppLanguage.hindi ? 'कृषि सहायता एवं संपर्क केंद्र' : 'KVK & Agricultural Helpline');

  String get kvkHeader => language == AppLanguage.marathi
      ? 'स्थानिक कृषी विज्ञान केंद्र'
      : (language == AppLanguage.hindi ? 'स्थानीय कृषि विज्ञान केंद्र' : 'Krishi Vigyan Kendra (KVK)');

  String get diagnosticLabsHeader => language == AppLanguage.marathi
      ? 'जिल्हा कृषी प्रयोगशाळा'
      : (language == AppLanguage.hindi ? 'जिला कृषि प्रयोगशालाएं' : 'District Diagnostic Labs');

  String get helplineHeader => language == AppLanguage.marathi
      ? 'शासकीय किसान कॉल सेंटर'
      : (language == AppLanguage.hindi ? 'सरकारी किसान कॉल सेंटर' : 'Kisan Call Center');

  String get callButton => language == AppLanguage.marathi
      ? 'कॉल करा'
      : (language == AppLanguage.hindi ? 'कॉल करें' : 'Call');

  String get noReferralsTitle => language == AppLanguage.marathi
      ? 'संपर्क माहिती उपलब्ध नाही'
      : (language == AppLanguage.hindi ? 'संपर्क जानकारी उपलब्ध नहीं है' : 'No referrals available');

  String get noReferralsMessage => language == AppLanguage.marathi
      ? 'स्थानिक कृषी संपर्क माहिती लवकरच अद्यतनित केली जाईल.'
      : (language == AppLanguage.hindi
          ? 'स्थानीय कृषि संपर्क विवरण जल्द ही उपलब्ध होगा।'
          : 'Local referral centers will appear once registered for your region.');

  // =========================================================================
  // STEP 6: VOICE-FIRST, CONNECTIVITY RESILIENCE & ACCESSIBILITY STRINGS
  // =========================================================================

  // Voice Interaction System
  String get greetingPartnerSubtitle => language == AppLanguage.marathi
      ? 'तुमचा शेतकरी साथी'
      : (language == AppLanguage.hindi ? 'आपका किसान साथी' : 'Your Farming Companion');

  String get voiceHeroTitle => language == AppLanguage.marathi
      ? 'बोलून विचारा'
      : (language == AppLanguage.hindi ? 'बोलकर पूछें' : 'Ask Bhoomi');

  String get voiceHeroSubtitle => language == AppLanguage.marathi
      ? 'तुमच्या पिकाबद्दल विचारा'
      : (language == AppLanguage.hindi ? 'अपनी फसल के बारे में पूछें' : 'Ask about your crop');

  String get voiceHeroSubtitleFull => language == AppLanguage.marathi
      ? 'तुमच्या पिकाबद्दल काहीही विचारा'
      : (language == AppLanguage.hindi ? 'अपनी फसल के बारे में कुछ भी पूछें' : 'Ask anything about your crop');

  String get voiceHeroCta => language == AppLanguage.marathi
      ? 'बोलायला सुरुवात करा'
      : (language == AppLanguage.hindi ? 'बोलना शुरू करें' : 'Start Speaking');

  String get checkCropCardSubtitle => language == AppLanguage.marathi
      ? 'फोटो काढून पिकाची समस्या जाणून घ्या'
      : (language == AppLanguage.hindi ? 'फोटो खींचकर फसल की समस्या जानें' : 'Take a photo to identify crop issues');

  String get checkCropCardCta => language == AppLanguage.marathi
      ? 'तपासणी करा →'
      : (language == AppLanguage.hindi ? 'जांच करें →' : 'Check Crop →');

  String get voiceHeroBadge => language == AppLanguage.marathi
      ? 'आवाज सहाय्यक'
      : (language == AppLanguage.hindi ? 'आवाज़ सहायक' : 'Voice Assistant');

  String get voiceTapToSpeak => language == AppLanguage.marathi
      ? 'बोलण्यासाठी टॅप करा'
      : (language == AppLanguage.hindi ? 'बोलने के लिए टैप करें' : 'Tap to speak');

  String get voiceContextDiagnosis => language == AppLanguage.marathi
      ? 'या समस्येबद्दल विचारा'
      : (language == AppLanguage.hindi ? 'इस समस्या के बारे में पूछें' : 'Ask about this problem');

  String get voiceContextAlert => language == AppLanguage.marathi
      ? 'हा इशारा का आला?'
      : (language == AppLanguage.hindi ? 'यह चेतावनी क्यों आई?' : 'Why did I get this alert?');

  String get voiceContextAlertWhy => voiceContextAlert;

  String get voiceContextAdvisoryExplain => language == AppLanguage.marathi
      ? 'मला समजावून सांगा'
      : (language == AppLanguage.hindi ? 'मुझे समझाइए' : 'Explain this to me');

  String get voiceContextAdvisoryAsk => language == AppLanguage.marathi
      ? 'आणखी काही विचारा'
      : (language == AppLanguage.hindi ? 'और पूछें' : 'Ask another question');

  String get voiceContextFollowupTell => language == AppLanguage.marathi
      ? 'बोलून सांगा'
      : (language == AppLanguage.hindi ? 'बोलकर बताएं' : 'Tell Bhoomi');

  String get voiceContextFollowupPrompt => language == AppLanguage.marathi
      ? 'पिकाची स्थिती आता कशी आहे?'
      : (language == AppLanguage.hindi ? 'फसल की स्थिति अब कैसी है?' : 'How is the crop condition now?');

  String get voiceContextHistoryListen => language == AppLanguage.marathi
      ? 'पुन्हा ऐका'
      : (language == AppLanguage.hindi ? 'दोबारा सुनें' : 'Listen again');

  String get voiceContextHistoryAsk => language == AppLanguage.marathi
      ? 'या तपासणीबद्दल विचारा'
      : (language == AppLanguage.hindi ? 'इस जांच के बारे में पूछें' : 'Ask about this check');

  String get voiceAboutContextPrefix => language == AppLanguage.marathi
      ? 'विषय'
      : (language == AppLanguage.hindi ? 'विषय' : 'Topic');

  String get voiceListeningPrompt => language == AppLanguage.marathi
      ? 'ऐकत आहे... बोला'
      : (language == AppLanguage.hindi ? 'सुन रहे हैं... बोलिए' : 'Listening... Speak now');

  String get voiceProcessingPrompt => language == AppLanguage.marathi
      ? 'तुमचा प्रश्न समजून घेत आहोत...'
      : (language == AppLanguage.hindi
          ? 'आपके प्रश्न को समझ रहे हैं...'
          : 'Understanding your question...');

  String get voiceProcessingSubtitle => language == AppLanguage.marathi
      ? 'कृपया थोडा वेळ थांबा...'
      : (language == AppLanguage.hindi
          ? 'कृपया प्रतीक्षा करें...'
          : 'Please wait, preparing advice...');

  String get voiceResultTitle => language == AppLanguage.marathi
      ? 'तुमचा प्रश्न'
      : (language == AppLanguage.hindi ? 'आपका प्रश्न' : 'Your Question');

  String get voiceStopListening => language == AppLanguage.marathi
      ? 'थांबवा'
      : (language == AppLanguage.hindi ? 'रोकें' : 'Stop');

  String get voiceRetry => language == AppLanguage.marathi
      ? 'पुन्हा बोला'
      : (language == AppLanguage.hindi ? 'फिर से बोलें' : 'Speak Again');

  String get voiceSubmit => language == AppLanguage.marathi
      ? 'विचारणा करा'
      : (language == AppLanguage.hindi ? 'पूछें' : 'Submit Query');

  String get voicePlayingAudio => language == AppLanguage.marathi
      ? 'सल्ला ऐकत आहात'
      : (language == AppLanguage.hindi ? 'सलाह सुन रहे हैं' : 'Playing Advice');

  String get listenSpokenSummary => language == AppLanguage.marathi
      ? 'सल्ला ऐका'
      : (language == AppLanguage.hindi ? 'सलाह सुनें' : 'Listen to Advice');

  String get pauseSpokenSummary => language == AppLanguage.marathi
      ? 'थांबवा'
      : (language == AppLanguage.hindi ? 'रोकें' : 'Pause Audio');

  String get replaySpokenSummary => language == AppLanguage.marathi
      ? 'पुन्हा ऐका'
      : (language == AppLanguage.hindi ? 'दोबारा सुनें' : 'Replay Audio');

  String get audioPlayingSubtitle => language == AppLanguage.marathi
      ? 'ऑडिओ सल्ला ऐकवला जात आहे...'
      : (language == AppLanguage.hindi ? 'ऑडियो सलाह चल रही है...' : 'Audio advisory playing...');

  String get audioTapToListenSubtitle => language == AppLanguage.marathi
      ? 'तुमच्या भाषेत हा सल्ला ऐकण्यासाठी टॅप करा'
      : (language == AppLanguage.hindi
          ? 'अपनी भाषा में यह सलाह सुनने के लिए टैप करें'
          : 'Tap to listen to this advisory in your language');

  // Phase 2 Core Voice Experience Strings
  String get voiceBhoomiAnswer => language == AppLanguage.marathi
      ? 'Bhoomi चे उत्तर'
      : (language == AppLanguage.hindi ? 'Bhoomi का जवाब' : "Bhoomi's Answer");

  String get voiceAskAgain => language == AppLanguage.marathi
      ? 'आणखी विचारा'
      : (language == AppLanguage.hindi ? 'और पूछें' : 'Ask Another Question');

  String get voiceSpeakInYourLanguage => language == AppLanguage.marathi
      ? 'तुमच्या भाषेत बोला'
      : (language == AppLanguage.hindi ? 'अपनी भाषा में बोलें' : 'Speak in your language');

  String get voiceErrorNotUnderstood => language == AppLanguage.marathi
      ? 'आवाज समजला नाही'
      : (language == AppLanguage.hindi ? 'आवाज़ समझ नहीं आई' : 'Could not understand speech');

  String get voiceErrorNotUnderstoodDesc => language == AppLanguage.marathi
      ? 'कृपया थोडे हळू आणि स्पष्ट बोलून पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi
          ? 'कृपया थोड़ा धीरे और स्पष्ट बोलकर दोबारा प्रयास करें।'
          : 'Please speak slowly and clearly, and try again.');

  String get voiceTypeFallback => language == AppLanguage.marathi
      ? 'टाइप करा'
      : (language == AppLanguage.hindi ? 'टाइप करें' : 'Type instead');

  String get voicePermissionTitle => language == AppLanguage.marathi
      ? 'मायक्रोफोनची परवानगी आवश्यक आहे'
      : (language == AppLanguage.hindi ? 'माइक्रोफ़ोन की अनुमति चाहिए' : 'Microphone Permission Required');

  String get voicePermissionDesc => language == AppLanguage.marathi
      ? 'Bhoomi ला तुमचा आवाज ऐकण्यासाठी मायक्रोफोनची परवानगी आवश्यक आहे.'
      : (language == AppLanguage.hindi
          ? 'Bhoomi को आपकी आवाज़ सुनने के लिए माइक्रोफ़ोन की अनुमति चाहिए।'
          : 'Bhoomi needs microphone permission to listen to your question.');

  String get voiceGrantPermission => language == AppLanguage.marathi
      ? 'परवानगी द्या'
      : (language == AppLanguage.hindi ? 'अनुमति दें' : 'Grant Permission');

  String get voiceOpenSettings => language == AppLanguage.marathi
      ? 'सेटिंग्ज उघडा'
      : (language == AppLanguage.hindi ? 'सेटिंग्स खोलें' : 'Open Settings');

  String get voicePermissionPermanentlyDenied => language == AppLanguage.marathi
      ? 'मायक्रोफोनची परवानगी बंद आहे. बोलण्यासाठी कृपया सेटिंग्जमध्ये जाऊन परवानगी चालू करा.'
      : (language == AppLanguage.hindi
          ? 'माइक्रोफ़ोन की अनुमति बंद है। बोलने के लिए कृपया सेटिंग्स में जाकर अनुमति दें।'
          : 'Microphone permission is disabled. Please enable it in Settings to speak.');

  String get voiceRecordingReady => language == AppLanguage.marathi
      ? 'बोलण्यासाठी तयार'
      : (language == AppLanguage.hindi ? 'बोलने के लिए तैयार' : 'Ready to Speak');

  String get voiceRecordingInProgress => language == AppLanguage.marathi
      ? 'आवाज नोंदवत आहे... (Recording)'
      : (language == AppLanguage.hindi ? 'आवाज़ रिकॉर्ड हो रही है...' : 'Recording voice note...');

  String get voiceStoppingRecording => language == AppLanguage.marathi
      ? 'नोंदणी पूर्ण करत आहे...'
      : (language == AppLanguage.hindi ? 'रिकॉर्डिंग पूरी हो रही है...' : 'Finalizing recording...');

  String get voiceEmptyRecordingError => language == AppLanguage.marathi
      ? 'आवाज ऐकू आला नाही. कृपया फोनच्या मायक्रोफोनजवळ स्पष्ट बोला.'
      : (language == AppLanguage.hindi
          ? 'आवाज़ सुनाई नहीं दी। कृपया फ़ोन के माइक के पास साफ़ बोलें।'
          : 'No voice was detected. Please speak clearly into the microphone.');

  String get voiceUploadFailed => language == AppLanguage.marathi
      ? 'आवाज पाठवणे शक्य झाले नाही. कृपया इंटरनेट तपासून पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi
          ? 'ऑडियो अपलोड नहीं हो सका। कृपया इंटरनेट जांचकर पुनः प्रयास करें।'
          : 'Failed to upload voice note. Please check your connection and retry.');

  String get voicePlaybackError => language == AppLanguage.marathi
      ? 'सल्ला प्ले करताना अडचण आली.'
      : (language == AppLanguage.hindi ? 'ऑडियो प्ले करने में समस्या आई।' : 'Unable to play audio advisory.');

  String get voiceAudioRecorded => language == AppLanguage.marathi
      ? 'आवाज नोंदवला गेला'
      : (language == AppLanguage.hindi ? 'आवाज़ रिकॉर्ड हो गई' : 'Voice note recorded');

  String get voiceUploading => language == AppLanguage.marathi
      ? 'आवाज पाठवत आहे...'
      : (language == AppLanguage.hindi ? 'ऑडियो भेजा जा रहा है...' : 'Uploading voice note...');

  String get voiceServiceUnavailable => language == AppLanguage.marathi
      ? 'आत्ता आवाजाची सेवा उपलब्ध नाही.'
      : (language == AppLanguage.hindi ? 'अभी आवाज़ सेवा उपलब्ध नहीं है।' : 'Voice service is currently unavailable.');

  String get voiceServiceUnavailableDesc => language == AppLanguage.marathi
      ? 'कृपया पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi ? 'कृपया दोबारा प्रयास करें।' : 'Please try again.');

  String get voiceListenAnswer => language == AppLanguage.marathi
      ? 'उत्तर ऐका'
      : (language == AppLanguage.hindi ? 'जवाब सुनें' : 'Listen to Answer');

  String get voicePauseAnswer => language == AppLanguage.marathi
      ? 'ऐकणे थांबवा'
      : (language == AppLanguage.hindi ? 'सुनना रोकें' : 'Pause Audio');

  String get voiceReplayAnswer => language == AppLanguage.marathi
      ? 'पुन्हा ऐका'
      : (language == AppLanguage.hindi ? 'दोबारा सुनें' : 'Replay Audio');

  // Conversational Voice Design System (Phase 2)
  String get voiceIdleSupporting => language == AppLanguage.marathi
      ? 'तुमच्या शेतात काय घडत आहे ते मला सांगा.'
      : (language == AppLanguage.hindi
          ? 'मुझे बताएं कि आपके खेत में क्या हो रहा है।'
          : "Tell me what's happening in your field.");

  String get voiceStartTalking => language == AppLanguage.marathi
      ? 'बोलणे सुरू करा'
      : (language == AppLanguage.hindi ? 'बातचीत शुरू करें' : 'Start Talking');

  String get voiceListening => language == AppLanguage.marathi
      ? 'Bhoomi ऐकत आहे...'
      : (language == AppLanguage.hindi ? 'Bhoomi सुन रही है...' : 'Bhoomi is listening...');

  String get voiceBhoomiListening => voiceListening;

  String get voiceTapToStop => language == AppLanguage.marathi
      ? 'थांबवण्यासाठी टॅप करा'
      : (language == AppLanguage.hindi ? 'रोकने के लिए टैप करें' : 'Tap to stop');

  String get voiceStopRecording => language == AppLanguage.marathi
      ? 'थांबवा'
      : (language == AppLanguage.hindi ? 'रोकें' : 'Stop');

  String get voiceYourQuestion => language == AppLanguage.marathi
      ? 'तुमचा प्रश्न'
      : (language == AppLanguage.hindi ? 'आपका प्रश्न' : 'Your Question');

  String get voiceUnderstanding => language == AppLanguage.marathi
      ? 'समजून घेत आहे...'
      : (language == AppLanguage.hindi ? 'समझ रहा हूँ...' : 'Understanding you...');

  String get voiceIHeard => language == AppLanguage.marathi
      ? 'मी ऐकले:'
      : (language == AppLanguage.hindi ? 'मैंने सुना:' : 'I heard:');

  String get voiceSoundsRight => language == AppLanguage.marathi
      ? 'बरोबर आहे'
      : (language == AppLanguage.hindi ? 'सही है' : 'Sounds right');

  String get voiceTryAgain => language == AppLanguage.marathi
      ? 'पुन्हा बोला'
      : (language == AppLanguage.hindi ? 'फिर से बोलें' : 'Try again');

  String get voicePlayWhatIHear => language == AppLanguage.marathi
      ? 'मी काय ऐकले ते ऐका'
      : (language == AppLanguage.hindi ? 'जो सुना वह सुनें' : 'Play what I heard');

  String get voiceBhoomiSpeaking => language == AppLanguage.marathi
      ? 'भूमी बोलत आहे...'
      : (language == AppLanguage.hindi ? 'भूमी बोल रही है...' : 'Bhoomi is speaking');

  String get voiceCouldNotHear => language == AppLanguage.marathi
      ? 'मला नीट ऐकू आले नाही.'
      : (language == AppLanguage.hindi ? 'मुझे साफ सुनाई नहीं दिया।' : "I couldn't hear you clearly.");

  String get voiceCouldNotPlay => language == AppLanguage.marathi
      ? 'आवाज आता प्ले करता आला नाही.'
      : (language == AppLanguage.hindi ? 'ऑडियो अभी नहीं चल सका।' : "I couldn't play that right now.");

  String get voicePermissionNeedMic => language == AppLanguage.marathi
      ? 'तुमचा आवाज ऐकण्यासाठी मला मायक्रोफोनची परवानगी हवी आहे.'
      : (language == AppLanguage.hindi
          ? 'आपकी आवाज़ सुनने के लिए मुझे माइक्रोफ़ोन अनुमति चाहिए।'
          : 'I need microphone access to hear you.');

  String get voiceShowAffectedLeaf => language == AppLanguage.marathi
      ? 'बाधित पान दाखवा'
      : (language == AppLanguage.hindi ? 'प्रभावित पत्ता दिखाएं' : 'Show me the affected leaf');

  String get voiceShowCropContextual => language == AppLanguage.marathi
      ? 'कृपया पिकाचा फोटो दाखवा'
      : (language == AppLanguage.hindi ? 'कृपया फसल की तस्वीर दिखाएं' : 'Please show me the crop');

  String get voiceTakeLeafPhoto => language == AppLanguage.marathi
      ? 'पानावरील डागांचा फोटो घ्या'
      : (language == AppLanguage.hindi ? 'धब्बों की तस्वीर लें' : 'Take a photo of the spots');

  String get semanticsStartRecording => language == AppLanguage.marathi
      ? 'आवाज नोंदवणे सुरू करा'
      : (language == AppLanguage.hindi ? 'वॉयस रिकॉर्डिंग शुरू करें' : 'Start voice recording');

  String get semanticsStopRecording => language == AppLanguage.marathi
      ? 'आवाज नोंदवणे थांबवा'
      : (language == AppLanguage.hindi ? 'वॉयस रिकॉर्डिंग रोकें' : 'Stop voice recording');

  String get semanticsReplayBhoomi => language == AppLanguage.marathi
      ? 'भूमीचा सल्ला पुन्हा ऐका'
      : (language == AppLanguage.hindi ? 'भूमी की सलाह दोबारा सुनें' : "Replay Bhoomi's advice");

  String get semanticsPauseBhoomi => language == AppLanguage.marathi
      ? 'भूमीचा सल्ला थांबवा'
      : (language == AppLanguage.hindi ? 'भूमी की सलाह रोकें' : "Pause Bhoomi's advice");

  String get voiceEditQuestion => language == AppLanguage.marathi
      ? 'प्रश्न बदला'
      : (language == AppLanguage.hindi ? 'सवाल बदलें' : 'Edit Question');

  String get voiceDefaultAnswer => language == AppLanguage.marathi
      ? 'पिकावर करप्याची किंवा बुरशीची लक्षणे असू शकतात. नत्रयुक्त खतांचा अतिवापर टाळा, शेतातून पाण्याचा निचरा करा आणि ट्रायकोग्रामा किंवा सेंद्रिय उपायांचा वापर करा.'
      : (language == AppLanguage.hindi
          ? 'फसल पर झुलसा या फफूंद के लक्षण हो सकते हैं। नाइट्रोजन का अत्यधिक उपयोग न करें, जल निकासी करें और जैविक उपायों का उपयोग करें।'
          : 'Crop may have blast or fungal symptoms. Avoid excess nitrogen fertilizer, ensure field drainage, and use organic IPM measures.');

  // Conversational Multi-Turn & Completed Flow (Phase 4 & 6)
  String get voicePreparingAnswer => language == AppLanguage.marathi
      ? 'भूमीचे उत्तर तयार करत आहे...'
      : (language == AppLanguage.hindi ? 'भूमी का जवाब तैयार हो रहा है...' : "Preparing Bhoomi's answer...");

  String get voiceFinishedSpeaking => language == AppLanguage.marathi
      ? 'भूमीचे बोलणे पूर्ण झाले.'
      : (language == AppLanguage.hindi ? 'भूमी का बोलना पूरा हुआ।' : 'Bhoomi has finished speaking.');

  String get voiceAskAgainConversational => language == AppLanguage.marathi
      ? 'भूमीला पुन्हा विचारा'
      : (language == AppLanguage.hindi ? 'भूमी से फिर पूछें' : 'Ask Bhoomi again');

  String get voiceHearAgainConversational => language == AppLanguage.marathi
      ? 'पुन्हा ऐका'
      : (language == AppLanguage.hindi ? 'फिर से सुनें' : 'Hear again');

  String get voiceReadOnScreen => language == AppLanguage.marathi
      ? 'स्क्रीनवर वाचा'
      : (language == AppLanguage.hindi ? 'स्क्रीन पर पढ़ें' : 'Read on screen');

  String get voiceCameraReturnChecking => language == AppLanguage.marathi
      ? 'धन्यवाद. मी आता फोटो तपासत आहे.'
      : (language == AppLanguage.hindi ? 'धन्यवाद. मैं अभी फ़ोटो देख रही हूँ।' : "Thank you. I'm checking the photo now.");

  String get voiceShowLeavesContextual => language == AppLanguage.marathi
      ? 'बाधित पानाचा स्पष्ट फोटो दाखवा.'
      : (language == AppLanguage.hindi ? 'प्रभावित पत्ते की स्पष्ट फ़ोटो दिखाएं।' : 'Show the affected leaf clearly.');

  String get voiceShowInsectsContextual => language == AppLanguage.marathi
      ? 'जवळ जाऊन किडीचा स्पष्ट फोटो दाखवा.'
      : (language == AppLanguage.hindi ? 'पास जाकर कीड़े की स्पष्ट फ़ोटो दिखाएं।' : 'Move closer so the insect is visible.');

  String get voiceShowPlantContextual => language == AppLanguage.marathi
      ? 'संपूर्ण रोप/झाड फ्रेममध्ये दाखवा.'
      : (language == AppLanguage.hindi ? 'पूरे पौधे को फ्रेम के अंदर दिखाएं।' : 'Fit the whole plant inside the frame.');

  String get voiceShowUnknownContextual => language == AppLanguage.marathi
      ? 'पिकाचा आणि बाधित भागाचा स्पष्ट फोटो दाखवा.'
      : (language == AppLanguage.hindi
          ? 'फसल और प्रभावित हिस्से की स्पष्ट फ़ोटो दिखाएं।'
          : 'Show a clear photo of the crop and affected area.');

  String get voiceShowFruitContextual => language == AppLanguage.marathi
      ? 'बाधित फळाचा किंवा शेंगेचा स्पष्ट फोटो दाखवा.'
      : (language == AppLanguage.hindi ? 'प्रभावित फल या फली की स्पष्ट फ़ोटो दिखाएं।' : 'Show the affected fruit or pod clearly.');

  String get voiceShowStemContextual => language == AppLanguage.marathi
      ? 'बाधित खोडाचा किंवा फांदीचा स्पष्ट फोटो दाखवा.'
      : (language == AppLanguage.hindi ? 'प्रभावित तने या शाखा की स्पष्ट फ़ोटो दिखाएं।' : 'Show the affected stem or branch clearly.');

  String get voiceShowRootContextual => language == AppLanguage.marathi
      ? 'मुळांचा स्पष्ट फोटो दाखवा.'
      : (language == AppLanguage.hindi ? 'जड़ों की स्पष्ट फ़ोटो दिखाएं।' : 'Show the roots clearly after gentle cleaning.');

  String get voiceShowSoilContextual => language == AppLanguage.marathi
      ? 'जमिनीचा व मातीचा स्पष्ट फोटो दाखवा.'
      : (language == AppLanguage.hindi ? 'मिट्टी और ज़मीन की स्पष्ट फ़ोटो दिखाएं।' : 'Show the soil surface and moisture condition clearly.');

  // Low Connectivity & Upload Failure Resilience
  String get presignFailedTitle => language == AppLanguage.marathi
      ? 'सर्व्हरशी संपर्क होऊ शकला नाही'
      : (language == AppLanguage.hindi
          ? 'सर्वर से संपर्क नहीं हो सका'
          : 'Could not connect to server');

  String get presignFailedDesc => language == AppLanguage.marathi
      ? 'इंटरनेट कनेक्शन धीमे आहे किंवा बंद आहे. कृपया नेटवर्क तपासा.'
      : (language == AppLanguage.hindi
          ? 'इंटरनेट धीमा है या बंद है। कृपया नेटवर्क जांचें।'
          : 'Connection is slow or offline. Please check your network.');

  String get uploadFailedTitle => language == AppLanguage.marathi
      ? 'फोटो अपलोड अयशस्वी झाला'
      : (language == AppLanguage.hindi ? 'तस्वीर अपलोड नहीं हो सकी' : 'Photo upload failed');

  String get uploadFailedDesc => language == AppLanguage.marathi
      ? 'तुमचा फोटो सुरक्षित आहे. इंटरनेट जोडणी तपासून पुन्हा पाठवा.'
      : (language == AppLanguage.hindi
          ? 'आपकी तस्वीर सुरक्षित है। इंटरनेट जांचकर पुनः भेजें।'
          : 'Your photo is safe. Check your connection and try again.');

  String get diagnosisTimeoutTitle => language == AppLanguage.marathi
      ? 'निदान प्रक्रियेस वेळ लागत आहे'
      : (language == AppLanguage.hindi
          ? 'निदान में अधिक समय लग रहा है'
          : 'Diagnosis is taking longer than usual');

  String get diagnosisTimeoutDesc => language == AppLanguage.marathi
      ? 'नेटवर्क धीमे असल्याने वेळ लागत आहे. कृपया पुन्हा प्रयत्न करा.'
      : (language == AppLanguage.hindi
          ? 'धीमे नेटवर्क के कारण समय लग रहा है। कृपया पुनः प्रयास करें।'
          : 'Slow network detected. Please retry or check your connection.');

  String get retryAction => language == AppLanguage.marathi
      ? 'पुन्हा प्रयत्न करा'
      : (language == AppLanguage.hindi ? 'पुनः प्रयास करें' : 'Retry');

  String get changePhotoAction => language == AppLanguage.marathi
      ? 'दुसरा फोटो निवडा'
      : (language == AppLanguage.hindi ? 'दूसरी तस्वीर चुनें' : 'Choose Another Photo');

  // Accessibility Semantics
  String get semanticsCapturePhoto => language == AppLanguage.marathi
      ? 'कॅमेराने पिकाचा फोटो काढा'
      : (language == AppLanguage.hindi ? 'कैमरे से फसल की फोटो लें' : 'Capture crop photo with camera');

  String get semanticsToggleFlash => language == AppLanguage.marathi
      ? 'कॅमेरा फ्लॅश चालू किंवा बंद करा'
      : (language == AppLanguage.hindi ? 'फ़्लैश चालू या बंद करें' : 'Toggle camera flash');

  String get semanticsVoiceMic => language == AppLanguage.marathi
      ? 'आवाजाने प्रश्न विचारा'
      : (language == AppLanguage.hindi ? 'बोलकर प्रश्न पूछें' : 'Ask question by voice');

  String get semanticsPlayAudio => language == AppLanguage.marathi
      ? 'सल्ला आवाजात ऐका'
      : (language == AppLanguage.hindi ? 'सलाह आवाज़ में सुनें' : 'Listen to spoken advice');

  String get semanticsStopAudio => language == AppLanguage.marathi
      ? 'आवाज थांबवा'
      : (language == AppLanguage.hindi ? 'आवाज़ रोकें' : 'Stop audio playback');

  // Farm Health Card Pure Localized Strings
  String get fieldHealthStatusTitle => language == AppLanguage.marathi
      ? 'शेतातील पिकाची स्थिती'
      : (language == AppLanguage.hindi ? 'खेत की फसल की स्थिति' : 'FIELD HEALTH STATUS');

  String get trendImproving => language == AppLanguage.marathi
      ? 'सुधारणा'
      : (language == AppLanguage.hindi ? 'सुधार' : 'Improving');

  String get trendNeedsAttention => language == AppLanguage.marathi
      ? 'लक्ष द्या'
      : (language == AppLanguage.hindi ? 'ध्यान दें' : 'Needs attention');

  String get trendStable => language == AppLanguage.marathi
      ? 'स्थिर'
      : (language == AppLanguage.hindi ? 'स्थिर' : 'Stable');

  String get statusIssuesLabel => language == AppLanguage.marathi
      ? 'समस्या'
      : (language == AppLanguage.hindi ? 'समस्याएं' : 'Issues');

  String get statusFollowupLabel => language == AppLanguage.marathi
      ? 'तपासणी'
      : (language == AppLanguage.hindi ? 'जांच' : 'Follow-up');

  String get statusAlertsLabel => language == AppLanguage.marathi
      ? 'सूचना'
      : (language == AppLanguage.hindi ? 'सूचनाएं' : 'Alerts');

  String get statusAllClearLabel => language == AppLanguage.marathi
      ? 'पीक सुरक्षित आहे'
      : (language == AppLanguage.hindi ? 'फसल सुरक्षित है' : 'Crop is Safe');

  String get defaultFarmName => language == AppLanguage.marathi
      ? 'माझे भाताचे शेत'
      : (language == AppLanguage.hindi ? 'मेरा धान का खेत' : 'My Paddy Field');

  // =========================================================================
  // LAUNCH LANDING PAGE & BRAND IDENTITY
  // =========================================================================
  String get landingTitle => 'Bhoomi';

  String get landingTagline => language == AppLanguage.marathi
      ? 'तुमचा शेतकरी साथी'
      : (language == AppLanguage.hindi ? 'आपका किसान साथी' : 'Your Farming Companion');

  String get landingSubtitle => language == AppLanguage.marathi
      ? 'AI-आधारित शेतकरी साथी'
      : (language == AppLanguage.hindi ? 'AI आधारित किसान साथी' : 'Your AI-powered farming companion');

  String get landingHeroMessage => language == AppLanguage.marathi
      ? 'बोला, दाखवा आणि योग्य सल्ला मिळवा.'
      : (language == AppLanguage.hindi
          ? 'बोलें, दिखाएँ और सही सलाह पाएँ।'
          : 'Talk, show your crop, and get the right advice.');

  String get landingHeroTagline => landingHeroMessage;

  String get landingTalkTitle => language == AppLanguage.marathi
      ? 'बोला'
      : (language == AppLanguage.hindi ? 'बोलें' : 'Talk');

  String get landingTalkSubtitle => language == AppLanguage.marathi
      ? 'शंका विचारा'
      : (language == AppLanguage.hindi ? 'अपना सवाल पूछें' : 'Ask your question');

  String get landingShowTitle => language == AppLanguage.marathi
      ? 'दाखवा'
      : (language == AppLanguage.hindi ? 'दिखाएँ' : 'Show');

  String get landingShowSubtitle => language == AppLanguage.marathi
      ? 'पिकाचा फोटो घ्या'
      : (language == AppLanguage.hindi ? 'फसल की फोटो लें' : 'Take a crop photo');

  String get landingListenTitle => language == AppLanguage.marathi
      ? 'ऐका'
      : (language == AppLanguage.hindi ? 'सुनें' : 'Listen');

  String get landingListenSubtitle => language == AppLanguage.marathi
      ? 'योग्य सल्ला ऐका'
      : (language == AppLanguage.hindi ? 'सही सलाह सुनें' : 'Hear the advice');

  String get landingPillarTalk => landingTalkTitle;
  String get landingPillarShow => landingShowTitle;
  String get landingPillarListen => landingListenTitle;

  String get landingStartButton => language == AppLanguage.marathi
      ? 'सुरू करा'
      : (language == AppLanguage.hindi ? 'शुरू करें' : 'Get Started');

  String get landingGetStarted => landingStartButton;

  String get landingSemanticsStart => language == AppLanguage.marathi
      ? 'Bhoomi सोबत सुरुवात करा'
      : (language == AppLanguage.hindi
          ? 'Bhoomi के साथ शुरुआत करें'
          : 'Get started with Bhoomi');

  // =========================================================================
  // SAFETY-CRITICAL LOCALIZATION (P4 HARDENING)
  // =========================================================================

  /// Localized Target Display Name Resolver
  String getLocalizedTargetName(String? rawTarget) =>
      AppConstants.getLocalizedTarget(rawTarget, lang: language.code);

  // --- 1. RiskCard Strings ---
  String get riskCardTriggerWeather => language == AppLanguage.marathi
      ? 'हवामान आधारित धोका'
      : (language == AppLanguage.hindi
          ? 'मौसम आधारित चेतावनी'
          : 'Weather Risk Alert');

  String get riskCardTriggerSpread => language == AppLanguage.marathi
      ? 'शेजारील शेत प्रसार इशारा'
      : (language == AppLanguage.hindi
          ? 'पड़ोसी खेत से प्रसार चेतावनी'
          : 'Nearby Farm Outbreak Alert');

  String get riskCardTriggerSeasonal => language == AppLanguage.marathi
      ? 'हंगामी कीड इशारा'
      : (language == AppLanguage.hindi
          ? 'मौसमी कीट चेतावनी'
          : 'Seasonal Pest Alert');

  String get riskCardTriggerCombined => language == AppLanguage.marathi
      ? 'एकत्रित धोका इशारा'
      : (language == AppLanguage.hindi
          ? 'संयुक्त जोखिम चेतावनी'
          : 'Combined Risk Alert');

  String get riskCardWhyHeader => language == AppLanguage.marathi
      ? 'कारणे व निरीक्षण:'
      : (language == AppLanguage.hindi ? 'कारण और विवरण:' : 'Why (Reason):');

  String get riskCardGoLookHeader => language == AppLanguage.marathi
      ? 'शेतात काय तपासावे (तपासणी कृती):'
      : (language == AppLanguage.hindi
          ? 'खेत में क्या जांचें (निरीक्षण):'
          : 'What to Inspect in Field:');

  String get riskCardInspectNowAction => language == AppLanguage.marathi
      ? 'मी तपासतो'
      : (language == AppLanguage.hindi
          ? 'मैं जांच करता हूं'
          : "I'll Inspect Field");

  String get riskCardRemindLaterAction => language == AppLanguage.marathi
      ? 'नंतर आठवण करा'
      : (language == AppLanguage.hindi ? 'बाद में याद दिलाएं' : 'Remind Later');

  String get riskCardDefaultReason => language == AppLanguage.marathi
      ? 'सलग ४ रात्री ९०% पेक्षा जास्त आर्द्रता आणि फुटव्यांची अवस्था.'
      : (language == AppLanguage.hindi
          ? 'लगातार ४ रातों तक ९०% से अधिक आर्द्रता।'
          : 'Humidity above 90% for 4 consecutive nights at tillering stage.');

  String get riskCardDefaultTask1 => language == AppLanguage.marathi
      ? 'शेतातील १० झाडांची वरची पाने तपासा.'
      : (language == AppLanguage.hindi
          ? 'खेत के १० पौधों की ऊपरी पत्तियों की जांच करें।'
          : 'Check the upper leaves on 10 plants across the field.');

  String get riskCardDefaultTask2 => language == AppLanguage.marathi
      ? 'राखाडी केंद्र असलेल्या ठिपक्याचा फोटो काढा.'
      : (language == AppLanguage.hindi
          ? 'धूसर केंद्र वाले किसी भी धब्बे का फोटो लें।'
          : 'Photograph any spot with a grey centre.');

  String getLocalizedRiskReason(String rawReason) {
    if (language == AppLanguage.english) return rawReason;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(rawReason)) return rawReason;
    final lower = rawReason.toLowerCase();
    if (lower.contains('heavy_precipitation') || lower == 'heavy_precipitation_forecast') {
      return language == AppLanguage.marathi
          ? 'पुढील २४ तासांत ६० ते ८० मिमी मुसळधार पावसाचा अंदाज आहे.'
          : 'अगले २४ घंटों में ६० से ८० मिमी भारी बारिश का अनुमान है।';
    }
    if (lower.contains('fruit_borer') || lower == 'fruit_borer_cluster_surge') {
      return language == AppLanguage.marathi
          ? 'शेजारील पिकांमध्ये फळ पोखरणारी अळीचा वाढता प्रादुर्भाव नोंदवला गेला आहे.'
          : 'आसपास के खेतों में फल छेदक कीट का बढ़ा हुआ प्रकोप देखा गया है।';
    }
    if (lower.contains('favorable_temperature_humidity') || lower == 'favorable_humidity') {
      return language == AppLanguage.marathi
          ? 'हवेतील उच्च आर्द्रता आणि तापमान बुरशीजन्य करपा वाढीसाठी अनुकूल आहे.'
          : 'हवा में उच्च आर्द्रता और तापमान फफूंद झुलसा रोग के लिए अनुकूल है।';
    }
    return rawReason;
  }

  String getLocalizedInspectionTask(String rawTask) {
    if (language == AppLanguage.english) return rawTask;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(rawTask)) return rawTask;
    final lower = rawTask.toLowerCase();
    if (lower.contains('heavy rainfall is expected') || (lower.contains('proper field drainage') && lower.contains('avoid unnecessary irrigation'))) {
      return language == AppLanguage.marathi
          ? 'मुसळधार पावसाचा अंदाज आहे. शेतात पाण्याचा योग्य निचरा ठेवा आणि अनावश्यक सिंचन टाळा.'
          : 'भारी बारिश की संभावना है। खेत में उचित जल निकासी सुनिश्चित करें और अनावश्यक सिंचाई से बचें।';
    }
    if (lower.contains('high humidity may increase fungal') || lower.contains('fungal disease risk in tomato')) {
      return language == AppLanguage.marathi
          ? 'उच्च आर्द्रतेमुळे टोमॅटो पिकात बुरशीजन्य रोगाचा धोका वाढू शकतो.'
          : 'उच्च आर्द्रता के कारण टमाटर की फसल में फफूंद जनित रोगों का खतरा बढ़ सकता है।';
    }
    if (lower.contains('monitor the underside of leaves') || lower.contains('early signs of pest activity')) {
      return language == AppLanguage.marathi
          ? 'किडीच्या सुरुवातीच्या लक्षणांसाठी पानांच्या खालच्या बाजूची तपासणी करा.'
          : 'कीट गतिविधि के शुरुआती लक्षणों के लिए पत्तियों की निचली सतह की निगरानी करें।';
    }
    if (lower.contains('check the upper leaves on 10 plants') || lower.contains('10 plants across the field')) {
      return language == AppLanguage.marathi
          ? 'शेतातील १० झाडांची वरची पाने तपासा.'
          : 'खेत में १० पौधों की ऊपरी पत्तियों की जांच करें।';
    }
    if (lower.contains('photograph any spot with a grey centre') || lower.contains('grey centre')) {
      return language == AppLanguage.marathi
          ? 'राखाडी केंद्र असलेल्या कोणत्याही ठिपक्याचा फोटो काढा.'
          : 'धूसर केंद्र वाले किसी भी धब्बे की फोटो लें।';
    }
    if (lower.contains('open drainage trenches') || (lower.contains('drainage') && lower.contains('prevent standing water'))) {
      return language == AppLanguage.marathi
          ? 'शेतात पाणी साचू नये म्हणून शेताच्या कडेला पाण्याचा निचरा करणारी चर उघडी करा.'
          : 'खेत में पानी जमा होने से रोकने के लिए जल निकासी नालियां खोलें।';
    }
    if (lower.contains('postpone scheduled') || (lower.contains('postpone') && lower.contains('fertilizer'))) {
      return language == AppLanguage.marathi
          ? 'पावसामुळे नियोजित खत व फवारणी तात्पुरती पुढे ढकला.'
          : 'बारिश के कारण निर्धारित उर्वरक और छिड़काव को स्थगित करें।';
    }
    if (lower.contains('pheromone traps') || lower.contains('4 pheromone')) {
      return language == AppLanguage.marathi
          ? 'लवकर नियंत्रणासाठी एकरी ४ कामगंध सापळे (फेरोमोन ट्रॅप) लावा.'
          : 'शुरुआती निगरानी के लिए प्रति एकड़ ४ फेरोमोन ट्रैप लगाएं।';
    }
    if (lower.contains('entry pinholes') || (lower.contains('flowering') && lower.contains('pinholes'))) {
      return language == AppLanguage.marathi
          ? 'फुलोरा आणि लहान हिरव्या फळांवर अळीच्या प्रवेशाची बारीक छिद्रे तपासा.'
          : 'फूलों और छोटे हरे फलों पर कीट के प्रवेश के बारीक छेदों की जांच करें।';
    }
    if (lower.contains('bottom canopy') || lower.contains('target ring lesions')) {
      return language == AppLanguage.marathi
          ? 'खालच्या पानांवर पिवळेपणा व करप्याचे वर्तुळाकार ठिपके तपासा.'
          : 'निचली पत्तियों पर पीलापन और गोल धब्बों की जांच करें।';
    }
    if (lower.contains('drip lines') || lower.contains('soil moisture is regulated')) {
      return language == AppLanguage.marathi
          ? 'ठिबक सिंचनाद्वारे जमिनीतील ओलावा नियंत्रित ठेवा.'
          : 'ड्रिप सिंचाई के माध्यम से मिट्टी की नमी को नियंत्रित रखें।';
    }
    return rawTask;
  }


  // --- 2. ConfidenceGateCard Strings ---
  String get gateAdviseHeader => language == AppLanguage.marathi
      ? 'उपचार मार्गदर्शनासाठी पुरेशी माहिती उपलब्ध'
      : (language == AppLanguage.hindi
          ? 'उपचार मार्गदर्शन के लिए पर्याप्त जानकारी उपलब्ध'
          : 'Sufficient confidence for treatment guidance');

  String get gateAdviseDetectedIssue => language == AppLanguage.marathi
      ? 'ओळखलेली समस्या'
      : (language == AppLanguage.hindi
          ? 'पहचानी गई समस्या'
          : 'Detected Issue');

  String get gateAdviseMatchBadge => language == AppLanguage.marathi
      ? 'तपासणी जुळणी'
      : (language == AppLanguage.hindi ? 'सटीकता' : 'Match');

  String get gateAdviseAlternativesHeader => language == AppLanguage.marathi
      ? 'इतर विचारात घेतलेल्या शक्यता:'
      : (language == AppLanguage.hindi
          ? 'अन्य संभावित संभावनाएं:'
          : 'Other Possibilities Considered:');

  String get gateAdviseViewAdvisoryButton => language == AppLanguage.marathi
      ? 'सल्ला व एकात्मिक उपाय पहा'
      : (language == AppLanguage.hindi
          ? 'सलाह और एकीकृत प्रबंधन देखें'
          : 'View Advisory Treatment Ladder');

  String get gateClarifyHeader => language == AppLanguage.marathi
      ? 'डाउट डॉक्टर · स्पष्टीकरण आवश्यक'
      : (language == AppLanguage.hindi
          ? 'डाउट डॉक्टर · स्पष्टीकरण आवश्यक'
          : 'Doubt Doctor · Clarification Needed');

  String get gateClarifyPrompt => language == AppLanguage.marathi
      ? 'दोन जवळच्या शक्यता दिसत आहेत:'
      : (language == AppLanguage.hindi
          ? 'दो समान संभावनाएं दिख रही हैं:'
          : 'I see two close possibilities:');

  String get gateClarifyObservationHeader => language == AppLanguage.marathi
      ? 'शेतातील एक प्रत्यक्ष निरीक्षण प्रश्न:'
      : (language == AppLanguage.hindi
          ? 'खेत में एक प्रत्यक्ष अवलोकन प्रश्न:'
          : 'One Field Observation Question:');

  String get gateClarifyYes => language == AppLanguage.marathi
      ? 'होय'
      : (language == AppLanguage.hindi ? 'हाँ' : 'Yes');

  String get gateClarifyNo => language == AppLanguage.marathi
      ? 'नाही'
      : (language == AppLanguage.hindi ? 'नहीं' : 'No');

  String get gateClarifyUnknown => language == AppLanguage.marathi
      ? 'सांगता येत नाही'
      : (language == AppLanguage.hindi ? 'पता नहीं' : "Can't Tell");

  String get gateEscalateHeader => language == AppLanguage.marathi
      ? 'थेट कृषी तज्ञ संदर्भ'
      : (language == AppLanguage.hindi
          ? 'सीधे कृषि विशेषज्ञ परामर्श'
          : 'Direct Agronomist Referral');

  String get gateEscalatePrompt => language == AppLanguage.marathi
      ? 'मला पुरेशी खात्री नाही. चुकीचा सल्ला टाळण्यासाठी तज्ञांची मदत घेऊया.'
      : (language == AppLanguage.hindi
          ? 'मुझे पर्याप्त विश्वास नहीं है। गलत सलाह से बचने के लिए विशेषज्ञ की मदद लें।'
          : "I am not confident enough to advise you. Let's get expert help.");

  String get gateEscalatePromptSub => language == AppLanguage.marathi
      ? 'केव्हीके शास्त्रज्ञ आपल्या पिकाची तपासणी करतील.'
      : (language == AppLanguage.hindi
          ? 'केवीके वैज्ञानिक आपकी फसल की जांच करेंगे।'
          : 'KVK agronomists will examine your crop record.');

  String get gateEscalateAssignedTo => language == AppLanguage.marathi
      ? 'नियुक्त तज्ञ'
      : (language == AppLanguage.hindi ? 'नियुक्त विशेषज्ञ' : 'Assigned To');

  String get gateEscalateDefaultAssigned => language == AppLanguage.marathi
      ? 'केव्हीके कृषी शास्त्रज्ञ'
      : (language == AppLanguage.hindi
          ? 'केवीके कृषि वैज्ञानिक'
          : 'KVK Agronomist (Krishi Vigyan Kendra)');

  String get gateEscalateQueuePos => language == AppLanguage.marathi
      ? 'प्रतीक्षा क्रमांक'
      : (language == AppLanguage.hindi ? 'कतार स्थिति' : 'Queue Pos.');

  String gateEscalateQueuePosValue(int pos) => language == AppLanguage.marathi
      ? '#$pos नंबर'
      : (language == AppLanguage.hindi ? '#$pos नंबर' : '#$pos in line');

  String get gateEscalateEstWait => language == AppLanguage.marathi
      ? 'अंदाजे वेळ'
      : (language == AppLanguage.hindi ? 'अनुमानित समय' : 'Est. Wait');

  String gateEscalateEstWaitValue(int mins) => language == AppLanguage.marathi
      ? '~$mins मिनिटे'
      : (language == AppLanguage.hindi ? '~$mins मिनट' : '~$mins mins');

  String get gateEscalateCallHelpline => language == AppLanguage.marathi
      ? 'किसान हेल्पलाईनला कॉल करा'
      : (language == AppLanguage.hindi
          ? 'किसान हेल्पलाइन को कॉल करें'
          : 'Call Kisan Helpline');

  // --- 3. PesticideVetoCard Strings ---
  String get pesticideVerdictTitleNoObjection => language == AppLanguage.marathi
      ? 'कोणताही आक्षेप आढळला नाही'
      : (language == AppLanguage.hindi
          ? 'कोई आपत्ति नहीं मिली'
          : 'NO OBJECTION FOUND');

  String get pesticideVerdictTitleNotInRecords => language == AppLanguage.marathi
      ? 'उत्पादन नोंदणीत आढळले नाही'
      : (language == AppLanguage.hindi
          ? 'उत्पाद रिकॉर्ड में नहीं मिला'
          : 'PRODUCT NOT IN RECORDS');

  String get pesticideVerdictTitleVeto => language == AppLanguage.marathi
      ? 'फवारणी करू नका — मनाई निकाल'
      : (language == AppLanguage.hindi
          ? 'छिड़काव न करें — निषेध निर्णय'
          : 'DO NOT SPRAY — VETO VERDICT');

  String get pesticideLabelOcrHeader => language == AppLanguage.marathi
      ? 'बाटलीवरील लेबल माहिती:'
      : (language == AppLanguage.hindi
          ? 'बोतल के लेबल की जानकारी:'
          : 'Bottle Label Information (OCR):');

  String get pesticideActiveIngredient => language == AppLanguage.marathi
      ? 'सक्रिय घटक:'
      : (language == AppLanguage.hindi
          ? 'सक्रिय घटक:'
          : 'Active Ingredient:');

  String get pesticideConcentrationForm => language == AppLanguage.marathi
      ? 'प्रमाण व प्रकार:'
      : (language == AppLanguage.hindi
          ? 'सांद्रता और रूप:'
          : 'Concentration & Form:');

  String get pesticideRegulatoryVerdictHeader => language == AppLanguage.marathi
      ? 'नियामक तपासणी निकाल:'
      : (language == AppLanguage.hindi
          ? 'नियामक जांच परिणाम:'
          : 'Regulatory Safety Verdict:');

  String get pesticideSafetyRule => language == AppLanguage.marathi
      ? 'सुरक्षा नियम: ही केवळ मनाई तपासणी आहे. मात्रा आणि वापरासाठी छापील बाटलीवरील लेबल हाच अंतिम पुरावा आहे.'
      : (language == AppLanguage.hindi
          ? 'सुरक्षा नियम: यह केवल निषेध जांच है। मात्रा और उपयोग के लिए मुद्रित बोतल का लेबल ही अंतिम प्रमाण है।'
          : 'Safety Rule: Veto check only. The printed bottle label remains the sole authority for dosage.');

  String get pesticideRetakePhoto => language == AppLanguage.marathi
      ? 'पुन्हा फोटो काढा'
      : (language == AppLanguage.hindi ? 'फिर से फोटो लें' : 'Retake Photo');

  String get pesticideAskExpert => language == AppLanguage.marathi
      ? 'तज्ञांना विचारा'
      : (language == AppLanguage.hindi ? 'विशेषज्ञ से पूछें' : 'Ask Expert');

  String get pesticideAcknowledgeAndFollow => language == AppLanguage.marathi
      ? 'माहिती वाचली, लेबलनुसार वापर करा'
      : (language == AppLanguage.hindi
          ? 'जानकारी समझी, लेबल का पालन करें'
          : 'Acknowledge & Follow Label');

  String getLocalizedVerdictMessage(String code, [String? custom]) {
    if (custom != null && custom.isNotEmpty) return custom;
    switch (code) {
      case 'NO_OBJECTION_FOUND':
        return language == AppLanguage.marathi
            ? 'कोणताही आक्षेप आढळला नाही. बाटलीवरील छापील प्रमाणानुसार फवारणी करा.'
            : (language == AppLanguage.hindi
                ? 'कोई आपत्ति नहीं मिली। बोतल पर छपे निर्देशानुसार मात्रा का पालन करें।'
                : 'No objection found. Follow the printed label for dosage.');
      case 'NOT_REGISTERED_FOR_TARGET':
        return language == AppLanguage.marathi
            ? 'हे उत्पादन या किडीसाठी/रोगासाठी नोंदणीकृत नाही. येथे वापर करू नका.'
            : (language == AppLanguage.hindi
                ? 'यह उत्पाद इस कीट/रोग के लिए पंजीकृत नहीं है। इसका उपयोग न करें।'
                : 'This product is not registered for this pest. Do not use it here.');
      case 'WRONG_CROP':
        return language == AppLanguage.marathi
            ? 'हे उत्पादन भातासाठी (धान) नोंदणीकृत नाही.'
            : (language == AppLanguage.hindi
                ? 'यह उत्पाद धान की फसल के लिए पंजीकृत नहीं है।'
                : 'This product is not registered for paddy.');
      case 'WRONG_CLASS':
        return language == AppLanguage.marathi
            ? 'हे बुरशीनाशक आहे. तुमची समस्या कीटकांची आहे.'
            : (language == AppLanguage.hindi
                ? 'यह कवकनाशी (Fungicide) है। आपकी समस्या कीट की है।'
                : 'This is a fungicide. Your problem is an insect pest.');
      case 'PHI_CONFLICT':
        return language == AppLanguage.marathi
            ? 'कापणी खूप जवळ आली आहे. या उत्पादनाला कापणीपूर्वी अधिक दिवसांचा कालावधी (PHI) लागतो.'
            : (language == AppLanguage.hindi
                ? 'कटाई का समय बहुत पास है। इस उत्पाद को कटाई से पहले अधिक दिनों की आवश्यकता है।'
                : 'Harvest is too close. This product needs more days before harvest.');
      case 'NOT_IN_RECORDS':
        return language == AppLanguage.marathi
            ? 'या उत्पादनाची नोंद प्रणालीत नाही. वापरण्यापूर्वी कृषी तज्ञांचा सल्ला घ्या.'
            : (language == AppLanguage.hindi
                ? 'इस उत्पाद का हमारे पास रिकॉर्ड नहीं है। उपयोग से पहले विशेषज्ञ से पूछें।'
                : 'I do not have a record of this product. Ask an expert before using it.');
      default:
        return language == AppLanguage.marathi
            ? 'वापरण्यापूर्वी कृषी तज्ञांशी चर्चा करा.'
            : (language == AppLanguage.hindi
                ? 'उपयोग से पहले कृषि विशेषज्ञ से सलाह लें।'
                : 'Check with an expert before application.');
    }
  }

  // --- 4. AdvisoryIpmCard Strings ---
  String get advisoryCardHeader => language == AppLanguage.marathi
      ? 'सल्ला व एकात्मिक कीड व्यवस्थापन'
      : (language == AppLanguage.hindi
          ? 'सलाह और एकीकृत कीट प्रबंधन'
          : 'Grounded Advisory & IPM Guide');

  String get advisoryWhatToAvoidHeader => language == AppLanguage.marathi
      ? 'हे अजिबात करू नका:'
      : (language == AppLanguage.hindi
          ? 'यह बिल्कुल न करें:'
          : 'What to Avoid First (Crucial):');

  String get advisoryWhatToCheckHeader => language == AppLanguage.marathi
      ? 'शेतात काय तपासावे:'
      : (language == AppLanguage.hindi
          ? 'खेत में क्या जांचें:'
          : 'What to Check in Field:');

  String get advisoryIpmLadderHeader => language == AppLanguage.marathi
      ? 'एकात्मिक कीड व्यवस्थापन पायऱ्या:'
      : (language == AppLanguage.hindi
          ? 'एकीकृत कीट प्रबंधन चरण:'
          : 'IPM Action Ladder (Step-by-Step):');

  String get advisoryStep1Title => language == AppLanguage.marathi
      ? 'मशागतीय / यांत्रिक उपाय'
      : (language == AppLanguage.hindi
          ? 'कृषि / यांत्रिक उपाय'
          : 'Cultural Management');

  String get advisoryStep1Subtitle => language == AppLanguage.marathi
      ? 'पहिली पायरी: बिन-रासायनिक पद्धती'
      : (language == AppLanguage.hindi
          ? 'प्रथम चरण: गैर-रासायनिक पद्धतियां'
          : 'First-line non-chemical practices');

  String get advisoryStep2Title => language == AppLanguage.marathi
      ? 'जैविक नियंत्रण'
      : (language == AppLanguage.hindi
          ? 'जैविक नियंत्रण'
          : 'Biological Management');

  String get advisoryStep2Subtitle => language == AppLanguage.marathi
      ? 'मित्र बुरशी, जीवाणू व नैसर्गिक भक्षक'
      : (language == AppLanguage.hindi
          ? 'जैव-नियंत्रक और प्राकृतिक मित्र कीट'
          : 'Bio-agents & natural predators');

  String get advisoryStep3Title => language == AppLanguage.marathi
      ? 'रासायनिक फवारणी'
      : (language == AppLanguage.hindi
          ? 'रासायनिक छिड़काव'
          : 'Chemical Management');

  String get advisoryStep3Subtitle => language == AppLanguage.marathi
      ? 'केवळ आवश्यक असल्यास — शेवटचा पर्याय'
      : (language == AppLanguage.hindi
          ? 'केवल आवश्यकता होने पर — अंतिम उपाय'
          : 'Last resort — strictly use only if required');

  String get advisoryLastResortBadge => language == AppLanguage.marathi
      ? 'शेवटचा पर्याय'
      : (language == AppLanguage.hindi ? 'अंतिम विकल्प' : 'Last Resort');

  String get advisoryDosageLabel => language == AppLanguage.marathi
      ? 'प्रमाण:'
      : (language == AppLanguage.hindi ? 'मात्रा:' : 'Dosage:');

  String get advisoryPhiLabel => language == AppLanguage.marathi
      ? 'कापणीपूर्व सुरक्षित अंतर:'
      : (language == AppLanguage.hindi
          ? 'कटाई पूर्व सुरक्षित अंतराल:'
          : 'Pre-Harvest Interval (PHI):');

  String advisoryPhiDaysText(int days) => language == AppLanguage.marathi
      ? '$days दिवस कापणीपूर्वी'
      : (language == AppLanguage.hindi
          ? '$days दिन कटाई से पहले'
          : '$days days before harvest');

  String get advisoryReentryLabel => language == AppLanguage.marathi
      ? 'पुनः प्रवेश कालावधी:'
      : (language == AppLanguage.hindi ? 'पुनः प्रवेश अवधि:' : 'Re-entry Period:');

  String advisoryReentryHoursText(int hours) => language == AppLanguage.marathi
      ? '$hours तास फवारणीनंतर'
      : (language == AppLanguage.hindi
          ? '$hours घंटे छिड़काव के बाद'
          : '$hours hours after spraying');

  String get advisoryExpertTriggerHeader => language == AppLanguage.marathi
      ? 'तज्ञ मदतीची वेळ:'
      : (language == AppLanguage.hindi
          ? 'विशेषज्ञ सहायता का समय:'
          : 'Expert Escalation Trigger:');

  String get advisorySourcePrefix => language == AppLanguage.marathi
      ? 'संदर्भ स्रोत'
      : (language == AppLanguage.hindi ? 'स्रोत' : 'Source');

  String get advisoryReviewedPrefix => language == AppLanguage.marathi
      ? 'तपासणी'
      : (language == AppLanguage.hindi ? 'समीक्षा' : 'Reviewed');

  String getLocalizedAdvisoryAvoid(String rawAvoid) {
    if (language == AppLanguage.english) return rawAvoid;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(rawAvoid)) return rawAvoid;
    final lower = rawAvoid.toLowerCase();
    if (lower.contains('overhead sprinkler') || (lower.contains('sprinkler') && lower.contains('nitrogen'))) {
      return language == AppLanguage.marathi
          ? 'तुषार सिंचनाने पाणी देणे आणि जास्त प्रमाणात रासायनिक नत्र खताचा वापर करणे टाळा, यामुळे बुरशी वेगाने पसरते.'
          : 'फव्वारा सिंचाई और अत्यधिक रासायनिक यूरिया (नाइट्रोजन) का प्रयोग न करें, इससे फफूंद तेजी से फैलती है।';
    }
    return rawAvoid;
  }

  String getLocalizedAdvisoryCheck(String rawCheck) {
    if (language == AppLanguage.english) return rawCheck;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(rawCheck)) return rawCheck;
    final lower = rawCheck.toLowerCase();
    if (lower.contains('concentric target rings') || (lower.contains('lower foliage') && lower.contains('circular spots'))) {
      return language == AppLanguage.marathi
          ? 'झाडाच्या खालच्या पानांवर पिवळे वलय असलेले तपकिरी गोल ठिपके आणि वर्तुळाकार पट्टे तपासा.'
          : 'निचली पत्तियों पर पीले घेरे वाले भूरे गोल धब्बे और छल्ले जांचें।';
    }
    if (lower.contains('grey centres') && lower.contains('upper leaves')) {
      return language == AppLanguage.marathi
          ? 'वरच्या पानांवर राखाडी केंद्र असलेले चौकोनी/लंबगोलाकार ठिपके तपासा.'
          : 'ऊपरी पत्तियों पर धूसर केंद्र वाले चौकोर/लंबवत धब्बे जांचें।';
    }
    return rawCheck;
  }

  String getLocalizedAdvisoryRungAction(String rawAction) {
    if (language == AppLanguage.english) return rawAction;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(rawAction)) return rawAction;
    final lower = rawAction.toLowerCase();
    if (lower.contains('cultural:') || (lower.contains('dispose') && lower.contains('infected lower leaves'))) {
      return language == AppLanguage.marathi
          ? 'मशागतीय: संसर्ग झालेली खालची पाने काढून नष्ट करा. हवा खेळती राहण्यासाठी योग्य अंतर ठेवा.'
          : 'कृषि उपाय: रोगग्रस्त निचली पत्तियों को तोड़कर नष्ट करें। हवा के आवागमन के लिए उचित दूरी रखें।';
    }
    if (lower.contains('biological:') || lower.contains('spray trichoderma harzianum')) {
      return language == AppLanguage.marathi
          ? 'जैविक: ट्रायकोडर्मा व्हिरिडी किंवा बॅसिलस सबटिलिसचे द्रावण सकाळच्या वेळी पानांवर फवारा.'
          : 'जैविक: ट्राइकोडर्मा विरिडी या बैसिलस सबटिलिस का घोल सुबह के समय पत्तियों पर छिड़कें।';
    }
    if (lower.contains('chemical:') || lower.contains('foliar spray of copper oxychloride')) {
      return language == AppLanguage.marathi
          ? 'रासायनिक: कॉपर ऑक्सिक्लोराईड ५०% WP किंवा मॅन्कोझेब ७५% WP ची पानांच्या खालच्या बाजूवर फवारणी करा.'
          : 'रासायनिक: कॉपर ऑक्सीक्लोराइड ५०% WP या मैंकोजेब ७५% WP का पत्तियों की निचली सतह पर छिड़काव करें।';
    }
    return rawAction;
  }

  String getLocalizedAdvisoryDosage(String? rawDosage) {
    if (rawDosage == null || rawDosage.isEmpty) return '';
    if (language == AppLanguage.english) return rawDosage;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(rawDosage)) return rawDosage;
    if (rawDosage.contains('5g') || rawDosage.contains('5 g')) {
      return language == AppLanguage.marathi
          ? '५ ग्रॅम / लिटर पाणी'
          : '५ ग्राम / लीटर पानी';
    }
    if (rawDosage.contains('2.5g') || rawDosage.contains('2.5 g')) {
      return language == AppLanguage.marathi
          ? '२.५ ग्रॅम / लिटर पाणी'
          : '२.५ ग्राम / लीटर पानी';
    }
    return rawDosage;
  }

  // --- 5. HomeScreen, Followup & Activity Strings ---
  String get homeRecentActivityHeader => language == AppLanguage.marathi
      ? 'अलीकडील नोंदी'
      : (language == AppLanguage.hindi ? 'हाल की गतिविधियां' : 'Recent Activity');

  String get followupCheckinHeader => language == AppLanguage.marathi
      ? 'पाठपुरावा तपासणी'
      : (language == AppLanguage.hindi ? 'फॉलो-अप जांच' : 'Follow-up Check-in');

  String get followupOptionImproved => language == AppLanguage.marathi
      ? 'सुधारणा'
      : (language == AppLanguage.hindi ? 'सुधार' : 'Improved');

  String get followupOptionNoChange => language == AppLanguage.marathi
      ? 'बदल नाही'
      : (language == AppLanguage.hindi ? 'कोई बदलाव नहीं' : 'No change');

  String get followupOptionGotWorse => language == AppLanguage.marathi
      ? 'बिघडले'
      : (language == AppLanguage.hindi ? 'और बिगड़ गया' : 'Got worse');

  // --- Status Badge Labels ---
  String get badgeHighRisk => language == AppLanguage.marathi
      ? 'गंभीर धोका'
      : (language == AppLanguage.hindi ? 'उच्च जोखिम' : 'HIGH RISK');

  String get badgeMediumRisk => language == AppLanguage.marathi
      ? 'मध्यम धोका'
      : (language == AppLanguage.hindi ? 'मध्यम जोखिम' : 'MEDIUM RISK');

  String get badgeLowRisk => language == AppLanguage.marathi
      ? 'कमी धोका'
      : (language == AppLanguage.hindi ? 'कम जोखिम' : 'LOW RISK');

  String get badgeAdvise => language == AppLanguage.marathi
      ? 'खात्रीशीर निदान'
      : (language == AppLanguage.hindi ? 'विश्वसनीय निदान' : 'CONFIDENT DIAGNOSIS');

  String get badgeClarify => language == AppLanguage.marathi
      ? 'एक निरीक्षण आवश्यक'
      : (language == AppLanguage.hindi ? 'एक अवलोकन आवश्यक' : 'ONE OBSERVATION NEEDED');

  String get badgeEscalate => language == AppLanguage.marathi
      ? 'तज्ञ पुनरावलोकन'
      : (language == AppLanguage.hindi ? 'विशेषज्ञ समीक्षा' : 'EXPERT REVIEW NEEDED');

  String get badgeDemoStub => language == AppLanguage.marathi
      ? 'डेमो मोड'
      : (language == AppLanguage.hindi ? 'डेमो मोड' : 'DEMO MODE');

  String get badgeSeverityModerate => language == AppLanguage.marathi
      ? 'मध्यम'
      : (language == AppLanguage.hindi ? 'मध्यम' : 'Moderate');

  String get badgeSeveritySevere => language == AppLanguage.marathi
      ? 'गंभीर'
      : (language == AppLanguage.hindi ? 'गंभीर' : 'Severe');

  String get badgeSeverityLow => language == AppLanguage.marathi
      ? 'सौम्य'
      : (language == AppLanguage.hindi ? 'हल्का' : 'Low');

  // --- Dialog & Modal Strings ---
  String get selectLanguagePrompt => language == AppLanguage.marathi
      ? 'भाषा निवडा'
      : (language == AppLanguage.hindi ? 'भाषा चुनें' : 'Select Language');

  String get close => language == AppLanguage.marathi
      ? 'बंद करा'
      : (language == AppLanguage.hindi ? 'बंद करें' : 'Close');

  String get logoutDialogTitle => language == AppLanguage.marathi
      ? 'भूमीमधून बाहेर पडायचे का?'
      : (language == AppLanguage.hindi ? 'भूमी से लॉग आउट करें?' : 'Log Out of Bhoomi?');

  String get logoutDialogMessage => language == AppLanguage.marathi
      ? 'पुन्हा लॉग इन करण्यासाठी तुम्हाला पुन्हा फोन नंबर सत्यापित करावा लागेल.'
      : (language == AppLanguage.hindi
          ? 'फिर से लॉग इन करने के लिए आपको अपना फोन नंबर पुनः सत्यापित करना होगा।'
          : 'You will need to verify your phone number again to log back in.');

  String get logoutConfirm => language == AppLanguage.marathi
      ? 'लॉग आउट'
      : (language == AppLanguage.hindi ? 'लॉग आउट' : 'Log Out');

  // --- Growth Stage Fruiting ---
  String get growthStageFruiting => language == AppLanguage.marathi
      ? 'फळ धारणा'
      : (language == AppLanguage.hindi ? 'फल लगना' : 'Fruiting');

  String getLocalizedGrowthStage(String? stage) {
    if (stage == null || stage.isEmpty) return '...';
    if (language == AppLanguage.english) {
      return stage.substring(0, 1).toUpperCase() + stage.substring(1);
    }
    final lower = stage.toLowerCase();
    switch (lower) {
      case 'nursery': return growthStageNursery;
      case 'vegetative': return growthStageVegetative;
      case 'tillering': return growthStageTillering;
      case 'booting': return growthStageBooting;
      case 'panicle_initiation':
      case 'panicle': return growthStagePanicle;
      case 'flowering': return growthStageFlowering;
      case 'fruiting': return growthStageFruiting;
      case 'grain_filling': return growthStageGrainFilling;
      case 'maturity': return growthStageMaturity;
      case 'germination': return growthStageGermination;
      case 'squaring': return growthStageSquaring;
      case 'boll_formation': return growthStageBollFormation;
      case 'boll_opening': return growthStageBollOpening;
      case 'emergence': return growthStageEmergence;
      case 'pod_formation': return growthStagePodFormation;
      case 'seed_filling': return growthStageSeedFilling;
      default: return stage;
    }
  }

  // --- Region Translation ---
  String getLocalizedRegion(String? region) {
    if (region == null || region.isEmpty) return 'महाराष्ट्र';
    if (language == AppLanguage.english) return region;
    final lower = region.toLowerCase();
    if (lower.contains('nashik') && lower.contains('maharashtra')) {
      return language == AppLanguage.marathi ? 'नाशिक, महाराष्ट्र' : 'नासिक, महाराष्ट्र';
    }
    if (lower.contains('pune') && lower.contains('maharashtra')) {
      return language == AppLanguage.marathi ? 'पुणे, महाराष्ट्र' : 'पुणे, महाराष्ट्र';
    }
    if (lower.contains('coimbatore') || lower.contains('tamil nadu')) {
      return language == AppLanguage.marathi ? 'कोइम्बतूर, तमिळनाडू' : 'कोयंबटूर, तमिलनाडु';
    }
    if (lower.contains('dharwad') || lower.contains('karnataka')) {
      return language == AppLanguage.marathi ? 'धारवाड, कर्नाटक' : 'धारवाड़, कर्नाटक';
    }
    if (lower.contains('maharashtra')) {
      return language == AppLanguage.marathi ? 'महाराष्ट्र' : 'महाराष्ट्र';
    }
    return region;
  }

  // --- Qualitative Farm Health Sentences ---
  String get healthSentenceDefault => language == AppLanguage.marathi
      ? 'शेताची माहिती नोंदवली आहे. देखरेख सुरू आहे.'
      : (language == AppLanguage.hindi
          ? 'खेत की जानकारी दर्ज है। निगरानी सक्रिय है।'
          : 'Farm memory initialized. Monitoring active.');

  String getLocalizedHealthSentence(String? sentence) {
    if (sentence == null || sentence.isEmpty) return healthSentenceDefault;
    if (language == AppLanguage.english) return sentence;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(sentence)) return sentence;
    final lower = sentence.toLowerCase();
    if (lower.contains('early blight') || (lower.contains('health is stable') && lower.contains('monitoring'))) {
      return language == AppLanguage.marathi
          ? 'टोमॅटोच्या करप्यासाठी नियमित देखरेखीसह शेताचे आरोग्य स्थिर आहे.'
          : 'टमाटर के झुलसा रोग की नियमित निगरानी के साथ खेत का स्वास्थ्य स्थिर है।';
    }
    if (lower.contains('one open problem') || lower.contains('being monitored')) {
      return language == AppLanguage.marathi
          ? '१ सक्रिय समस्या, सतत देखरेख सुरू आहे.'
          : '१ सक्रिय समस्या, निरंतर निगरानी जारी है।';
    }
    if (lower.contains('farm memory initialized') || lower.contains('monitoring active')) {
      return healthSentenceDefault;
    }
    if (lower.contains('loading farm status')) {
      return language == AppLanguage.marathi
          ? 'शेताची स्थिती लोड होत आहे...'
          : 'खेत की स्थिति लोड हो रही है...';
    }
    if (lower.contains('farm status offline') || lower.contains('cached data')) {
      return language == AppLanguage.marathi
          ? 'शेताची स्थिती ऑफलाइन. ऑफलाइन माहिती दाखवत आहे.'
          : 'खेत की स्थिति ऑफलाइन। सहेजी गई जानकारी दिखाई जा रही है।';
    }
    return sentence;
  }

  // --- Timeline Event Titles & Descriptions ---
  String getLocalizedTimelineTitle(String id, String rawTitle) {
    if (language == AppLanguage.english) return rawTitle;
    if (id == 'tl_demo_01' || id == 'tl_audit_01' || rawTitle.toLowerCase().contains('treatment recommendation')) {
      return timelineAdvisoryTitle;
    }
    if (id == 'tl_demo_02' || id == 'tl_audit_02' || rawTitle.toLowerCase().contains('blight detected') || rawTitle.toLowerCase().contains('diagnosis')) {
      return timelineDiagnosisTitle;
    }
    if (id == 'tl_demo_03' || rawTitle.toLowerCase().contains('alert')) {
      return timelineAlertTitle;
    }
    if (id == 'tl_audit_00' || rawTitle.toLowerCase().contains('image submitted')) {
      return language == AppLanguage.marathi ? 'पिकाचा फोटो सादर केला' : 'फसल का फोटो जमा किया गया';
    }
    if (id == 'tl_audit_03' || rawTitle.toLowerCase().contains('clarification')) {
      return language == AppLanguage.marathi ? 'डाउट डॉक्टर स्पष्टीकरण पूर्ण' : 'डाउट डॉक्टर स्पष्टीकरण पूर्ण';
    }
    if (id == 'tl_audit_04' || rawTitle.toLowerCase().contains('follow-up scheduled')) {
      return language == AppLanguage.marathi ? 'शेत पाहणी पाठपुरावा नियोजित' : 'खेत निरीक्षण फॉलो-अप निर्धारित';
    }
    return rawTitle;
  }

  String? getLocalizedTimelineDescription(String id, String? rawDesc) {
    if (rawDesc == null || rawDesc.isEmpty) return rawDesc;
    if (language == AppLanguage.english) return rawDesc;
    if (id == 'tl_demo_01') return timelineAdvisoryDesc;
    if (id == 'tl_demo_02') return timelineDiagnosisDesc;
    if (id == 'tl_demo_03') return timelineAlertDesc;
    if (id == 'tl_audit_00' || rawDesc.toLowerCase().contains('photo submitted')) {
      return language == AppLanguage.marathi
          ? 'पीक आरोग्य विश्लेषणासाठी टोमॅटो पानांचा फोटो सादर केला.'
          : 'फसल स्वास्थ्य विश्लेषण के लिए टमाटर की पत्ती का फोटो जमा किया गया।';
    }
    if (id == 'tl_audit_01' || rawDesc.toLowerCase().contains('trichoderma application')) {
      return language == AppLanguage.marathi
          ? 'लवकर करप्यासाठी मशागतीय छाटणी व ट्रायकोडर्मा फवारणीची शिफारस.'
          : 'अगेती झुलसा के लिए कृषि छंटाई और ट्राइकोडर्मा के छिड़काव की सिफारिश।';
    }
    if (id == 'tl_audit_02' || rawDesc.toLowerCase().contains('high confidence detection')) {
      return language == AppLanguage.marathi
          ? 'टोमॅटोच्या पानांवर ९२% खात्रीसह लवकर करपा (अल्टरनेरिया सोलानी) आढळला.'
          : 'टमाटर की पत्तियों पर ९२% सटीकता के साथ अगेती झुलसा (अल्टरनेरिया सोलानी) पाया गया।';
    }
    if (id == 'tl_audit_03' || rawDesc.toLowerCase().contains('older lower-leaf')) {
      return language == AppLanguage.marathi
          ? 'टोमॅटोच्या लवकर करप्यासाठी जुन्या पानांवरील लक्षणे निश्चित केली.'
          : 'टमाटर के अगेती झुलसा के लिए पुरानी पत्तियों के लक्षणों की पुष्टि की गई।';
    }
    if (id == 'tl_audit_04' || rawDesc.toLowerCase().contains('post-treatment recovery')) {
      return language == AppLanguage.marathi
          ? '१७ सप्टेंबर रोजी उपचारांनंतरच्या सुधारणेची पडताळणी नियोजित.'
          : '१७ सितंबर को उपचार के बाद सुधार की पुष्टि निर्धारित।';
    }
    return rawDesc;
  }

  // --- Follow-up Questions ---
  String getLocalizedFollowupQuestion(String? question) {
    if (question == null || question.isEmpty) return followupQuestionDefault;
    if (language == AppLanguage.english) return question;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(question)) return question;
    final lower = question.toLowerCase();
    if (lower.contains('check leaf spread after 7 days') || lower.contains('new lesions stopped appearing')) {
      return language == AppLanguage.marathi
          ? '७ दिवसांनंतर पानांचा प्रादुर्भाव तपासा: नवीन कोवळ्या पानांवर करप्याचे डाग थांबले आहेत का?'
          : '७ दिनों के बाद पत्तियों का फैलाव जांचें: क्या नई पत्तियों पर धब्बे आना बंद हो गए हैं?';
    }
    return followupQuestionDefault;
  }

  // --- Assigned To ---
  String getLocalizedAssignedTo(String? rawAssignedTo) {
    if (rawAssignedTo == null || rawAssignedTo.isEmpty) {
      return language == AppLanguage.marathi
          ? 'कृषी विज्ञान केंद्र (KVK) नाशिक तज्ञ पॅनल'
          : (language == AppLanguage.hindi
              ? 'कृषि विज्ञान केंद्र (KVK) नासिक विशेषज्ञ पैनल'
              : 'Krishi Vigyan Kendra (KVK) Expert Panel');
    }
    if (language == AppLanguage.english) return rawAssignedTo;
    final lower = rawAssignedTo.toLowerCase();
    if (lower.contains('kvk') || lower.contains('krishi vigyan kendra')) {
      return language == AppLanguage.marathi
          ? 'कृषी विज्ञान केंद्र (KVK) वनस्पती विकृतीशास्त्र तज्ञ पॅनल'
          : 'कृषि विज्ञान केंद्र (KVK) पादप रोग विशेषज्ञ पैनल';
    }
    return rawAssignedTo;
  }

  // --- App / About Details ---
  String get aboutAppName => language == AppLanguage.marathi
      ? 'भूमी शेतकरी साथीदार'
      : (language == AppLanguage.hindi ? 'भूमी किसान साथी' : 'Bhoomi Farmer Companion');

  String get aboutLegalese => language == AppLanguage.marathi
      ? 'महाराष्ट्र शासन — कीड व रोग नियंत्रण एकात्मिक प्रणाली'
      : (language == AppLanguage.hindi
          ? 'महाराष्ट्र शासन — कीट एवं रोग प्रबंधन प्रणाली'
          : 'Government of Maharashtra — Pest & Disease Management System');

  String callingHelpline(String title, String phone) => language == AppLanguage.marathi
      ? '$title ($phone) वर संपर्क करत आहे...'
      : (language == AppLanguage.hindi
          ? '$title ($phone) पर कॉल किया जा रहा है...'
          : 'Calling $title ($phone)...');

  String get noObservationsRecorded => language == AppLanguage.marathi
      ? 'कोणतेही प्रत्यक्ष निरीक्षण नोंदवले नाही.'
      : (language == AppLanguage.hindi ? 'कोई प्रत्यक्ष अवलोकन दर्ज नहीं है।' : 'No field observations recorded.');

  String get advisorySummaryHeader => language == AppLanguage.marathi
      ? 'उपाययोजना सारांश'
      : (language == AppLanguage.hindi ? 'उपाय सारांश' : 'Advisory Summary');

  String get listenAdvisory => language == AppLanguage.marathi
      ? 'सल्ला ऐका'
      : (language == AppLanguage.hindi ? 'सलाह सुनें' : 'Listen to Advisory');

  String getLocalizedCueLabel(String? cueId) {
    if (cueId == null || cueId.isEmpty) {
      return language == AppLanguage.marathi
          ? 'शेत प्रत्यक्ष तपासणी'
          : (language == AppLanguage.hindi ? 'खेत प्रत्यक्ष जांच' : 'Physical inspection');
    }
    if (cueId.contains('tomato_leaf_spots') || cueId.contains('leaf_spot')) {
      return language == AppLanguage.marathi
          ? 'पानांवरील डागांची तपासणी'
          : (language == AppLanguage.hindi ? 'पत्तियों पर धब्बों की जांच' : 'Leaf Spot Cue');
    }
    return 'Cue: $cueId';
  }

  String getLocalizedAnswer(String answer) {
    final lower = answer.toLowerCase();
    if (lower == 'yes') return answerYes;
    if (lower == 'no') return answerNo;
    if (lower == 'unknown') return answerUnknown;
    return answer.toUpperCase();
  }

  String get latitudePrefix => language == AppLanguage.marathi
      ? 'अक्षांश'
      : (language == AppLanguage.hindi ? 'अक्षांश' : 'Lat');

  String get longitudePrefix => language == AppLanguage.marathi
      ? 'रेखांश'
      : (language == AppLanguage.hindi ? 'रेखांश' : 'Lon');

  String get defaultInspectionTask => language == AppLanguage.marathi
      ? 'शेतातील १० झाडांची वरची पाने तपासा.'
      : (language == AppLanguage.hindi
          ? 'खेत में १० पौधों की ऊपरी पत्तियों की जांच करें।'
          : 'Check the upper leaves on 10 plants across the field.');

  String get escalationStubBanner => language == AppLanguage.marathi
      ? 'डेमो मोड: तज्ञ मार्गदर्शन सिमुलेशन सक्रिय आहे.'
      : (language == AppLanguage.hindi
          ? 'डेमो मोड: विशेषज्ञ मार्गदर्शन सिमुलेशन सक्रिय है।'
          : 'Demonstration Mode: Expert routing simulated by mock engine.');

  String get invalidCoordinatesError => language == AppLanguage.marathi
      ? 'कृपया योग्य समन्वय प्रविष्ट करा (-९० ते ९०, -१८० ते १८०)'
      : (language == AppLanguage.hindi
          ? 'कृपया वैध निर्देशांक दर्ज करें (-९० से ९०, -१८० से १८०)'
          : 'Please enter valid coordinates (-90 to 90, -180 to 180)');

  String get verifiedStatus => language == AppLanguage.marathi
      ? 'सत्यापित'
      : (language == AppLanguage.hindi ? 'सत्यापित' : 'Verified');

  String get samplePhotoPreview => language == AppLanguage.marathi
      ? 'नमुना पीक फोटो पूर्वावलोकन'
      : (language == AppLanguage.hindi ? 'नमूना फसल फोटो पूर्वावलोकन' : 'Sample Crop Photo Preview');
}

