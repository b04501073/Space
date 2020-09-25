import 'package:Space/screens/home/activity_form.dart';
import 'package:Space/screens/home/map.dart';
import 'package:Space/services/auth.dart';
import 'package:Space/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:Space/screens/home/activry_list.dart';

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

  void _showActivityPanel(){
    showModalBottomSheet(context: context, builder: (context){
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: Activityform(),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        /*
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showActivityPanel(),
          backgroundColor: Colors.brown[500],
          child: Icon(Icons.add),
        ),
        */
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text("Home"),
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          actions: [
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text("logout"),
              onPressed: () async {
                dynamic result = await _auth.signOut();
              },
            ),
          ],
        ),
        body: (_currentLocation != null)
            ? Stack(
                children: <Widget> [
                  FireMap(
                    initialLocation: _currentLocation,
                  ),
                  Positioned(
                    child: Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: ActivityList(),
                    )
                  ),
                ]
              )
            : Loading(),
      ),
    );
  }
}
