import 'dart:io';

import 'package:Space/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

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
    await firestore.runTransaction((transaction) async => transaction.update(
        firestore.collection("users").doc(userId), {"userProPicURL": imgUrl}));
  }

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

  void listenOnFriendsList(Function callback) async {
    var friendRef = firestore.collection("Friend_lists").doc(userId);

    if (!(await checkIfDocExist(friendRef))) {
      friendRef.set(
        {"friends": List<User>()},
      );
    }
    friendRef.snapshots().listen(
      (data) {
        List<SpaceUser> friendIDs = List<SpaceUser>();

        try {
          List<dynamic> idList = data["friends"];

          idList.forEach(
            (element) {
              friendIDs.add(SpaceUser(uid: element.toString()));
            },
          );
          callback(friendIDs);
        } catch (e) {
          print(e);
        }
      },
    );
  }

  void listenOnProPic(Function callback) async {
    var userRef = firestore.collection("users").doc(userId);

    if (!(await checkIfDocExist(userRef)) ||
        !(await userRef.get()).data().containsKey("userProPicURL")) {
      await userRef.update(
        {"userProPicURL": ""},
      );
    }
    userRef.snapshots().listen(
      (data) {
        try {
          String imgUrl = data["userProPicURL"];
          callback(imgUrl);
        } catch (e) {
          print(e);
        }
      },
    );
  }

  void listenOnUserPublicID(Function callback) async {
    var userRef = firestore.collection("users").doc(userId);

    if (!(await checkIfDocExist(userRef)) ||
        !(await userRef.get()).data().containsKey("publicID")) {
      await userRef.update(
        {"publicID": ""},
      );
    }
    userRef.snapshots().listen(
      (data) {
        try {
          String id = data["publicID"];
          callback(id);
        } catch (e) {
          print(e);
        }
      },
    );
  }

  Future<dynamic> getUserByID(String userID) async {
    DocumentSnapshot ds = await firestore.collection("users").doc(userID).get();
    if (ds.exists) {
      SpaceUser user = SpaceUser(uid: userID);
      user.imageUrl = ds["userProPicURL"];
      return user;
    }
    return null;
  }

  Future<bool> checkIfDocExist(DocumentReference ref) async {
    DocumentSnapshot ds = await ref.get();
    return ds.exists;
  }

  Future<bool> isSetUserIDSuccessful(String idToSet) async {
    if (await checkIfPublicIDExist(idToSet)) {
      return false;
    } else {
      firestore.collection("users").doc(userId).update({
        "publicID": idToSet,
      });
      return true;
    }
  }

  Future<bool> checkIfPublicIDExist(String idForChecking) async {
    QuerySnapshot _query = await firestore
        .collection("users")
        .where("publicID", isEqualTo: idForChecking)
        .get();

    if (_query.docs.length > 0) {
      return true;
    }
    return false;
  }

  Future<bool> isFriendExist(String friendID) async {
    return (await firestore
                .collection("users")
                .where("publicID", isEqualTo: friendID)
                .get())
            .docs
            .length >
        0;
  }

  Future<bool> addFriendByID(String friendID) async {
    print(friendID);
    if (friendID != userId && await isFriendExist(friendID)) {
      firestore.collection("Friend_lists").doc(userId).update(
        {
          "friends": FieldValue.arrayUnion(
            [friendID],
          ),
        },
      );
      print("true");
      return true;
    }
    print("false");
    return false;
  }
}
