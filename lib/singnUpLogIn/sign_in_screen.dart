import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common.dart';
import 'authentication_service.dart';

// Shows All the sign in options

class SignIn extends StatefulWidget {
  SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _passwordConformController =
      new TextEditingController();
  late AuthenticationService _authService;
  String? status;
  bool hasConnection = false;

  @override
  void initState() {
    checkConnection().then((value) => hasConnection = value);
    _authService = context.read<AuthenticationService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: getPadding(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/login.png',
                fit: BoxFit.cover,
              ),
              gradientBorder(
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', border: InputBorder.none),
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              gradientBorder(
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password', border: InputBorder.none),
                ),
              ),
              _authService.authPage != 'signup'
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: gradientBorder(
                        TextField(
                          controller: _passwordConformController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: InputBorder.none),
                        ),
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                child: gradientButton(
                    _authService.authPage != 'signup' ? 'Sign in' : 'Sign up',
                    () {
                  if (hasConnection) {
                    _authService.authPage != 'signup'
                        ? context.read<AuthenticationService>().signInWithEmail(
                            email: _emailController.text,
                            password: _passwordController.text)
                        : _passwordController.text ==
                                _passwordConformController.text
                            ? context
                                .read<AuthenticationService>()
                                .signUpWithEmail(
                                    email: _emailController.text,
                                    password: _passwordController.text)
                            : show(context,
                                'Password not matched with Conform password');
                  } else
                    show(context, 'Not Internet');
                }),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('OR')),
              _authService.authPage != 'signup'
                  ? Container(
                      height: 40,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          gradientBorderButton('Sign in with Phone',
                              () => _authService.changePage('phoneAuth')),
                          gradientBorderButton('Sign in with Google', () {
                            if (hasConnection) {
                              context
                                  .read<AuthenticationService>()
                                  .googleLogin();
                            } else
                              show(context, 'No Internet');
                          })
                        ],
                      ),
                    )
                  : SizedBox(),
              GestureDetector(
                  onTap: () {
                    if (_authService.authPage == 'signup')
                      _authService.changePage('');
                    else
                      _authService.changePage('signup');
                  },
                  child: _authService.authPage == 'signup'
                      ? Text('Already have account? SignIn')
                      : Text('Don\'t have account? SignUp Now')),
            ],
          ),
        ),
      ),
    );
  }
}