import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String? uid;

  MyUser({this.uid});
}

class UserData {
  final String? uid, name, age;

  UserData({this.uid, this.name, this.age});
}

class UserDatabaseService {
  final String? uid;
  final userCollection = FirebaseFirestore.instance.collection('users');

  UserDatabaseService({this.uid});

  Future updateUserData(String name, String age) async {
    return await userCollection.doc(uid).set({'name': name, 'age': age});
  }

  Stream<UserData> get getUserData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        uid: uid, name: snapshot.get('name'), age: snapshot.get('age'));
  }
}
