import 'package:flutter/material.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/login_screen.dart';
import 'package:ion/store.dart';
import 'package:ion/theme/app_colors.dart';
import 'package:ion/utils.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key});

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
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Store.isLightMode.value;
    final userInitials = initials(Store.displayName);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(27, 18, 18, 4),
            child: Text(
              '마이 페이지',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 14),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 18, bottom: 18),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 480),
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
                                backgroundColor: Color(0xFF10A37F),
                                child: Text(
                                  userInitials,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (Store.username.isNotEmpty)
                                      Text(
                                        '@${Store.username}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF9CA3AF),
                                        ),
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
                                isLight,
                              ),
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
                                color: AppColors.pageBtnIcon,
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  '테마',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.pageBtnIcon,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 6,
                                children: [
                                  Text(
                                    isLight ? '라이트' : '다크',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  Switch(
                                    value: !isLight,
                                    onChanged: (v) =>
                                        Store.isLightMode.value = !v,
                                    activeThumbColor: Color(0xFF10A37F),
                                    activeTrackColor: Color(
                                      0xFF10A37F,
                                    ).withValues(alpha: 0.4),
                                    inactiveTrackColor: Color(0xffF3F3F3FF),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── 로그아웃 ──
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _logout,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                Text(
                                  '로그아웃',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
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
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceBackground,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  Widget _section(String label, bool isLight) => Text(
    label,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.sectionLabel,
    ),
  );

  Widget _infoRow(String label, String value, bool isLight) => Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _divider(bool isLight) => Divider(
    height: 1,
    color: AppColors.cardDivider,
  );

  Widget _roleBadge(String role) {
    final isAdmin = role == 'ADMIN';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? Color(0xFFF59E0B).withValues(alpha: 0.12)
            : Color(0xFF10A37F).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? '관리자' : '학생',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAdmin ? Color(0xFFF59E0B) : Color(0xFF10A37F),
        ),
      ),
    );
  }
}

