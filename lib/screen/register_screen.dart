import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:here/component/custom_textfield.dart';
import 'package:here/firebase/firebase_realtime_database.dart';

import '../component/device_info_module.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String> uidNotifier = ValueNotifier('');
  final formKey = GlobalKey<FormState>();

  String? _name;
  String? _phoneNumber;
  String? _classType;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    _name = arguments['fulName'];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('등록'),
      ),
      body: SafeArea(
        child: Form(
          key: this.formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기본 정보를\n입력하세요',
                      style: TextStyle(
                        fontSize: 32.0,
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    ),
                    renderNameWidget(),
                    SizedBox(
                      height: 20.0,
                    ),
                    CustomTextField(
                      labelText: '전화번호',
                      isString: false,
                      validator: (val) {
                        if (val.length < 1) {
                          return '전화번호를 입력해주세요';
                        }
                        _phoneNumber = val;
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    /*InkWell(
                      onTap: showPicker,
                      child: Text('class 선택'),
                    ),*/
                    CustomTextField(
                      labelText: '클래스 타입',
                      isString: true,
                      validator: (val) {
                        if (val.length < 1) {
                          return '1자 이상 입력해주세요';
                        }
                        _classType = val;
                        return null;
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: register,
                            child: Text('등록 하기'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder:
                      (BuildContext context, bool isLoading, Widget? child) {
                    return isLoading ? _loadingProgress() : SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getSign();
  }

  Widget _loadingProgress() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ],
    );
  }

  void getSign() async {
    print('getSign');
    _isLoading.value = true;
    uidNotifier.value = await getDeviceUniqueId();
    _isLoading.value = false;
  }

  void register() async {
    if (this.formKey.currentState!.validate()) {
      if (_phoneNumber == '' || _name == '' || _classType == '') {
        showToast('모든 항목을 입력해주세요');
        return;
      }
      _isLoading.value = true;
      FirebaseRealtimeDatabase()
          .register(FirebaseAuth.instance.currentUser!.uid, _name!,
              _phoneNumber!, uidNotifier.value, _classType!)
          .then((value) {
        _isLoading.value = false;
        showToast('등록을 성공했습니다.');
        Navigator.pop(context);
      }).catchError((error) {
        _isLoading.value = false;
        showToast('에러가 발생했습니다.');
      });
    }
  }

  Widget renderNameWidget() {
    return _name != ''
        ? Text(
            '입력된 이름 : '+_name!,
            style: TextStyle(
              fontSize: 16.0
            ),
          )
        : CustomTextField(
            labelText: '이름',
            isString: true,
            validator: (val) {
              if (val.length < 1) {
                return '1자 이상 입력해주세요';
              }
              _name = val;
              return null;
            },
          );
  }
}

void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
