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

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

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
          markers: Set<Marker>.of(_markers.values),
        ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: FlatButton(
              onPressed: () {
                //todo: should trigger the flow of the creation of a new activity
              },
              child: Icon(Icons.add),
            ),
          ),
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
      _markers.clear();
    });
    updateMarks(documentList);
  }

  // Future<Uint8List> getUserPicture(var thumbnailUrl) async {
  //   final File markerImageFile =
  //       await DefaultCacheManager().getSingleFile(thumbnailUrl);
  //   final Uint8List markerImageBytes = await markerImageFile.readAsBytes();

  //   final Codec markerImageCodec = await instantiateImageCodec(
  //     markerImageBytes,
  //     targetWidth: 100,
  //   );
  //   final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
  //   final ByteData byteData = await frameInfo.image.toByteData(
  //     format: ImageByteFormat.png,
  //   );
  //   final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();
  //   return resizedMarkerImageBytes;
  // }

  // void updateCircles(List<DocumentSnapshot> documentList, String currentState) {
  //   CircleId circleId = CircleId(userId);
  //   var nCircle = Circle(
  //     center: LatLng(
  //       currentLocation.value.latitude,
  //       currentLocation.value.longitude,
  //     ),
  //     circleId: circleId,
  //     fillColor: Colors.blueAccent.withOpacity(0.3),
  //     radius: 10000,
  //     strokeWidth: 1,
  //   );
  //   setState(() {
  //     _circles[circleId] = nCircle;
  //   });
  // }

  void updateMarks(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      if (document.documentID != userId) {
        GeoPoint geo = document.data["position"]["geopoint"];
        final MarkerId markerId = MarkerId(document.documentID.toString());
        // todo: fetch other users' propics
        // firestore
        //     .collection("users")
        //     .document(document.documentID)
        //     .get()
        //     .then((snapShop) async {
        //   var thumbnailUrl = snapShop.data["thumbnailUrl"];
        //   var nMark = Marker(
        //     position: LatLng(geo.latitude, geo.longitude),
        //     icon:
        //         BitmapDescriptor.fromBytes(await getUserPicture(thumbnailUrl)),
        //     markerId: markerId,
        //   );
        //   setState(() {
        //     markers[markerId] = nMark;
        //   });
        // });
        var nMark = Marker(
          position: LatLng(geo.latitude, geo.longitude),
          icon: BitmapDescriptor.defaultMarker,
          markerId: markerId,
        );
        setState(() {
          _markers[markerId] = nMark;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // todo: operation on dataBase when exit app or lose connection
  }

  @override
  void dispose() {
    _locationSub.cancel();
    super.dispose();
  }
}
