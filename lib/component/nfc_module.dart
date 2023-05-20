import 'dart:io';

import 'package:here/model/nfc_data.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcModule {
  NfcData handleTag(NfcTag tag) {
    try {
      final List<int> tempIntList;
      String message = '';
      String id = '';

      print('tag data : ${tag.data}');

      if (Platform.isIOS) {
        tempIntList = List<int>.from(tag.data["mifare"]["identifier"]);
      } else {
        tempIntList = List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
      }
      // get message from ndef
      Ndef.from(tag)?.cachedMessage?.records.forEach((element) {
        message = new String.fromCharCodes(element.payload).substring(3);
      });

      tempIntList.forEach((element) {
        id = id + element.toRadixString(16);
      });

      print(id);
      print(message);

      return NfcData(id, message);
    } catch (e) {
      print(e);
      throw "NFC 데이터를 가져올 수 없습니다.";
    }
  }
}
