import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';

// --- Global state management for bookings ---
class BookingProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _bookings = [
    {
      'date': DateTime(2025, 9, 2),
      'doctorName': 'Dr. Atul Srivastava',
      'specialty': 'Orthopaedics',
      'details': 'Consultation for C/O cervical spondylosis'
    },
  ];

  final List<Map<String, dynamic>> _chats = [
    {
      'doctorName': 'Dr. Preethi Rao',
      'date': DateTime(2025, 8, 28),
      'messages': [
        ChatMessage(text: "Hi there! How can I help you today?", isUser: false),
        ChatMessage(text: "I have a terrible headache and feel dizzy.", isUser: true),
        ChatMessage(text: "Have you been hydrating well? Are there any other symptoms?", isUser: false),
        ChatMessage(text: "I think it's because of my high blood pressure.", isUser: true),
        ChatMessage(text: "Please send me your latest blood pressure readings.", isUser: false),
      ]
    },
    {
      'doctorName': 'Dr. Alok Sharma',
      'date': DateTime(2025, 9, 1),
      'messages': [
        ChatMessage(text: "Hello! What brings you in today?", isUser: false),
        ChatMessage(text: "I've been having some knee pain after my morning runs.", isUser: true),
        ChatMessage(text: "Please describe the pain. Is it sharp or dull? Does it get worse with activity?", isUser: false),
      ]
    },
  ];

  List<Map<String, dynamic>> get bookings => _bookings;
  List<Map<String, dynamic>> get chats => _chats;

  void addBooking(Map<String, dynamic> booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void addMessage(String doctorName, ChatMessage message) {
    final chat = _chats.firstWhere((c) => c['doctorName'] == doctorName, orElse: () {
      final newChat = {'doctorName': doctorName, 'date': DateTime.now(), 'messages': []};
      _chats.add(newChat);
      return newChat;
    });
    chat['messages'].add(message);
    notifyListeners();
  }
}

// --- Main Application Entry Point ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    ChangeNotifierProvider(
      create: (context) => BookingProvider(),
      child: NabhaHealthcareApp(camera: firstCamera),
    ),
  );
}

// --- App Localizations (Manual for simplicity, usually generated) ---
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  String get appTitle {
    switch (locale.languageCode) {
      case 'ml':
        return 'നാഭ ഹെൽത്ത് കെയർ';
      case 'bn':
        return 'স্বাস্থ্য সাথী';
      case 'hi':
        return 'सेहत साथी';
      default:
        return 'Sehat Saathi';
    }
  }

  String get myHealth {
    switch (locale.languageCode) {
      case 'ml':
        return 'എന്റെ ആരോഗ്യം';
      case 'bn':
        return 'আমার স্বাস্থ্য';
      case 'hi':
        return 'मेरा स्वास्थ्य';
      default:
        return 'My Health';
    }
  }

  String get home {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഹോം';
      case 'bn':
        return 'হোম';
      case 'hi':
        return 'হোম';
      default:
        return 'Home';
    }
  }

  String get healthRecords {
    switch (locale.languageCode) {
      case 'ml':
        return 'ആരോഗ്യ രേഖകൾ';
      case 'bn':
        return 'স্বাস্থ্য রেকর্ড';
      case 'hi':
        return 'स्वास्थ्य रिकॉर्ड';
      default:
        return 'Health Records';
    }
  }

  String get healthReports {
    switch (locale.languageCode) {
      case 'ml':
        return 'ആരോഗ്യ റിപ്പോർട്ടുകൾ';
      case 'bn':
        return 'স্বাস্থ্য রিপোর্ট';
      case 'hi':
        return 'স্বাস্থ্য রিপোর্ট';
      default:
        return 'Health Reports';
    }
  }

  String get pharmacy {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഫാർമസി';
      case 'bn':
        return 'ফার্মেসি';
      case 'hi':
        return 'फार्मेसी';
      default:
        return 'Pharmacy';
    }
  }

  String get symptomChecker {
    switch (locale.languageCode) {
      case 'ml':
        return 'രോഗലക്ഷണ പരിശോധന';
      case 'bn':
        return 'লক্ষণ পরীক্ষণ';
      case 'hi':
        return 'लक्षण जांचकर्ता';
      default:
        return 'Symptom Checker';
    }
  }

  String get bookAppointment {
    switch (locale.languageCode) {
      case 'ml':
        return 'അപ്പോയിന്റ്മെന്റ് ബുക്ക് ചെയ്യുക';
      case 'bn':
        return 'অ্যাপয়েন্টমেন্ট বুক করুন';
      case 'hi':
        return 'अपॉइंटमेंट बुक करें';
      default:
        return 'Book Appointment';
    }
  }

  String get testsAndCheckups {
    switch (locale.languageCode) {
      case 'ml':
        return 'ടെസ്റ്റുകളും പരിശോധനകളും';
      case 'bn':
        return 'পরীক্ষা ও চেকআপ';
      case 'hi':
        return 'टेस्ट और चेकअप';
      default:
        return 'Tests & Checkups';
    }
  }

  String get myBookings {
    switch (locale.languageCode) {
      case 'ml':
        return 'എന്റെ ബുക്കിംഗുകൾ';
      case 'bn':
        return 'আমার বুকিং';
      case 'hi':
        return 'मेरी बुकिंग';
      default:
        return 'My Bookings';
    }
  }

  String get vaccineImmunization {
    switch (locale.languageCode) {
      case 'ml':
        return 'വാക്സിൻ & പ്രതിരോധ കുത്തിവയ്പ്പ്';
      case 'bn':
        return 'ভ্যাকসিন ও টিকাকরণ';
      case 'hi':
        return 'वैक्सीन और टीकाकरण';
      default:
        return 'Vaccine & Immunization';
    }
  }

  String get ourExpertise {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഞങ്ങളുടെ വൈദഗ്ധ്യം';
      case 'bn':
        return 'আমাদের দক্ষতা';
      case 'hi':
        return 'हमारी विशेषज्ञता';
      default:
        return 'Our Expertise';
    }
  }

  String get cardiacSciences {
    switch (locale.languageCode) {
      case 'ml':
        return 'കാർഡിയാക് സയൻസസ്';
      case 'bn':
        return 'কার্ডিয়াক সায়েন্সেস';
      case 'hi':
        return 'কার্ডিয়েক সাইন্সেস';
      default:
        return 'Cardiac Sciences';
    }
  }

  String get cancerCare {
    switch (locale.languageCode) {
      case 'ml':
        return 'കാൻസർ കെയർ';
      case 'bn':
        return 'ক্যান্সার কেয়ার';
      case 'hi':
        return 'ক্যান্সার যত্ন';
      default:
        return 'Cancer Care';
    }
  }

  String get neuroSciences {
    switch (locale.languageCode) {
      case 'ml':
        return 'ന്യൂറോ സയൻസസ്';
      case 'bn':
        return 'নিউরো সায়েন্সেস';
      case 'hi':
        return 'স্নায়ু বিজ্ঞান';
      default:
        return 'Neuro Sciences';
    }
  }

  String get nephrology {
    switch (locale.languageCode) {
      case 'ml':
        return 'നെഫ്രോളജി';
      case 'bn':
        return 'নেফ্রোলজি';
      case 'hi':
        return 'নেফ্রোলজি';
      default:
        return 'Nephrology';
    }
  }

  String get gastroenterology {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഗ്യാസ്‌ട്രോഎൻട്രോളജി';
      case 'bn':
        return 'গ্যাস্ট্রোএন্টেরোলজি';
      case 'hi':
        return 'গ্যাস্ট্রোএন্টারোলজি';
      default:
        return 'Gastroenterology';
    }
  }

  String get orthopaedics {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഓർത്തോപീഡിക്സ്';
      case 'bn':
        return 'অর্থোপেডিকস';
      case 'hi':
        return 'অর্থোপেডিকস';
      default:
        return 'Orthopaedics';
    }
  }

  String get searchByDoctorName {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഡോക്ടറുടെ പേര് തിരയുക';
      case 'bn':
        return 'ডাক্তারের নাম দিয়ে অনুসন্ধান করুন';
      case 'hi':
        return 'डॉक्टर के नाम से खोजें';
      default:
        return 'Search by doctor\'s name';
    }
  }

  String get hospitals {
    switch (locale.languageCode) {
      case 'ml':
        return 'ആശുപത്രികൾ';
      case 'bn':
        return 'হাসপাতাল';
      case 'hi':
        return 'अस्पताल';
      default:
        return 'Hospitals';
    }
  }

  String get doctors {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഡോക്ടർമാർ';
      case 'bn':
        return 'ডাক্তার';
      case 'hi':
        return 'डॉक्टर';
      default:
        return 'Doctors';
    }
  }

  String get selectLanguage {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഭാഷ തിരഞ്ഞെടുക്കുക';
      case 'bn':
        return 'ভাষা নির্বাচন করুন';
      case 'hi':
        return 'ভাষা চয়ন করুন';
      default:
        return 'Select Language';
    }
  }

  String get english {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഇംഗ്ലീഷ്';
      case 'bn':
        return 'ইংরেজি';
      case 'hi':
        return 'अंग्रेजी';
      default:
        return 'English';
    }
  }

  String get malayalam {
    switch (locale.languageCode) {
      case 'ml':
        return 'മലയാളം';
      case 'bn':
        return 'মালায়ালাম';
      case 'hi':
        return 'মালায়ালম';
      default:
        return 'Malayalam';
    }
  }

  String get bengali {
    switch (locale.languageCode) {
      case 'ml':
        return 'ബംഗാളി';
      case 'bn':
        return 'বাংলা';
      case 'hi':
        return 'বাংলা';
      default:
        return 'Bengali';
    }
  }

  String get hindi {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഹിന്ദി';
      case 'bn':
        return 'হিন্দি';
      case 'hi':
        return 'হিন্দি';
      default:
        return 'Hindi';
    }
  }

  String get teleconsultDescription {
    switch (locale.languageCode) {
      case 'ml':
        return 'ഡോക്ടർമാരുമായി വീഡിയോ കോളിലൂടെ ബന്ധപ്പെടുക. നിങ്ങളുടെ വീടിന്റെ സുഖസൗകര്യങ്ങളിൽ നിന്ന് വൈദ്യോപദേശം നേടുക.';
      case 'bn':
        return 'ভিডিও কলের মাধ্যমে ডাক্তারদের সাথে সংযোগ করুন। আপনার বাড়ির আরাম থেকে চিকিৎসা পরামর্শ নিন।';
      case 'hi':
        return 'ভিডিও কলের মাধ্যমে ডাক্তারদের সাথে সংযোগ করুন। আপনার বাড়ির আরাম থেকে চিকিৎসা পরামর্শ নিন।';
      default:
        return 'Connect with doctors via video call. Get medical advice from the comfort of your home.';
    }
  }

  String get addRecord {
    switch (locale.languageCode) {
      case 'ml':
        return 'രേഖ ചേർക്കുക';
      case 'bn':
        return 'রেকর্ড যোগ করুন';
      case 'hi':
        return 'রেকর্ড যোগ করুন';
      default:
        return 'Add Record';
    }
  }

  String get recordTitle {
    switch (locale.languageCode) {
      case 'ml':
        return 'രേഖയുടെ തലക്കെട്ട്';
      case 'bn':
        return 'রেকর্ডের শিরোনাম';
      case 'hi':
        return 'রেকর্ড শিরোনাম';
      default:
        return 'Record Title';
    }
  }

  String get recordDetails {
    switch (locale.languageCode) {
      case 'ml':
        return 'രേഖയുടെ വിവരങ്ങൾ';
      case 'bn':
        return 'রেকর্ডের বিবরণ';
      case 'hi':
        return 'রেকর্ড বিবরণ';
      default:
        return 'Record Details';
    }
  }

  String get selectImage {
    switch (locale.languageCode) {
      case 'ml':
        return 'ചിത്രം തിരഞ്ഞെടുക്കുക';
      case 'bn':
        return 'ছবি নির্বাচন করুন';
      case 'hi':
        return 'ছবি নির্বাচন করুন';
      default:
        return 'Select Image';
    }
  }

  String get saveRecord {
    switch (locale.languageCode) {
      case 'ml':
        return 'രേഖ സംരക്ഷിക്കുക';
      case 'bn':
        return 'রেকর্ড সংরক্ষণ করুন';
      case 'hi':
        return 'রেকর্ড সংরক্ষণ করুন';
      default:
        return 'Save Record';
    }
  }

  String get noRecords {
    switch (locale.languageCode) {
      case 'ml':
        return 'രേഖകളൊന്നും ലഭ്യമല്ല.';
      case 'bn':
        return 'কোনো স্বাস্থ্য রেকর্ড নেই।';
      case 'hi':
        return 'कोई स्वास्थ्य रिकॉर्ड उपलब्ध नहीं है।';
      default:
        return 'No health records available.';
    }
  }

  String get medicineAvailability {
    switch (locale.languageCode) {
      case 'ml':
        return 'മരുന്ന് ലഭ്യത';
      case 'bn':
        return 'ওষুধের প্রাপ্যতা';
      case 'hi':
        return 'दवा की उपलब्धता';
      default:
        return 'Medicine Availability';
    }
  }

  String get searchMedicine {
    switch (locale.languageCode) {
      case 'ml':
        return 'മരുന്ന് തിരയുക...';
      case 'bn':
        return 'ওষুধ অনুসন্ধান করুন...';
      case 'hi':
        return 'দवा खोजें...';
      default:
        return 'Search medicine...';
    }
  }

  String get typeYourSymptoms {
    switch (locale.languageCode) {
      case 'ml':
        return 'നിങ്ങളുടെ രോഗലക്ഷണങ്ങൾ ടൈപ്പ് ചെയ്യുക...';
      case 'bn':
        return 'আপনার লক্ষণগুলি টাইপ করুন...';
      case 'hi':
        return 'अपने लक्षण टाइप करें...';
      default:
        return 'Type your symptoms...';
    }
  }

  String get symptomCheckerIntro {
    switch (locale.languageCode) {
      case 'ml':
        return 'നിങ്ങളുടെ രോഗലക്ഷണങ്ങൾ എന്താണെന്ന് എന്നോട് പറയുക, ഞാൻ ചില വിവരങ്ങൾ നൽകാം. ഇത് ഒരു മെഡിക്കൽ ഉപദേശമല്ല.';
      case 'bn':
        return 'আপনার লক্ষণগুলি আমাকে বলুন, এবং আমি কিছু তথ্য দিতে পারি। এটি চিকিৎসা পরামর্শ নয়।';
      case 'hi':
        return 'আপনার লক্ষণগুলি আমাকে বলুন, এবং আমি কিছু তথ্য দিতে পারি। এটি চিকিৎসা পরামর্শ নয়।';
      default:
        return 'Tell me your symptoms, and I can provide some information. This is not medical advice.';
    }
  }

  String get error {
    switch (locale.languageCode) {
      case 'ml':
        return 'പിശക്';
      case 'bn':
        return 'ত্রুটি';
      case 'hi':
        return 'ত্রুটি';
      default:
        return 'Error';
    }
  }

  String get geminiError {
    switch (locale.languageCode) {
      case 'ml':
        return 'ജെമിനി എപിഐ പിശക്';
      case 'bn':
        return 'জেমিনি এপিআই ত্রুটি';
      case 'hi':
        return 'জেমিনি এপিআই ত্রুটি';
      default:
        return 'Gemini API Error';
    }
  }

  String get networkError {
    switch (locale.languageCode) {
      case 'ml':
        return 'നെറ്റ്‌വർക്ക് പിശക്';
      case 'bn':
        return 'নেটওয়ার্ক ত্রুটি';
      case 'hi':
        return 'নেটওয়ার্ক ত্রুটি';
      default:
        return 'Network Error';
    }
  }

  String get recordAddedSuccessfully {
    switch (locale.languageCode) {
      case 'ml':
        return 'രേഖ വിജയകരമായി ചേർത്തു.';
      case 'bn':
        return 'রেকর্ড সফলভাবে যোগ করা হয়েছে।';
      case 'hi':
        return 'রেকর্ড সফলভাবে যোগ করা হয়েছে।';
      default:
        return 'Record added successfully.';
    }
  }

  String get enterTitleAndDetails {
    switch (locale.languageCode) {
      case 'ml':
        return 'തലക്കെട്ടും വിവരങ്ങളും നൽകുക.';
      case 'bn':
        return 'অনুগ্রহ করে শিরোনাম এবং বিবরণ লিখুন।';
      case 'hi':
        return 'অনুগ্রহ করে শিরোনাম এবং বিবরণ লিখুন।';
      default:
        return 'Please enter title and details.';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ml', 'bn', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// --- Nabha Healthcare App Widget ---
class NabhaHealthcareApp extends StatefulWidget {
  final CameraDescription camera;
  const NabhaHealthcareApp({super.key, required this.camera});

  @override
  State<NabhaHealthcareApp> createState() => _NabhaHealthcareAppState();
}

class _NabhaHealthcareAppState extends State<NabhaHealthcareApp> {
  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  Future<void> _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehat Saathi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6666CC),
          primary: const Color(0xFF6666CC), // Deep Blue
          onPrimary: Colors.white,
          secondary: const Color(0xFFE88A1A), // Orange
          onSecondary: Colors.white,
          tertiary: const Color(0xFF6A994E), // Green
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF212121),
          surfaceVariant: const Color(0xFFF0F0F0),
          onSurfaceVariant: const Color(0xFF424242),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6666CC),
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFFE88A1A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 6,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Color(0xFF6666CC), width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6666CC),
          unselectedItemColor: Colors.grey.shade600,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ml', ''),
        Locale('bn', ''),
        Locale('hi', ''),
      ],
      home: HomePage(setLocale: _setLocale, camera: widget.camera),
    );
  }
}

