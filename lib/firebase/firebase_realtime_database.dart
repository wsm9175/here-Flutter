import 'package:firebase_database/firebase_database.dart';
import 'package:here/model/login_user.dart';
import 'package:here/util/random_string.dart';
import 'package:intl/intl.dart';

class FirebaseRealtimeDatabase {
  FirebaseDatabase _database = FirebaseDatabase.instance;

  FirebaseRealtimeDatabase._privateConstructor() {
    _database.databaseURL =
        'https://here-flutter-default-rtdb.asia-southeast1.firebasedatabase.app';
  }

  static final FirebaseRealtimeDatabase _instance =
      FirebaseRealtimeDatabase._privateConstructor();

  factory FirebaseRealtimeDatabase() {
    return _instance;
  }

  Future<DataSnapshot> getUserInfo(String uid) async {
    print('getUserInfo');
    final ref = _database.ref();
    final snapshot = await ref.child('userStudent/$uid').get();
    if (snapshot.exists) {
      print('user info : ${snapshot.value}');
    } else {
      print('No data available.');
    }
    return snapshot;
  }

  Future<DataSnapshot> getTodayAttendanceInfo() async{
    String nowDate = DateFormat('yyyyMMdd').format(DateTime.now());
    final ref = _database.ref();
    final snapshot = await ref.child('attendance/$nowDate').get();

    if (snapshot.exists) {
      print('attendance info : ${snapshot.value}');
    } else {
      print('No data available.');
    }
    return snapshot;
  }

  Future<DataSnapshot> getTagList() async{
    print('getTagList');
    final ref = _database.ref();
    final snapshot = await ref.child('tagList').get();
    if(snapshot.exists){
      print('tagList : ${snapshot.value}');
    }else{
      print('now data available');
    }
    return snapshot;
  }


  Future<void> doAttendance(bool isAttendance) async {
    print('doAttendance');
    String nowDate = DateFormat('yyyyMMdd').format(DateTime.now());
    String nowTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final ref = _database.ref('attendance/$nowDate/${getRandomString(16)}');
    return await ref.set({
      'attendance': isAttendance,
      'classType': LoginUser().classType,
      'name': LoginUser().name,
      'phoneNumber': LoginUser().phoneNumber,
      'studentUid': LoginUser().uid,
      'time': nowTime,
    });
  }

  Future<void> register(String uid, String name, String phoneNumber, String deviceUid, String classType) async{
    print('register');
    final ref = _database.ref('userStudent/${uid}');
    return await ref.set({
      'classType' : classType,
      'deviceId' : deviceUid,
      'name' : name,
      'phoneNumber' : phoneNumber,
    });
  }

  Future<void> revoke() async{
    final ref = _database.ref('userStudent/${LoginUser().uid}');
    return await ref.remove();
  }

  Future<void> changeDeviceUid(String uid,String deviceUid) async{
    final ref = _database.ref('userStudent/${uid}');
    return ref.update({
      'deviceId' : deviceUid,
    });
  }
}
