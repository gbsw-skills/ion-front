import 'package:flutter/material.dart';

import '../utils.dart';

class CustomHistoryBar extends StatefulWidget {
  const CustomHistoryBar({super.key});

  @override
  State<CustomHistoryBar> createState() => _CustomHistoryBarState();
}

class _CustomHistoryBarState extends State<CustomHistoryBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: sizeh(context),
      color: backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: .center,
              children: [
                Text('기록', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: .w800)),
                Spacer(),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Color(0xff23C69E),
                    borderRadius: .circular(10),
                  ),
                ),
                SizedBox(width: 14),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Color(0xffEFEFEF),
                    borderRadius: .circular(10),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
