import 'package:flutter/material.dart';
import 'package:here/model/nfc_data.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:lottie/lottie.dart';

class AndroidSessionDialog extends StatefulWidget {
  final String alertMessage;
  final NfcData Function(NfcTag tag) handleTag;
  final void Function(String tagId) doAttendance;

  const AndroidSessionDialog(
      this.alertMessage, this.handleTag, this.doAttendance);

  @override
  State<StatefulWidget> createState() => _AndroidSessionDialogState();
}

class _AndroidSessionDialogState extends State<AndroidSessionDialog> {
  String? _alertMessage;
  String? _errorMessage;

  NfcData? _result;

  @override
  void initState() {
    super.initState();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          await NfcManager.instance.stopSession();
          _result = widget.handleTag(tag);

          _alertMessage = "NFC 태그를 인식하였습니다. 처리중..";
          widget.doAttendance(_result!.message);
        } catch (e) {
          await NfcManager.instance.stopSession();
          setState(() => _errorMessage = '$e');
        } finally{
          Navigator.pop(context);
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _errorMessage?.isNotEmpty == true
            ? "오류"
            : _alertMessage?.isNotEmpty == true
                ? "성공"
                : "준비",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _errorMessage?.isNotEmpty == true
                ? _errorMessage!
                : _alertMessage?.isNotEmpty == true
                    ? _alertMessage!
                    : widget.alertMessage,
          ),
          Lottie.asset('asset/img/nfc_lottie.json'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            _errorMessage?.isNotEmpty == true
                ? "확인"
                : _alertMessage?.isNotEmpty == true
                    ? "완료"
                    : "취소",
          ),
          onPressed: () => Navigator.of(context).pop(_result),
        ),
      ],
    );
  }
}
