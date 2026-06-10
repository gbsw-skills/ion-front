import 'package:flutter/material.dart';

import '../store.dart';

class AppColors {
  AppColors._();

  static final Color accent = Color(0xFF10A37F);

  static Color get textPrimary =>
      Store.isLightMode.value ? Color(0xFF1E1F22) : Color(0xFFEEEEEE);

  static Color get textSecondary =>
      Store.isLightMode.value ? Color(0xFF9F9F9F) : Color(0xFFABABAB);

  static Color get textMuted =>
      Store.isLightMode.value ? Color(0xFF9CA3AF) : Color(0xFFABABAB);

  static Color get paginationText =>
      Store.isLightMode.value ? Color(0xFF6B7280) : Color(0xFFABABAB);

  static Color get pageBtnIcon =>
      Store.isLightMode.value ? Color(0xFF374151) : Color(0xFFEEEEEE);

  static Color get loginPageBackground =>
      Store.isLightMode.value ? Color(0xffF5F5F5) : Color(0xff282A2E);

  static Color get inputFieldBackground =>
      Store.isLightMode.value ? Color(0xffF5F5F5) : Color(0xff4B4F5B);

  static Color get sectionLabel =>
      Store.isLightMode.value ? Color(0xFF9CA3AF) : Color(0xFF6B7280);

  static Color get cardDivider =>
      Store.isLightMode.value ? Color(0xFFF3F4F6) : Color(0xFF3F424A);

  static Color get pageBackground =>
      Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff282A2E);

  static Color get cardBackground =>
      Store.isLightMode.value ? Color(0xffF5F5F5) : Color(0xFF3F424A);

  static Color get surfaceBackground =>
      Store.isLightMode.value ? Colors.white : Color(0xFF4B4F5B);

  static Color get dialogBackground =>
      Store.isLightMode.value ? Colors.white : Color(0xFF3F424A);

  static Color get inputShadow =>
      Store.isLightMode.value ? Color(0x0d1e1f22) : Color(0x331e1f22);

  static Color get iconBoxBackground =>
      Store.isLightMode.value ? Color(0xffE7E9F0) : Color(0xff404450);

  static Color get divider =>
      Store.isLightMode.value ? Color(0xFFD0D0D0) : Color(0xFF4A4F5E);

  static Color get codeInlineText =>
      Store.isLightMode.value ? Color(0xFF1E1F22) : Color(0xFFE6EDF3);

  static Color get chatBubbleMine =>
      Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff4B4F5B);

  static Color get chatBubbleOther =>
      Store.isLightMode.value ? Color(0xffD8EFE9) : Color(0xff28303F);

  static Color get historyTitle =>
      Store.isLightMode.value ? Color(0xFF1E1F22) : Colors.white;

  static Color get historyIconBoxBackground =>
      Store.isLightMode.value ? Color(0xffEFEFEF) : Color(0xff1E1F22);

  static Color get searchBarBackground =>
      Store.isLightMode.value ? Color(0xFFD6D6D6) : Color(0xFF3F424A);

  static Color get sidebarBackground =>
      Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff1E1F22);

  static Color get sidebarBorder =>
      Store.isLightMode.value ? Color(0xffEAEAEA) : Color(0xff2D2E30);

  static Color get sidebarButtonBackground =>
      Store.isLightMode.value ? Color(0xffF9F9F9) : Color(0xff2D2E31);

  static Color get themeTogglePillBackground =>
      Store.isLightMode.value ? Color(0xffE2E2E2) : Color(0xff3F424A);

  static Color get themeTogglePillThumb =>
      Store.isLightMode.value ? Colors.white : Color(0xff64666D);

  static Color get themeToggleTrack =>
      Store.isLightMode.value ? Color(0xffE2E2E2) : Color(0xff2D2E31);

  static Color get themeToggleThumb =>
      Store.isLightMode.value ? Colors.white : Color(0xff64666D);

  static Color get historyItemSelectedBackground =>
      Store.isLightMode.value ? Color(0xFFE3FEF7) : Color(0xFF1E1F22);

  static Color get historyItemDateColor =>
      Store.isLightMode.value ? Color(0xFF9F9F9F) : Color(0x99ABABAB);

  static Color get tabBarBackground =>
      Store.isLightMode.value ? Color(0xffEEEEEE) : Color(0xFF3F424A);

  static Color get tabIndicatorBackground =>
      Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff1E1F22);

  static Color get tabIndicatorGradientStart =>
      Store.isLightMode.value ? Color(0xFF878787) : Color(0xff1E1F22);

  static Color get tabIndicatorGradientEnd =>
      Store.isLightMode.value ? Color(0xFFE8E8E8) : Color(0xff1E1F22);

  static Color get tabUnselectedText =>
      Store.isLightMode.value ? Color(0xFF3B3B3B) : Color(0xFFEEEEEE);

  static Color get adminBackground =>
      Store.isLightMode.value ? Color(0xFFF3F4F8) : Color(0xFF282A2E);

  static Color get adminNavSelected =>
      accent.withValues(alpha: Store.isLightMode.value ? 0.10 : 0.18);

  static Color get dangerText =>
      Store.isLightMode.value ? Color(0xFFE53935) : Color(0xFFFF6B6B);

  static Color get borderMuted =>
      Store.isLightMode.value ? Color(0xFFD1D5DB) : Color(0xFF4A4F5E);

  static Color get infoBadge =>
      Store.isLightMode.value ? Color(0xFF3B82F6) : Color(0xFF60A5FA);

  static Color get warningBadge =>
      Store.isLightMode.value ? Color(0xFFF59E0B) : Color(0xFFFBBF24);

  static final Color deleteButton = Color(0xFFEF4444);
}
