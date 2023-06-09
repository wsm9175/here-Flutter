import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLogin{
  Future<bool> login() async{
    try{
      bool isInstalled = await isKakaoTalkInstalled();
      if(isInstalled){
        try{
          await UserApi.instance.loginWithKakaoTalk();
          return true;
        }catch(error){
          print(error);
          return false;
        }
      }else{
        try{
          await UserApi.instance.loginWithKakaoAccount();
          return true;
        }catch(error){
          print(error);
          return false;
        }
      }
    }catch(error){
      print(error);
      return false;
    }

  }

  Future<bool> logout() async{
    try{
      await UserApi.instance.unlink();
      return true;
    }catch(error){
      print(error);
      return false;
    }
  }
}