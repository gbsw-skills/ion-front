import 'package:flutter/material.dart';
import 'package:ion/store.dart';

sizew(context) => MediaQuery.of(context).size.width;
sizeh(context) => MediaQuery.of(context).size.height;

Color get primaryColor => Store.isLightMode.value ? Color(0xff10A37F) : Color(0xff2D2E31);
Color get secondaryColor => Store.isLightMode.value ? Color(0xffF9F9F9) : Color(0xff2D2E31);
Color get surfaceColor => Store.isLightMode.value ? Color(0xffF9F9F9) : Color(0xff2D2E31);
Color get dividerColor => Store.isLightMode.value ? Color(0xffEAEAEA) : Color(0xff2D2E30);
Color get backgroundColor => Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff1E1F22);
Color get buttonColor => Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff64666D);
Color get titleColor => Store.isLightMode.value ? Color(0xff1E1F22) : Color(0xffEEEEEE);
