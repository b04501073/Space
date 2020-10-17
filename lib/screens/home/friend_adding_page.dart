import 'package:Space/services/auth.dart';
import 'package:flutter/material.dart';

class FriendAddingPage extends StatefulWidget {
  @override
  _FriendAddingPageState createState() => _FriendAddingPageState();
}

class _FriendAddingPageState extends State<FriendAddingPage> {
  String _inputID = "";
  String error;
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friend add page"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          // key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text("Friend's ID"),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                onChanged: (val) {
                  setState(() {
                    _inputID = val;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () async {
                  if (await _auth.addFriendByID(_inputID)) {
                    Navigator.pop(context);
                  } else {
                    error = "failed to find the userID";
                  }
                },
                color: Colors.pink[400],
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(error != null ? error : ""),
            ],
          ),
        ),
      ),
    );
  }
}
