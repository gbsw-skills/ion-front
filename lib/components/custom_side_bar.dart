import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/login_screen.dart';

import '../store.dart';
import '../utils.dart';

class CustomSideBar extends StatefulWidget {
  const CustomSideBar({super.key});

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
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: sizeh(context),
      decoration: BoxDecoration(
        color: Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff1E1F22),
        border: Border(right: BorderSide(color: Store.isLightMode.value ? Color(0xffEAEAEA) : Color(0xff2D2E30))),
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
                color: Store.isLightMode.value ? Color(0xffF9F9F9) : Color(0xff2D2E31),
                borderRadius: .circular(10),
              ),
              child: SvgPicture.asset('assets/icons/exit.svg'),
            ),
          ),
          SizedBox(height: 14),
          Divider(color: Store.isLightMode.value ? Color(0xffEAEAEA) : Color(0xff2D2E30), indent: 22, endIndent: 22, radius: .circular(100), thickness: 2),
          SizedBox(height: 14),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 38,
            height: 60,
            padding: .symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              color: Store.isLightMode.value ? Color(0xffE2E2E2) : Color(0xff3F424A),
              borderRadius: .circular(13),
            ),
            child: Stack(
              children: [
                // 슬라이딩 pill
                AnimatedAlign(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Store.isLightMode.value
                      ? Alignment.bottomCenter
                      : Alignment.topCenter,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Store.isLightMode.value
                          ? Colors.white
                          : Color(0xff64666D),
                      borderRadius: .circular(8),
                    ),
                  ),
                ),
                // 다크 모드 아이콘 (고정 상단)
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () => Store.isLightMode.value = false,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: double.infinity,
                      height: 24,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/${Store.isLightMode.value ? '' : 'dark_'}dark.svg',
                          width: 12,
                          height: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                // 라이트 모드 아이콘 (고정 하단)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () => Store.isLightMode.value = true,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: double.infinity,
                      height: 24,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/${Store.isLightMode.value ? '' : 'dark_'}light.svg',
                          width: 12,
                          height: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget button(String iconName, int index) {
    bool isSelected = Store.currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => Store.currentIndex = index),
      child: Container(
        width: 38,
        height: 38,
        padding: .all(10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff10A37F) : Store.isLightMode.value ? Color(0xffF9F9F9) : Color(0xff2D2E31),
          borderRadius: .circular(10),
        ),
        child: SvgPicture.asset('assets/icons/${iconName}_${isSelected ? 'selected' : 'unselected'}.svg'),
      ),
    );
  }
}