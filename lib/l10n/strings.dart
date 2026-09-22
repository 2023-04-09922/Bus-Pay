import '../state/app_state.dart';

class S {
  S(this.language);

  final AppLanguage language;

  bool get isSw => language == AppLanguage.sw;

  String get appName => 'Bus Pay';
  String get loginFailed =>
      isSw ? 'Login failed' : 'Login failed';
  String get incorrectCredentials =>
      isSw ? 'Jina la mtumiaji au nenosiri si sahihi' : 'Incorrect username or password';
  String get noAccount => isSw
      ? 'Hakuna akaunti. Jisajili kwanza.'
      : 'No account yet. Please sign up first.';
  String get registrationOk =>
      isSw ? 'Usajili umefanikiwa' : 'Registration successful';
  String get connectionTimeout => isSw
      ? 'Seva haijibu. Angalia Wi-Fi na backend.'
      : 'Server did not respond. Check Wi-Fi and that the backend is running.';
  String get pinLocked => isSw
      ? 'Akaunti imefungwa kwa muda. Jaribu tena baadaye.'
      : 'Account locked. Try again later.';
  String get tooManyRequests => isSw
      ? 'Majaribio mengi mno. Subiri kidogo kisha jaribu tena.'
      : 'Too many attempts. Wait a moment, then try again.';
  String get unknownUser =>
      isSw ? 'Akaunti haijapatikana' : 'Account not found';
  String get signUp => isSw ? 'Jisajili' : 'Sign up';
  String get firstName => isSw ? 'Jina la kwanza' : 'First name';
  String get lastName => isSw ? 'Jina la mwisho' : 'Last name';
  String get nida => 'NIDA';
  String get nidaHint => '';
  String get yourId => isSw ? 'Kitambulisho chako' : 'Your ID';
  String get signAs => isSw ? 'Jisajili kama' : 'Sign up as';
  String get agent => isSw ? 'Wakala' : 'Agent';
  String get agentLater => isSw
      ? 'Taarifa zaidi za wakala zitaongezwa baadaye. Akaunti ya majaribio imeundwa.'
      : 'More agent fields will be added later. A trial account was created.';
  String get sajiliCard => isSw ? 'Sajili card' : 'Register card';
  String get sajiliCardHint =>
      isSw ? 'Andika kadi mpya na salio la kwanza' : 'Issue a new card with first load';
  String get renewCard => isSw ? 'Huisha card' : 'Renew card';
  String get renewCardHint =>
      isSw ? 'Huisha UID au taarifa za kadi' : 'Refresh UID or card details';
  String get topUpCard => isSw ? 'Ongeza salio' : 'Top up card';
  String get topUpCardHint =>
      isSw ? 'Weka pesa kwenye kadi' : 'Add money to a card';
  String get cardRenewed => isSw ? 'Card imehuishwa' : 'Card renewed';
  String get topUpOk => isSw ? 'Salio limeongezwa' : 'Card topped up';
  String get amountRequired =>
      isSw ? 'Weka kiasi cha kuongeza kwenye kadi' : 'Enter the amount to add to the card';
  String get cardRequired =>
      isSw ? 'Weka namba ya kadi iliyosajiliwa' : 'Enter a registered card number';
  String get currentBalance => isSw ? 'Salio la sasa' : 'Current balance';
  String get newBalance => isSw ? 'Salio jipya' : 'New balance';
  String get amountAdded => isSw ? 'Kiasi kilichoongezwa' : 'Amount added';
  String get cardServices => isSw ? 'Huduma za kadi' : 'Card services';
  String get wakalaDesk => isSw ? 'Dawati la wakala' : 'Agent desk';
  String get huishaCard => isSw ? 'Huisha card' : 'Deactivate card';
  String get msaada => isSw ? 'Msaada' : 'Help';
  String get jihudumie => isSw ? 'Jihudumie' : 'Self service';
  String get loginAsAgent => isSw ? 'Ingia kama wakala' : 'Sign in as agent';
  String get agentLoginTitle => isSw ? 'Ingia kama wakala' : 'Agent login';
  String get agentLoginHint =>
      isSw ? 'Weka barua pepe na nenosiri.' : 'Enter email and password.';
  String get gmailOnly =>
      isSw ? 'Tumia barua pepe yenye mwisho @gmail.com' : 'Use an email ending with @gmail.com';
  String get agentPassword => isSw ? 'Nenosiri' : 'Password';
  String get emailUsername =>
      isSw ? 'Barua pepe / jina la mtumiaji' : 'Email / username';
  String get forgotPassword =>
      isSw ? 'Umesahau nenosiri?' : 'Forgot password?';
  String get forgotPasswordHint => isSw
      ? 'Weka barua pepe yako, tutatuma namba ya kurejesha nenosiri.'
      : 'Enter your email and we will send a password reset code.';
  String get emailFormatHint => '';
  String get invalidEmail =>
      isSw ? 'Weka barua pepe au jina la mtumiaji' : 'Enter email or username';
  String get sendCode => isSw ? 'Tuma namba' : 'Send code';
  String get resetCode => isSw ? 'Namba ya kurejesha' : 'Reset code';
  String get enterResetCode => isSw
      ? 'Weka namba 6 uliyotumiwa, kisha nenosiri jipya.'
      : 'Enter the 6-digit code, then your new password.';
  String get resetCodeSent => isSw
      ? 'Namba ya kurejesha imetumwa kwenye barua pepe yako.'
      : 'A reset code was sent to your email.';
  String get resetPassword => isSw ? 'Rejesha nenosiri' : 'Reset password';
  String get passwordResetOk =>
      isSw ? 'Nenosiri limebadilishwa' : 'Password reset successful';
  String get devResetCode => isSw ? 'Namba ya majaribio' : 'Test code';
  String get strongPasswordHint => isSw
      ? 'Angalau herufi 8, kubwa, ndogo, namba na alama. Mfano: Wakala@123'
      : 'At least 8 characters with upper, lower, number and symbol. Example: Wakala@123';
  String get enterPin => isSw ? 'Weka PIN' : 'Enter PIN';
  String get wekaPin => isSw ? 'Weka PIN' : 'Enter PIN';
  String get hakikiPin => isSw ? 'Hakiki PIN' : 'Confirm PIN';
  String get createPin => isSw ? 'Tengeneza PIN' : 'Create PIN';
  String get pinHint => isSw
      ? 'Weka namba 4 tu. Mfano: 1234'
      : 'Enter exactly 4 digits. Example: 1234';
  String get badPinFormat => isSw
      ? 'PIN lazima iwe namba 4 tu'
      : 'PIN must be exactly 4 digits';
  String get pinIncorrect =>
      isSw ? 'PIN sio sahihi' : 'Wrong PIN';
  String get pinMismatch => isSw ? 'PIN hazifanani' : 'PINs do not match';
  String get cameraFingerHint => isSw
      ? 'Sogeza vidole vinne mbele ya kamera, kimoja baada ya kingine'
      : 'Hold four fingers in front of the camera, one after another';
  String get cameraBusy =>
      isSw ? 'Kamera inasoma alama za vidole...' : 'Camera is scanning fingerprints...';
  String get cameraFail => isSw
      ? 'Kamera haikufunguka. Ruhusu kamera kisha jaribu tena.'
      : 'Camera did not open. Allow camera access and try again.';
  String get continueBtn => isSw ? 'Endelea' : 'Continue';
  String get cardNumber => isSw ? 'Namba ya card' : 'Card number';
  String get lostCardNumber =>
      isSw ? 'Namba ya card iliyopotea' : 'Lost card number';
  String get customerName => isSw ? 'Jina la mteja' : 'Customer name';
  String get fourFingers =>
      isSw ? 'Sogeza vidole vinne' : 'Place four fingers';
  String get fingerHint => isSw
      ? 'Weka vidole vinne kwenye skana, kimoja baada ya kingine'
      : 'Place four fingers on the scanner, one after another';
  String get fingerDone => isSw ? 'Imethibitishwa' : 'Verified';
  String get newPassword => isSw ? 'Nenosiri jipya' : 'New password';
  String get confirmPassword =>
      isSw ? 'Thibitisha nenosiri' : 'Confirm password';
  String get passwordMismatch =>
      isSw ? 'Nenosiri halifanani' : 'Passwords do not match';
  String get emergency => isSw ? 'Namba ya dharura' : 'Emergency number';
  String get emergencyNumber => '0800 750 750';
  String get howToRegister =>
      isSw ? 'Jinsi ya kusajili card mpya' : 'How to register a new card';
  String get changePassword =>
      isSw ? 'Badili password' : 'Change password';
  String get cardRegistered =>
      isSw ? 'Card imesajiliwa' : 'Card registered';
  String get skip => isSw ? 'Ruka' : 'Skip';
  String get enterCardSerial =>
      isSw ? 'Weka namba ya kadi' : 'Enter card serial';
  String get firstLoad =>
      isSw ? 'Kiasi cha kuweka (TZS)' : 'First load (TZS)';
  String get cardDeactivated =>
      isSw ? 'Card imehuishwa' : 'Card deactivated';
  String get malipo => isSw ? 'Malipo' : 'Payments';
  String get miamala => isSw ? 'Miamala' : 'Transactions';
  String get toaPesa => isSw ? 'Toa pesa' : 'Withdraw';
  String get tumaPesa => isSw ? 'Tuma pesa' : 'Send money';
  String get settings => isSw ? 'Mipangilio' : 'Settings';
  String get wakalaSettingsHint => isSw
      ? 'Lugha na nenosiri'
      : 'Language and password';
  String get profile => isSw ? 'Wasifu' : 'Profile';
  String get wallet => isSw ? 'Pochi' : 'Wallet';
  String get nauli => isSw ? 'NAULI' : 'FARE';
  String get lipia => isSw ? 'LIPIA' : 'PAY';
  String get enterFare =>
      isSw ? 'Weka kiasi cha nauli kwanza' : 'Enter the fare first';
  String get bringCard =>
      isSw ? 'Karibisha kadi karibu na simu' : 'Hold the card near the phone';
  String get scanning => isSw ? 'Inasoma kadi...' : 'Scanning card...';
  String get cardFound => isSw ? 'Kadi imesomwa' : 'Card detected';
  String get verifyTitle =>
      isSw ? 'Thibitisha malipo' : 'Verify payment';
  String get confirm => isSw ? 'Thibitisha' : 'Confirm';
  String get cancel => isSw ? 'Ghairi' : 'Cancel';
  String get noTx =>
      isSw ? 'Hakuna miamala bado' : 'No transactions yet';
  String get paymentsTab => isSw ? 'Malipo' : 'Payments';
  String get withdrawalsTab => isSw ? 'Zilizotolewa' : 'Withdrawals';
  String get noWithdrawals =>
      isSw ? 'Hakuna fedha zilizotolewa bado' : 'No withdrawals yet';
  String get agentCode => isSw ? 'Namba ya wakala' : 'Agent number';
  String get wakalaTill => isSw ? 'TILL ya wakala' : 'Wakala TILL';
  String get toaPesaHint =>
      isSw ? 'Toa pesa kupitia wakala' : 'Withdraw through an agent';
  String get toaPesaTillHint => isSw
      ? 'Weka namba ya TILL ya wakala, kisha endelea.'
      : 'Enter the wakala TILL number, then continue.';
  String get enterWithdrawAmount =>
      isSw ? 'Weka kiasi cha kutoa' : 'Enter amount to withdraw';
  String get withdrawOk =>
      isSw ? 'Pesa imetolewa' : 'Withdrawal successful';
  String get reference => isSw ? 'Kumbukumbu' : 'Reference';
  String get back => isSw ? 'Rudi' : 'Back';
  String get amount => isSw ? 'Kiasi' : 'Amount';
  String get withdraw => isSw ? 'TOA PESA' : 'WITHDRAW';
  String get send => isSw ? 'TUMA' : 'SEND';
  String get phone => isSw ? 'Namba ya simu' : 'Phone number';
  String get network => isSw ? 'Mtandao' : 'Network';
  String get theme => isSw ? 'Mandhari' : 'Theme';
  String get languageLabel => isSw ? 'Lugha' : 'Language';
  String get display => isSw ? 'Onyesho' : 'Display';
  String get light => isSw ? 'Mwanga' : 'Light';
  String get dark => isSw ? 'Giza' : 'Dark';
  String get system => isSw ? 'Mfumo' : 'System';
  String get swahili => 'Kiswahili';
  String get english => 'English';
  String get compact => isSw ? 'Finyazi' : 'Compact';
  String get normal => isSw ? 'Kawaida' : 'Normal';
  String get large => isSw ? 'Kubwa' : 'Large';
  String get logout => isSw ? 'Toka' : 'Log out';
  String get conductor => isSw ? 'Kondakta' : 'Conductor';
  String get email => isSw ? 'Barua pepe' : 'Email';
  String get mobile => isSw ? 'Simu' : 'Mobile';
  String get conductorId => 'Conductor ID';
  String get save => isSw ? 'Hifadhi' : 'Save';
  String get success => isSw ? 'Imefanikiwa' : 'Successful';
  String get failed => isSw ? 'Imeshindikana' : 'Failed';
  String get lowBalance =>
      isSw ? 'Salio halitoshi' : 'Insufficient balance';
  String get fillAll =>
      isSw ? 'Tafadhali jaza taarifa zote' : 'Please fill all fields';
  String get security => isSw ? 'Usalama' : 'Security';
  String get changePin => isSw ? 'Badili PIN' : 'Change PIN';
  String get changePinHint => isSw
      ? 'Weka PIN ya sasa, kisha PIN mpya ya namba 4.'
      : 'Enter your current PIN, then a new 4-digit PIN.';
  String get currentPin => isSw ? 'PIN ya sasa' : 'Current PIN';
  String get newPin => isSw ? 'PIN mpya' : 'New PIN';
  String get confirmNewPin =>
      isSw ? 'Thibitisha PIN mpya' : 'Confirm New PIN';
  String get pinChanged =>
      isSw ? 'PIN imebadilishwa' : 'PIN changed successfully';
  String get forgotPin => isSw ? 'Umesahau PIN?' : 'Forgot PIN?';
  String get forgotPinHint => isSw
      ? 'Weka namba ya simu na NIDA. Tutakutumia namba ya uthibitisho.'
      : 'Enter your phone and NIDA. We will send a verification code.';
  String get phoneHint => '';
  String get phoneAlreadyUsed =>
      isSw ? 'Namba ya simu tayari imesajiliwa' : 'Phone already registered';
  String get nidaAlreadyUsed =>
      isSw ? 'NIDA tayari imesajiliwa' : 'NIDA already registered';
  String get badPhoneFormat => isSw
      ? 'Weka namba ya simu sahihi'
      : 'Enter a valid phone number';
  String get badNidaFormat => isSw
      ? 'NIDA lazima iwe tarakimu 20'
      : 'NIDA must be 20 digits';
  String get sendVerificationCode =>
      isSw ? 'Tuma namba ya uthibitisho' : 'Send verification code';
  String get verificationCode =>
      isSw ? 'Namba ya uthibitisho' : 'Verification code';
  String get enterPinResetCode => isSw
      ? 'Weka namba 6, kisha PIN mpya ya namba 4.'
      : 'Enter the 6-digit code, then your new 4-digit PIN.';
  String get resetPin => isSw ? 'Rejesha PIN' : 'Reset PIN';
  String get pinResetOk =>
      isSw ? 'PIN imerejeshwa. Ingia na PIN mpya.' : 'PIN reset. Sign in with your new PIN.';
  String get currentPassword =>
      isSw ? 'Nenosiri la sasa' : 'Current password';
  String get changePasswordHint => isSw
      ? 'Weka nenosiri la sasa, kisha nenosiri jipya.'
      : 'Enter your current password, then a new password.';
  String get passwordChanged =>
      isSw ? 'Nenosiri limebadilishwa' : 'Password changed successfully';
  String get passenger => isSw ? 'Abiria' : 'Passenger';
  String get menu => isSw ? 'Menyu' : 'Menu';
  String get nfcHint => isSw
      ? 'Leta kadi ya abiria karibu, kisha subiri isomwe.'
      : 'Bring the passenger card close, then wait to scan.';
  String get paid => isSw ? 'Amelipa' : 'Paid';
  String get paymentComplete =>
      isSw ? 'MALIPO YAMEKAMILIKA' : 'PAYMENT COMPLETE';
  String get paymentFailed =>
      isSw ? 'MALIPO HAYAKUFANIKIWA' : 'PAYMENT FAILED';
  String get tryAgain => isSw ? 'Jaribu tena' : 'Try again';
  String get nfcUid => 'NFC UID';
  String get scanUid => isSw ? 'Soma UID' : 'Scan UID';
  String get scanCard => isSw ? 'Soma kadi' : 'Scan card';
  String get scanCardFirst => isSw
      ? 'Soma kadi kwanza ili UID na namba ya kadi zionekane'
      : 'Scan the card first so UID and card number appear';
  String get passengerDetailsStep => isSw
      ? 'Taarifa za abiria'
      : 'Passenger details';
  String get scanCardStep => isSw ? 'Soma kadi (NFC)' : 'Scan card (NFC)';
  String get scanCardStepHint => isSw
      ? 'Leta kadi karibu. NFC UID na namba ya kadi (tarakimu 12) zitaonekana.'
      : 'Hold the card near the phone. NFC UID and 12-digit card number appear automatically.';
  String get initialTopUpStep =>
      isSw ? 'Weka salio la kwanza' : 'Enter initial top-up';
  String get topUpScanHint => isSw
      ? 'Leta kadi karibu. Taarifa za mmiliki wa kadi zitaonekana moja kwa moja.'
      : 'Hold the card near the phone. Owner details appear automatically.';
  String get enterTopUpAmount =>
      isSw ? 'Weka kiasi cha kuongeza' : 'Enter top-up amount';
  String get cardAlreadyRegistered => isSw
      ? 'Kadi hii tayari imesajiliwa'
      : 'This card is already registered';
  String get smsSentHint => isSw
      ? 'SMS imetumwa kwa simu ya abiria.'
      : 'SMS sent to the passenger phone.';
  String get digits => isSw ? 'tarakimu' : 'digits';
  String get done => isSw ? 'Sawa' : 'Done';
  String get withdrawn => isSw ? 'Imetolewa' : 'Withdrawn';
  String get sent => isSw ? 'Imetumwa' : 'Sent';
  String tzs(int n) => 'TZS ${_format(n)}';

  String _format(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
