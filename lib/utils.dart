import 'package:flutter/material.dart';
import 'package:ion/store.dart';

sizew(context) => MediaQuery.of(context).size.width;
sizeh(context) => MediaQuery.of(context).size.height;

Color primaryColor = Store.isLightMode.value ? Color(0xff10A37F) : Color(0xff2D2E31);
Color secondaryColor = Store.isLightMode.value ? Color(0xffF9F9F9) : Color(0xff2D2E31);
Color backgroundColor = Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff1E1F22);
