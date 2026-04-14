import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ion/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List<String> tabBarList = ['chat', 'filter', 'compass', 'settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          sideBar(),
          historyBar(),
        ],
      ),
    );
  }

  Widget sideBar() => Container(
    width: sizew(context) * 0.05,
    height: sizeh(context),
    decoration: BoxDecoration(
      color: backgroundColor,
      border: Border(right: BorderSide(color: Color(0xffEAEAEA))),
    ),
    child: Column(
      crossAxisAlignment: .center,
      children: [
        SizedBox(height: 128),
        ListView.separated(
          padding: .symmetric(horizontal: 18),
          shrinkWrap: true,
          itemBuilder: (context, index) => button(tabBarList[index], index),
          separatorBuilder: (context, index) => SizedBox(height: 24),
          itemCount: tabBarList.length,
        ),
        Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: .circular(10),
          ),
        ),
        Divider(color: Color(0xffEFEFEF), indent: 22, endIndent: 22, radius: .circular(100), thickness: 2),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: .circular(10),
          ),
        ),
        SizedBox(height: 128),
      ],
    ),
  );

  Widget button(String iconName, int index) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
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

  Widget historyBar() => Container(
    width: sizew(context) * 0.25,
    height: sizeh(context),
    color: Colors.red,
    child: Column(
      children: [
        Row(
          children: [
            Text('기록', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: .w800)),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xff23C69E),
                borderRadius: .circular(10),
              ),
            )
          ],
        ),
      ],
    ),
  );
}
