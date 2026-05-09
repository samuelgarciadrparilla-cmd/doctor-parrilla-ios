import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/constants.dart';
import '../webview/webview_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidPhone(String phone) {
    final String cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.startsWith('+595')) {
      return RegExp(r'^\+5959\d{8}$').hasMatch(cleaned);
    }
    return RegExp(r'^09\d{8}$').hasMatch(cleaned);
  }

  String _normalizePhone(String phone) {
    final String cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.startsWith('09')) {
      return '+595${cleaned.substring(1)}';
    }
    return cleaned;
  }

  Future<void> _login() async {
    final String phone = _phoneController.text.trim();
    if (!_isValidPhone(phone)) {
      setState(() => _error = 'Ingresá un número válido de Paraguay (+595 9X XXX XXXX)');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    await AuthService.instance.savePhone(_normalizePhone(phone));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const WebViewScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, Animation<double> anim, _, Widget child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 3),
              _buildLogo(),
              const SizedBox(height: 16),
              _buildBrandText(),
              const Spacer(flex: 3),
              _buildPhoneField(),
              const SizedBox(height: 12),
              if (_error != null) _buildError(),
              const SizedBox(height: 16),
              _buildLoginButton(),
              const Spacer(flex: 2),
              _buildFooter(),
              const SizedBox(height: 16),
            ],
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
        errorBuilder: (_, _, _) => const Icon(
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

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
      ],
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: 'Número de teléfono',
        hintText: '+595 9X XXX XXXX',
        labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
        hintStyle: TextStyle(color: Colors.white.withAlpha(80)),
        prefixIcon: const Icon(
          Icons.phone,
          color: Color(AppConstants.accentGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(AppConstants.accentGold)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(AppConstants.errorRed)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(AppConstants.errorRed)),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(10),
      ),
      onSubmitted: (_) => _login(),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        _error!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(AppConstants.errorRed),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.accentGold),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Doctor Parrilla · Paraguay',
      style: TextStyle(
        color: Colors.white.withAlpha(60),
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }
}
