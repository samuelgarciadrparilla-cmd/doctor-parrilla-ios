import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service that monitors network connectivity state.
/// Provides a stream of connectivity changes and a method to check current state.
class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get onConnectionChanged => _connectionController.stream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Initialize the connectivity listener.
  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final bool isConnected = _isConnected(results);
        _connectionController.add(isConnected);
      },
    );
  }

  /// Check if currently connected to the internet.
  Future<bool> checkConnectivity() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      return _isConnected(results);
    } catch (_) {
      return false;
    }
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (ConnectivityResult result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  /// Dispose of resources.
  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}
