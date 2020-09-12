import 'dart:async';
import 'package:Space/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class FireMap extends StatefulWidget {
  @override
  final LocationData initialLocation;

  const FireMap({Key key, this.initialLocation}) : super(key: key);
  _FireMapState createState() => _FireMapState();
}

//todo: delete user info on firebase on disconnection
class _FireMapState extends State<FireMap> with WidgetsBindingObserver {
  GoogleMapController _controller;
  final Location location = Location();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<CircleId, Circle> _circles = <CircleId, Circle>{};

  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  FirebaseApp firebase = FirebaseApp.instance;
  String userId;

  var currentLocation = BehaviorSubject<LocationData>();

  StreamSubscription _locationSub;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentLocationInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
              target: LatLng(widget.initialLocation.latitude,
                  widget.initialLocation.longitude),
              zoom: 14),
          onMapCreated: _onMapCreated,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          compassEnabled: true,
          markers: Set<Marker>.of(markers.values),
          circles: Set<Circle>.of(_circles.values),
        ),
      ],
    );
  }

  _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    initialQuery();
  }

  void currentLocationInitialization() {
    currentLocation.add(widget.initialLocation);
  }

  //set up queries
  void initialQuery() async {
    userId = await AuthService().userId;

    _locationSub = location.onLocationChanged.listen((LocationData newLoc) {
      currentLocation.add(newLoc);
      _updataUserLocation(newLoc);
    });

    //update the center of the monitoring stream
    currentLocation.switchMap(
      (loc) {
        //todo: change queryRef to composite query
        var queryRef = firestore.collection("userLocations");
        return geo.collection(collectionRef: queryRef).within(
            center: GeoFirePoint(loc.latitude, loc.longitude),
            radius: 10,
            field: 'position',
            strictMode: true);
      },
    ).listen(
      (docList) {
        _updateMapInfo(docList);
      },
    );
  }

  Future<void> _updataUserLocation(LocationData loc) async {
    GeoFirePoint pointToAdd = GeoFirePoint(loc.latitude, loc.longitude);
    //TOTO: should use a class to cast the data instead of direct mapping, i.e. UsetLocationData(position: ....)
    firestore.collection("userLocations").document(userId).setData({
      "position": pointToAdd.data,
      "user": "",
    });
  }

  //todo: should cast the documentList to customized class
  void _updateMapInfo(List<DocumentSnapshot> documentList) async {
    setState(() {
      markers.clear();
      _circles.clear();
    });
    updateMarks(documentList);
  }

  void updateMarks(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      if (document.documentID != userId) {
        GeoPoint geo = document.data["position"]["geopoint"];
        final MarkerId markerId = MarkerId(document.documentID.toString());
    
        var nMark = Marker(
          position: LatLng(geo.latitude, geo.longitude),
          icon: BitmapDescriptor.defaultMarker,
          markerId: markerId,
        );
        setState(() {
          markers[markerId] = nMark;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {

  }

  @override
  void dispose() {
    _locationSub.cancel();
    super.dispose();
  }
}
