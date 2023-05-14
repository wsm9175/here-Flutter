import 'package:flutter/material.dart';

import '../component/device_info_module.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  ValueNotifier<String> valueNotifier = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('등록'),
      ),
      body: SafeArea(
        child: Form(
          child: Column(
            children: [
              ValueListenableBuilder(
                  valueListenable: valueNotifier,
                  builder: (BuildContext context, String value, Widget? child) {
                    return Text(value);
                  },
              ),
            ],
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

  void getSign() async{
    print('getSign');
    valueNotifier.value = await getDeviceUniqueId();
  }

}
