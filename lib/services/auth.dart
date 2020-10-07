import 'dart:io';

import 'package:Space/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';

class AuthService {
  static final AuthService _singleton = AuthService._internal();

  factory AuthService() {
    return _singleton;
  }

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  SpaceUser _userFromFireBaseUser(User user) {
    return user != null ? SpaceUser(uid: user.uid) : null;
  }

  Stream<SpaceUser> get user {
    print("signed in");
    return _auth
        .authStateChanges()
        .map((User user) => _userFromFireBaseUser(user));
  }

  String get userId {
    return _auth.currentUser.uid;
  }

  Future registerWithEmail(String email, String password,
      [File userImg]) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User user = result.user;
      if (userImg != null) {
        uploadImageToFirebase(user.uid, userImg);
      }
      return _userFromFireBaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> uploadImageToFirebase(String userID, File imageFile) async {
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$userID/userImg');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var imgUrl = await taskSnapshot.ref.getDownloadURL();
    setUserProPicUrl(imgUrl.toString());
  }

  Future<void> setUserProPicUrl(String imgUrl) async {
    await deletePreviousProPic();
    await firestore.runTransaction((transaction) async => transaction.set(
        firestore.collection("users").doc(userId), {"userProPicURL": imgUrl}));
  }

  Future deletePreviousProPic() async {}
  Future signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFireBaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> updataUserLocation(GeoFirePoint pointToAdd) async {
    await firestore.runTransaction(
      (transaction) async => transaction.set(
        firestore.collection("userLocations").doc(userId),
        {
          "position": pointToAdd.data,
          "user": userId,
        },
      ),
    );
  }

  Stream<List<DocumentSnapshot>> getUserGeoCollection(LocationData loc) {
    var queryRef = firestore.collection("userLocations");
    return geo.collection(collectionRef: queryRef).within(
        center: GeoFirePoint(loc.latitude, loc.longitude),
        radius: 10,
        field: 'position',
        strictMode: true);
  }

  Stream<List<DocumentSnapshot>> getActivitiesGeoCollection(LocationData loc) {
    var queryRef = firestore.collection("activity_locations");
    return geo.collection(collectionRef: queryRef).within(
        center: GeoFirePoint(loc.latitude, loc.longitude),
        radius: 10,
        field: 'position',
        strictMode: true);
  }

  Future<dynamic> getUserImgUrl(String userId) async {
    var userRef = firestore.collection("users").doc(userId);
    DocumentSnapshot docSnap = await userRef.get();
    return docSnap.data() != null && docSnap.data().containsKey("userProPicURL")
        ? docSnap.data()["userProPicURL"]
        : null;
  }

// Future<dynamic> getUserP
}
