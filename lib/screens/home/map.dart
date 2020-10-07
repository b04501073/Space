import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:Space/model/user.dart';
import 'package:Space/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class FireMap extends StatefulWidget {
  final LocationData initialLocation;

  const FireMap({Key key, this.initialLocation}) : super(key: key);
  _FireMapState createState() => _FireMapState();
}

//todo: delete user info on firebase on disconnection
class _FireMapState extends State<FireMap> with WidgetsBindingObserver {
  final Location location = Location();
  AuthService _auth = AuthService();

  Map<MarkerId, Marker> usersMarkers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> activitiesMarkers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // Map<CircleId, Circle> _circles = <CircleId, Circle>{};

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
          // circles: Set<Circle>.of(_circles.values),
        ),
      ],
    );
  }

  _onMapCreated(GoogleMapController controller) {
    initialQuery();
  }

  void currentLocationInitialization() {
    currentLocation.add(widget.initialLocation);
  }

  //set up queries
  void initialQuery() async {
    // userId = await AuthService().userId;

    _locationSub = location.onLocationChanged.listen((LocationData newLoc) {
      currentLocation.add(newLoc);
      _updataUserLocation(newLoc);
    });

    //update the center of the monitoring stream
    currentLocation.switchMap(
      (loc) {
        //todo: change queryRef to composite query
        return _auth.getUserGeoCollection(loc);
      },
    ).listen(
      (docList) {
        _updateUsersMapInfo(docList);
      },
    );

    currentLocation.switchMap(
      (loc) {
        //todo: change queryRef to composite query
        return _auth.getActivitiesGeoCollection(loc);
      },
    ).listen(
      (docList) {
        _updateActivitiesMapInfo(docList);
      },
    );
  }

  Future<void> _updataUserLocation(LocationData loc) async {
    GeoFirePoint pointToAdd = GeoFirePoint(loc.latitude, loc.longitude);
    _auth.updataUserLocation(pointToAdd);
    //TOTO: should use a class to cast the data instead of direct mapping, i.e. UsetLocationData(position: ....)
  }

  //todo: should cast the documentList to customized class
  void _updateUsersMapInfo(List<DocumentSnapshot> documentList) async {
    setState(() {
      usersMarkers.forEach(
        (key, value) {
          if (!isMarkerInDocumentList(documentList, key)) {
            markers.remove(key);
          }
        },
      );
    });

    updateUsersMarks(documentList);
  }

  void _updateActivitiesMapInfo(List<DocumentSnapshot> documentList) async {
    setState(() {
      activitiesMarkers.forEach(
        (key, value) {
          if (!isMarkerInDocumentList(documentList, key)) {
            markers.remove(key);
          }
        },
      );
      // activitiesMarkers.removeWhere(
      //     (key, value) => !isMarkerInDocumentList(documentList, key));
    });

    updateActivitiesMarks(documentList);
  }

  bool isMarkerInDocumentList(
      List<DocumentSnapshot> documentList, MarkerId markerId) {
    for (int i = 0; i < documentList.length; ++i) {
      if (markerId.value.toString() == documentList[i].id.toString()) {
        return true;
      }
    }
    return false;
  }

  void updateUsersMarks(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint geo = document.data()["position"]["geopoint"];
      final MarkerId markerId = MarkerId(document.id.toString());
      if (document.id != _auth.userId) {
        if (markers.containsKey(markerId)) {
          // only change position
          var marker = Marker(
            position: LatLng(geo.latitude, geo.longitude),
            icon: markers[markerId].icon,
            markerId: markerId,
          );
          setState(() {
            markers[markerId] = marker;

            usersMarkers[markerId] = marker;
          });
        } else {
          // load images
          setAvatarIconOfMarks(markerId, document["user"], geo, 200);
        }
      }
    });
  }

  void updateActivitiesMarks(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint geo = document.data()["position"]["geopoint"];
      final MarkerId markerId = MarkerId(document.id.toString());
      if (markers.containsKey(markerId)) {
        // only change position
        var marker = Marker(
          position: LatLng(geo.latitude, geo.longitude),
          icon: markers[markerId].icon,
          markerId: markerId,
        );
        setState(() {
          markers[markerId] = marker;

          activitiesMarkers[markerId] = marker;
        });
      } else {
        //   // load images
        setEventIconOfMarks(markerId, geo, 200);
      }
    });
  }

  void setAvatarIconOfMarks(
      MarkerId markerId, String userId, GeoPoint geo, int size) async {
    var userImgUrl = await _auth.getUserImgUrl(userId);
    if (userImgUrl != null) {
      final File markerImageFile =
          await DefaultCacheManager().getSingleFile(userImgUrl);

      final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
      // avatarImage
      ui.Codec codec = await ui.instantiateImageCodec(markerImageBytes,
          targetWidth: size, targetHeight: size);
      ui.FrameInfo fi = await codec.getNextFrame();

      final Uint8List markerImage = await getCircularCanvas(size, fi.image);
      Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markerImage),
        position: LatLng(
          geo.latitude,
          geo.longitude,
        ),
      );

      setState(() {
        markers[markerId] = marker;

        usersMarkers[markerId] = marker;
      });
    }
  }

  void setEventIconOfMarks(MarkerId markerId, GeoPoint geo, int size) async {
    Marker marker = Marker(
      markerId: markerId,
      icon: await getRectangleCanvas(200, markerId),
      position: LatLng(
        geo.latitude,
        geo.longitude,
      ),
    );

    setState(() {
      markers[markerId] = marker;

      activitiesMarkers[markerId] = marker;
    });
  }

//https://stackoverflow.com/questions/56700620/how-can-i-draw-a-image-with-circular-border-in-canvas
  Future<Uint8List> getCircularCanvas(int size, ui.Image uiImg) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.blue;
    Paint paintBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    Path path = Path()
      ..addOval(Rect.fromLTWH(
          0.toDouble(), 0.toDouble(), size.toDouble(), size.toDouble()));

    canvas.clipPath(path);
    canvas.drawImage(uiImg, Offset.zero, paint);

    double borderRadius = size.toDouble() / 2;
    canvas.drawCircle(
        Offset(borderRadius, borderRadius), borderRadius, paintBorder);
    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

//https://medium.com/coletiv-stories/customize-your-cluster-markers-on-flutter-google-maps-1e5c28da4a9e
  Future<BitmapDescriptor> getRectangleCanvas(int size, MarkerId id) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.white;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = size / 2;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );
    textPainter.text = TextSpan(
      text: "Act",
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );
    final image = await pictureRecorder.endRecording().toImage(
          radius.toInt() * 2,
          radius.toInt() * 2,
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {}

  @override
  void dispose() {
    _locationSub.cancel();
    super.dispose();
  }
}
