import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../store.dart';
import '../utils.dart';

class CustomSideBar extends StatefulWidget {
  const CustomSideBar({super.key});

  @override
  State<CustomSideBar> createState() => _CustomSideBarState();
}

class _CustomSideBarState extends State<CustomSideBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: sizeh(context),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(right: BorderSide(color: Color(0xffEAEAEA))),
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
          Container(
            width: 38,
            height: 38,
            padding: .all(8),
            decoration: BoxDecoration(
              color: Color(0xffF9F9F9),
              borderRadius: .circular(10),
            ),
            child: SvgPicture.asset('assets/icons/exit.svg'),
          ),
          SizedBox(height: 14),
          Divider(color: Color(0xffEFEFEF), indent: 22, endIndent: 22, radius: .circular(100), thickness: 2),
          SizedBox(height: 14),
          Container(
            width: 38,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xffE2E2E2),
              borderRadius: .circular(13),
            ),
            child: Stack(
              alignment: .center,
              children: [
                Align(alignment: .topCenter, child: GestureDetector(onTap: () => Store.isLightMode.value = true, child: Container(color: Colors.red, width: 12, child: SvgPicture.asset('assets/icons/dark.svg', fit: .cover)))),
                Align(alignment: .bottomCenter, child: GestureDetector(onTap: () {
                  Store.isLightMode.value = false;
                }, child: Container(color: Colors.red, width: 12, child: SvgPicture.asset('assets/icons/light.svg', fit: .cover)))),
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
          color: isSelected ? primaryColor : secondaryColor,
          borderRadius: .circular(10),
        ),
        child: SvgPicture.asset('assets/icons/${iconName}_${isSelected ? 'selected' : 'unselected'}.svg'),
      ),
    );
  }
}
