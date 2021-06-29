import 'package:flutter/material.dart';
import 'package:metanoia_flutter_test/common.dart';
import 'package:metanoia_flutter_test/product/home.dart';
import 'package:metanoia_flutter_test/singnUpLogIn/authentication_service.dart';
import 'package:metanoia_flutter_test/singnUpLogIn/sign_in_with_phone.dart';
import 'package:metanoia_flutter_test/user/usermodel.dart';
import 'package:provider/provider.dart';

import 'sign_in_screen.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  String? authPage = '', errorMsg = '';

  @override
  Widget build(BuildContext context) {
    //check which login option to show
    context.read<AuthenticationService>().addListener(() {
      setState(() {
        authPage = context.read<AuthenticationService>().authPage!;
        errorMsg = context.read<AuthenticationService>().error;
      });
    });

    //get CurrentUer
    final user = context.watch<MyUser?>();
    if (user != null) {
      return Home();
    } else {
      if (authPage == 'phoneAuth') {
        if (errorMsg != '') {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            show(context, errorMsg!);
          });
        }
        return LoginPhone();
      }
      if (errorMsg != '') {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          show(context, errorMsg!);
        });
      }
      return SignIn();
    }
  }
}
