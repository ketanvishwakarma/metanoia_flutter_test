import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metanoia_flutter_test/singnUpLogIn/authentication_service.dart';
import 'package:metanoia_flutter_test/user/usermodel.dart';
import 'package:provider/provider.dart';

import '../common.dart';

// Shows All the sign in options

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _ageController = new TextEditingController();

  late AuthenticationService _authService;
  bool hasConnection = false;

  @override
  void initState() {
    checkConnection().then((value) => hasConnection = value);
    _authService = context.read<AuthenticationService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //get CurrentUer
    final user = context.watch<MyUser?>();

    return Scaffold(
        appBar: AppBar(
          title: Text('Update User Profile'),
        ),
        body: Padding(
          padding: getPadding(),
          child: StreamBuilder<UserData>(
            stream: UserDatabaseService(uid: user!.uid).getUserData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _nameController.text = snapshot.data!.name!;
                _ageController.text = snapshot.data!.age!;
                return Column(
                  children: [
                    gradientBorder(
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            labelText: 'Name', border: InputBorder.none),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    gradientBorder(
                      TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: InputDecoration(
                            labelText: 'Age', border: InputBorder.none,counterText: ''),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 60,
                      child: gradientButton('Submit', () {
                        if (hasConnection) {
                          UserDatabaseService(uid: user.uid)
                              .updateUserData(
                                  _nameController.text, _ageController.text)
                              .then((value) => Navigator.pop(context));
                        } else
                          show(context, 'Not Internet');
                      }),
                    ),
                  ],
                );
              }
              return loadingWidget();
            },
          ),
        ));
  }
}
