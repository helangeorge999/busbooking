class Tr {
  static String _lang = 'en';

  static void setLanguage(String lang) => _lang = lang;

  static String get(String key) =>
      (_data[key]?[_lang]) ?? (_data[key]?['en']) ?? key;

  static final Map<String, Map<String, String>> _data = {
    // ── Common ─────────────────────────────────────────────────────────────
    'app_name': {'en': 'Bus Booking', 'ne': 'बस बुकिङ'},
    'home': {'en': 'Home', 'ne': 'गृहपृष्ठ'},
    'bookings': {'en': 'Bookings', 'ne': 'बुकिङहरू'},
    'booking_history': {'en': 'Booking History', 'ne': 'बुकिङ इतिहास'},
    'save': {'en': 'Save', 'ne': 'सेभ गर्नुहोस्'},
    'cancel': {'en': 'Cancel', 'ne': 'रद्द गर्नुहोस्'},
    'ok': {'en': 'OK', 'ne': 'ठीक छ'},
    'error': {'en': 'Error', 'ne': 'त्रुटि'},
    'success': {'en': 'Success', 'ne': 'सफल'},
    'loading': {'en': 'Loading...', 'ne': 'लोड हुँदैछ...'},
    'coming_soon': {'en': 'Coming soon!', 'ne': 'चाँडै आउँदैछ!'},

    // ── Greeting ───────────────────────────────────────────────────────────
    'good_morning': {'en': 'Good Morning', 'ne': 'शुभ प्रभात'},
    'good_afternoon': {'en': 'Good Afternoon', 'ne': 'शुभ दिउँसो'},
    'good_evening': {'en': 'Good Evening', 'ne': 'शुभ सन्ध्या'},
    'hello': {'en': 'Hello', 'ne': 'नमस्ते'},
    'ready_to_book': {
      'en': 'Ready to book your next bus trip?',
      'ne': 'तपाईंको अर्को बस यात्रा बुक गर्न तयार हुनुहुन्छ?',
    },
    'what_to_do': {
      'en': 'What would you like to do?',
      'ne': 'तपाईं के गर्न चाहनुहुन्छ?',
    },

    // ── Actions ────────────────────────────────────────────────────────────
    'book_ticket': {'en': 'Book a Ticket', 'ne': 'टिकट बुक गर्नुहोस्'},
    'search_buses': {
      'en': 'Search buses and reserve your seat',
      'ne': 'बस खोज्नुहोस् र सिट आरक्षित गर्नुहोस्',
    },
    'view_past_trips': {
      'en': 'View your past and upcoming trips',
      'ne': 'तपाईंका विगत र आगामी यात्राहरू हेर्नुहोस्',
    },

    // ── Stats ──────────────────────────────────────────────────────────────
    'routes': {'en': 'Routes', 'ne': 'मार्गहरू'},
    'buses': {'en': 'Buses', 'ne': 'बसहरू'},
    'rating': {'en': 'Rating', 'ne': 'रेटिङ'},

    // ── Profile & Drawer ───────────────────────────────────────────────────
    'view_profile': {'en': 'View Profile', 'ne': 'प्रोफाइल हेर्नुहोस्'},
    'edit_profile': {'en': 'Edit Profile', 'ne': 'प्रोफाइल सम्पादन'},
    'change_password': {'en': 'Change Password', 'ne': 'पासवर्ड परिवर्तन'},
    'settings': {'en': 'Settings', 'ne': 'सेटिङ'},
    'help_support': {'en': 'Help & Support', 'ne': 'सहायता र समर्थन'},
    'sign_out': {'en': 'Sign Out', 'ne': 'साइन आउट'},
    'sign_out_confirm': {
      'en': 'Are you sure you want to sign out?',
      'ne': 'के तपाईं साइन आउट गर्न चाहनुहुन्छ?',
    },

    // ── Profile Page ───────────────────────────────────────────────────────
    'personal_info': {'en': 'Personal Information', 'ne': 'व्यक्तिगत जानकारी'},
    'email': {'en': 'Email', 'ne': 'इमेल'},
    'phone': {'en': 'Phone', 'ne': 'फोन'},
    'gender': {'en': 'Gender', 'ne': 'लिङ्ग'},
    'date_of_birth': {'en': 'Date of Birth', 'ne': 'जन्म मिति'},
    'change_photo': {'en': 'Change Photo', 'ne': 'फोटो परिवर्तन'},
    'uploading': {'en': 'Uploading…', 'ne': 'अपलोड हुँदैछ…'},
    'photo_updated': {
      'en': 'Profile photo updated!',
      'ne': 'प्रोफाइल फोटो अपडेट भयो!',
    },
    'upload_failed': {
      'en': 'Upload failed. Try again.',
      'ne': 'अपलोड असफल। फेरि प्रयास गर्नुहोस्।',
    },
    'choose_gallery': {
      'en': 'Choose from Gallery',
      'ne': 'ग्यालरीबाट छान्नुहोस्',
    },
    'pick_existing': {
      'en': 'Pick an existing photo',
      'ne': 'अवस्थित फोटो छान्नुहोस्',
    },
    'take_photo': {'en': 'Take a Photo', 'ne': 'फोटो खिच्नुहोस्'},
    'use_camera': {
      'en': 'Use your camera',
      'ne': 'आफ्नो क्यामेरा प्रयोग गर्नुहोस्',
    },
    'update_profile_photo': {
      'en': 'Update Profile Photo',
      'ne': 'प्रोफाइल फोटो अपडेट',
    },
    'your_name': {'en': 'Your Name', 'ne': 'तपाईंको नाम'},

    // ── Edit Profile ───────────────────────────────────────────────────────
    'name': {'en': 'Name', 'ne': 'नाम'},
    'dob': {'en': 'DOB', 'ne': 'जन्म मिति'},
    'gallery': {'en': 'Gallery', 'ne': 'ग्यालरी'},
    'camera': {'en': 'Camera', 'ne': 'क्यामेरा'},
    'save_changes': {'en': 'Save Changes', 'ne': 'परिवर्तनहरू सेभ गर्नुहोस्'},
    'failed_upload': {'en': 'Failed to upload photo', 'ne': 'फोटो अपलोड असफल'},
    'server_error': {'en': 'Server error', 'ne': 'सर्भर त्रुटि'},

    // ── Settings ───────────────────────────────────────────────────────────
    'push_notifications': {'en': 'Push Notifications', 'ne': 'पुश सूचनाहरू'},
    'notif_subtitle': {
      'en': 'Get booking updates & alerts',
      'ne': 'बुकिङ अपडेट र अलर्ट पाउनुहोस्',
    },
    'sms_alerts': {'en': 'SMS Alerts', 'ne': 'SMS अलर्ट'},
    'sms_subtitle': {
      'en': 'Receive booking confirmation via SMS',
      'ne': 'SMS मार्फत बुकिङ पुष्टि प्राप्त गर्नुहोस्',
    },
    'dark_mode': {'en': 'Dark Mode', 'ne': 'डार्क मोड'},
    'dark_subtitle': {
      'en': 'Switch app appearance',
      'ne': 'एप उपस्थिति परिवर्तन',
    },
    'language': {'en': 'Language', 'ne': 'भाषा'},
    'english': {'en': 'English', 'ne': 'अंग्रेजी'},
    'nepali': {'en': 'Nepali', 'ne': 'नेपाली'},
    'privacy_policy': {'en': 'Privacy Policy', 'ne': 'गोपनीयता नीति'},
    'about_app': {'en': 'About App', 'ne': 'एपबारे'},
    'version': {'en': 'Version 1.0.0', 'ne': 'संस्करण १.०.०'},
    'select_language': {'en': 'Select Language', 'ne': 'भाषा छान्नुहोस्'},

    // ── Change Password ────────────────────────────────────────────────────
    'current_password': {'en': 'Current Password', 'ne': 'हालको पासवर्ड'},
    'new_password': {'en': 'New Password', 'ne': 'नयाँ पासवर्ड'},
    'confirm_password': {
      'en': 'Confirm New Password',
      'ne': 'नयाँ पासवर्ड पुष्टि',
    },
    'update_password': {'en': 'Update Password', 'ne': 'पासवर्ड अपडेट'},
    'enter_current': {
      'en': 'Enter current password',
      'ne': 'हालको पासवर्ड प्रविष्ट गर्नुहोस्',
    },
    'min_6_chars': {'en': 'Minimum 6 characters', 'ne': 'कम्तिमा ६ अक्षर'},
    'passwords_mismatch': {
      'en': 'Passwords do not match',
      'ne': 'पासवर्ड मेल खाँदैन',
    },
    'password_changed': {
      'en': 'Password changed successfully!',
      'ne': 'पासवर्ड सफलतापूर्वक परिवर्तन भयो!',
    },
    'session_expired': {
      'en': 'Session expired. Please login again.',
      'ne': 'सत्र समाप्त भयो। कृपया पुन: लगइन गर्नुहोस्।',
    },
    'network_error': {
      'en': 'Network error. Check your connection.',
      'ne': 'नेटवर्क त्रुटि। आफ्नो जडान जाँच गर्नुहोस्।',
    },

    // ── Display & Sensors ──────────────────────────────────────────────────
    'display': {'en': 'Display', 'ne': 'प्रदर्शन'},
    'sensors': {'en': 'Sensors', 'ne': 'सेन्सरहरू'},
    'light_mode': {'en': 'Light Mode', 'ne': 'लाइट मोड'},
    'system_mode': {'en': 'System Mode', 'ne': 'सिस्टम मोड'},
    'choose_theme': {'en': 'Choose Theme', 'ne': 'थिम छान्नुहोस्'},
  };
}
