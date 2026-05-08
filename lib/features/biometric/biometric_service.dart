import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

enum BiometricResult { success, failure, notAvailable, lockedOut, cancelled }

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  // Sesión válida por 30 segundos — igual que apps bancarias top
  static const Duration _sessionValidity = Duration(seconds: 30);
  DateTime? _lastAuthTime;

  bool get isSessionValid {
    if (_lastAuthTime == null) return false;
    return DateTime.now().difference(_lastAuthTime!) < _sessionValidity;
  }

  void markAuthenticated() => _lastAuthTime = DateTime.now();
  void invalidateSession() => _lastAuthTime = null;

  /// True si el dispositivo tiene biométrico INSCRIPTO y listo para usar.
  Future<bool> isAvailable() async {
    try {
      final bool enrolled = await _auth.canCheckBiometrics;
      final bool supported = await _auth.isDeviceSupported();
      return enrolled && supported;
    } catch (_) {
      return false;
    }
  }

  /// Retorna qué tipo de biométrico tiene el dispositivo.
  Future<List<BiometricType>> getAvailableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  Future<BiometricResult> authenticate() async {
    try {
      final bool result = await _auth.authenticate(
        localizedReason: 'Verificá tu identidad para acceder',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
      if (result) {
        markAuthenticated();
        return BiometricResult.success;
      }
      return BiometricResult.cancelled;
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notAvailable:
        case auth_error.notEnrolled:
        case auth_error.passcodeNotSet:
          return BiometricResult.notAvailable;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return BiometricResult.lockedOut;
        default:
          return BiometricResult.failure;
      }
    } catch (_) {
      return BiometricResult.notAvailable;
    }
  }
}
