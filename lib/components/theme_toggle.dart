import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../store.dart';
import '../theme/app_colors.dart';

class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 60,
      height: 38,
      padding: .symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.themeToggleTrack,
        borderRadius: .circular(13),
      ),
      child: Stack(
        children: [
          // 슬라이딩 pill
          AnimatedAlign(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Store.isLightMode.value
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 24,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.themeToggleThumb,
                borderRadius: .circular(8),
              ),
            ),
          ),
          // 라이트 모드 아이콘 (고정 좌측)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Store.isLightMode.value = true,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 24,
                height: double.infinity,
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
          // 다크 모드 아이콘 (고정 우측)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Store.isLightMode.value = false,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 24,
                height: double.infinity,
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
        ],
      ),
    );
  }
}

class ThemeTogglePill extends StatelessWidget {
  const ThemeTogglePill({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 38,
      height: 60,
      padding: .symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.themeTogglePillBackground,
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
                color: AppColors.themeTogglePillThumb,
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
    );
  }
}