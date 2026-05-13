import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../store.dart';

class CustomInputFiled extends StatefulWidget {
  const CustomInputFiled({
    super.key,
    required this.label,
    required this.controller, this.isPassword = false,
  });

  final String label;
  final TextEditingController controller;
  final bool isPassword;

  @override
  State<CustomInputFiled> createState() => _CustomInputFiledState();
}

class _CustomInputFiledState extends State<CustomInputFiled> {
  final FocusNode focusNode = FocusNode();
  bool enablePassword = false;
  OutlineInputBorder outlineBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(200),
    borderSide: BorderSide(color: color,),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.addListener(() => setState(() {}),);
    },);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: widget.controller,
      obscureText: widget.isPassword && enablePassword,
      style: TextStyle(
        fontSize: 14,
        color: Store.isLightMode.value
            ? Color(0xFF1E1F22)
            : Color(0xFFEEEEEE),
      ),
      decoration: InputDecoration(
        enabledBorder: outlineBorder(Store.isLightMode.value
            ? Color(0xFFEFEFEF)
            : Color(0xFF2D2E30)),
        focusedBorder: outlineBorder(Color(0xFF10A37F)),
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFFA0A7BB),
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 14,
          color: focusNode.hasFocus
              ? Color(0xFF10A37F)
              : Color(0xFFA0A7BB),
        ),
        suffixIcon: widget.isPassword ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => setState(() {
              enablePassword = !enablePassword;
            }),
            child: Icon(
                enablePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined
            ),
          ),
        ) : null,
      ),
    );
  }
}
