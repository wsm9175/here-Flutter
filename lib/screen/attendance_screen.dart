import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:here/component/nfc_ios.dart';
import 'package:here/component/nfc_module.dart';
import 'package:here/component/timer.dart';
import 'package:here/model/login_user.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../component/nfc_dialog_android.dart';

bool isNfcAvaliable = false;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with WidgetsBindingObserver {
  final nfcModule = NfcModule();
  final loginUser = LoginUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else if (snapshot.data!) {
                return Column(
                  children: [
                    const _TimeInfo(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LoginInfo(loginUser: loginUser),
                          SizedBox(height: 24.0),
                          _AttendanceButton(onPressed: taggingNfc),
                          const SizedBox(height: 16.0),
                          _LeaveButton(onPressed: taggingNfc),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: checkNfc,
                      child: Text('NFC 활성화'),
                    )
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {});
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }

  void taggingNfc() async {
    if (!await NfcManager.instance.isAvailable()) {
      checkNfc();
    } else {
      if (Platform.isIOS) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return IosSessionScreen(handleTag: nfcModule.handleTag);
        }));
      } else {
        showDialog(
          context: context,
          builder: (_) {
            return AndroidSessionDialog(
              'nfc 태그에 기기를 태깅해주세요.',
              nfcModule.handleTag,
            );
          },
        );
      }
    }
  }

  void checkNfc() async {
    if (!(isNfcAvaliable)) {
      if (Platform.isAndroid) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("오류"),
            content: const Text(
              "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  AppSettings.openNFCSettings();
                },
                child: Text("설정"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "확인",
                ),
              ),
            ],
          ),
        );
      }
      throw "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.";
    }
  }
}

class _TimeInfo extends StatelessWidget {
  const _TimeInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image(
            image: AssetImage('asset/img/clock.png'),
            width: 200.0,
            height: 200.0,
          ),
          SizedBox(
            height: 24.0,
          ),
          Clock(),
        ],
      ),
    );
  }
}

class _LoginInfo extends StatelessWidget {
  final LoginUser loginUser;
  final textStyle = const TextStyle(
    fontSize: 20.0,
    color: Colors.white,
  );

  const _LoginInfo({required this.loginUser, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('로그인 정보',
                style: textStyle.copyWith(
                  fontWeight: FontWeight.w400,
                )),
            SizedBox(height: 8.0),
            Text(
              '성명 : ${loginUser.name}',
              style: textStyle,
            ),
            SizedBox(height: 8.0),
            Text(
              '전화번호 : ${loginUser.phoneNumber}',
              style: textStyle,
            ),
            SizedBox(height: 8.0),
            Text(
              '반 타입 : ${loginUser.classType}',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AttendanceButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50.0,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(
                "출 석",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LeaveButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50.0,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(
                "퇴 근",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
