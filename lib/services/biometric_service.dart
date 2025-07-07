import 'package:local_auth/local_auth.dart';
import '../utils/logger.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    bool authenticated = await auth.authenticate(
      localizedReason: 'Authenticate to mark attendance',
      options: AuthenticationOptions(biometricOnly: true),
    );
    // loginfo("Biometric authentication: ${authenticated ? 'Success' : 'Failed'}");
    return authenticated;
  }
}
