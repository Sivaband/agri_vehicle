class AppStrings {
  static bool _isTelugu = false;

  static void setTelugu(bool val) => _isTelugu = val;
  static bool get isTelugu => _isTelugu;

  // App
  static String get appName => _isTelugu ? 'వ్యవసాయ వాహన నిర్వహణ' : 'Agri Vehicle Manager';

  // Auth
  static String get login => _isTelugu ? 'లాగిన్' : 'Login';
  static String get signup => _isTelugu ? 'సైన్ అప్' : 'Sign Up';
  static String get logout => _isTelugu ? 'లాగ్అవుట్' : 'Logout';
  static String get mobileOrEmail => _isTelugu ? 'మొబైల్ నంబర్ లేదా ఈమెయిల్' : 'Mobile Number or Email';
  static String get password => _isTelugu ? 'పాస్వర్డ్' : 'Password';
  static String get rememberMe => _isTelugu ? 'నన్ను గుర్తుంచుకో' : 'Remember Me';
  static String get dontHaveAccount => _isTelugu ? 'ఖాతా లేదా? సైన్ అప్' : "Don't have an account? Sign Up";
  static String get alreadyHaveAccount => _isTelugu ? 'ఇప్పటికే ఖాతా ఉందా? లాగిన్' : 'Already have an account? Login';
  static String get name => _isTelugu ? 'పేరు' : 'Name';
  static String get mobileNumber => _isTelugu ? 'మొబైల్ నంబర్' : 'Mobile Number';

  // Vehicle Selection
  static String get selectVehicle => _isTelugu ? 'వాహనం ఎంచుకోండి' : 'Select Your Vehicle';
  static String get tractor => _isTelugu ? 'ట్రాక్టర్' : 'Tractor';
  static String get jcb => _isTelugu ? 'జేసీబీ' : 'JCB';
  static String get harvester => _isTelugu ? 'హార్వెస్టర్' : 'Harvester';

  // Dashboard
  static String get dashboard => _isTelugu ? 'డాష్‌బోర్డ్' : 'Dashboard';
  static String get totalEarnings => _isTelugu ? 'మొత్తం ఆదాయం' : 'Total Earnings';
  static String get dieselCost => _isTelugu ? 'డీజిల్ ఖర్చు' : 'Diesel Cost';
  static String get profit => _isTelugu ? 'లాభం' : 'Profit';
  static String get workingTime => _isTelugu ? 'పని సమయం' : 'Working Time';
  static String get todayWork => _isTelugu ? 'నేటి పని' : "Today's Work";
  static String get startWork => _isTelugu ? 'పని ప్రారంభించు' : 'Start Work';
  static String get history => _isTelugu ? 'చరిత్ర' : 'History';
  static String get reports => _isTelugu ? 'నివేదికలు' : 'Reports';
  static String get noWorkToday => _isTelugu ? 'నేడు పని లేదు' : 'No work entries today';

  // Work Entry
  static String get newWorkEntry => _isTelugu ? 'కొత్త పని నమోదు' : 'New Work Entry';
  static String get customerName => _isTelugu ? 'కస్టమర్ పేరు' : 'Customer Name';
  static String get enterCustomerName => _isTelugu ? 'కస్టమర్ పేరు నమోదు చేయండి' : 'Enter customer name';
  static String get workType => _isTelugu ? 'పని రకం' : 'Work Type';
  static String get startTime => _isTelugu ? 'ప్రారంభ సమయం' : 'Start Time';
  static String get endTime => _isTelugu ? 'ముగింపు సమయం' : 'End Time';
  static String get acres => _isTelugu ? 'ఎకరాలు' : 'Acres';
  static String get dieselUsed => _isTelugu ? 'వాడిన డీజిల్ (లీటర్లు)' : 'Diesel Used (Liters)';
  static String get pricePerHour => _isTelugu ? 'గంట ధర' : 'Price per Hour';
  static String get pricePerAcre => _isTelugu ? 'ఎకరం ధర' : 'Price per Acre';
  static String get totalIncome => _isTelugu ? 'మొత్తం ఆదాయం' : 'Total Income';
  static String get saveWork => _isTelugu ? 'పని సేవ్ చేయండి' : 'Save Work';
  static String get speakName => _isTelugu ? 'పేరు చెప్పండి' : 'Speak Name';
  static String get listening => _isTelugu ? 'వింటున్నాను...' : 'Listening...';
  static String get calculation => _isTelugu ? 'లెక్క' : 'Calculation';

  // Work Types - Tractor
  static String get rotor => _isTelugu ? 'రోటర్' : 'Rotor';
  static String get ploughing => _isTelugu ? 'దున్నడం' : 'Ploughing';
  static String get cultivation => _isTelugu ? 'సేద్యం' : 'Cultivation';
  static String get seeding => _isTelugu ? 'విత్తనం' : 'Seeding';

  // Work Types - JCB
  static String get digging => _isTelugu ? 'తవ్వడం' : 'Digging';
  static String get leveling => _isTelugu ? 'సమం చేయడం' : 'Leveling';
  static String get loading => _isTelugu ? 'లోడింగ్' : 'Loading';

  // Work Types - Harvester
  static String get paddyCutting => _isTelugu ? 'వరి కోత' : 'Paddy Cutting';
  static String get wheatHarvesting => _isTelugu ? 'గోధుమ కోత' : 'Wheat Harvesting';

  // History
  static String get customerHistory => _isTelugu ? 'కస్టమర్ చరిత్ర' : 'Customer History';
  static String get allCustomers => _isTelugu ? 'అందరు కస్టమర్లు' : 'All Customers';
  static String get totalJobs => _isTelugu ? 'మొత్తం పనులు' : 'Total Jobs';
  static String get lastWork => _isTelugu ? 'చివరి పని' : 'Last Work';

  // Reports
  static String get daily => _isTelugu ? 'రోజువారీ' : 'Daily';
  static String get weekly => _isTelugu ? 'వారపు' : 'Weekly';
  static String get monthly => _isTelugu ? 'నెలవారీ' : 'Monthly';
  static String get earningsChart => _isTelugu ? 'ఆదాయం చార్ట్' : 'Earnings Chart';

  // Misc
  static String get save => _isTelugu ? 'సేవ్' : 'Save';
  static String get cancel => _isTelugu ? 'రద్దు' : 'Cancel';
  static String get hours => _isTelugu ? 'గంటలు' : 'hrs';
  static String get rupee => '₹';
  static String get liters => _isTelugu ? 'లీ' : 'L';
  static String get dieselPricePerLiter => _isTelugu ? 'డీజిల్ ధర/లీ' : 'Diesel ₹/Liter';
  static String get settings => _isTelugu ? 'సెట్టింగులు' : 'Settings';
  static String get language => _isTelugu ? 'భాష' : 'Language';
  static String get switchLanguage => _isTelugu ? 'English కి మార్చు' : 'తెలుగులో మార్చు';
}
