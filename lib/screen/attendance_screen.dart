import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:here/component/nfc_ios.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AttendanceButton(onPressed: taggingNfc),
                    SizedBox(height: 16.0),
                    LeaveButton(onPressed: taggingNfc),
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
          return IosSessionScreen(handleTag: handleTag);
        }));
      } else {
        showDialog(
          context: context,
          builder: (_) {
            return AndroidSessionDialog(
              'nfc 태그에 기기를 태깅해주세요.',
              (tag) => handleTag(tag),
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
            title: Text("오류"),
            content: Text(
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
                child: Text(
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

  String handleTag(NfcTag tag) {
    try {
      final List<int> tempIntList;

      if (Platform.isIOS) {
        tempIntList = List<int>.from(tag.data["mifare"]["identifier"]);
      } else {
        tempIntList =
            List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
      }
      String id = "";

      tempIntList.forEach((element) {
        id = id + element.toRadixString(16);
      });

      print(id);

      return id;
    } catch (e) {
      print(e);
      throw "NFC 데이터를 가져올 수 없습니다.";
    }
  }
}

class AttendanceButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AttendanceButton({
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
              child: Text("출 석"),
            ),
          ),
        ),
      ],
    );
  }
}

class LeaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LeaveButton({
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
              child: Text("퇴 근"),
            ),
          ),
        ),
      ],
    );
  }
}
