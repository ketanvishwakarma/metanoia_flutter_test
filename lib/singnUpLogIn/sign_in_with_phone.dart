import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../common.dart';
import 'authentication_service.dart';

class LoginPhone extends StatefulWidget {
  LoginPhone({Key? key}) : super(key: key);

  @override
  _LoginPhoneState createState() => _LoginPhoneState();
}

class _LoginPhoneState extends State<LoginPhone> {
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _otpController = new TextEditingController();
  late AuthenticationService _authService;
  String? status;
  bool hasConnection = false;

  @override
  void initState() {
    checkConnection().then((value) => hasConnection = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _authService = context.read<AuthenticationService>();
    _authService.addListener(() {
      setState(() {
        status = _authService.status;
      });
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: getPadding(),
          child: Column(
            children: [
              Image.asset(
                'assets/login.png',
                fit: BoxFit.cover,
              ),
              gradientBorder(
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 13,
                  decoration: InputDecoration(
                      hintText: '+911234567890',
                      labelText: 'Phone Number With Country Code',
                      counterText: '',
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              status == 'codesent'
                  ? SizedBox(
                      child: gradientBorder(
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'OTP', border: InputBorder.none),
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 10,
              ),
              status != 'codesent'
                  ? Container(
                      height: 60,
                      child: gradientButton('SendOTP', () {
                        if (hasConnection) {
                          if (_phoneController.text.length == 13)
                            _authService
                                .submitPhoneNumber(_phoneController.text).then((value) {

                            });
                          else
                            show(context, 'Please Enter Valid Phone Number');
                        } else
                          show(context, 'No Internet');
                      }))
                  : Container(
                      height: 60,
                      child: gradientButton('Verify', () {
                        if (hasConnection)
                          _authService.submitOTP(_otpController.text);
                        else
                          show(context, 'No Internet');
                      }),
                    ),
              SizedBox(height: 20,),
              GestureDetector(
                  onTap: () {
                      _authService.changePage('');
                  },
                  child: Text('Sign In With Email or Google'),)
            ],
          ),
        ),
      ),
    );
  }
}
