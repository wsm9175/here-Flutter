import 'package:flutter/material.dart';
import 'package:here/model/nfc_data.dart';
import 'package:nfc_manager/nfc_manager.dart';

class IosSessionScreen extends StatelessWidget {
  final handleTag;
  final void Function(String tagId) doAttendance;

  const IosSessionScreen({
    required this.handleTag,
    required this.doAttendance,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NfcData? _result;
    print('nfc_ios session build');
    return Scaffold(
      body: SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            print('nfc start session');
            NfcManager.instance.startSession(
              pollingOptions: {
                NfcPollingOption.iso14443,
                NfcPollingOption.iso15693,
              },
              alertMessage: "기기를 필터 가까이에 가져다주세요.",
              onDiscovered: (NfcTag tag) async {
                try {
                    _result = handleTag(tag);
                    doAttendance(_result!.message);
                } catch (e) {
                  setState(() {
                    null;
                  });
                } finally {
                  await NfcManager.instance.stopSession(alertMessage: "완료되었습니다.");
                  Navigator.pop(context);
                }
              },
            );
            return Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  // id == null ? "취소" : "확인",
                  "확인",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
