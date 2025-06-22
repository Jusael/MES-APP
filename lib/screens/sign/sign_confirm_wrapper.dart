import 'package:flutter/material.dart';
import 'package:mes_mobile_app/screens/sign/sign_confirm_screen.dart';
import 'package:mes_mobile_app/dtos/sign_dto.dart';

class SignConfirmWrapper extends StatelessWidget {
  const SignConfirmWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // SignDto 객체를 arguments로 받음
    final sign = ModalRoute
        .of(context)!
        .settings
        .arguments as SignDto;

    return SignatureConfirmScreen(signDto: sign);
  }
}