// --- MOCK DOCTOR DATA (Increased to 50, added hospitals and specializations) ---
class MockData {
  static final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Alok Sharma', 'specialty': 'Orthopaedics', 'qualifications': 'MBBS, MS (Orthopaedics)', 'experienceYears': 15, 'timeSlot': 'Mon-Fri, 10:00 AM - 1:00 PM',
      'hospitals': ['City Hospital, New Delhi', 'Apollo Clinic, Gurugram', 'Fortis Hospital, New Delhi']
    },
    {
      'name': 'Dr. Kavitha Menon', 'specialty': 'Gastroenterology', 'qualifications': 'MBBS, MD (Internal Medicine), DM (Gastroenterology)', 'experienceYears': 10, 'timeSlot': 'Mon-Wed-Fri, 9:00 AM - 12:00 PM',
      'hospitals': ['Nabha Medicals, Kochi', 'Aster Medcity, Kochi']
    },
    {
      'name': 'Dr. Arjun Reddy', 'specialty': 'Neuro Sciences', 'qualifications': 'MBBS, MD (General Medicine), DM (Neurology)', 'experienceYears': 12, 'timeSlot': 'Tue-Thu, 11:00 AM - 2:00 PM',
      'hospitals': ['Nabha Medicals, Hyderabad', 'Yashoda Hospitals, Hyderabad']
    },
    {
      'name': 'Dr. Preethi Rao', 'specialty': 'Cardiac Sciences', 'qualifications': 'MBBS, MD (General Medicine), DM (Cardiology)', 'experienceYears': 18, 'timeSlot': 'Mon-Sat, 9:30 AM - 1:30 PM',
      'hospitals': ['Narayana Health, Bengaluru', 'Manipal Hospitals, Bengaluru']
    },
    {
      'name': 'Dr. Vimal Kumar', 'specialty': 'Dermatology', 'qualifications': 'MBBS, MD (Dermatology)', 'experienceYears': 8, 'timeSlot': 'Tue-Fri, 3:00 PM - 6:00 PM',
      'hospitals': ['Max Healthcare, New Delhi', 'Apollo Clinic, New Delhi']
    },
    {
      'name': 'Dr. Anjali Singh', 'specialty': 'Pediatrics', 'qualifications': 'MBBS, MD (Pediatrics)', 'experienceYears': 11, 'timeSlot': 'Mon-Sat, 2:00 PM - 5:00 PM',
      'hospitals': ['Rainbow Children’s Hospital, Bengaluru', 'Cloudnine Hospital, Bengaluru']
    },
    {
      'name': 'Dr. Rajesh Nair', 'specialty': 'General Physician', 'qualifications': 'MBBS, MD (General Medicine)', 'experienceYears': 20, 'timeSlot': 'Mon-Fri, 8:00 AM - 11:00 AM',
      'hospitals': ['Nabha Medicals, Kochi', 'Lisie Hospital, Kochi']
    },
    {
      'name': 'Dr. Nisha Patel', 'specialty': 'Endocrinology', 'qualifications': 'MBBS, MD, DM (Endocrinology)', 'experienceYears': 14, 'timeSlot': 'Wed-Sat, 10:00 AM - 1:00 PM',
      'hospitals': ['Apollo Hospitals, Ahmedabad', 'Sterling Hospital, Ahmedabad']
    },
    {
      'name': 'Dr. Suresh Kumar', 'specialty': 'Urology', 'qualifications': 'MBBS, MS, MCh (Urology)', 'experienceYears': 16, 'timeSlot': 'Mon-Tue, 4:00 PM - 7:00 PM',
      'hospitals': ['Fortis Hospital, Mumbai', 'Global Hospitals, Mumbai']
    },
    {
      'name': 'Dr. Maya Krishnan', 'specialty': 'Ophthalmology', 'qualifications': 'MBBS, MS (Ophthalmology)', 'experienceYears': 9, 'timeSlot': 'Tue-Thu-Sat, 1:00 PM - 4:00 PM',
      'hospitals': ['Narayana Nethralaya, Bengaluru', 'Dr. Agarwal’s Eye Hospital, Bengaluru']
    },
    {
      'name': 'Dr. Siddharth Jain', 'specialty': 'Pulmonology', 'qualifications': 'MBBS, MD (Pulmonary Medicine)', 'experienceYears': 7, 'timeSlot': 'Mon-Fri, 1:30 PM - 4:30 PM',
      'hospitals': ['Medanta, Gurugram', 'Max Healthcare, Gurugram']
    },
    {
      'name': 'Dr. Rohit Verma', 'specialty': 'Cardiac Sciences', 'qualifications': 'MBBS, MD, DM (Cardiology)', 'experienceYears': 22, 'timeSlot': 'Mon-Wed-Fri, 10:00 AM - 2:00 PM',
      'hospitals': ['Apollo Hospitals, Chennai', 'MIOT International, Chennai']
    },
    {
      'name': 'Dr. Aarti Desai', 'specialty': 'Nephrology', 'qualifications': 'MBBS, MD, DM (Nephrology)', 'experienceYears': 19, 'timeSlot': 'Tue-Thu, 9:00 AM - 1:00 PM',
      'hospitals': ['Fortis Hospitals, Mumbai', 'Lilavati Hospital, Mumbai']
    },
    {
      'name': 'Dr. Sameer Khan', 'specialty': 'Orthopaedics', 'qualifications': 'MBBS, MS (Orthopaedics)', 'experienceYears': 14, 'timeSlot': 'Mon-Sat, 11:00 AM - 3:00 PM',
      'hospitals': ['Columbia Asia Hospital, Pune', 'Ruby Hall Clinic, Pune']
    },
    {
      'name': 'Dr. Priya Sharma', 'specialty': 'Gastroenterology', 'qualifications': 'MBBS, MD, DM (Gastroenterology)', 'experienceYears': 13, 'timeSlot': 'Wed-Fri, 2:00 PM - 5:00 PM',
      'hospitals': ['Max Healthcare, New Delhi', 'Aakash Hospital, New Delhi']
    },
    {
      'name': 'Dr. Karan Gupta', 'specialty': 'Neuro Sciences', 'qualifications': 'MBBS, MD, DM (Neurology)', 'experienceYears': 25, 'timeSlot': 'Mon-Sat, 9:00 AM - 1:00 PM',
      'hospitals': ['Narayana Health, Bengaluru', 'Aster CMI Hospital, Bengaluru']
    },
    {
      'name': 'Dr. Aditi Mukherjee', 'specialty': 'Pediatrics', 'qualifications': 'MBBS, DNB (Pediatrics)', 'experienceYears': 10, 'timeSlot': 'Tue-Thu, 10:00 AM - 1:00 PM',
      'hospitals': ['Apollo Hospitals, Kolkata', 'AMRI Hospitals, Kolkata']
    },
    {
      'name': 'Dr. Sanjay Agarwal', 'specialty': 'Urology', 'qualifications': 'MBBS, MS, MCh (Urology)', 'experienceYears': 17, 'timeSlot': 'Mon-Fri, 9:30 AM - 12:30 PM',
      'hospitals': ['Medanta, Gurugram', 'Fortis Memorial Research Institute, Gurugram']
    },
    {
      'name': 'Dr. Nikita Bansal', 'specialty': 'Endocrinology', 'qualifications': 'MBBS, MD, DM (Endocrinology)', 'experienceYears': 9, 'timeSlot': 'Tue-Wed-Fri, 11:00 AM - 2:00 PM',
      'hospitals': ['Artemis Hospital, Gurugram', 'Max Healthcare, Gurugram']
    },
    {
      'name': 'Dr. Vishal Singh', 'specialty': 'Pulmonology', 'qualifications': 'MBBS, MD (Pulmonary Medicine)', 'experienceYears': 11, 'timeSlot': 'Mon-Fri, 2:00 PM - 5:00 PM',
      'hospitals': ['Fortis Hospital, Noida', 'Apollo Hospitals, Noida']
    },
    {
      'name': 'Dr. Sneha Raj', 'specialty': 'Ophthalmology', 'qualifications': 'MBBS, MS (Ophthalmology)', 'experienceYears': 15, 'timeSlot': 'Mon-Thu-Sat, 10:00 AM - 1:00 PM',
      'hospitals': ['Vasan Eye Care, Chennai', 'Sankara Nethralaya, Chennai']
    },
    {
      'name': 'Dr. Arvind Joshi', 'specialty': 'Cardiac Sciences', 'qualifications': 'MBBS, MD, DM (Cardiology)', 'experienceYears': 20, 'timeSlot': 'Mon-Tue-Fri, 3:00 PM - 6:00 PM',
      'hospitals': ['Narayana Health, Bengaluru', 'Fortis Hospitals, Bengaluru']
    },
    {
      'name': 'Dr. Surbhi Singh', 'specialty': 'Gastroenterology', 'qualifications': 'MBBS, MD, DM (Gastroenterology)', 'experienceYears': 8, 'timeSlot': 'Tue-Thu-Sat, 11:00 AM - 2:00 PM',
      'hospitals': ['Sir Ganga Ram Hospital, New Delhi', 'Apollo Hospitals, New Delhi']
    },
    {
      'name': 'Dr. Mukesh Verma', 'specialty': 'Orthopaedics', 'qualifications': 'MBBS, MS (Orthopaedics)', 'experienceYears': 18, 'timeSlot': 'Mon-Fri, 9:00 AM - 1:00 PM',
      'hospitals': ['Medanta, Gurugram', 'Max Hospital, Gurugram']
    },
    {
      'name': 'Dr. Rina Das', 'specialty': 'Neuro Sciences', 'qualifications': 'MBBS, MD, DM (Neurology)', 'experienceYears': 16, 'timeSlot': 'Mon-Wed-Fri, 10:00 AM - 1:00 PM',
      'hospitals': ['Apollo Gleneagles Hospitals, Kolkata', 'Fortis Hospital, Kolkata']
    },
    {
      'name': 'Dr. Vikram Sharma', 'specialty': 'Cancer Care', 'qualifications': 'MBBS, MD (Radiation Oncology)', 'experienceYears': 25, 'timeSlot': 'Mon-Fri, 9:00 AM - 5:00 PM',
      'hospitals': ['Rajiv Gandhi Cancer Institute, New Delhi', 'Max Institute of Cancer Care, New Delhi']
    },
    {
      'name': 'Dr. Leena Shah', 'specialty': 'Cancer Care', 'qualifications': 'MBBS, MD, DM (Medical Oncology)', 'experienceYears': 19, 'timeSlot': 'Tue-Thu-Sat, 10:00 AM - 2:00 PM',
      'hospitals': ['Apollo Hospitals, Chennai', 'MIOT International, Chennai']
    },
    {
      'name': 'Dr. Deepak Rao', 'specialty': 'Nephrology', 'qualifications': 'MBBS, MD, DM (Nephrology)', 'experienceYears': 14, 'timeSlot': 'Mon-Wed-Fri, 1:00 PM - 4:00 PM',
      'hospitals': ['Global Hospitals, Hyderabad', 'Yashoda Hospitals, Hyderabad']
    },
    {
      'name': 'Dr. Geetha Kumar', 'specialty': 'Nephrology', 'qualifications': 'MBBS, MD, DM (Nephrology)', 'experienceYears': 11, 'timeSlot': 'Tue-Thu, 10:00 AM - 1:00 PM',
      'hospitals': ['Columbia Asia Hospital, Pune', 'Jehangir Hospital, Pune']
    },
    {
      'name': 'Dr. Sumit Bansal', 'specialty': 'Pediatrics', 'qualifications': 'MBBS, MD (Pediatrics)', 'experienceYears': 15, 'timeSlot': 'Mon-Fri, 4:00 PM - 7:00 PM',
      'hospitals': ['Max Healthcare, Gurugram', 'Fortis Memorial Research Institute, Gurugram']
    },
    {
      'name': 'Dr. Anu Patel', 'specialty': 'General Physician', 'qualifications': 'MBBS, MD (General Medicine)', 'experienceYears': 12, 'timeSlot': 'Mon-Sat, 9:00 AM - 12:00 PM',
      'hospitals': ['Nabha Medicals, Ahmedabad', 'Apollo Clinic, Ahmedabad']
    },
    {
      'name': 'Dr. Anand Kumar', 'specialty': 'Orthopaedics', 'qualifications': 'MBBS, MS (Orthopaedics)', 'experienceYears': 20, 'timeSlot': 'Mon-Fri, 10:00 AM - 2:00 PM',
      'hospitals': ['Aster Medcity, Kochi', 'Lisie Hospital, Kochi']
    },
    {
      'name': 'Dr. Lakshmi Gopal', 'specialty': 'Ophthalmology', 'qualifications': 'MBBS, MS (Ophthalmology)', 'experienceYears': 10, 'timeSlot': 'Tue-Thu-Sat, 2:00 PM - 5:00 PM',
      'hospitals': ['Narayana Nethralaya, Bengaluru', 'Manipal Hospitals, Bengaluru']
    },
    {
      'name': 'Dr. Rahul Bose', 'specialty': 'Pulmonology', 'qualifications': 'MBBS, MD (Pulmonary Medicine)', 'experienceYears': 13, 'timeSlot': 'Wed-Fri, 10:00 AM - 1:00 PM',
      'hospitals': ['Fortis Hospital, Noida', 'Max Healthcare, Noida']
    },
    {
      'name': 'Dr. Sneha Sinha', 'specialty': 'Endocrinology', 'qualifications': 'MBBS, MD, DM (Endocrinology)', 'experienceYears': 16, 'timeSlot': 'Mon-Fri, 1:00 PM - 4:00 PM',
      'hospitals': ['Artemis Hospital, Gurugram', 'Medanta, Gurugram']
    },
    {
      'name': 'Dr. Rohan Mehra', 'specialty': 'Neuro Sciences', 'qualifications': 'MBBS, MD, DM (Neurology)', 'experienceYears': 18, 'timeSlot': 'Mon-Wed-Fri, 9:30 AM - 12:30 PM',
      'hospitals': ['Sir Ganga Ram Hospital, New Delhi', 'Apollo Hospitals, New Delhi']
    },
    {
      'name': 'Dr. Vinay Reddy', 'specialty': 'Cardiac Sciences', 'qualifications': 'MBBS, MD, DM (Cardiology)', 'experienceYears': 12, 'timeSlot': 'Tue-Thu, 11:00 AM - 2:00 PM',
      'hospitals': ['Manipal Hospitals, Bengaluru', 'Apollo Hospitals, Bengaluru']
    },
    {
      'name': 'Dr. Preeti Jain', 'specialty': 'Gastroenterology', 'qualifications': 'MBBS, MD, DM (Gastroenterology)', 'experienceYears': 17, 'timeSlot': 'Mon-Sat, 10:00 AM - 1:00 PM',
      'hospitals': ['Nabha Medicals, Mumbai', 'Lilavati Hospital, Mumbai']
    },
    {
      'name': 'Dr. Karthik Menon', 'specialty': 'Nephrology', 'qualifications': 'MBBS, MD, DM (Nephrology)', 'experienceYears': 9, 'timeSlot': 'Mon-Fri, 8:00 AM - 11:00 AM',
      'hospitals': ['Fortis Hospital, Chennai', 'Apollo Hospitals, Chennai']
    },
    {
      'name': 'Dr. Smita Rao', 'specialty': 'Cancer Care', 'qualifications': 'MBBS, MD (Medical Oncology)', 'experienceYears': 14, 'timeSlot': 'Tue-Thu, 1:00 PM - 4:00 PM',
      'hospitals': ['Narayana Health, Bengaluru', 'HCG Cancer Hospital, Bengaluru']
    },
    {
      'name': 'Dr. Ashwin Gupta', 'specialty': 'Urology', 'qualifications': 'MBBS, MS, MCh (Urology)', 'experienceYears': 13, 'timeSlot': 'Wed-Sat, 9:00 AM - 12:00 PM',
      'hospitals': ['Max Healthcare, New Delhi', 'Sir Ganga Ram Hospital, New Delhi']
    },
    {
      'name': 'Dr. Pooja Sharma', 'specialty': 'Dermatology', 'qualifications': 'MBBS, MD (Dermatology)', 'experienceYears': 8, 'timeSlot': 'Mon-Wed-Fri, 10:00 AM - 1:00 PM',
      'hospitals': ['Apollo Hospitals, Mumbai', 'Global Hospitals, Mumbai']
    },
    {
      'name': 'Dr. Dinesh Kumar', 'specialty': 'General Physician', 'qualifications': 'MBBS, MD (General Medicine)', 'experienceYears': 25, 'timeSlot': 'Mon-Sat, 11:00 AM - 2:00 PM',
      'hospitals': ['Nabha Medicals, Hyderabad', 'Yashoda Hospitals, Hyderabad']
    },
    {
      'name': 'Dr. Sunita Patel', 'specialty': 'Pediatrics', 'qualifications': 'MBBS, MD (Pediatrics)', 'experienceYears': 18, 'timeSlot': 'Tue-Thu, 9:00 AM - 12:00 PM',
      'hospitals': ['Rainbow Children’s Hospital, Hyderabad', 'Apollo Hospitals, Hyderabad']
    },
    {
      'name': 'Dr. Ankit Singh', 'specialty': 'Pulmonology', 'qualifications': 'MBBS, MD (Pulmonary Medicine)', 'experienceYears': 9, 'timeSlot': 'Mon-Fri, 3:00 PM - 6:00 PM',
      'hospitals': ['Fortis Memorial Research Institute, Gurugram', 'Medanta, Gurugram']
    },
    {
      'name': 'Dr. Reena Sen', 'specialty': 'Endocrinology', 'qualifications': 'MBBS, MD, DM (Endocrinology)', 'experienceYears': 11, 'timeSlot': 'Wed-Sat, 10:00 AM - 1:00 PM',
      'hospitals': ['Apollo Gleneagles Hospitals, Kolkata', 'AMRI Hospitals, Kolkata']
    },
    {
      'name': 'Dr. Abhinav Gupta', 'specialty': 'Neuro Sciences', 'qualifications': 'MBBS, MD, DM (Neurology)', 'experienceYears': 20, 'timeSlot': 'Mon-Fri, 2:00 PM - 5:00 PM',
      'hospitals': ['Manipal Hospitals, Bengaluru', 'Fortis Hospitals, Bengaluru']
    },
    {
      'name': 'Dr. Nandini Iyer', 'specialty': 'Gastroenterology', 'qualifications': 'MBBS, MD, DM (Gastroenterology)', 'experienceYears': 13, 'timeSlot': 'Tue-Thu, 9:00 AM - 1:00 PM',
      'hospitals': ['Apollo Hospitals, Chennai', 'MIOT International, Chennai']
    },
    {
      'name': 'Dr. Vivek Sharma', 'specialty': 'Cardiac Sciences', 'qualifications': 'MBBS, MD, DM (Cardiology)', 'experienceYears': 16, 'timeSlot': 'Mon-Sat, 9:00 AM - 1:00 PM',
      'hospitals': ['Sir Ganga Ram Hospital, New Delhi', 'Max Healthcare, New Delhi']
    },
    {
      'name': 'Dr. Shilpa Deshmukh', 'specialty': 'Ophthalmology', 'qualifications': 'MBBS, MS (Ophthalmology)', 'experienceYears': 12, 'timeSlot': 'Mon-Wed-Fri, 1:00 PM - 4:00 PM',
      'hospitals': ['Nabha Medicals, Pune', 'Ruby Hall Clinic, Pune']
    },
    {
      'name': 'Dr. Pankaj Jain', 'specialty': 'Urology', 'qualifications': 'MBBS, MS, MCh (Urology)', 'experienceYears': 19, 'timeSlot': 'Tue-Thu, 10:00 AM - 1:00 PM',
      'hospitals': ['Nabha Medicals, Mumbai', 'Kokilaben Dhirubhai Ambani Hospital, Mumbai']
    },
  ];
}


