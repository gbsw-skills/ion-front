import 'package:flutter/material.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/admin_page.dart';
import 'package:ion/screens/home_page.dart';
import 'package:ion/store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '아이디와 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepository.login(username, password);

    if (!mounted) return;

    if (result == 'success') {
      final dest = Store.userRole == 'ADMIN' ? const AdminPage() : const HomePage();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => dest),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result == 'different'
            ? '아이디 또는 비밀번호가 올바르지 않습니다.'
            : '로그인에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Store.isLightMode.value;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xffF5F5F5) : const Color(0xff282A2E),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xff3F424A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1A000000),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10A37F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'ION',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isLight ? const Color(0xFF1E1F22) : const Color(0xFFEEEEEE),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _fieldLabel('아이디', isLight),
              const SizedBox(height: 8),
              _textField(
                controller: _usernameController,
                isLight: isLight,
                hint: '아이디를 입력해주세요.',
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 20),
              _fieldLabel('비밀번호', isLight),
              const SizedBox(height: 8),
              _textField(
                controller: _passwordController,
                hint: '비밀번호를 입력해주세요.',
                isLight: isLight,
                obscure: _obscurePassword,
                onSubmitted: (_) => _login(),
                suffix: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: const Color(0xffA0A7BB),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFE53935), fontSize: 13),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10A37F),
                    disabledBackgroundColor: const Color(0xFF10A37F).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, bool isLight) => Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isLight ? const Color(0xFF1E1F22) : const Color(0xFFEEEEEE),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required bool isLight,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmitted,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: TextStyle(
          fontSize: 14,
          color: isLight ? const Color(0xFF1E1F22) : const Color(0xFFEEEEEE),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xffA0A7BB)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: suffix,
          filled: true,
          fillColor: isLight ? const Color(0xffF5F5F5) : const Color(0xff4B4F5B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF10A37F), width: 1.5),
          ),
        ),
      );
}
