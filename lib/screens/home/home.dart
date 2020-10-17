import 'dart:io';
import 'dart:math';

import 'package:Space/model/user.dart';
import 'package:Space/screens/home/create.dart';
import 'package:Space/screens/home/friend_adding_page.dart';
import 'package:Space/screens/home/map.dart';
import 'package:Space/screens/home/user_ID_setting.dart';
import 'package:Space/services/auth.dart';
import 'package:Space/shared/loading.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  LocationData _currentLocation;
  Image _image;
  String _publicID = "";
  final ImagePicker picker = ImagePicker();
  List<SpaceUser> _friends;
  double plusWidth = 60;

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
    _setProPicListener();
    _setFirendsListListener();
    _setUserPublicID();
    super.initState();
  }

  _setUserPublicID() {
    _auth.listenOnUserPublicID((id) {
      setState(() {
        _publicID = id;
      });
    });
  }

  _setProPicListener() {
    _auth.listenOnProPic((imgUrl) {
      if (imgUrl != "") {
        setState(() {
          _image = Image.network(imgUrl);
        });
      }
    });
  }

  _setFirendsListListener() {
    _auth.listenOnFriendsList((friends) {
      setState(() {
        _friends = friends;
      });
    });
  }

  void upDataFriendsList(List<SpaceUser> friends) {
    setState(() {
      _friends = friends;
    });
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
      },
    );
  }

  List<Widget> getFriends(List<SpaceUser> users) {
    if (users == null) {
      return [];
    }
    return List.generate((users.length + 1), (index) {
      if (index == 0) {
        return Container(
          alignment: Alignment.center,
          width: 60.0,
          height: 60.0,
          margin: EdgeInsets.all(4.0),
        );
      } else {
        var path = Path();
        path.addOval(Rect.fromCircle(
          center: Offset(36, 36),
          radius: 33.0,
        ));

        // assume the number of messages is equal to the index
        // Todo: dynamic updates the message number
        var numberOfMessages = index - 1;

        var totalLength = 2 * pi * 33;
        // var dashPattern = double[];
        var spaceLength = numberOfMessages == 0 ? 0.toDouble() : 4.toDouble();
        var dashLength = totalLength / numberOfMessages - spaceLength;

        return DottedBorder(
          dashPattern: [dashLength, spaceLength],
          strokeCap: StrokeCap.round,
          strokeWidth: 2,
          customPath: (size) => path,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ]),
            alignment: Alignment.center,
            width: 60.0,
            height: 60.0,
            margin: EdgeInsets.all(4.0),
            child: Text("${index + 1}"),
          ),
        );
      }
    });
  }

  _onUpdateScroll(ScrollMetrics _metrics) {
    var offSet = _metrics.extentBefore;
    if (offSet < 40) {
      setState(() {
        plusWidth = 60 - offSet;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      // appBar: AppBar(
      //   title: Text("Home"),
      //   backgroundColor: Colors.blue[400],
      //   elevation: 0.0,
      // ),
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
              accountName: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserIDSetting(
                        originalID: _publicID != "" ? _publicID : null,
                      ),
                    ),
                  );
                },
                child: Text(
                  _publicID != "" ? _publicID : "set User's public ID",
                  style: TextStyle(
                      color: _publicID != "" ? Colors.black : Colors.grey[800]),
                ),
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
                      await _auth.signOut();
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
              body: Stack(
                children: [
                  Center(
                    child: FireMap(
                      initialLocation: _currentLocation,
                    ),
                  ),
                  SafeArea(
                    child: Container(
                        height: 120,
                        // color: Colors.black,
                        child: Stack(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: [
                                Flexible(
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification: (scrollNotification) {
                                      if (scrollNotification
                                          is ScrollUpdateNotification) {
                                        _onUpdateScroll(
                                            scrollNotification.metrics);
                                      }
                                    },
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: getFriends(_friends),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FriendAddingPage()),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: Offset(
                                          0, 1), // changes position of shadow
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                width: plusWidth,
                                height: 60.0,
                                margin: EdgeInsets.all(4.0),
                                child: Text("+"),
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
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
