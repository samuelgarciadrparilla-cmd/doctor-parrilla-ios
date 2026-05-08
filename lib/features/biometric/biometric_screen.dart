import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../app/constants.dart';
import '../webview/webview_screen.dart';
import 'biometric_service.dart';

class BiometricScreen extends StatefulWidget {
  /// isOverlay: true cuando se muestra sobre el WebView (re-auth),
  /// false cuando es la pantalla inicial (gate).
  final bool isOverlay;

  const BiometricScreen({super.key, this.isOverlay = false});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

enum _AuthState { checking, ready, authenticating, success, failed, lockedOut, unavailable }

class _BiometricScreenState extends State<BiometricScreen>
    with TickerProviderStateMixin {

  _AuthState _state = _AuthState.checking;
  bool _hasFaceId = false;

  // Pulso del ícono biométrico
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Shake al fallar
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  // Fade general
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  // Escala del ícono en success
  late final AnimationController _successController;
  late final Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkAndAuth();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _checkAndAuth() async {
    final bool available = await BiometricService.instance.isAvailable();
    if (!mounted) return;

    if (!available) {
      setState(() => _state = _AuthState.unavailable);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _navigateToApp();
      return;
    }

    final List<BiometricType> types =
        await BiometricService.instance.getAvailableTypes();
    _hasFaceId = types.contains(BiometricType.face);

    setState(() => _state = _AuthState.ready);

    // Pequeña pausa para que la UI se pinte antes de mostrar el prompt del sistema
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) _authenticate();
  }

  Future<void> _authenticate() async {
    if (!mounted) return;
    setState(() => _state = _AuthState.authenticating);

    final BiometricResult result = await BiometricService.instance.authenticate();
    if (!mounted) return;

    switch (result) {
      case BiometricResult.success:
        _pulseController.stop();
        setState(() => _state = _AuthState.success);
        await _successController.forward();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        _navigateToApp();
      case BiometricResult.lockedOut:
        setState(() => _state = _AuthState.lockedOut);
      case BiometricResult.notAvailable:
        _navigateToApp();
      case BiometricResult.failure:
      case BiometricResult.cancelled:
        setState(() => _state = _AuthState.failed);
        _shakeController.forward(from: 0);
    }
  }

  void _navigateToApp() {
    if (!mounted) return;
    if (widget.isOverlay) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => const WebViewScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, Animation<double> anim, __, Widget child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 2),
                _buildLogo(),
                const SizedBox(height: 16),
                _buildBrandText(),
                const Spacer(flex: 3),
                _buildBiometricIcon(),
                const SizedBox(height: 32),
                _buildStatusText(),
                const SizedBox(height: 24),
                _buildActionArea(),
                const Spacer(flex: 2),
                _buildFooter(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 90,
      height: 90,
      child: Image.asset(
        'assets/icon/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.local_fire_department,
          size: 80,
          color: Color(AppConstants.accentGold),
        ),
      ),
    );
  }

  Widget _buildBrandText() {
    return Column(
      children: <Widget>[
        Text(
          'DOCTOR PARRILLA',
          style: TextStyle(
            color: const Color(AppConstants.accentGold),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Paraguay',
          style: TextStyle(
            color: Colors.white.withAlpha(120),
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricIcon() {
    final bool isSuccess = _state == _AuthState.success;
    final bool isFailed = _state == _AuthState.failed;
    final bool isLocked = _state == _AuthState.lockedOut;

    Color iconColor = const Color(AppConstants.accentGold);
    if (isFailed) iconColor = const Color(AppConstants.errorRed);
    if (isLocked) iconColor = Colors.orange;
    if (isSuccess) iconColor = Colors.greenAccent;

    final IconData icon = isSuccess
        ? Icons.check_circle_outline_rounded
        : isLocked
            ? Icons.lock_outline_rounded
            : _hasFaceId
                ? Icons.face_unlock_outlined
                : Icons.fingerprint;

    Widget iconWidget = AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, Widget? child) {
        final double offset = isFailed
            ? math.sin(_shakeAnim.value * math.pi * 6) * 12
            : 0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: isSuccess
          ? ScaleTransition(
              scale: _successAnim,
              child: Icon(icon, size: 72, color: iconColor),
            )
          : (_state == _AuthState.authenticating || _state == _AuthState.ready)
              ? AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, Widget? child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: Icon(icon, size: 72, color: iconColor),
                )
              : Icon(icon, size: 72, color: iconColor),
    );

    // Glow dorado alrededor del ícono
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, Widget? child) {
        final double glowOpacity = (_state == _AuthState.authenticating ||
                _state == _AuthState.ready)
            ? (_pulseAnim.value - 0.85) / 0.15
            : 0;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: iconColor.withAlpha((glowOpacity * 60).round()),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(child: iconWidget),
        );
      },
    );
  }

  Widget _buildStatusText() {
    String text;
    Color color = Colors.white.withAlpha(200);

    switch (_state) {
      case _AuthState.checking:
      case _AuthState.ready:
        text = _hasFaceId ? 'Usá Face ID para ingresar' : 'Usá tu huella para ingresar';
      case _AuthState.authenticating:
        text = _hasFaceId ? 'Mirá la cámara' : 'Apoyá tu dedo';
        color = const Color(AppConstants.accentGold);
      case _AuthState.success:
        text = '¡Identidad verificada!';
        color = Colors.greenAccent;
      case _AuthState.failed:
        text = 'No se reconoció. Intentá de nuevo.';
        color = const Color(AppConstants.errorRed);
      case _AuthState.lockedOut:
        text = 'Demasiados intentos fallidos.\nUsá el PIN del dispositivo para desbloquear.';
        color = Colors.orange;
      case _AuthState.unavailable:
        text = 'Entrando...';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey<_AuthState>(_state),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 15,
          height: 1.5,
          fontWeight: _state == _AuthState.authenticating
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    if (_state == _AuthState.failed) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _authenticate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConstants.accentGold),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _hasFaceId ? Icons.face_unlock_outlined : Icons.fingerprint,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Intentar de nuevo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_state == _AuthState.lockedOut) {
      return TextButton(
        onPressed: _authenticate,
        child: Text(
          'Intentar con PIN del dispositivo',
          style: TextStyle(
            color: Colors.white.withAlpha(150),
            fontSize: 14,
          ),
        ),
      );
    }

    return const SizedBox(height: 52);
  }

  Widget _buildFooter() {
    return Text(
      '🔒 Acceso protegido · Doctor Parrilla',
      style: TextStyle(
        color: Colors.white.withAlpha(60),
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }
}
