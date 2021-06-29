import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metanoia_flutter_test/singnUpLogIn/authentication_service.dart';
import 'package:metanoia_flutter_test/singnUpLogIn/authentication_wrapper.dart';
import 'package:metanoia_flutter_test/user/usermodel.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),

          //Check user login logout
          StreamProvider<MyUser?>(
              create: (context) =>
                  context.read<AuthenticationService>().authStateChanges,
              initialData: null)
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              accentColor: Colors.orange,
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
              textTheme: GoogleFonts.ralewayTextTheme().copyWith(
                  headline4: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black54),
                  headline5: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black54),
                  subtitle1: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black45),
                  subtitle2: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black45),
                bodyText1: TextStyle(fontSize: 18, color: Colors.black45),
                bodyText2: TextStyle(fontSize: 14, color: Colors.black45),
              )),
          home: AuthenticationWrapper(),
        ));
  }
}
