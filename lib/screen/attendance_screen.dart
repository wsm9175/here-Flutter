import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:here/component/nfc_ios.dart';
import 'package:here/component/nfc_module.dart';
import 'package:here/component/timer.dart';
import 'package:here/model/login_user.dart';
import 'package:here/model/today_attendance_status.dart';
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
    TodayAttendanceStatus todayAttendanceStatus =
        TodayAttendanceStatus(false, false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          '출근 관리',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else if (snapshot.data!) {
                return Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AttendanceStatus(
                              todayAttendanceStatus: todayAttendanceStatus),
                          _LoginInfo(loginUser: loginUser),
                          const _TimeInfo(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24.0),
                          _AttendanceButton(
                            onPressed: taggingNfc,
                            doAttendance: todayAttendanceStatus.doAttendance,
                          ),
                          const SizedBox(height: 16.0),
                          _LeaveButton(
                            onPressed: taggingNfc,
                            doLeave: todayAttendanceStatus.doLeave,
                            doAttendance: todayAttendanceStatus.doAttendance,
                          ),
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

class _AttendanceStatus extends StatelessWidget {
  final TodayAttendanceStatus todayAttendanceStatus;

  const _AttendanceStatus({
    required this.todayAttendanceStatus,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    );

    return todayAttendanceStatus.doAttendance
        ? todayAttendanceStatus.doLeave
            ? const _AllDone(
                textStyle: textStyle,
              )
            : const _NotLeave(
                textStyle: textStyle,
              )
        : const _NotAttendance(
            textStyle: textStyle,
          );
  }
}

class _NotAttendance extends StatelessWidget {
  final TextStyle textStyle;

  const _NotAttendance({required this.textStyle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 하루도 화이팅!',
          style: textStyle,
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          '출근을 진행해주세요.',
          style: textStyle,
        ),
      ],
    );
  }
}

class _NotLeave extends StatelessWidget {
  final TextStyle textStyle;

  const _NotLeave({required this.textStyle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '아직 퇴근안하셨네요!',
          style: textStyle,
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          '퇴근을 진행해주세요.',
          style: textStyle,
        ),
      ],
    );
  }
}

class _AllDone extends StatelessWidget {
  final TextStyle textStyle;

  const _AllDone({required this.textStyle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '오늘 하루도 수고하셨습니다 :)',
      style: textStyle,
    );
  }
}

class _TimeInfo extends StatelessWidget {
  const _TimeInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*Image(
          image: AssetImage('asset/img/clock.png'),
          width: 200.0,
          height: 200.0,
        )*/
        Text(
          '시간을 확인해주세요',
          style: TextStyle(fontSize: 24.0),
        ),
        SizedBox(
          height: 16.0,
        ),
        Clock(),
      ],
    );
  }
}

class _LoginInfo extends StatelessWidget {
  final LoginUser loginUser;
  final textStyle = const TextStyle(
    fontSize: 20.0,
    color: Colors.black,
  );

  const _LoginInfo({required this.loginUser, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black,
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
  final bool doAttendance;

  const _AttendanceButton({
    required this.onPressed,
    required this.doAttendance,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 100.0,
            child: OutlinedButton(
              onPressed: doAttendance
                  ? () {
                      showToast('오늘 출근 처리 하셨습니다 :)');
                    }
                  : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "출 근",
                style: TextStyle(
                  color: Colors.black,
                ),
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
  final bool doAttendance;
  final bool doLeave;

  const _LeaveButton({
    required this.onPressed,
    required this.doAttendance,
    required this.doLeave,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 100.0,
            child: OutlinedButton(
              onPressed: doLeave
                  ? () {
                      showToast('오늘 퇴근 처리 하셨습니다 :)');
                    }
                  : doAttendance
                      ? onPressed
                      : () {
                          showToast('출근 처리를 진행해주세요!');
                        },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "퇴 근",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
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
