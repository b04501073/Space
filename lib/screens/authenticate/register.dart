import 'dart:io';

import 'package:Space/services/auth.dart';
// import 'package:Space/shared/constant.dart';
import 'package:Space/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = "";
  String password = "";
  String err = "";
  PickedFile _image;
  final ImagePicker picker = ImagePicker();

  _pickImage(ImageSource imageSource) async {
    PickedFile image =
        await picker.getImage(source: imageSource, imageQuality: 20);

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('Photo Library'),
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text("Sign up to App"),
              actions: [
                FlatButton.icon(
                  label: Text("Sign in"),
                  onPressed: () {
                    widget.toggleView();
                  },
                  icon: Icon(Icons.person),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Column(
                children: [
                  ClipOval(
                    child: Material(
                      color: Colors.white30, // button color
                      child: InkWell(
                        // splashColor: Colors.red, // inkwell color
                        child: Image(
                          image: _image == null
                              ? AssetImage("assets/images/user_image.png")
                              : FileImage(File(_image.path)),
                          width: 80,
                          height: 80,
                        ),
                        onTap: () {
                          _showPicker(context);
                        },
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (val) =>
                              val.isEmpty ? "Enter an email" : null,
                          onChanged: (val) {
                            email = val;
                          },
                          decoration: InputDecoration(
                            hintText: "Email",
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (val) => val.length < 6
                              ? "Enter a password 6+ long"
                              : null,
                          obscureText: true,
                          onChanged: (val) {
                            password = val;
                          },
                          decoration: InputDecoration(
                            hintText: "Password",
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                loading = true;
                              });
                              dynamic result;
                              if (_image == null) {
                                result = await _auth.registerWithEmail(
                                    email, password);
                              } else {
                                result = await _auth.registerWithEmail(
                                  email,
                                  password,
                                  File(_image.path),
                                );
                              }

                              if (result == null) {
                                setState(() {
                                  err = "Please enter a new set";
                                  loading = false;
                                });
                              }
                            }
                          },
                          color: Colors.pink[400],
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          err,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
