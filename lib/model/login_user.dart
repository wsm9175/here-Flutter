class LoginUser {
  late String uid;
  late String name;
  late String phoneNumber;
  late String classType;

  static final LoginUser _instance = LoginUser._privateConstructor();

  factory LoginUser() => _instance;

  LoginUser._privateConstructor(){
    print('User created');
  }

  void settingUserInfo(Map<dynamic, dynamic> map, String key){
    uid = key;
    name = map['name'];
    phoneNumber = map['phoneNumber'];
    classType = map['classType'];
  }

  void logout(){
    uid = '';
    name = '';
    phoneNumber = '';
    classType = '';
  }

  @override
  String toString() {
    return 'loginUser = '
        'uid : ${uid}'
        'name : ${name} '
        'phoneNumber : ${phoneNumber} '
        'classType : ${classType} ';
  }
}