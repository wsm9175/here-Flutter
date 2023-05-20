import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:here/component/nfc_ios.dart';
import 'package:here/component/nfc_module.dart';
import 'package:here/component/timer.dart';
import 'package:here/firebase/firebase_realtime_database.dart';
import 'package:here/model/login_user.dart';
import 'package:here/model/tag_data.dart';
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
  TodayAttendanceStatus todayAttendanceStatus =
      TodayAttendanceStatus(false, false);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
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
                return Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _AttendanceButton(
                          onPressed: taggingNfc,
                          doAttendance:
                          todayAttendanceStatus.doAttendance,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LoginInfo(loginUser: loginUser),
                            SizedBox(height: 8.0),
                            const _TimeInfo(),
                          ],
                        ),
                        _LeaveButton(
                          onPressed: taggingNfc,
                          doLeave: todayAttendanceStatus.doLeave,
                          doAttendance:
                          todayAttendanceStatus.doAttendance,
                        ),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isLoading,
                      builder: (BuildContext context, bool isLoading,
                          Widget? child) {
                        return isLoading
                            ? _loadingProgress()
                            : SizedBox.shrink();
                      },
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
    getTodayAttendanceInfo();
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

  void taggingNfc() async {
    if (!await NfcManager.instance.isAvailable()) {
      checkNfc();
    } else {
      if (Platform.isIOS) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return IosSessionScreen(
            handleTag: nfcModule.handleTag,
            doAttendance: getFirebaseTagList,
          );
        }));
      } else {
        showDialog(
          context: context,
          builder: (_) {
            return AndroidSessionDialog(
              'nfc 태그에 기기를 태깅해주세요.',
              nfcModule.handleTag,
              getFirebaseTagList,
            );
          },
        );
      }
    }
  }

  void checkNfc() async {
    print('checkNfc');
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

  void getFirebaseTagList(String tagId) {
    _isLoading.value = true;
    // get tagId From Firebase
    FirebaseRealtimeDatabase()
        .getTagList()
        .then((value) => {settingTagData(value, tagId)})
        .catchError((error) => {print(error)});
    // get
  }

  settingTagData(DataSnapshot snapshot, String tagId) {
    Map<dynamic, dynamic> valueList = snapshot.value as Map<dynamic, dynamic>;
    List<TagData> dataList = <TagData>[];

    for (String key in valueList.keys) {
      dataList.add(TagData(valueList[key], key));
    }

    bool check = false;

    dataList.forEach((element) {
      print('element key : ${element.key} tagId : ${tagId}');
      if (element.key == tagId) check = true;
    });

    if (check) {
      // 출석
      FirebaseRealtimeDatabase()
          .doAttendance(!todayAttendanceStatus.doAttendance)
          .then((value) => {
                setState(() {
                  if (!todayAttendanceStatus.doAttendance) {
                    todayAttendanceStatus = TodayAttendanceStatus(true, false);
                    showToast('출근을 완료했습니다.');
                  } else {
                    todayAttendanceStatus = TodayAttendanceStatus(true, true);
                    showToast('퇴근을 완료했습니다.');
                  }
                  _isLoading.value = false;
                })
              })
          .catchError((error) => showToast('오류가 발생했습니다.'));
    } else {
      // 잘못된 태그
      showToast('잘못된 태그입니다.');
      _isLoading.value = false;
    }
  }

  void getTodayAttendanceInfo() {
    _isLoading.value = true;
    FirebaseRealtimeDatabase()
        .getTodayAttendanceInfo()
        .then((value) => checkMyAttendance(value))
        .catchError((error) {
      print(error);
      _isLoading.value = false;
    });
  }

  void checkMyAttendance(DataSnapshot snapshot) {
    Map<dynamic, dynamic> valueList = snapshot.value as Map<dynamic, dynamic>;

    bool doAttendance = false;
    bool doLeave = false;

    for (String key in valueList.keys) {
      if (valueList[key]['studentUid'] == LoginUser().uid) {
        if (valueList[key]['attendance'] == true)
          doAttendance = true;
        else
          doLeave = true;
      }
    }
    setState(() {
      todayAttendanceStatus = TodayAttendanceStatus(doAttendance, doLeave);
      _isLoading.value = false;
    });
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
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '현재 시간을 확인해주세요',
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
    fontSize: 28.0,
    color: Colors.black,
  );

  const _LoginInfo({required this.loginUser, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${loginUser.name}님', style: textStyle,)
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
            height: MediaQuery.of(context).size.height * 0.2,
            child: OutlinedButton(
              onPressed: doAttendance
                  ? () {
                      showToast('오늘 입실 처리 하셨습니다 :)');
                    }
                  : onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: doAttendance ? Colors.blue : Colors.white,
                side: BorderSide(width: 3.0, color: Colors.blue)
              ),
              child: Text(
                doAttendance ? '입  실  완  료' : '입  실',
                style: TextStyle(
                  color: doAttendance ? Colors.white : Colors.black,
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
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
            height: MediaQuery.of(context).size.height * 0.2,
            child: OutlinedButton(
              onPressed: doLeave
                  ? () {
                      showToast('오늘 퇴실 처리 하셨습니다 :)');
                    }
                  : doAttendance
                      ? onPressed
                      : () {
                          showToast('입실 처리를 진행해주세요!');
                        },
              style: ElevatedButton.styleFrom(
                backgroundColor: doLeave ? Colors.yellow : Colors.white,
                side: BorderSide(width: 3.0, color: Colors.yellow),
              ),
              child: Text(
                doLeave ? '퇴  실  완  료': "퇴  실",
                style: TextStyle(
                  color: doLeave ? Colors.white : Colors.black,
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
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
