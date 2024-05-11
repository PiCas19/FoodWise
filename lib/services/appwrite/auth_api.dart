import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:foodwaste/services/appwrite/appwrite_api.dart';
import '../../models/preferences/user_preferences.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends AppwriteAPI {
  late final Account account;
  late User _currentUser;
  AuthStatus _status = AuthStatus.uninitialized;

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser?.name;
  String? get email => _currentUser?.email;
  String? get userid => _currentUser?.$id;

  // Constructor
  AuthAPI() : super() {
    account = Account(client);
    loadUser();
  }


  loadUser() async {
    try {
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  void updateAuthenticationStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  Future<User> createUser(
      {required String email, required String password, required String name}) async {
    notifyListeners();

    try {
      final user = await account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: name
      );
      return user;
    } finally {
      notifyListeners();
    }
  }


  Future<Session> createEmailSession(
      {required String email, required String password}) async {
    notifyListeners();

    try {
      final session =
      await account.createEmailSession(email: email, password: password);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  signInWithProvider({required String provider}) async {
    try {
      final session = await account.createOAuth2Session(provider: provider);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> sendVerificationMail() async {
    try {
      await account.createVerification(
          url:
          "https://reset-and-verifyemail-node-appwrite.onrender.com/verify");
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<bool> sendRecoveryMail(String email) async {
    try {
      await account.createRecovery(
          email: email,
          url:
          "https://reset-and-verifyemail-node-appwrite.onrender.com/recovery");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UserPreferences?> getUserPreferences() async {
    try {
      final prefs = await account.getPrefs();
      return UserPreferences.fromJson(prefs.data);
    } catch (e) {
      throw Exception('Failed to load user preferences');
    }
  }


  Future<void> updatePreferences({required UserPreferences preferences}) async {
    try {
      await account.updatePrefs(prefs: preferences.toJson());
    } catch (e) {
      throw Exception('Failed to update user preferences');
    }
  }

}

