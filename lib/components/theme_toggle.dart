import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';



  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
              ),
            ),
          ),
          Align(
            child: GestureDetector(
              onTap: () => Store.isLightMode.value = false,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                child: Center(
                  child: SvgPicture.asset(
                    width: 12,
                    height: 12,
                  ),
                ),
              ),
            ),
          ),
          Align(
            child: GestureDetector(
              onTap: () => Store.isLightMode.value = true,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                child: Center(
                  child: SvgPicture.asset(
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
