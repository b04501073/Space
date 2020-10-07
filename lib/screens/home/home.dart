import 'dart:io';

import 'package:Space/screens/home/create.dart';
import 'package:Space/screens/home/map.dart';
import 'package:Space/services/auth.dart';
import 'package:Space/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  LocationData _currentLocation;
  Image _image;
  final ImagePicker picker = ImagePicker();

  Future<void> getCurrentLocation() async {
    Location location = new Location();
    location.getLocation().then((_fetchedLocation) {
      setState(() {
        _currentLocation = _fetchedLocation;
      });
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    _setProPic();
    super.initState();
  }

  _setProPic() async {
    var url = await _auth.getUserImgUrl(_auth.userId);
    if (url != null) {
      try {
        final File markerImageFile =
            await DefaultCacheManager().getSingleFile(url);
        setState(() {
          _image = Image(image: FileImage(markerImageFile));
        });
      } on Exception catch (_) {
        _image = null;
        print('failed to load image');
      }
    }
  }

  _pickImage(ImageSource imageSource) async {
    PickedFile image =
        await picker.getImage(source: imageSource, imageQuality: 20);

    setState(() {
      var file = File(image.path);
      _image = Image(image: FileImage(file));
      _auth.uploadImageToFirebase(_auth.userId, File(image.path));
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
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            UserAccountsDrawerHeader(
              // Todo:  change to custom widget in the future
              currentAccountPicture: InkWell(
                // splashColor: Colors.red, // inkwell color
                child: ClipOval(
                  child: Material(
                    color: Colors.white30, // button color
                    child: InkWell(
                      // splashColor: Colors.red, // inkwell color
                      child: _image == null
                          ? Image(
                              image: AssetImage("assets/images/user_image.png"),
                            )
                          : _image,
                      onTap: () {
                        _showPicker(context);
                      },
                    ),
                  ),
                ),
                onTap: () {
                  _showPicker(context);
                },
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton.icon(
                    icon: Icon(Icons.person),
                    label: Text("logout"),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () async {
                      dynamic result = await _auth.signOut();
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: (_currentLocation != null)
          ? new Scaffold(
              body: new Center(
                child: FireMap(
                  initialLocation: _currentLocation,
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: new FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateActivity()),
                  );
                },
                tooltip: 'Increment',
                child: new Icon(Icons.add),
                elevation: 10.0,
              ),
            )
          : Loading(),
    );
  }
}
