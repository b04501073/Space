import 'package:Space/services/auth.dart';
import 'package:flutter/material.dart';

class UserIDSetting extends StatefulWidget {
  final String originalID;

  UserIDSetting({this.originalID});

  @override
  _UserIDSettingState createState() => _UserIDSettingState();
}

class _UserIDSettingState extends State<UserIDSetting> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  String idInserted;
  String err;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User ID setting"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                widget.originalID != null ? widget.originalID : "first setting",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                onChanged: (val) {
                  setState(() {
                    idInserted = val;
                  });
                },
                validator: (val) =>
                    val.length < 6 ? "Enter an ID 6+ long" : null,
                decoration: InputDecoration(
                  hintText: "User ID",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate() &&
                      await _auth.isSetUserIDSuccessful(idInserted)) {
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      err =
                          "The ID has already been taken, please change a new one";
                    });
                  }
                },
                color: Colors.pink[400],
                child: Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                err != null ? err : "",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
