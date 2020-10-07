import 'package:Space/model/user.dart';
import 'package:Space/screens/authenticate/authenticate.dart';
import 'package:Space/screens/wrapper.dart';
import 'package:Space/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<SpaceUser>.value(
        value: AuthService().user,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: Wrapper(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
