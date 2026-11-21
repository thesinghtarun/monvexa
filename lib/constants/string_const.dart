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
  static const noTransactionsFound = 'No transactions found for this account.';
  static const noActivityToday = 'No spending activity recorded today.';
  static const scanAndDetectAccounts = 'Scan & Detect Accounts';
  static const scanAndAddOtherAccounts = 'Scan & Add Other Accounts';
  static const myAccounts = 'My Accounts';
  static const noAccountsAddedYet = 'No accounts added yet.';

  static const totalBal = 'Total Balance';
  static const encryptedBal = 'XXXX';
  static const todaysIncome = "Today's Income";
  static const todaysExpense = "Today's Expense";

  ///Permission Dialog
  static const smsPermissionRequired = 'SMS Permission Required';
  static const smsPermissionDesc =
      'Monvexa needs access to your SMS to automatically detect and track your bank transactions.';
  static const realtimeTrackingTitle = 'Enable Real-time Tracking';
  static const realtimeTrackingDesc =
      'Allow Monvexa to instantly detect bank transaction alerts so your expenses and balance update the moment you spend.';
  static const notificationRequiredSms =
      'Real-time SMS permission is required for transaction notifications.';
  static const cancelButton = 'Cancel';
  static const openSettingsButton = 'Open Settings';
  static const remindLaterButton = 'Remind Later';

  ///Account Detection Screen
  static const closeButton = 'Close';
  static const gettingStarted = 'Getting started...';
  static const scanningInbox = 'Scanning inbox messages...';
  static const analyzingTransactions = 'Analyzing transaction alerts...';
  static const verifyingBank = 'Verifying new bank accounts...';
  static const finalizingAccounts = 'Finalizing accounts...';

  static const settingUpAccounts = 'Setting Up Your Accounts';
  static const readingAccount =
      'Scanning your inbox to securely discover your bank accounts.';
  static const onDevicePrivacy = '100% on-device private processing';

  static const newAccountsFound = 'New Accounts Found';
  static String newAccountsDiscovered(int count) =>
      'We found $count new bank account(s). Check the ones you want to save.';
  static const confirmAndSaveAccounts = 'Confirm & Save Accounts';

  static const noNewAccountsFound = 'No New Accounts Found';
  static const noNewAccountsDesc =
      'All detected bank accounts from your SMS are already saved, or no new transaction alerts were found.';
  static const retryScan = 'Retry Scan';
  static const backToHomeTab = 'Back to Home Tab';

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
