class StringConst {
  ///App Name
  static const String appName = 'Monvexa';
  static const String appDescription = 'A Expense Tracker Application.';

  ///Onboarding Screens
  static const onboarding1Title1 = 'Your Expenses';
  static const onboarding1Title2 = 'Track Automatically';
  static const onboarding1Description =
      'No more manually adding every transaction.\nLet us help organize your spending.';
  static const onboarding2Title1 = 'Your Messages';
  static const onboarding2Title2 = 'Stays Yours';
  static const onboarding2Description =
      'Your privacy matters.\nWe never compromise it.';
  static const onboarding3Title1 = 'Reach Your';
  static const onboarding3Title2 = 'Financial Goals';
  static const onboarding3Description =
      'Save more, spend smarter\nand achieve your goals.';

  static const nextButton = 'Next';
  static const getStartedButton = 'Get Started';

  ///Home Screen
  static const home = 'Home';
  static const scan = 'Scan';
  static const wallet = 'Wallet';
  static const settings = 'Settings';

  ///Home Tab
  static const hello = 'Hello!';
  static const recentTransactions = 'Recent Transactions';
  static const noAccountFound = 'No Account found.';
  static const tapBelowToAddAccount = 'Tap below to add an account.';
  static const addAccount = 'Add Account';
  static const noTransactions = 'No transactions yet.';

  ///Account Detection Screen

  static const gettingStarted = 'Getting started...';
  static const scanningInbox = 'Scanning inbox messages...';
  static const analyzingTransactions = 'Analyzing transaction alerts...';
  static const verifyingBank = 'Verifying bank accounts...';
  static const finalizingAccounts = 'Finalizing accounts...';

  
  static const settingUpAccounts = 'Setting Up Your Accounts';
  static const readingAccount =
      'We are reading your inbox messages securely on-device to auto-detect your bank accounts.';
  static const onDevicePrivacy = '100% on-device private processing';
  static const accountDetected = 'Accounts Detected';
  static String noOfAccDetected(int len) =>
      'We discovered $len bank account(s) from your transaction SMS.';
  static String transactionAlert(String sender, int count, String matchedBy) =>
      '$sender • $count transaction alerts ($matchedBy)';
  static const noAccountFoundAfterScanningSms =
      'We scanned your SMS inbox but could not match any transaction alerts with our bank patterns. You can add your account manually or retry the scan.';
  static const retryScan = 'Retry Scan';
  static const continueToHome = 'Continue to Home Tab';

  ///Settings Tab
  static const settingsTabTitle = 'Settings';
  static const language = 'Language';
  static const darkMode = 'Dark Mode';
  static const biometric = 'Biometric';
  static const currency = 'Currency';
  static const notification = 'Notification';
  static const privacyPolicy = 'Privacy Policy';
  static const feedback = 'Feedback';
  static const rateUs = 'Rate Us';
  static const shareApp = 'Share App';
  static const aboutApp = 'About App';
  static const appVersion = 'App Version';
}
