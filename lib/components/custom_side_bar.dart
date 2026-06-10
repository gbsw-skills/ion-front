import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/login_screen.dart';

import '../store.dart';
import '../theme/app_colors.dart';
import '../utils.dart';
import 'theme_toggle.dart';

class CustomSideBar extends StatefulWidget {
  CustomSideBar({super.key});

  @override
  State<CustomSideBar> createState() => _CustomSideBarState();
}

class _CustomSideBarState extends State<CustomSideBar> {
  @override
  void initState() {
    super.initState();
    Store.isLightMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    Store.isLightMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

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
    return Container(
      width: 90,
      height: sizeh(context),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.sidebarBorder)),
      ),
      child: Column(
        crossAxisAlignment: .center,
        children: [
          SizedBox(height: 128),
          button('chat', 0),
          SizedBox(height: 24),
          button('filter', 1),
          SizedBox(height: 24),
          button('compass', 2),
          SizedBox(height: 24),
          button('settings', 3),
          Spacer(),
          GestureDetector(
            onTap: _logout,
            child: Container(
              width: 38,
              height: 38,
              padding: .all(8),
              decoration: BoxDecoration(
                color: AppColors.sidebarButtonBackground,
                borderRadius: .circular(10),
              ),
              child: SvgPicture.asset('assets/icons/exit.svg'),
            ),
          ),
          SizedBox(height: 14),
          Divider(
            color: AppColors.sidebarBorder,
            indent: 22,
            endIndent: 22,
            radius: .circular(100),
            thickness: 2,
          ),
          SizedBox(height: 14),
          ThemeTogglePill(),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget button(String iconName, int index) {
    bool isSelected = Store.currentIndex.value == index;

    return GestureDetector(
      onTap: () => setState(() => Store.currentIndex.value = index),
      child: Container(
        width: 38,
        height: 38,
        padding: .all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xff10A37F)
              : AppColors.sidebarButtonBackground,
          borderRadius: .circular(10),
        ),
        child: SvgPicture.asset(
          'assets/icons/${iconName}_${isSelected ? 'selected' : 'unselected'}.svg',
        ),
      ),
    );
  }
}
