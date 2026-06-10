import 'package:flutter/material.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/admin_page.dart';
import 'package:ion/screens/home_page.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

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
      final dest = Store.userRole == 'ADMIN' ? AdminPage() : HomePage();
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
      backgroundColor: AppColors.loginPageBackground,
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          decoration: BoxDecoration(
            color: AppColors.dialogBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 40,
                offset: Offset(0, 8),
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
                    color: Color(0xFF10A37F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'ION',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 32),
              _fieldLabel('아이디', isLight),
              SizedBox(height: 8),
              _textField(
                controller: _usernameController,
                isLight: isLight,
                hint: '아이디를 입력해주세요.',
                onSubmitted: (_) => _login(),
              ),
              SizedBox(height: 20),
              _fieldLabel('비밀번호', isLight),
              SizedBox(height: 8),
              _textField(
                controller: _passwordController,
                hint: '비밀번호를 입력해주세요.',
                isLight: isLight,
                obscure: _obscurePassword,
                onSubmitted: (_) => _login(),
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: Color(0xffA0A7BB),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 13,
                  ),
                ),
              ],
              SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10A37F),
                    disabledBackgroundColor: Color(
                      0xFF10A37F,
                    ).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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
      color: AppColors.textPrimary,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required bool isLight,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmitted,
  }) => TextField(
    controller: controller,
    obscureText: obscure,
    onSubmitted: onSubmitted,
    onTapOutside: (_) => FocusScope.of(context).unfocus(),
    style: TextStyle(
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xffA0A7BB)),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.inputFieldBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF10A37F), width: 1.5),
      ),
    ),
  );
}
