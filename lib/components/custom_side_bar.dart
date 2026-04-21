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
          Container(
            width: 38,
            height: 38,
            padding: .all(8),
            decoration: BoxDecoration(
              color: Store.isLightMode.value ? Color(0xffF9F9F9) : Color(0xff2D2E31),
              borderRadius: .circular(10),
            ),
            child: SvgPicture.asset('assets/icons/exit.svg'),
          ),
          SizedBox(height: 14),
          Divider(color: Store.isLightMode.value ? Color(0xffEAEAEA) : Color(0xff2D2E30), indent: 22, endIndent: 22, radius: .circular(100), thickness: 2),
          SizedBox(height: 14),
          Container(
            width: 38,
            height: 60,
            padding: .symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Store.isLightMode.value ? Color(0xffE2E2E2) : Color(0xff3F424A),
              borderRadius: .circular(13),
            ),
            child: Stack(
              alignment: .center,
              children: [
                AnimatedAlign(
                  duration: Duration(milliseconds: 400),
                  alignment: .topCenter,
                  child: GestureDetector(
                    onTap: () => Store.isLightMode.value = false,
                    child: Container(
                      width: 24,
                      height: 24,
                      padding: .all(6),
                      decoration: BoxDecoration(
                        color: Store.isLightMode.value ? Colors.transparent : Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff64666D),
                        borderRadius: .circular(10),
                      ),
                      child: SvgPicture.asset('assets/icons/${Store.isLightMode.value ? '' : 'dark_'}dark.svg', fit: .cover),
                    ),
                  ),
                ),
                AnimatedAlign(
                  duration: Duration(milliseconds: 400),
                  alignment: .bottomCenter,
                  child: GestureDetector(
                    onTap: () => Store.isLightMode.value = true,
                    child: Container(
                      width: 24,
                      height: 24,
                      padding: .all(6),
                      decoration: BoxDecoration(
                        color: !Store.isLightMode.value ? Colors.transparent : Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff64666D),
                        borderRadius: .circular(10),
                      ),
                      child: SvgPicture.asset('assets/icons/${Store.isLightMode.value ? '' : 'dark_'}light.svg', fit: .cover),
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