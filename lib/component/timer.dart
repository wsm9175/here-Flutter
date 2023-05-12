import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';

class Clock extends StatelessWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(
        const Duration(seconds: 1),
        builder: (_){
          return Text(
            DateFormat('yyyy/MM/dd - HH:mm:ss').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 30.0,
              color: Colors.white,
            ),
          );
        },
    );
  }
}
