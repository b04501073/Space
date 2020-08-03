import 'package:Space/model/user.dart';
import 'package:Space/screens/authenticate/authenticate.dart';
import 'package:Space/screens/authenticate/register.dart';
import 'package:Space/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
