// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
//
// class ModelScreen extends StatefulWidget {
//   @override
//   _ModelScreenState createState() => _ModelScreenState();
// }
//
// class _ModelScreenState extends State<ModelScreen> {
//   List<GyroscopeEvent> gyroscopeData = [];
//   List<AccelerometerEvent> accelerometerData = [];
//   Interpreter? _interpreter;
//   bool _modelLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadModel().then((value) {
//       setState(() {
//         _modelLoaded = true;
//       });
//     });
//
//     // Gyroscope 센서 데이터
//     gyroscopeEvents.listen((gyroscopeEvent) {
//       setState(() {
//         gyroscopeData.add(gyroscopeEvent);
//       });
//     });
//
//     // Accelerometer 센서 데이터
//     accelerometerEvents.listen((accelerometerEvent) {
//       setState(() {
//         accelerometerData.add(accelerometerEvent);
//       });
//     });
//
//     // 20Hz 주기로 데이터 저장을 위한 Timer 설정
//     const duration = const Duration(milliseconds: 100);
//     Timer.periodic(duration, (timer) {
//       // 여기에서 데이터를 저장하거나 원하는 작업을 수행.
//       // 예를 들어, gyroscopeData와 accelerometerData를 사용하여 작업 수행 가능
//       if (_modelLoaded) {
//         _runModel();
//       }
//     });
//   }
//
//   Future<void> _loadModel() async {
//     final interpreterOptions = InterpreterOptions()..threads = 4;
//     final interpreter = await Interpreter.fromAsset('assets/phone_0903Fall_ST.tflite', options: interpreterOptions);
//     setState(() {
//       _interpreter = interpreter;
//     });
//   }
//
//   void _runModel() {
//     if (_interpreter == null) {
//       return;
//     }
//
//     // gyroscope와 accelerometer 데이터를 모델 입력 형식에 맞게 처리
//     final input = [
//       ...gyroscopeData.map((event) => [event.x, event.y, event.z]),
//       ...accelerometerData.map((event) => [event.x, event.y, event.z]),
//     ];
//
//     // 모델 실행
//     final output = List.filled(3, 0.0); // 클래스 수에 맞게 초기화 (0, 1, 2)
//     _interpreter!.run(input, output);
//
//     // 결과 해석
//     final predictedClass = output.indexOf(output.reduce((curr, next) => curr > next ? curr : next));
//
//     // 예측 결과 출력
//     print('Predicted Class: $predictedClass');
//
//     // 여기에서 예측 결과를 화면에 표시하도록 구현 가능
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Sensor Data Example'),
//           actions: [
//             IconButton(
//               icon: Icon(
//                 Icons.exit_to_app_sharp,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 FirebaseAuth.instance.signOut();
//               },
//             )
//           ],
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text('Gyroscope Data: $gyroscopeData'),
//               Text('Accelerometer Data: $accelerometerData'),
//               Text('모델 로드 상태: ${_modelLoaded ? '로드됨' : '로딩 중'}'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // 앱이 종료될 때 센서 데이터 구독을 해제
//     gyroscopeEvents.drain();
//     accelerometerEvents.drain();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelScreen extends StatefulWidget {
  @override
  _ModelScreenState createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  // List<GyroscopeEvent> gyroscopeData = [];
  // List<AccelerometerEvent> accelerometerData = [];
  List<String> inputFeatures = [
    "Acc_Z_Amplitude",
    "Acc_Y_Amplitude",
    "Acc_X_Amplitude",
    "Acc_Z_Energy",
    "Acc_Y_Energy",
    "Acc_X_Energy",
    "Gyr_X_Amplitude",
    "Gyr_Y_Amplitude",
    "Gyr_Z_Amplitude",
    "Acc_Total_Energy",
    "Gyr_Total_Energy"
  ];

  // 측정된 acc, gyro 데이터
  List<double> accDataX = [];
  List<double> accDataY = [];
  List<double> accDataZ = [];
  List<double> gyroDataX = [];
  List<double> gyroDataY = [];
  List<double> gyroDataZ = [];
  // 진폭(최대, 최소 차이)
  List<double> accAmplitudeX = [];
  List<double> accAmplitudeY = [];
  List<double> accAmplitudeZ = [];
  List<double> gyroAmplitudeX = [];
  List<double> gyroAmplitudeY = [];
  List<double> gyroAmplitudeZ = [];
  // 50개 데이터 제곱의 합
  List<double> accEnergyX = [];
  List<double> accEnergyY = [];
  List<double> accEnergyZ = [];
  List<double> gyroEnergyX = [];
  List<double> gyroEnergyY = [];
  List<double> gyroEnergyZ = [];

  // x^2 + y^2 + z^2
  List<double> accTotalEnergy = [];
  List<double> gyroTotalEnergy = [];

  late Interpreter interpreter;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    loadModel();
    startSensors();

    // // Gyroscope 센서 데이터
    // gyroscopeEvents.listen((gyroscopeEvent) {
    //   setState(() {
    //     gyroscopeData.add(gyroscopeEvent);
    //   });
    // });
    //
    // // Accelerometer 센서 데이터
    // accelerometerEvents.listen((accelerometerEvent) {
    //   setState(() {
    //     accelerometerData.add(accelerometerEvent);
    //   });
    // });

    // 20Hz 주기로 데이터 저장을 위한 Timer 설정
    // const duration = const Duration(milliseconds: 100);
    // Timer.periodic(duration, (timer) {
    //   // 여기에서 데이터를 저장하거나 원하는 작업을 수행.
    //   // 예를 들어, gyroscopeData와 accelerometerData를 사용하여 작업 수행 가능
    //   if (_modelLoaded) {
    //     _runModel();
    //   }
    // });
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/firstModel.tflite');
  }

  Future<void> startSensors() async {
    const duration = const Duration(milliseconds: 100); // 10Hz 단위로 뽑아오기
    Timer.periodic(duration, (timer) {
      if (_modelLoaded) {
        accelerometerEvents.listen((AccelerometerEvent event) {
          // accelerometer 센서 데이터 추출
          accDataX.add(event.x);
          accDataY.add(event.y);
          accDataZ.add(event.z);

          if (accDataX.length == 50) {
            // 50개 데이터를 수집했을 때 처리
            classify();
            // 데이터 초기화
            accDataX.clear();
            accDataY.clear();
            accDataZ.clear();
          }
        });

        // gyroscope 센서 데이터 추출
        gyroscopeEvents.listen((GyroscopeEvent event) {
          // accelerometer 센서 데이터 추출
          gyroDataX.add(event.x);
          gyroDataY.add(event.y);
          gyroDataZ.add(event.z);

          if (gyroDataX.length == 50) {
            // 50개 데이터를 수집했을 때 처리
            // classify();
            // 데이터 초기화
            gyroDataX.clear();
            gyroDataY.clear();
            gyroDataZ.clear();
          }
        });
      }
    });
  }

  void classify() {
    // 데이터 정제하기
  }

  // void _runModel() {
  //   if (_interpreter == null) {
  //     return;
  //   }
  //
  //   // gyroscope와 accelerometer 데이터를 모델 입력 형식에 맞게 처리
  //   final input = [
  //     // ...gyroscopeData.map((event) => [event.x, event.y, event.z]),
  //     // ...accelerometerData.map((event) => [event.x, event.y, event.z]),
  //   ];
  //
  //   // 모델 실행
  //   final output = List.filled(3, 0.0); // 클래스 수에 맞게 초기화 (0, 1, 2)
  //   // _interpreter!.run(input, output);
  //
  //   // 결과 해석
  //   final predictedClass = output.indexOf(output.reduce((curr, next) => curr > next ? curr : next));
  //
  //   // 예측 결과 출력
  //   print('Predicted Class: $predictedClass');
  //
  //   // 여기에서 예측 결과를 화면에 표시하도록 구현 가능
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sensor Data Example'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app_sharp,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Accelerometer Data: ${accDataX.isEmpty ? "로딩 중" : "[${accDataX.join(', ')}]"}'),
              Text('Gyroscope Data: [$gyroDataX, $gyroDataY, $gyroDataZ]'),
              Text('모델 로드 상태: ${_modelLoaded ? '로드됨' : '로딩 중'}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 앱이 종료될 때 센서 데이터 구독을 해제
    gyroscopeEvents.drain();
    accelerometerEvents.drain();
    super.dispose();
  }
}
