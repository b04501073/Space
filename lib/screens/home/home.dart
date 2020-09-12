import 'package:Space/screens/home/create.dart';
import 'package:Space/screens/home/map.dart';
import 'package:Space/services/auth.dart';
import 'package:Space/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  LocationData _currentLocation;

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
    super.initState();
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
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: ListView(
                children: <Widget>[
                  Text(
                    'Personal Information',
                    textAlign: TextAlign.center,
                  ),
                ],
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
            ))
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
