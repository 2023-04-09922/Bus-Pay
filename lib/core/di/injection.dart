import '../../data/repositories/repository_impl.dart';
import '../../domain/usecases/card_usecases.dart';

class Injection {
  Injection._();

  static late final AgentLogin agentLogin;
  static late final RegisterCard registerCard;
  static late final RenewCard renewCard;
  static late final TopUpCard topUpCard;

  static void init() {
    final auth = AuthRepositoryImpl();
    final cards = CardRepositoryImpl();
    agentLogin = AgentLogin(auth);
    registerCard = RegisterCard(cards);
    renewCard = RenewCard(cards);
    topUpCard = TopUpCard(cards);
  }
}
