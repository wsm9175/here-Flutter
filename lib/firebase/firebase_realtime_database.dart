import 'package:firebase_database/firebase_database.dart';

class FirebaseRealtimeDatabase{
  FirebaseDatabase _database = FirebaseDatabase.instance;
  FirebaseRealtimeDatabase._privateConstructor();

  static final FirebaseRealtimeDatabase _instance = FirebaseRealtimeDatabase._privateConstructor();

  factory FirebaseRealtimeDatabase() {
    return _instance;
  }


  void getUserInfo(String uid) async{
    print('getUserInfo');
    _database.databaseURL = 'https://here-flutter-default-rtdb.asia-southeast1.firebasedatabase.app';
    final ref = _database.ref();
    final snapshot = await ref.child('userStudent/$uid').get();
    if (snapshot.exists) {
      print('user info : ${snapshot.value}');
    } else {
      print('No data available.');
    }
  }
}

