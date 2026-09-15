import '../state/app_state.dart';

class S {
  S(this.language);

  final AppLanguage language;

  bool get isSw => language == AppLanguage.sw;

  String get appName => 'DALADALA';
  String get malipo => isSw ? 'Malipo' : 'Payments';
  String get miamala => isSw ? 'Miamala' : 'Transactions';
  String get toaPesa => isSw ? 'Toa pesa' : 'Withdraw';
  String get tumaPesa => isSw ? 'Tuma pesa' : 'Send money';
  String get settings => isSw ? 'Mipangilio' : 'Settings';
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
  String get agentCode => isSw ? 'Namba ya wakala' : 'Agent number';
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
  String get passenger => isSw ? 'Abiria' : 'Passenger';
  String get menu => isSw ? 'Menyu' : 'Menu';
  String get nfcHint => isSw
      ? 'Leta kadi ya abiria karibu, kisha subiri isomwe.'
      : 'Bring the passenger card close, then wait to scan.';
  String get paid => isSw ? 'Amelipa' : 'Paid';
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
