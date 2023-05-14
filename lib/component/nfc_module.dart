import 'dart:io';

import 'package:nfc_manager/nfc_manager.dart';

class NfcModule {
  String handleTag(NfcTag tag) {
    try {
      final List<int> tempIntList;
      String message = '';

      if (Platform.isIOS) {
        tempIntList = List<int>.from(tag.data["mifare"]["identifier"]);
      } else {
        tempIntList = List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
        Ndef.from(tag)?.cachedMessage?.records.forEach((element) {
          message = new String.fromCharCodes(element.payload).substring(3);
        });
      }


      String id = "";

      tempIntList.forEach((element) {
        id = id + element.toRadixString(16);
      });

      print(id);
      print(message);

      return id;
    } catch (e) {
      print(e);
      throw "NFC 데이터를 가져올 수 없습니다.";
    }
  }
}
