import 'package:flutter/material.dart';
import 'package:ion/components/custom_input_filed.dart';
import 'package:ion/enums/request_code.dart';
import 'package:ion/repositories/auth_repository.dart';
import 'package:ion/screens/home_page.dart';

import '../store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository authRepository = AuthRepository();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String loginErrorMessage = '';

  Future<void> login() async {
    final result = await authRepository.login(idController.text, passwordController.text);

    if(result == RequestCode.SUCCESS) {
      setState(() {
        loginErrorMessage = '';
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
    } else {
      setState(() {
        loginErrorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Store.isLightMode.value ? Color(0xffFFFFFF) : Color(0xff282A2E),
      body: SafeArea(child: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('로그인', style: TextStyle(
                fontSize: 30,
                color: Store.isLightMode.value
                    ? Color(0xFF1E1F22)
                    : Color(0xFFEEEEEE),
                fontWeight: FontWeight.bold,
              ),),
              CustomInputFiled(label: '아이디', controller: idController),
              CustomInputFiled(label: '비밀번호', controller: passwordController, isPassword: true,),
              if(loginErrorMessage.isNotEmpty) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(loginErrorMessage, style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10A37F),
                  ),),
                ),
              ),
              SizedBox(),
              GestureDetector(
                onTap: login,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Store.isLightMode.value
                        ? Color(0xFF1E1F22)
                        : Color(0xFFEEEEEE),
                  ),
                  child: Text('계속', style: TextStyle(
                    fontSize: 16,
                    color: Store.isLightMode.value
                        ? Color(0xFFEEEEEE)
                        : Color(0xFF1E1F22),
                  ),),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