// --- Chat Message Model (for Symptom Checker and My Health) ---
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// --- Health Record Model (for Offline Storage) ---
class HealthRecord {
  final int? id;
  final String title;
  final String details;
  final String? imagePath;
  final DateTime timestamp;

  HealthRecord({
    this.id,
    required this.title,
    required this.details,
    this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      title: map['title'],
      details: map['details'],
      imagePath: map['imagePath'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

// --- Local Database Service (for Health Records) ---
class LocalDatabaseService {
  static Database? _database;
  static const String _tableName = 'health_records';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/health_records.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            details TEXT,
            imagePath TEXT,
            timestamp TEXT
          )
          ''',
        );
      },
    );
  }

  Future<void> insertRecord(HealthRecord record) async {
    final db = await database;
    await db.insert(
      _tableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HealthRecord>> getRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query(_tableName, orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return HealthRecord.fromMap(maps[i]);
    });
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// --- MOCK COLORS FOR THE NEW UI ---
// To simulate the colorful icons and elements in the image
const List<Color> _vibrantColors = [
  Color(0xFF6B5B95), // a deep purple
  Color(0xFF88B04B), // a lively green
  Color(0xFFE63946), // a strong red
  Color(0xFF2A9D8F), // a blue-green teal
  Color(0xFFF4A261), // a warm orange
  Color(0xFFE76F51), // a reddish-orange
];


// --- Home Page (Main Navigation) ---
class HomePage extends StatefulWidget {
  final Function(Locale) setLocale;
  final CameraDescription camera;
  const HomePage({super.key, required this.setLocale, required this.camera});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDoctors);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDoctors);
    _searchController.dispose();
    super.dispose();
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDoctors = [];
      } else {
        _filteredDoctors = MockData.doctors.where((doctor) {
          final name = doctor['name']!.toLowerCase();
          final specialty = doctor['specialty']!.toLowerCase();
          final hospitals = doctor['hospitals']!.map((h) => h.toLowerCase()).toList();
          return name.contains(query) || specialty.contains(query) || hospitals.any((h) => h.contains(query));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<Widget> pages = <Widget>[
      _buildHomeContent(localizations),
      MyHealthScreen(localizations: localizations),
      PharmacyScreen(localizations: localizations),
      SymptomCheckerScreen(localizations: localizations),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(
        title: Text(localizations.appTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<Locale>(
              value: localizations.locale,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: Theme.of(context).colorScheme.primary,
              underline: const SizedBox.shrink(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  widget.setLocale(newLocale);
                }
              },
              items: <Locale>[
                const Locale('en', ''),
                const Locale('ml', ''),
                const Locale('bn', ''),
                const Locale('hi', ''),
              ].map<DropdownMenuItem<Locale>>((Locale value) {
                return DropdownMenuItem<Locale>(
                  value: value,
                  child: Text(
                    value.languageCode == 'en'
                        ? localizations.english
                        : value.languageCode == 'ml'
                        ? localizations.malayalam
                        : value.languageCode == 'bn'
                        ? localizations.bengali
                        : localizations.hindi,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: localizations.myHealth,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_pharmacy_outlined),
            activeIcon: const Icon(Icons.local_pharmacy),
            label: localizations.pharmacy,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.question_mark_outlined),
            activeIcon: const Icon(Icons.question_mark),
            label: localizations.symptomChecker,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent(AppLocalizations localizations) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Top row for language and notifications
                  Positioned(
                    top: 45,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: DropdownButton<Locale>(
                            value: localizations.locale,
                            icon: const Icon(Icons.language, color: Colors.white),
                            dropdownColor: Theme.of(context).colorScheme.primary,
                            underline: const SizedBox.shrink(),
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null) {
                                widget.setLocale(newLocale);
                              }
                            },
                            items: <Locale>[
                              const Locale('en', ''),
                              const Locale('ml', ''),
                              const Locale('bn', ''),
                              const Locale('hi', ''),
                            ].map<DropdownMenuItem<Locale>>((Locale value) {
                              return DropdownMenuItem<Locale>(
                                value: value,
                                child: Text(
                                  value.languageCode == 'en'
                                      ? localizations.english
                                      : value.languageCode == 'ml'
                                      ? localizations.malayalam
                                      : value.languageCode == 'bn'
                                      ? localizations.bengali
                                      : localizations.hindi,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Centered content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo Placeholder
                        Image.asset(
                          'assets/logo.png',
                          height: 140,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: (localizations.locale.languageCode == 'bn') ? 'ডাক্তার, হাসপাতাল বা পরিষেবা অনুসন্ধান করুন...' : 'Search for doctors, hospitals, or services...',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              if (_searchController.text.isEmpty) ...[
                // Quick Access Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildQuickAccessButton(context, localizations.bookAppointment, Icons.calendar_today, _vibrantColors[0], () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BookAppointmentScreen(localizations: localizations)));
                        }).animate().fade(duration: 500.ms).slideX(begin: -0.5),
                        _buildQuickAccessButton(context, localizations.testsAndCheckups, Icons.medical_services, _vibrantColors[1], () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TestsAndCheckupsScreen(localizations: localizations)));
                        }).animate().fade(duration: 500.ms).slideX(begin: -0.5, delay: 100.ms),
                        _buildQuickAccessButton(context, localizations.myBookings, Icons.event_note, _vibrantColors[2], () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyBookingsScreen(localizations: localizations)));
                        }).animate().fade(duration: 500.ms).slideX(begin: -0.5, delay: 200.ms),
                        _buildQuickAccessButton(context, localizations.vaccineImmunization, Icons.vaccines, _vibrantColors[3], () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VaccineImmunizationScreen(localizations: localizations)));
                        }).animate().fade(duration: 500.ms).slideX(begin: -0.5, delay: 300.ms),
                      ],
                    ),
                  ),
                ),
                // Our Expertise Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    localizations.ourExpertise,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildExpertiseCard(context, localizations.cardiacSciences, Icons.favorite, _vibrantColors[4], () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialtyDoctorsScreen(specialty: localizations.cardiacSciences, localizations: localizations, camera: widget.camera)));
                      }).animate().fade(duration: 500.ms).slideX(begin: 0.5),
                      _buildExpertiseCard(context, localizations.cancerCare, Icons.shield_outlined, _vibrantColors[5], () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialtyDoctorsScreen(specialty: localizations.cancerCare, localizations: localizations, camera: widget.camera)));
                      }).animate().fade(duration: 500.ms).slideX(begin: 0.5, delay: 100.ms),
                      _buildExpertiseCard(context, localizations.neuroSciences, Icons.psychology, _vibrantColors[0], () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialtyDoctorsScreen(specialty: localizations.neuroSciences, localizations: localizations, camera: widget.camera)));
                      }).animate().fade(duration: 500.ms).slideX(begin: 0.5, delay: 200.ms),
                      _buildExpertiseCard(context, localizations.nephrology, Icons.sports_kabaddi, _vibrantColors[1], () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialtyDoctorsScreen(specialty: localizations.nephrology, localizations: localizations, camera: widget.camera)));
                      }).animate().fade(duration: 500.ms).slideX(begin: 0.5, delay: 300.ms),
                      _buildExpertiseCard(context, localizations.gastroenterology, Icons.health_and_safety, _vibrantColors[2], () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialtyDoctorsScreen(specialty: localizations.gastroenterology, localizations: localizations, camera: widget.camera)));
                      }).animate().fade(duration: 500.ms).slideX(begin: 0.5, delay: 400.ms),
                      _buildExpertiseCard(context, localizations.orthopaedics, Icons.medication, _vibrantColors[3], () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialtyDoctorsScreen(specialty: localizations.orthopaedics, localizations: localizations, camera: widget.camera)));
                      }).animate().fade(duration: 500.ms).slideX(begin: 0.5, delay: 500.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ] else ...[
                // Display search results
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    (localizations.locale.languageCode == 'bn') ? '"${_searchController.text}" এর জন্য অনুসন্ধান ফলাফল' : 'Search Results for "${_searchController.text}"',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_filteredDoctors.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        (localizations.locale.languageCode == 'bn') ? 'কোনো ডাক্তার পাওয়া যায়নি। অন্য কিছু দিয়ে চেষ্টা করুন।' : 'No doctors found. Try a different search term.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ..._filteredDoctors.map((doctor) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1E5280),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(doctor['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doctor['specialty']!),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailScreen(doctor: doctor, localizations: localizations, camera: widget.camera),
                                ),
                              );
                            },
                            child: Text((localizations.locale.languageCode == 'bn') ? 'দেখুন' : 'View'),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertiseCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
    );
  }
}

// --- NEW SCREENS ---
class BookAppointmentScreen extends StatefulWidget {
  final AppLocalizations localizations;
  const BookAppointmentScreen({super.key, required this.localizations});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final List<Map<String, dynamic>> _doctors = MockData.doctors;

  void _bookAppointment(Map<String, dynamic> doctor) {
    final newBooking = {
      'date': DateTime.now(),
      'doctorName': doctor['name'],
      'specialty': doctor['specialty'],
      'details': (widget.localizations.locale.languageCode == 'bn') ? 'সাধারণ পরীক্ষার জন্য পরামর্শ।' : 'Consultation for general checkup.'
    };
    Provider.of<BookingProvider>(context, listen: false).addBooking(newBooking);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text((widget.localizations.locale.languageCode == 'bn') ? '${doctor['name']} এর সাথে অ্যাপয়েন্টমেন্ট বুক করা হয়েছে।' : 'Appointment booked with ${doctor['name']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.localizations.bookAppointment)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (widget.localizations.locale.languageCode == 'bn') ? 'উপলব্ধ ডাক্তার' : 'Available Doctors',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(doctor['name']),
                      subtitle: Text('${doctor['specialty']} - ${doctor['timeSlot']}'),
                      trailing: ElevatedButton(
                        onPressed: () => _bookAppointment(doctor),
                        child: Text((widget.localizations.locale.languageCode == 'bn') ? 'বুক করুন' : 'Book'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestsAndCheckupsScreen extends StatelessWidget {
  final AppLocalizations localizations;
  const TestsAndCheckupsScreen({super.key, required this.localizations});

  final List<Map<String, dynamic>> _tests = const [
    {'name': 'Full Body Checkup', 'price': 2500, 'details': 'Includes CBC, LFT, KFT, Thyroid Profile, etc.'},
    {'name': 'Thyroid Profile', 'price': 800, 'details': 'T3, T4, and TSH levels.'},
    {'name': 'Diabetic Profile', 'price': 1200, 'details': 'Fasting and Post-prandial glucose, HbA1c.'},
    {'name': 'Cardiac Risk Profile', 'price': 3500, 'details': 'Lipid Profile, hs-CRP, Homocysteine.'},
  ];

  final List<Map<String, dynamic>> _testsBn = const [
    {'name': 'ফুল বডি চেকআপ', 'price': 2500, 'details': 'সিবিসি, এলএফটি, কেএফটি, থাইরয়েড প্রোফাইল ইত্যাদি অন্তর্ভুক্ত।'},
    {'name': 'থাইরয়েড প্রোফাইল', 'price': 800, 'details': 'টি৩, টি৪, এবং টিএসএইচ মাত্রা।'},
    {'name': 'ডায়াবেটিক প্রোফাইল', 'price': 1200, 'details': 'ফাস্টিং এবং পোস্ট-প্রান্ডিয়াল গ্লুকোজ, এইচবিএ১সি।'},
    {'name': 'কার্ডিয়াক ঝুঁকি প্রোফাইল', 'price': 3500, 'details': 'লিপিড প্রোফাইল, এইচএস-সিআরপি, হোমোসিস্টিন।'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isBengali = localizations.locale.languageCode == 'bn';
    final List<Map<String, dynamic>> currentTests = isBengali ? _testsBn : _tests;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.testsAndCheckups)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBengali ? 'উপলব্ধ পরীক্ষা ও চেকআপ' : 'Available Tests & Checkups',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentTests.length,
                itemBuilder: (context, index) {
                  final test = currentTests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(test['name']!),
                      subtitle: Text('₹${test['price']} - ${test['details']}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isBengali ? '${test['name']} পরীক্ষার বুকিং একটি মক ফিচার।' : 'Test booking for ${test['name']} is a mock feature.')),
                          );
                        },
                        child: Text(isBengali ? 'বুক করুন' : 'Book'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBookingsScreen extends StatelessWidget {
  final AppLocalizations localizations;
  const MyBookingsScreen({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings;
    final isBengali = localizations.locale.languageCode == 'bn';

    return Scaffold(
      appBar: AppBar(title: Text(localizations.myBookings)),
      body: bookings.isEmpty
          ? Center(child: Text(isBengali ? 'কোনো বুকিং নেই।' : 'No bookings available.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(isBengali ? '${booking['doctorName']} এর সাথে অ্যাপয়েন্টমেন্ট' : 'Appointment with ${booking['doctorName']}'),
              subtitle: Text(isBengali ? 'বিশেষজ্ঞতা: ${booking['specialty']}\nতারিখ: ${DateFormat.yMd().add_jm().format(booking['date'])}' : 'Specialty: ${booking['specialty']}\nDate: ${DateFormat.yMd().add_jm().format(booking['date'])}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

class VaccineImmunizationScreen extends StatelessWidget {
  final AppLocalizations localizations;
  const VaccineImmunizationScreen({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    final isBengali = localizations.locale.languageCode == 'bn';
    return Scaffold(
      appBar: AppBar(title: Text(localizations.vaccineImmunization)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(isBengali ? 'এটি ভ্যাকসিন ও টিকাকরণ স্ক্রিন। এখানে উপলব্ধ ভ্যাকসিন এবং সময়সূচীর মক ডেটা তালিকাভুক্ত করা হবে।' : 'This is the Vaccine & Immunization screen. Mock data for available vaccines and schedules will be listed here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      ),
    );
  }
}

// --- NEW MyHealthScreen with patient details and chat ---
class MyHealthScreen extends StatefulWidget {
  final AppLocalizations localizations;
  const MyHealthScreen({super.key, required this.localizations});

  @override
  _MyHealthScreenState createState() => _MyHealthScreenState();
}

class _MyHealthScreenState extends State<MyHealthScreen> {
  final List<Map<String, dynamic>> _mockHealthReports = const [
    {'title': 'Complete Blood Count', 'date': '25 Sep 2024'},
    {'title': 'Lipid Profile', 'date': '10 Aug 2024'},
    {'title': 'Thyroid Function Test', 'date': '15 Jun 2024'},
  ];

  final List<Map<String, dynamic>> _mockMedications = const [
    {'name': 'Amoxicillin', 'dosage': '500mg, 3 times daily'},
    {'name': 'Ibuprofen', 'dosage': '200mg, as needed for pain'},
  ];

  final List<Map<String, dynamic>> _mockVisitHistory = const [
    {
      'doctor': 'Dr. Atul Srivastava',
      'specialty': 'Orthopaedics',
      'date': '2 Sep 2024',
      'reason': 'Cervical spondylosis follow-up'
    },
    {
      'doctor': 'Dr. Preethi Rao',
      'specialty': 'Cardiac Sciences',
      'date': '15 Aug 2024',
      'reason': 'Routine heart check-up'
    },
  ];

  final List<Map<String, dynamic>> _mockHealthReportsBn = const [
    {'title': 'সম্পূর্ণ রক্তের গণনা', 'date': '২৫ সেপ্টেম্বর ২০২৪'},
    {'title': 'লিপিড প্রোফাইল', 'date': '১০ আগস্ট ২০২৪'},
    {'title': 'থাইরয়েড ফাংশন টেস্ট', 'date': '১৫ জুন ২০২৪'},
  ];

  final List<Map<String, dynamic>> _mockMedicationsBn = const [
    {'name': 'অ্যামোক্সিসিলিন', 'dosage': '৫০০মিলিগ্রাম, দিনে ৩ বার'},
    {'name': 'আইবুপ্রোফেন', 'dosage': '২০০মিলিগ্রাম, ব্যথা অনুযায়ী'},
  ];

  final List<Map<String, dynamic>> _mockVisitHistoryBn = const [
    {
      'doctor': 'ডাঃ অতুল শ্রীবাস্তব',
      'specialty': 'Orthopaedics',
      'date': '২ সেপ্টেম্বর ২০২৪',
      'reason': 'জরায়ুর স্পন্ডাইলোসিস ফলো-আপ'
    },
    {
      'doctor': 'ডাঃ প্রীতি রাও',
      'specialty': 'Cardiac Sciences',
      'date': '১৫ আগস্ট ২০২৪',
      'reason': 'নিয়মিত হার্ট চেক-আপ'
    },
  ];


  @override
  Widget build(BuildContext context) {
    final bool isBengali = widget.localizations.locale.languageCode == 'bn';
    final List<Map<String, dynamic>> healthReports = isBengali ? _mockHealthReportsBn : _mockHealthReports;
    final List<Map<String, dynamic>> medications = isBengali ? _mockMedicationsBn : _mockMedications;
    final List<Map<String, dynamic>> visitHistory = isBengali ? _mockVisitHistoryBn : _mockVisitHistory;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: CircularProgressIndicator(
                        value: 0.7, // Mock value
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                    const Icon(Icons.lock, size: 50, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isBengali ? 'আপনার স্বাস্থ্যের সারসংক্ষেপ' : 'Your Health Summary',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  isBengali ? 'আপনার স্বাস্থ্যের অন্তর্দৃষ্টি লাভ করুন। আজই একটি চেকআপ দিয়ে শুরু করুন!' : 'Gain insights into your health. Start with a checkup today!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(isBengali ? 'স্বাস্থ্য রিপোর্ট' : 'Health Reports', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...healthReports.map((report) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(report['title']!),
              subtitle: Text(isBengali ? 'তারিখ: ${report['date']}' : 'Date: ${report['date']}'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          )),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(isBengali ? 'চলমান ঔষধ' : 'Ongoing Medication', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...medications.map((med) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(med['name']!),
              subtitle: Text(isBengali ? 'মাত্রা: ${med['dosage']}' : 'Dosage: ${med['dosage']}'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          )),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(isBengali ? 'পরিদর্শন ইতিহাস' : 'Visit History', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...visitHistory.map((visit) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(isBengali ? '${visit['doctor']} এর সাথে পরামর্শ' : 'Consultation with ${visit['doctor']}'),
              subtitle: Text(isBengali ? 'কারণ: ${visit['reason']}' : 'Reason: ${visit['reason']}'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          )),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(isBengali ? 'ডিজিটাল স্বাস্থ্য রেকর্ড' : 'Digital Health Records', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.folder_open, color: Theme.of(context).colorScheme.primary),
              title: Text(widget.localizations.healthRecords),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HealthRecordsScreen(localizations: widget.localizations)),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(isBengali ? 'ডাক্তার চ্যাট' : 'Doctor Chat', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.chat, color: Theme.of(context).colorScheme.primary),
              title: Text(isBengali ? 'আগের চ্যাটগুলি দেখুন' : 'See previous chats'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PreviousChatsScreen(localizations: widget.localizations)),
                );
              },
            ),
          ),

          const SizedBox(height: 80), // To prevent bottom nav overlap
        ],
      ),
    );
  }
}

class PreviousChatsScreen extends StatelessWidget {
  final AppLocalizations localizations;
  const PreviousChatsScreen({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<BookingProvider>(context);
    final bookings = chatProvider.bookings;
    final chats = chatProvider.chats;
    final isBengali = localizations.locale.languageCode == 'bn';

    return Scaffold(
      appBar: AppBar(title: Text(isBengali ? 'আগের ডাক্তার চ্যাট' : 'Previous Doctor Chats')),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(isBengali ? '${chat['doctorName']} এর সাথে চ্যাট' : 'Chat with ${chat['doctorName']}'),
              subtitle: Text('Date: ${DateFormat.yMd().format(chat['date'])}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorChatScreen(localizations: localizations, doctorName: chat['doctorName'], initialMessages: chat['messages'])),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DoctorChatScreen extends StatefulWidget {
  final AppLocalizations localizations;
  final String doctorName;
  final List<ChatMessage> initialMessages;

  const DoctorChatScreen({super.key, required this.localizations, required this.doctorName, this.initialMessages = const []});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final String _geminiApiKey = 'AIzaSyBYNV1NRykJvEto3F6hqFjQE8HzrKhsZ1U';
  late final GenerativeModel _model;
  late ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _messages.addAll(widget.initialMessages);
    _initializeGemini();
  }

  void _initializeGemini() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
    _chat = _model.startChat(
      history: _messages.map((m) => Content(m.isUser ? 'user' : 'model', [TextPart(m.text)])).toList(),
    );
  }

  Future<void> _sendMessage({String? text, File? image}) async {
    if ((text == null || text.trim().isEmpty) && image == null) return;

    final userMessage = ChatMessage(text: text ?? '', isUser: true);
    setState(() {
      _messages.add(userMessage);
      _textController.clear();
      _isLoading = true;
    });

    Provider.of<BookingProvider>(context, listen: false).addMessage(widget.doctorName, userMessage);

    try {
      final List<Part> parts = [];
      if (text != null) {
        parts.add(TextPart(text));
      }
      if (image != null) {
        parts.add(DataPart('image/jpeg', await image.readAsBytes()));
      }

      final response = await _chat.sendMessage(Content.multi(parts));
      String geminiResponseText = response.text ?? 'I am sorry, I am unable to provide information at this moment.';

      final words = geminiResponseText.split(' ');
      if (words.length > 50) {
        geminiResponseText = words.sublist(0, 50).join(' ') + '...';
      }

      setState(() {
        _messages.add(ChatMessage(
          text: geminiResponseText,
          isUser: false,
        ));
      });
    } on Exception catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            text: '${widget.localizations.geminiError}: $e', isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendMessage(image: File(pickedFile.path));
    }
  }

  Future<void> _speakText(String text) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Speaking: "$text"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBengali = widget.localizations.locale.languageCode == 'bn';
    return Scaffold(
      appBar: AppBar(title: Text(isBengali ? '${widget.doctorName} এর সাথে চ্যাট' : 'Chat with ${widget.doctorName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageBubble(
                  message: message,
                  onTap: () {
                    _speakText(message.text);
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: isBengali ? 'একটি বার্তা লিখুন...' : 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isBengali ? 'স্পিচ টু টেক্সট একটি মক ফিচার।' : 'Speech to text is a mock feature.')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(text: _textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW SpecialtyDoctorsScreen ---
class SpecialtyDoctorsScreen extends StatefulWidget {
  final String specialty;
  final AppLocalizations localizations;
  final CameraDescription camera;
  const SpecialtyDoctorsScreen({super.key, required this.specialty, required this.localizations, required this.camera});

  @override
  State<SpecialtyDoctorsScreen> createState() => _SpecialtyDoctorsScreenState();
}

class _SpecialtyDoctorsScreenState extends State<SpecialtyDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _filterDoctors();
    _searchController.addListener(_filterDoctors);
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = MockData.doctors.where((doctor) {
        return doctor['specialty']!.toLowerCase() == widget.specialty.toLowerCase() &&
            doctor['name']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBengali = widget.localizations.locale.languageCode == 'bn';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.specialty),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: widget.localizations.searchByDoctorName,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _filteredDoctors[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1E5280),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(isBengali ? doctor['name']!.replaceFirst('Dr. ', 'ডাঃ ') : doctor['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(isBengali ? '${doctor['experienceYears']} বছরের অভিজ্ঞতা' : '${doctor['experienceYears']} years of experience'),
                      trailing: Icon(Icons.video_call, color: Theme.of(context).colorScheme.secondary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailScreen(doctor: doctor, localizations: widget.localizations, camera: widget.camera),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Digital Health Records Screen (not used in bottom nav) ---
class HealthRecordsScreen extends StatefulWidget {
  final AppLocalizations localizations;
  const HealthRecordsScreen({super.key, required this.localizations});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  List<HealthRecord> _records = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _dbService.getRecords();
    setState(() {
      _records = records;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveRecord() async {
    if (_titleController.text.isEmpty || _detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.localizations.enterTitleAndDetails),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? imagePath;
    if (_imageFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String localPath = '${appDir.path}/$fileName';
      await _imageFile!.copy(localPath);
      imagePath = localPath;
    }

    final newRecord = HealthRecord(
      title: _titleController.text,
      details: _detailsController.text,
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );
    await _dbService.insertRecord(newRecord);
    _titleController.clear();
    _detailsController.clear();
    setState(() {
      _imageFile = null;
    });
    _loadRecords();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.localizations.recordAddedSuccessfully),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteRecord(int id) async {
    await _dbService.deleteRecord(id);
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final isBengali = widget.localizations.locale.languageCode == 'bn';
    return Scaffold(
      appBar: AppBar(title: Text(widget.localizations.healthRecords)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: widget.localizations.recordTitle,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: widget.localizations.recordDetails,
                  ),
                ),
                const SizedBox(height: 16),
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: Text(widget.localizations.selectImage),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveRecord,
                        icon: const Icon(Icons.add),
                        label: Text(widget.localizations.saveRecord),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _records.isEmpty
                ? Center(
              child: Text(
                widget.localizations.noRecords,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: record.imagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(record.imagePath!),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notes,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        record.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${record.details}\n${DateFormat.yMd(widget.localizations.locale.languageCode).add_jm().format(record.timestamp)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRecord(record.id!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Pharmacy Screen (Mock Data) ---
class PharmacyScreen extends StatefulWidget {
  final AppLocalizations localizations;
  const PharmacyScreen({super.key, required this.localizations});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _medicines = const [
    {
      'name': 'Paracetamol',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 25.50,
      'composition': 'Acetaminophen',
      'sideEffects': 'Nausea, stomach pain, loss of appetite, dark urine, clay-colored stools, or jaundice (yellowing of the skin or eyes).',
      'alternatives': ['Ibuprofen', 'Naproxen']
    },
    {
      'name': 'Amoxicillin',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 80.00,
      'composition': 'Amoxicillin Trihydrate',
      'sideEffects': 'Diarrhea, nausea, vomiting, skin rash, or itching.',
      'alternatives': ['Azithromycin', 'Ciprofloxacin']
    },
    {
      'name': 'Ibuprofen',
      'status': 'Unavailable',
      'pharmacy': 'Rural Health Store',
      'price': 35.75,
      'composition': 'Ibuprofen',
      'sideEffects': 'Upset stomach, mild heartburn, nausea, vomiting, bloating, gas, diarrhea, constipation, dizziness, headache, or nervousness.',
      'alternatives': ['Paracetamol', 'Aspirin']
    },
    {
      'name': 'Vitamin C',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 50.00,
      'composition': 'Ascorbic Acid',
      'sideEffects': 'Stomach cramps, diarrhea, and nausea.',
      'alternatives': ['Multivitamin supplements']
    },
    {
      'name': 'Cough Syrup',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 65.25,
      'composition': 'Dextromethorphan, Guaifenesin',
      'sideEffects': 'Dizziness, drowsiness, nausea, and vomiting.',
      'alternatives': ['Honey and lemon remedy', 'Saline nasal spray']
    },
    {
      'name': 'Omeprazole',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 120.00,
      'composition': 'Omeprazole',
      'sideEffects': 'Headache, stomach pain, nausea, diarrhea, or gas.',
      'alternatives': ['Lansoprazole', 'Pantoprazole']
    },
    {
      'name': 'Cetirizine',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 40.00,
      'composition': 'Cetirizine Hydrochloride',
      'sideEffects': 'Drowsiness, fatigue, dry mouth, or dizziness.',
      'alternatives': ['Loratadine', 'Fexofenadine']
    },
    {
      'name': 'Metformin',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 150.00,
      'composition': 'Metformin Hydrochloride',
      'sideEffects': 'Nausea, vomiting, diarrhea, stomach ache, loss of appetite.',
      'alternatives': ['Glipizide', 'Pioglitazone']
    },
    {
      'name': 'Levothyroxine',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 90.00,
      'composition': 'Levothyroxine Sodium',
      'sideEffects': 'Heart palpitations, anxiety, sweating, headache, hair loss, or weight changes.',
      'alternatives': ['Liothyronine']
    },
    {
      'name': 'Amlodipine',
      'status': 'Unavailable',
      'pharmacy': 'City Pharmacy',
      'price': 110.00,
      'composition': 'Amlodipine Besilate',
      'sideEffects': 'Swelling of ankles or feet, headache, tiredness, or flushing.',
      'alternatives': ['Lisinopril', 'Hydrochlorothiazide']
    },
    {
      'name': 'Simvastatin',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 200.00,
      'composition': 'Simvastatin',
      'sideEffects': 'Muscle pain, tenderness or weakness, stomach pain, constipation.',
      'alternatives': ['Atorvastatin', 'Rosuvastatin']
    },
    {
      'name': 'Losartan',
      'status': 'Low Stock',
      'pharmacy': 'Rural Health Store',
      'price': 130.00,
      'composition': 'Losartan Potassium',
      'sideEffects': 'Dizziness, stuffy nose, back pain, or diarrhea.',
      'alternatives': ['Valsartan', 'Irbesartan']
    },
    {
      'name': 'Gabapentin',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 250.00,
      'composition': 'Gabapentin',
      'sideEffects': 'Drowsiness, dizziness, unsteadiness, or blurred vision.',
      'alternatives': ['Pregabalin']
    },
    {
      'name': 'Albuterol',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 180.00,
      'composition': 'Albuterol Sulfate',
      'sideEffects': 'Nervousness or shakiness, headache, throat or nasal irritation, muscle aches.',
      'alternatives': ['Levalbuterol']
    },
    {
      'name': 'Hydrochlorothiazide',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 75.00,
      'composition': 'Hydrochlorothiazide',
      'sideEffects': 'Dizziness, lightheadedness, headache, or stomach upset.',
      'alternatives': ['Furosemide', 'Bumetanide']
    },
    {
      'name': 'Sertraline',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 220.00,
      'composition': 'Sertraline Hydrochloride',
      'sideEffects': 'Nausea, diarrhea, constipation, vomiting, dizziness, or drowsiness.',
      'alternatives': ['Fluoxetine', 'Escitalopram']
    },
    {
      'name': 'Lisinopril',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 95.00,
      'composition': 'Lisinopril',
      'sideEffects': 'Dry cough, dizziness, lightheadedness, or headache.',
      'alternatives': ['Enalapril', 'Ramipril']
    },
    {
      'name': 'Aspirin',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 15.00,
      'composition': 'Acetylsalicylic acid',
      'sideEffects': 'Stomach upset or heartburn.',
      'alternatives': ['Paracetamol', 'Ibuprofen']
    },
    {
      'name': 'Clopidogrel',
      'status': 'Low Stock',
      'pharmacy': 'Rural Health Store',
      'price': 300.00,
      'composition': 'Clopidogrel Bisulfate',
      'sideEffects': 'Easy bruising or bleeding, stomach upset, or diarrhea.',
      'alternatives': ['Prasugrel', 'Ticagrelor']
    },
    {
      'name': 'Furosemide',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 60.00,
      'composition': 'Furosemide',
      'sideEffects': 'Frequent urination, dizziness, or lightheadedness.',
      'alternatives': ['Hydrochlorothiazide', 'Bumetanide']
    },
    {
      'name': 'Loratadine',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 55.00,
      'composition': 'Loratadine',
      'sideEffects': 'Headache, fatigue, or dry mouth.',
      'alternatives': ['Cetirizine', 'Fexofenadine']
    },
    {
      'name': 'Metoprolol',
      'status': 'Unavailable',
      'pharmacy': 'Nabha Medicals',
      'price': 105.00,
      'composition': 'Metoprolol Tartrate',
      'sideEffects': 'Dizziness, tiredness, or lightheadedness.',
      'alternatives': ['Atenolol', 'Carvedilol']
    },
    {
      'name': 'Naproxen',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 45.00,
      'composition': 'Naproxen Sodium',
      'sideEffects': 'Heartburn, nausea, stomach pain, or dizziness.',
      'alternatives': ['Ibuprofen', 'Paracetamol']
    },
    {
      'name': 'Prednisone',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 175.00,
      'composition': 'Prednisone',
      'sideEffects': 'Increased appetite, weight gain, insomnia, or mood swings.',
      'alternatives': ['Hydrocortisone', 'Dexamethasone']
    },
    {
      'name': 'Ranitidine',
      'status': 'Unavailable',
      'pharmacy': 'City Pharmacy',
      'price': 85.00,
      'composition': 'Ranitidine Hydrochloride',
      'sideEffects': 'Headache, dizziness, or diarrhea.',
      'alternatives': ['Famotidine', 'Omeprazole']
    },
    {
      'name': 'Warfarin',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 280.00,
      'composition': 'Warfarin Sodium',
      'sideEffects': 'Easy bruising or bleeding, nosebleeds, or blood in urine.',
      'alternatives': ['Apixaban', 'Rivaroxaban']
    },
    {
      'name': 'Ciprofloxacin',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 160.00,
      'composition': 'Ciprofloxacin Hydrochloride',
      'sideEffects': 'Nausea, diarrhea, abdominal pain, or headache.',
      'alternatives': ['Levofloxacin', 'Azithromycin']
    },
    {
      'name': 'Azithromycin',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 190.00,
      'composition': 'Azithromycin Dihydrate',
      'sideEffects': 'Diarrhea, nausea, stomach pain, or vomiting.',
      'alternatives': ['Amoxicillin', 'Doxycycline']
    },
    {
      'name': 'Doxycycline',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 140.00,
      'composition': 'Doxycycline',
      'sideEffects': 'Nausea, vomiting, diarrhea, or upset stomach.',
      'alternatives': ['Tetracycline', 'Minocycline']
    },
    {
      'name': 'Levofloxacin',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 210.00,
      'composition': 'Levofloxacin',
      'sideEffects': 'Nausea, headache, constipation, or diarrhea.',
      'alternatives': ['Ciprofloxacin', 'Moxifloxacin']
    },
    {
      'name': 'Fluoxetine',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 185.00,
      'composition': 'Fluoxetine Hydrochloride',
      'sideEffects': 'Nausea, headache, trouble sleeping, or nervousness.',
      'alternatives': ['Sertraline', 'Paroxetine']
    },
    {
      'name': 'Escitalopram',
      'status': 'Low Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 240.00,
      'composition': 'Escitalopram Oxalate',
      'sideEffects': 'Nausea, dry mouth, sweating, or dizziness.',
      'alternatives': ['Sertraline', 'Citalopram']
    },
    {
      'name': 'Alprazolam',
      'status': 'Unavailable',
      'pharmacy': 'Rural Health Store',
      'price': 170.00,
      'composition': 'Alprazolam',
      'sideEffects': 'Drowsiness, dizziness, or lightheadedness.',
      'alternatives': ['Lorazepam', 'Clonazepam']
    },
    {
      'name': 'Diazepam',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 195.00,
      'composition': 'Diazepam',
      'sideEffects': 'Drowsiness, fatigue, or muscle weakness.',
      'alternatives': ['Clonazepam', 'Lorazepam']
    },
    {
      'name': 'Clonazepam',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 210.00,
      'composition': 'Clonazepam',
      'sideEffects': 'Drowsiness, dizziness, or unsteadiness.',
      'alternatives': ['Alprazolam', 'Diazepam']
    },
    {
      'name': 'Tramadol',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 155.00,
      'composition': 'Tramadol Hydrochloride',
      'sideEffects': 'Dizziness, constipation, nausea, or drowsiness.',
      'alternatives': ['Codeine', 'Hydrocodone']
    },
    {
      'name': 'Tizanidine',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 135.00,
      'composition': 'Tizanidine Hydrochloride',
      'sideEffects': 'Drowsiness, dry mouth, or dizziness.',
      'alternatives': ['Baclofen', 'Cyclobenzaprine']
    },
    {
      'name': 'Cyclobenzaprine',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 125.00,
      'composition': 'Cyclobenzaprine Hydrochloride',
      'sideEffects': 'Drowsiness, dry mouth, or dizziness.',
      'alternatives': ['Tizanidine', 'Baclofen']
    },
    {
      'name': 'Hydrocodone',
      'status': 'Unavailable',
      'pharmacy': 'Nabha Medicals',
      'price': 250.00,
      'composition': 'Hydrocodone Bitartrate',
      'sideEffects': 'Dizziness, lightheadedness, nausea, or vomiting.',
      'alternatives': ['Oxycodone', 'Morphine']
    },
    {
      'name': 'Oxycodone',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 300.00,
      'composition': 'Oxycodone Hydrochloride',
      'sideEffects': 'Drowsiness, constipation, nausea, or dizziness.',
      'alternatives': ['Hydrocodone', 'Morphine']
    },
    {
      'name': 'Morphine',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 350.00,
      'composition': 'Morphine Sulfate',
      'sideEffects': 'Drowsiness, constipation, dizziness, or lightheadedness.',
      'alternatives': ['Oxycodone', 'Hydrocodone']
    },
    {
      'name': 'Gabapentin',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 250.00,
      'composition': 'Gabapentin',
      'sideEffects': 'Drowsiness, dizziness, unsteadiness, or blurred vision.',
      'alternatives': ['Pregabalin', 'Carbamazepine']
    },
    {
      'name': 'Pregabalin',
      'status': 'Low Stock',
      'pharmacy': 'Rural Health Store',
      'price': 280.00,
      'composition': 'Pregabalin',
      'sideEffects': 'Dizziness, sleepiness, or blurred vision.',
      'alternatives': ['Gabapentin']
    },
    {
      'name': 'Carbamazepine',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 180.00,
      'composition': 'Carbamazepine',
      'sideEffects': 'Dizziness, drowsiness, or unsteadiness.',
      'alternatives': ['Valproic Acid', 'Lamotrigine']
    },
    {
      'name': 'Valproic Acid',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 220.00,
      'composition': 'Valproic Acid',
      'sideEffects': 'Nausea, headache, drowsiness, or tremor.',
      'alternatives': ['Carbamazepine', 'Lamotrigine']
    },
    {
      'name': 'Lamotrigine',
      'status': 'Low Stock',
      'pharmacy': 'Rural Health Store',
      'price': 230.00,
      'composition': 'Lamotrigine',
      'sideEffects': 'Dizziness, double vision, or tremor.',
      'alternatives': ['Valproic Acid', 'Carbamazepine']
    },
    {
      'name': 'Atorvastatin',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 180.00,
      'composition': 'Atorvastatin Calcium',
      'sideEffects': 'Joint pain, upset stomach, or diarrhea.',
      'alternatives': ['Simvastatin', 'Rosuvastatin']
    },
    {
      'name': 'Rosuvastatin',
      'status': 'Low Stock',
      'pharmacy': 'City Pharmacy',
      'price': 200.00,
      'composition': 'Rosuvastatin Calcium',
      'sideEffects': 'Headache, muscle pain, or abdominal pain.',
      'alternatives': ['Atorvastatin', 'Simvastatin']
    },
    {
      'name': 'Pantoprazole',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 110.00,
      'composition': 'Pantoprazole Sodium',
      'sideEffects': 'Headache, diarrhea, or dizziness.',
      'alternatives': ['Omeprazole', 'Lansoprazole']
    },
    {
      'name': 'Lansoprazole',
      'status': 'Unavailable',
      'pharmacy': 'Nabha Medicals',
      'price': 115.00,
      'composition': 'Lansoprazole',
      'sideEffects': 'Diarrhea, stomach pain, or nausea.',
      'alternatives': ['Omeprazole', 'Pantoprazole']
    },
    {
      'name': 'Fluconazole',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 90.00,
      'composition': 'Fluconazole',
      'sideEffects': 'Nausea, headache, or dizziness.',
      'alternatives': ['Nystatin', 'Clotrimazole']
    },
    {
      'name': 'Clotrimazole',
      'status': 'Low Stock',
      'pharmacy': 'Rural Health Store',
      'price': 50.00,
      'composition': 'Clotrimazole',
      'sideEffects': 'Skin irritation, redness, or itching.',
      'alternatives': ['Miconazole', 'Nystatin']
    },
    {
      'name': 'Miconazole',
      'status': 'In Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 65.00,
      'composition': 'Miconazole Nitrate',
      'sideEffects': 'Skin irritation, burning sensation, or itching.',
      'alternatives': ['Clotrimazole', 'Nystatin']
    },
    {
      'name': 'Diphenhydramine',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 40.00,
      'composition': 'Diphenhydramine Hydrochloride',
      'sideEffects': 'Drowsiness, dizziness, or dry mouth.',
      'alternatives': ['Loratadine', 'Cetirizine']
    },
    {
      'name': 'Fexofenadine',
      'status': 'Low Stock',
      'pharmacy': 'Rural Health Store',
      'price': 80.00,
      'composition': 'Fexofenadine Hydrochloride',
      'sideEffects': 'Headache, dizziness, or nausea.',
      'alternatives': ['Loratadine', 'Cetirizine']
    },
    {
      'name': 'Ranitidine',
      'status': 'Unavailable',
      'pharmacy': 'City Pharmacy',
      'price': 85.00,
      'composition': 'Ranitidine Hydrochloride',
      'sideEffects': 'Headache, dizziness, or diarrhea.',
      'alternatives': ['Famotidine', 'Omeprazole']
    },
    {
      'name': 'Famotidine',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 70.00,
      'composition': 'Famotidine',
      'sideEffects': 'Headache, dizziness, or constipation.',
      'alternatives': ['Ranitidine', 'Omeprazole']
    },
    {
      'name': 'Ondansetron',
      'status': 'In Stock',
      'pharmacy': 'Rural Health Store',
      'price': 150.00,
      'composition': 'Ondansetron Hydrochloride',
      'sideEffects': 'Headache, constipation, or diarrhea.',
      'alternatives': ['Metoclopramide']
    },
    {
      'name': 'Metoclopamide',
      'status': 'Low Stock',
      'pharmacy': 'Nabha Medicals',
      'price': 130.00,
      'composition': 'Metoclopamide Hydrochloride',
      'sideEffects': 'Drowsiness, dizziness, or restlessness.',
      'alternatives': ['Ondansetron']
    },
    {
      'name': 'Spironolactone',
      'status': 'In Stock',
      'pharmacy': 'City Pharmacy',
      'price': 160.00,
      'composition': 'Spironolactone',
      'sideEffects': 'Drowsiness, dizziness, or lightheadedness.',
      'alternatives': ['Eplerenone']
    },
  ];
  List<Map<String, dynamic>> _filteredMedicines = [];

  final List<Map<String, dynamic>> _medicinesBn = const [
    {
      'name': 'প্যারাসিটামল',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 25.50,
      'composition': 'অ্যাসিটামিনোফেন',
      'sideEffects': 'বমি বমি ভাব, পেটে ব্যথা, ক্ষুধা হ্রাস, গাঢ় প্রস্রাব, মাটির রঙের মল, বা জন্ডিস (ত্বক বা চোখের হলুদ ভাব)।',
      'alternatives': ['আইবুপ্রোফেন', 'নেপ্রোক্সেন']
    },
    {
      'name': 'অ্যামোক্সিসিলিন',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 80.00,
      'composition': 'অ্যামোক্সিসিলিন ট্রাইহাইড্রেট',
      'sideEffects': 'ডায়রিয়া, বমি বমি ভাব, বমি, ত্বকের ফুসকুড়ি, বা চুলকানি।',
      'alternatives': ['অ্যাজিথ্রোমাইসিন', 'সিপ্রোফ্লক্সাসিন']
    },
    {
      'name': 'আইবুপ্রোফেন',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 35.75,
      'composition': 'আইবুপ্রোফেন',
      'sideEffects': 'পেট খারাপ, হালকা বুকজ্বালা, বমি বমি ভাব, বমি, ফোলা, গ্যাস, ডায়রিয়া, কোষ্ঠকাঠিন্য, মাথা ঘোরা, মাথাব্যথা, বা নার্ভাসনেস।',
      'alternatives': ['প্যারাসিটামল', 'অ্যাসপিরিন']
    },
    {
      'name': 'ভিটামিন সি',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 50.00,
      'composition': 'অ্যাসকরবিক অ্যাসিড',
      'sideEffects': 'পেটে ব্যথা, ডায়রিয়া এবং বমি বমি ভাব।',
      'alternatives': ['মাল্টিভিটামিন সাপ্লিমেন্টস']
    },
    {
      'name': 'কাশির সিরাপ',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 65.25,
      'composition': 'ডেক্সট্রোমেথোরফান, গুয়াইফেনেসিন',
      'sideEffects': 'মাথা ঘোরা, তন্দ্রা, বমি বমি ভাব, এবং বমি।',
      'alternatives': ['মধু এবং লেবুর প্রতিকার', 'স্যালাইন নাকের স্প্রে']
    },
    {
      'name': 'ওমেপ্রাজোল',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 120.00,
      'composition': 'ওমেপ্রাজোল',
      'sideEffects': 'মাথাব্যথা, পেটে ব্যথা, বমি বমি ভাব, ডায়রিয়া, বা গ্যাস।',
      'alternatives': ['ল্যান্সোপ্রাজোল', 'প্যান্টোপ্রাজোল']
    },
    {
      'name': 'সেটিরিজাইন',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 40.00,
      'composition': 'সেটিরিজাইন হাইড্রোক্লোরাইড',
      'sideEffects': 'তন্দ্রা, ক্লান্তি, শুকনো মুখ, বা মাথা ঘোরা।',
      'alternatives': ['লোরাটাডিন', 'ফেক্সোফেনাডাইন']
    },
    {
      'name': 'মেটফরমিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 150.00,
      'composition': 'মেটফরমিন হাইড্রোক্লোরাইড',
      'sideEffects': 'বমি বমি ভাব, বমি, ডায়রিয়া, পেট ব্যথা, ক্ষুধা হ্রাস।',
      'alternatives': ['গ্লিপিজাইড', 'পিয়োগ্লিটাজোন']
    },
    {
      'name': 'লেভোথাইরক্সিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 90.00,
      'composition': 'লেভোথাইরক্সিন সোডিয়াম',
      'sideEffects': 'হৃদপিণ্ডের ধড়পড়ানি, উদ্বেগ, ঘাম, মাথাব্যথা, চুল পড়া, বা ওজন পরিবর্তন।',
      'alternatives': ['লিওথাইরোনিন']
    },
    {
      'name': 'অ্যামলোডিপিন',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 110.00,
      'composition': 'অ্যামলোডিপিন বেসিলেট',
      'sideEffects': 'গোড়ালি বা পায়ের ফোলা, মাথাব্যথা, ক্লান্তি, বা ফ্লাশিং।',
      'alternatives': ['লিসিনোপ্রিল', 'হাইড্রোক্লোরোথিয়াজাইড']
    },
    {
      'name': 'সিম্ভাস্ট্যাটিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 200.00,
      'composition': 'সিম্ভাস্ট্যাটিন',
      'sideEffects': 'পেশী ব্যথা, কোমলতা বা দুর্বলতা, পেটে ব্যথা, কোষ্ঠকাঠিন্য।',
      'alternatives': ['অ্যাটরভ্যাস্ট্যাটিন', 'রোসুভ্যাস্ট্যাটিন']
    },
    {
      'name': 'লোসার্টান',
      'status': 'কম স্টক',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 130.00,
      'composition': 'লোসার্টান পটাসিয়াম',
      'sideEffects': 'মাথা ঘোরা, নাক বন্ধ, পিঠ ব্যথা, বা ডায়রিয়া।',
      'alternatives': ['ভালসার্টান', 'ইর্বেসার্টান']
    },
    {
      'name': 'গাবাপেন্টিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 250.00,
      'composition': 'গাবাপেন্টিন',
      'sideEffects': 'তন্দ্রা, মাথা ঘোরা, অস্থিরতা, বা ঝাপসা দৃষ্টি।',
      'alternatives': ['প্রেগাবালিন']
    },
    {
      'name': 'অ্যালবুটেরল',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 180.00,
      'composition': 'অ্যালবুটেরল সালফেট',
      'sideEffects': 'নার্ভাসনেস বা কাঁপুনি, মাথাব্যথা, গলা বা নাকের জ্বালা, পেশী ব্যথা।',
      'alternatives': ['লিভালবুটেরল']
    },
    {
      'name': 'হাইড্রোক্লোরোথিয়াজাইড',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 75.00,
      'composition': 'হাইড্রোক্লোরোথিয়াজাইড',
      'sideEffects': 'মাথা ঘোরা, হালকা মাথা ব্যথা, মাথাব্যথা, বা পেট খারাপ।',
      'alternatives': ['ফিউরোসেমাইড', 'বুমটানাইড']
    },
    {
      'name': 'সার্ট্রালিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 220.00,
      'composition': 'সার্ট্রালিন হাইড্রোক্লোরাইড',
      'sideEffects': 'বমি বমি ভাব, ডায়রিয়া, কোষ্ঠকাঠিন্য, বমি, মাথা ঘোরা, বা তন্দ্রা।',
      'alternatives': ['ফ্লুঅক্সেটিন', 'এসকিটালোপ্রাম']
    },
    {
      'name': 'লিসিনোপ্রিল',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 95.00,
      'composition': 'লিসিনোপ্রিল',
      'sideEffects': 'শুকনো কাশি, মাথা ঘোরা, হালকা মাথা ব্যথা, বা মাথাব্যথা।',
      'alternatives': ['এনালপ্রিল', 'রামপ্রিল']
    },
    {
      'name': 'অ্যাসপিরিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 15.00,
      'composition': 'অ্যাসিটিলস্যালিসিলিক অ্যাসিড',
      'sideEffects': 'পেট খারাপ বা বুকজ্বালা।',
      'alternatives': ['প্যারাসিটামল', 'আইবুপ্রোফেন']
    },
    {
      'name': 'ক্লপিডোগ্রেল',
      'status': 'কম স্টক',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 300.00,
      'composition': 'ক্লপিডোগ্রেল বিসালফেট',
      'sideEffects': 'সহজে ক্ষত বা রক্তপাত, পেট খারাপ, বা ডায়রিয়া।',
      'alternatives': ['প্রাসুগেল', 'টিকাগ্রেলর']
    },
    {
      'name': 'ফিউরোসেমাইড',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 60.00,
      'composition': 'ফিউরোসেমাইড',
      'sideEffects': 'ঘন ঘন প্রস্রাব, মাথা ঘোরা, বা হালকা মাথা ব্যথা।',
      'alternatives': ['হাইড্রোক্লোরোথিয়াজাইড', 'বুমটানাইড']
    },
    {
      'name': 'লোরাটাডিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 55.00,
      'composition': 'লোরাটাডিন',
      'sideEffects': 'মাথাব্যথা, ক্লান্তি, বা শুকনো মুখ।',
      'alternatives': ['সেটিরিজাইন', 'ফেক্সোফেনাডাইন']
    },
    {
      'name': 'মেটোপ্রোলোল',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 105.00,
      'composition': 'মেটোপ্রোলোল টারট্রেট',
      'sideEffects': 'মাথা ঘোরা, ক্লান্তি, বা হালকা মাথা ব্যথা।',
      'alternatives': ['অ্যাটেনোলোল', 'কার্ভেডিলো']
    },
    {
      'name': 'নেপ্রোক্সেন',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 45.00,
      'composition': 'নেপ্রোক্সেন সোডিয়াম',
      'sideEffects': 'বুকজ্বালা, বমি বমি ভাব, পেটে ব্যথা, বা মাথা ঘোরা।',
      'alternatives': ['আইবুপ্রোফেন', 'প্যারাসিটামল']
    },
    {
      'name': 'প্রেডনিসোন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 175.00,
      'composition': 'প্রেডনিসোন',
      'sideEffects': 'ক্ষুধা বৃদ্ধি, ওজন বৃদ্ধি, অনিদ্রা, বা মেজাজ পরিবর্তন।',
      'alternatives': ['হাইড্রোকর্টিসোন', 'ডেক্সামেথাসোন']
    },
    {
      'name': 'রানিটিডিন',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 85.00,
      'composition': 'রানিটিডিন হাইড্রোক্লোরাইড',
      'sideEffects': 'মাথাব্যথা, মাথা ঘোরা, বা ডায়রিয়া।',
      'alternatives': ['ফেমোটিডিন', 'ওমেপ্রাজোল']
    },
    {
      'name': 'ওয়ারফারিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 280.00,
      'composition': 'ওয়ারফারিন সোডিয়াম',
      'sideEffects': 'সহজে ক্ষত বা রক্তপাত, নাক থেকে রক্তপাত, বা প্রস্রাবে রক্ত।',
      'alternatives': ['অ্যাপিক্সাবান', 'রিভারোক্সাবান']
    },
    {
      'name': 'সিপ্রোফ্লক্সাসিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 160.00,
      'composition': 'সিপ্রোফ্লক্সাসিন হাইড্রোক্লোরাইড',
      'sideEffects': 'বমি বমি ভাব, ডায়রিয়া, পেটে ব্যথা, বা মাথাব্যথা।',
      'alternatives': ['লেভোফ্লক্সাসিন', 'অ্যাজিথ্রোমাইসিন']
    },
    {
      'name': 'অ্যাজিথ্রোমাইসিন',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 190.00,
      'composition': 'অ্যাজিথ্রোমাইসিন ডাইহাইড্রেট',
      'sideEffects': 'ডায়রিয়া, বমি বমি ভাব, পেটে ব্যথা, বা বমি।',
      'alternatives': ['অ্যামোক্সিসিলিন', 'ডক্সিসাইক্লিন']
    },
    {
      'name': 'ডক্সিসাইক্লিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 140.00,
      'composition': 'ডক্সিসাইক্লিন',
      'sideEffects': 'বমি বমি ভাব, বমি, ডায়রিয়া, বা পেট খারাপ।',
      'alternatives': ['টেট্রাসাইক্লিন', 'মিনোসাইক্লিন']
    },
    {
      'name': 'লেভোফ্লক্সাসিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 210.00,
      'composition': 'লেভোফ্লক্সাসিন',
      'sideEffects': 'বমি বমি ভাব, মাথাব্যথা, কোষ্ঠকাঠিন্য, বা ডায়রিয়া।',
      'alternatives': ['সিপ্রোফ্লক্সাসিন', 'মক্সিফ্লক্সাসিন']
    },
    {
      'name': 'ফ্লুঅক্সেটিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 185.00,
      'composition': 'ফ্লুঅক্সেটিন হাইড্রোক্লোরাইড',
      'sideEffects': 'বমি বমি ভাব, মাথাব্যথা, ঘুম না হওয়া, বা নার্ভাসনেস।',
      'alternatives': ['সার্ট্রালিন', 'পারক্সিটিন']
    },
    {
      'name': 'এসকিটালোপ্রাম',
      'status': 'কম স্টক',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 240.00,
      'composition': 'এসকিটালোপ্রাম অক্সালেট',
      'sideEffects': 'বমি বমি ভাব, শুকনো মুখ, ঘাম, বা মাথা ঘোরা।',
      'alternatives': ['সার্ট্রালিন', 'সিটালোপ্রাম']
    },
    {
      'name': 'অ্যালপ্রাজোলাম',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 170.00,
      'composition': 'অ্যালপ্রাজোলাম',
      'sideEffects': 'তন্দ্রা, মাথা ঘোরা, বা হালকা মাথা ব্যথা।',
      'alternatives': ['লোরাজিপাম', 'ক্লোনাজেপাম']
    },
    {
      'name': 'ডায়াজিপাম',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 195.00,
      'composition': 'ডায়াজিপাম',
      'sideEffects': 'তন্দ্রা, ক্লান্তি, বা পেশী দুর্বলতা।',
      'alternatives': ['ক্লোনাজেপাম', 'লোরাজিপাম']
    },
    {
      'name': 'ক্লোনাজেপাম',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 210.00,
      'composition': 'ক্লোনাজেপাম',
      'sideEffects': 'তন্দ্রা, মাথা ঘোরা, বা অস্থিরতা।',
      'alternatives': ['অ্যালপ্রাজোলাম', 'ডায়াজিপাম']
    },
    {
      'name': 'ট্রামডল',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 155.00,
      'composition': 'ট্রামডল হাইড্রোক্লোরাইড',
      'sideEffects': 'মাথা ঘোরা, কোষ্ঠকাঠিন্য, বমি বমি ভাব, বা তন্দ্রা।',
      'alternatives': ['কোডাইন', 'হাইড্রোকোডন']
    },
    {
      'name': 'টিজানাইডিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 135.00,
      'composition': 'টিজানাইডিন হাইড্রোক্লোরাইড',
      'sideEffects': 'তন্দ্রা, শুকনো মুখ, বা মাথা ঘোরা।',
      'alternatives': ['ব্যাক্লোফেন', 'সাইক্লোবেনজাপ্রাইন']
    },
    {
      'name': 'সাইক্লোবেনজাপ্রাইন',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 125.00,
      'composition': 'সাইক্লোবেনজাপ্রাইন হাইড্রোক্লোরাইড',
      'sideEffects': 'তন্দ্রা, শুকনো মুখ, বা মাথা ঘোরা।',
      'alternatives': ['টিজানাইডিন', 'ব্যাক্লোফেন']
    },
    {
      'name': 'হাইড্রোকোডন',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 250.00,
      'composition': 'হাইড্রোকোডন বিটারট্রেট',
      'sideEffects': 'মাথা ঘোরা, হালকা মাথা ব্যথা, বমি বমি ভাব, বা বমি।',
      'alternatives': ['অক্সিকোডন', 'মরফিন']
    },
    {
      'name': 'অক্সিকোডন',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 300.00,
      'composition': 'অক্সিকোডন হাইড্রোক্লোরাইড',
      'sideEffects': 'তন্দ্রা, কোষ্ঠকাঠিন্য, বমি বমি ভাব, বা মাথা ঘোরা।',
      'alternatives': ['হাইড্রোকোডন', 'মরফিন']
    },
    {
      'name': 'মরফিন',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 350.00,
      'composition': 'মরফিন সালফেট',
      'sideEffects': 'তন্দ্রা, কোষ্ঠকাঠিন্য, মাথা ঘোরা, বা হালকা মাথা ব্যথা।',
      'alternatives': ['অক্সিকোডন', 'হাইড্রোকোডন']
    },
    {
      'name': 'গাবাপেন্টিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 250.00,
      'composition': 'গাবাপেন্টিন',
      'sideEffects': 'তন্দ্রা, মাথা ঘোরা, অস্থিরতা, বা ঝাপসা দৃষ্টি।',
      'alternatives': ['প্রেগাবালিন', 'কার্বামাজেপাইন']
    },
    {
      'name': 'প্রেগাবালিন',
      'status': 'কম স্টক',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 280.00,
      'composition': 'প্রেগাবালিন',
      'sideEffects': 'মাথা ঘোরা, ঘুম ঘুম ভাব, বা ঝাপসা দৃষ্টি।',
      'alternatives': ['গাবাপেন্টিন']
    },
    {
      'name': 'কার্বামাজেপাইন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 180.00,
      'composition': 'কার্বামাজেপাইন',
      'sideEffects': 'মাথা ঘোরা, তন্দ্রা, বা অস্থিরতা।',
      'alternatives': ['ভ্যালপ্রোইক অ্যাসিড', 'ল্যামোট্রিজিন']
    },
    {
      'name': 'ভ্যালপ্রোইক অ্যাসিড',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 220.00,
      'composition': 'ভ্যালপ্রোইক অ্যাসিড',
      'sideEffects': 'বমি বমি ভাব, মাথাব্যথা, তন্দ্রা, বা কাঁপুনি।',
      'alternatives': ['কার্বামাজেপাইন', 'ল্যামোট্রিজিন']
    },
    {
      'name': 'ল্যামোট্রিজিন',
      'status': 'কম স্টক',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 230.00,
      'composition': 'ল্যামোট্রিজিন',
      'sideEffects': 'মাথা ঘোরা, দ্বিগুণ দৃষ্টি, বা কাঁপুনি।',
      'alternatives': ['ভ্যালপ্রোইক অ্যাসিড', 'কার্বামাজেপাইন']
    },
    {
      'name': 'অ্যাটরভ্যাস্ট্যাটিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 180.00,
      'composition': 'অ্যাটরভ্যাস্ট্যাটিন ক্যালসিয়াম',
      'sideEffects': 'জয়েন্টে ব্যথা, পেট খারাপ, বা ডায়রিয়া।',
      'alternatives': ['সিম্ভাস্ট্যাটিন', 'রোসুভ্যাস্ট্যাটিন']
    },
    {
      'name': 'রোসুভ্যাস্ট্যাটিন',
      'status': 'কম স্টক',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 200.00,
      'composition': 'রোসুভ্যাস্ট্যাটিন ক্যালসিয়াম',
      'sideEffects': 'মাথাব্যথা, পেশী ব্যথা, বা পেটে ব্যথা।',
      'alternatives': ['অ্যাটরভ্যাস্ট্যাটিন', 'সিম্ভাস্ট্যাটিন']
    },
    {
      'name': 'প্যান্টোপ্রাজোল',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 110.00,
      'composition': 'প্যান্টোপ্রাজোল সোডিয়াম',
      'sideEffects': 'মাথাব্যথা, ডায়রিয়া, বা মাথা ঘোরা।',
      'alternatives': ['ওমেপ্রাজোল', 'ল্যান্সোপ্রাজোল']
    },
    {
      'name': 'ল্যান্সোপ্রাজোল',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 115.00,
      'composition': 'ল্যান্সোপ্রাজোল',
      'sideEffects': 'ডায়রিয়া, পেটে ব্যথা, বা বমি বমি ভাব।',
      'alternatives': ['ওমেপ্রাজোল', 'প্যান্টোপ্রাজোল']
    },
    {
      'name': 'ফ্লুকোনাজোল',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 90.00,
      'composition': 'ফ্লুকোনাজোল',
      'sideEffects': 'বমি বমি ভাব, মাথাব্যথা, বা মাথা ঘোরা।',
      'alternatives': ['নাইস্ট্যাটিন', 'ক্লোট্রিমাজোল']
    },
    {
      'name': 'ক্লোট্রিমাজোল',
      'status': 'কম স্টক',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 50.00,
      'composition': 'ক্লোট্রিমাজোল',
      'sideEffects': 'ত্বকে জ্বালা, লালভাব, বা চুলকানি।',
      'alternatives': ['মিকোনাজোল', 'নাইস্ট্যাটিন']
    },
    {
      'name': 'মিকোনাজোল',
      'status': 'স্টকে আছে',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 65.00,
      'composition': 'মিকোনাজোল নাইট্রেট',
      'sideEffects': 'ত্বকে জ্বালা, জ্বালাপোড়া, বা চুলকানি।',
      'alternatives': ['ক্লোট্রিমাজোল', 'নাইস্ট্যাটিন']
    },
    {
      'name': 'ডাইফেনহাইড্রামিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 40.00,
      'composition': 'ডাইফেনহাইড্রামিন হাইড্রোক্লোরাইড',
      'sideEffects': 'তন্দ্রা, মাথা ঘোরা, বা শুকনো মুখ।',
      'alternatives': ['লোরাটাডিন', 'সেটিরিজাইন']
    },
    {
      'name': 'ফেক্সোফেনাডাইন',
      'status': 'কম স্টক',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 80.00,
      'composition': 'ফেক্সোফেনাডাইন হাইড্রোক্লোরাইড',
      'sideEffects': 'মাথাব্যথা, মাথা ঘোরা, বা বমি বমি ভাব।',
      'alternatives': ['লোরাটাডিন', 'সেটিরিজাইন']
    },
    {
      'name': 'রানিটিডিন',
      'status': 'অনুপলব্ধ',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 85.00,
      'composition': 'রানিটিডিন হাইড্রোক্লোরাইড',
      'sideEffects': 'মাথাব্যথা, মাথা ঘোরা, বা ডায়রিয়া।',
      'alternatives': ['ফেমোটিডিন', 'ওমেপ্রাজোল']
    },
    {
      'name': 'ফেমোটিডিন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 70.00,
      'composition': 'ফেমোটিডিন',
      'sideEffects': 'মাথাব্যথা, মাথা ঘোরা, বা কোষ্ঠকাঠিন্য।',
      'alternatives': ['রানিটিডিন', 'ওমেপ্রাজোল']
    },
    {
      'name': 'ওন্ডানসেট্রন',
      'status': 'স্টকে আছে',
      'pharmacy': 'রুরাল হেলথ স্টোর',
      'price': 150.00,
      'composition': 'ওন্ডানসেট্রন হাইড্রোক্লোরাইড',
      'sideEffects': 'মাথাব্যথা, কোষ্ঠকাঠিন্য, বা ডায়রিয়া।',
      'alternatives': ['মেটোক্লোপ্রামাইড']
    },
    {
      'name': 'মেটোক্লোপ্রামাইড',
      'status': 'কম স্টক',
      'pharmacy': 'নভ্যা মেডিকেলস',
      'price': 130.00,
      'composition': 'মেটোক্লোপ্রামাইড হাইড্রোক্লোরাইড',
      'sideEffects': 'তন্দ্রা, মাথা ঘোরা, বা অস্থিরতা।',
      'alternatives': ['ওন্ডানসেট্রন']
    },
    {
      'name': 'স্পিরোনোল্যাকটোন',
      'status': 'স্টকে আছে',
      'pharmacy': 'সিটি ফার্মেসি',
      'price': 160.00,
      'composition': 'স্পিরোনোল্যাকটোন',
      'sideEffects': 'তন্দ্রা, মাথা ঘোরা, বা হালকা মাথা ব্যথা।',
      'alternatives': ['এপ্লেরেনোন']
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredMedicines = _isBengali() ? _medicinesBn : _medicines;
    _searchController.addListener(_filterMedicines);
  }

  void _filterMedicines() {
    final query = _searchController.text.toLowerCase();
    final List<Map<String, dynamic>> currentMedicines = _isBengali() ? _medicinesBn : _medicines;
    setState(() {
      _filteredMedicines = currentMedicines.where((med) {
        return med['name']!.toLowerCase().contains(query) ||
            med['pharmacy']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  bool _isBengali() {
    return widget.localizations.locale.languageCode == 'bn';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Stock':
      case 'স্টকে আছে':
        return const Color(0xFF6A994E); // Green
      case 'Low Stock':
      case 'কম স্টক':
        return const Color(0xFFE88A1A); // Orange
      case 'Unavailable':
      case 'অনুপলব্ধ':
        return const Color(0xFFE63946); // Red
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.localizations.searchMedicine,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMedicines.length,
            itemBuilder: (context, index) {
              final medicine = _filteredMedicines[index];
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineDetailScreen(
                            medicine: medicine,
                            localizations: widget.localizations,
                          ),
                        ),
                      );
                    },
                    title: Text(
                      medicine['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      medicine['pharmacy']!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${medicine['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(medicine['status']!)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            medicine['status']!,
                            style: TextStyle(
                                color: _getStatusColor(medicine['status']!),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Medicine Detail Screen ---
class MedicineDetailScreen extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final AppLocalizations localizations;

  const MedicineDetailScreen({
    super.key,
    required this.medicine,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final isBengali = localizations.locale.languageCode == 'bn';
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine['name']!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${medicine['name']}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${localizations.pharmacy}: ${medicine['pharmacy']}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _buildDetailCard(
                context,
                isBengali ? 'মূল্য' : 'Price',
                '₹${medicine['price'].toStringAsFixed(2)}',
                Icons.currency_rupee,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                context,
                isBengali ? 'গঠন' : 'Composition',
                medicine['composition'],
                Icons.science,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                context,
                isBengali ? 'পার্শ্ব প্রতিক্রিয়া' : 'Side Effects',
                medicine['sideEffects'],
                Icons.warning_amber,
              ),
              const SizedBox(height: 16),
              _buildAlternativesCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
      BuildContext context, String title, String content, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativesCard(BuildContext context) {
    List<dynamic> alternatives = medicine['alternatives'] ?? [];
    final isBengali = localizations.locale.languageCode == 'bn';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  isBengali ? 'বিকল্প' : 'Alternatives',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (alternatives.isNotEmpty)
              ...alternatives
                  .map((alt) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '• $alt',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ))
                  .toList()
            else
              Text(
                isBengali ? 'কোনো বিকল্প নেই।' : 'No alternatives listed.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

// --- AI-Powered Symptom Checker Screen ---
class SymptomCheckerScreen extends StatefulWidget {
  final AppLocalizations localizations;
  const SymptomCheckerScreen({super.key, required this.localizations});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final String _geminiApiKey = 'AIzaSyBYNV1NRykJvEto3F6hqFjQE8HzrKhsZ1U';
  late final GenerativeModel _model;
  late ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _messages.add(
      ChatMessage(
        text: widget.localizations.symptomCheckerIntro,
        isUser: false,
      ),
    );
  }

  void _initializeGemini() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
    _chat = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final String messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: messageText, isUser: true));
      _textController.clear();
      _isLoading = true;
    });

    try {
      final String prompt = """
You are an AI assistant designed to provide very brief and concise general information about symptoms. You are NOT a medical professional. Always advise the user to consult a doctor. The user is describing symptoms. Based on the following symptoms, provide a summary of possible conditions and next steps. Limit your response to a maximum of 50 words. Respond in the language requested by the user, if possible. Ask only one follow-up question per reply. Your responses should sound like a natural conversation. For some questions, you can provide options, e.g., "How would you rate the severity of your fever (High, Medium, Low)?".

User's symptoms: "$messageText"
""";

      final response = await _chat.sendMessage(Content.text(prompt));
      String geminiResponseText = response.text ?? 'I am sorry, I am unable to provide information at this moment.';

      final words = geminiResponseText.split(' ');
      if (words.length > 50) {
        geminiResponseText = words.sublist(0, 50).join(' ') + '...';
      }

      setState(() {
        _messages.add(ChatMessage(
          text: geminiResponseText,
          isUser: false,
        ));
      });
    } on Exception catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            text: '${widget.localizations.geminiError}: $e', isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            reverse: false,
            padding: const EdgeInsets.all(8.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ChatMessageBubble(message: message);
            },
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary),
          ),
        _buildMessageInput(widget.localizations),
      ],
    );
  }

  Widget _buildMessageInput(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: localizations.typeYourSymptoms,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Icon(Icons.send,
                color: Theme.of(context).colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

// --- Widget for displaying a single chat message (for Symptom Checker) ---
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTap;

  const ChatMessageBubble({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.all(12.0),
          constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: message.isUser
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(message.isUser ? 20.0 : 4.0),
              topRight: Radius.circular(message.isUser ? 4.0 : 20.0),
              bottomLeft: const Radius.circular(20.0),
              bottomRight: const Radius.circular(20.0),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
                color: message.isUser
                    ? Theme.of(context).colorScheme.onSecondary
                    : Theme.of(context).colorScheme.onPrimary,
                fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// --- Doctor Detail Screen (Updated to show hospitals) ---
class DoctorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final AppLocalizations localizations;
  final CameraDescription camera;

  const DoctorDetailScreen({super.key, required this.doctor, required this.localizations, required this.camera});

  @override
  Widget build(BuildContext context) {
    final isBengali = localizations.locale.languageCode == 'bn';
    final Map<String, dynamic> doctorData = isBengali ? {
      'name': doctor['name'],
      'specialty': doctor['specialty'],
      'qualifications': doctor['qualifications'],
      'experienceYears': doctor['experienceYears'],
      'timeSlot': doctor['timeSlot'],
      'hospitals': doctor['hospitals'],
    } : {
      'name': doctor['name'],
      'specialty': doctor['specialty'],
      'qualifications': doctor['qualifications'],
      'experienceYears': doctor['experienceYears'],
      'timeSlot': doctor['timeSlot'],
      'hospitals': doctor['hospitals'],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(doctorData['name']!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF1E5280),
                    radius: 40,
                    child: Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorData['name']!,
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctorData['specialty']!,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildInfoCard(
                context,
                isBengali ? 'যোগ্যতা' : 'Qualifications',
                doctorData['qualifications']!,
                Icons.school,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                isBengali ? 'অভিজ্ঞতা' : 'Experience',
                isBengali ? '${doctorData['experienceYears']} বছর' : '${doctorData['experienceYears']} years',
                Icons.work,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                isBengali ? 'সময় স্লট' : 'Time Slot',
                doctorData['timeSlot']!,
                Icons.access_time,
              ),
              const SizedBox(height: 16),
              _buildHospitalsCard(context),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoConsultationScreen(camera: camera, doctorName: doctorData['name']),
                          ),
                        );
                      },
                      icon: const Icon(Icons.video_call),
                      label: Text(isBengali ? 'ভিডিও পরামর্শ শুরু করুন' : 'Start Video Consultation'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        textStyle: const TextStyle(fontSize: 18),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorChatScreen(localizations: localizations, doctorName: doctorData['name'])));
                      },
                      icon: const Icon(Icons.chat),
                      label: Text(isBengali ? 'ডাক্তারের সাথে চ্যাট করুন' : 'Chat with Doctor'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        textStyle: const TextStyle(fontSize: 18),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalsCard(BuildContext context) {
    List<dynamic> hospitals = doctor['hospitals'] ?? [];
    final isBengali = localizations.locale.languageCode == 'bn';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  localizations.hospitals,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hospitals.isNotEmpty)
              ...hospitals
                  .map((hospital) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '• $hospital',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ))
                  .toList()
            else
              Text(
                isBengali ? 'কোনো হাসপাতাল তালিকাভুক্ত নেই।' : 'No hospitals listed.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

// --- Video Consultation Screen ---
class VideoConsultationScreen extends StatefulWidget {
  final CameraDescription camera;
  final String? doctorName;

  const VideoConsultationScreen({super.key, required this.camera, this.doctorName});

  @override
  State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBengali = Localizations.localeOf(context).languageCode == 'bn';
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Doctor Placeholder (Large)
                Container(
                  color: Colors.grey.shade900,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 100, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.doctorName ?? (isBengali ? 'ডাক্তার' : 'Doctor'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // User's Camera Feed (Small)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                // Bottom control panel
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCallButton(Icons.mic, () {}, isBengali ? 'মিউট' : 'Mute'),
                        const SizedBox(width: 20),
                        _buildCallButton(Icons.call_end, () {
                          Navigator.pop(context);
                        }, isBengali ? 'কল শেষ করুন' : 'End Call', backgroundColor: Colors.red),
                        const SizedBox(width: 20),
                        _buildCallButton(Icons.videocam, () {}, isBengali ? 'ভিডিও বন্ধ করুন' : 'Stop Video'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Widget _buildCallButton(IconData icon, VoidCallback onTap, String label, {Color? backgroundColor}) {
  return Column(
    children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: backgroundColor ?? Colors.grey.shade800,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ],
  );
}
