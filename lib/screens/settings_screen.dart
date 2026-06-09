import 'package:flutter/material.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/login_screen.dart';
import 'package:ion/store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_rebuild);
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _logout() async {
    await AuthRepository().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Store.isLightMode.value;
    final initials = _initials(Store.displayName);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(27, 18, 18, 4),
            child: Text(
              '마이 페이지',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isLight
                    ? const Color(0xFF1E1F22)
                    : const Color(0xFFEEEEEE),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 18, bottom: 18),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: isLight
                    ? const Color(0xffF5F5F5)
                    : const Color(0xFF3F424A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        // ── 프로필 카드 ──
                        _card(
                          isLight,
                          child: Row(
                            spacing: 20,
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFF10A37F),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 6,
                                  children: [
                                    Text(
                                      Store.displayName.isEmpty
                                          ? '사용자'
                                          : Store.displayName,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isLight
                                              ? const Color(0xFF1E1F22)
                                              : const Color(0xFFEEEEEE)),
                                    ),
                                    if (Store.username.isNotEmpty)
                                      Text(
                                        '@${Store.username}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9CA3AF)),
                                      ),
                                    _roleBadge(Store.userRole),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── 계정 정보 ──
                        _section('계정 정보', isLight),
                        _card(
                          isLight,
                          child: Column(
                            children: [
                              _infoRow('이름', Store.displayName, isLight),
                              _divider(isLight),
                              _infoRow('아이디', Store.username, isLight),
                              _divider(isLight),
                              _infoRow(
                                  '권한',
                                  Store.userRole == 'ADMIN' ? '관리자' : '학생',
                                  isLight),
                            ],
                          ),
                        ),

                        // ── 앱 설정 ──
                        _section('앱 설정', isLight),
                        _card(
                          isLight,
                          child: Row(
                            children: [
                              Icon(
                                isLight
                                    ? Icons.light_mode_outlined
                                    : Icons.dark_mode_outlined,
                                size: 20,
                                color: isLight
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFEEEEEE),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  '테마',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: isLight
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFEEEEEE)),
                                ),
                              ),
                              Row(
                                spacing: 6,
                                children: [
                                  Text(
                                    isLight ? '라이트' : '다크',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9CA3AF)),
                                  ),
                                  Switch(
                                    value: !isLight,
                                    onChanged: (v) =>
                                        Store.isLightMode.value = !v,
                                    activeThumbColor: const Color(0xFF10A37F),
                                    activeTrackColor: const Color(0xFF10A37F)
                                        .withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── 로그아웃 ──
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _logout,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.3)),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
                              children: [
                                Icon(Icons.logout,
                                    size: 18, color: Color(0xFFEF4444)),
                                Text('로그아웃',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFEF4444))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(bool isLight, {required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF4B4F5B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _section(String label, bool isLight) => Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isLight
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF6B7280)),
      );

  Widget _infoRow(String label, String value, bool isLight) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF))),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isLight
                        ? const Color(0xFF1E1F22)
                        : const Color(0xFFEEEEEE)),
              ),
            ),
          ],
        ),
      );

  Widget _divider(bool isLight) => Divider(
        height: 1,
        color: isLight
            ? const Color(0xFFF3F4F6)
            : const Color(0xFF3F424A),
      );

  Widget _roleBadge(String role) {
    final isAdmin = role == 'ADMIN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
            : const Color(0xFF10A37F).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? '관리자' : '학생',
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isAdmin
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10A37F)),
      ),
    );
  }
}

String _initials(String name) {
  if (name.isEmpty) return '?';
  final trimmed = name.trim();
  if (trimmed.length >= 2) return trimmed.substring(0, 2);
  return trimmed;
}
