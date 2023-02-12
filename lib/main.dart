import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sensors/flutter_sensors.dart';

void main() {
  runApp(const MyApp());
}

class SensorData {
  static const int TIME_STAMP = 100;
  static bool ready = false;
  List<double> accX = [];
  List<double> accY = [];
  List<double> accZ = [];
  List<double> gyroX = [];
  List<double> gyroY = [];
  List<double> gyroZ = [];
  List<double> linAccX = [];
  List<double> linAccY = [];
  List<double> linAccZ = [];

  setaccX(double value){
    accX.add(value);
    testStamp();
  }
  setaccY(double value){
    accY.add(value);
    testStamp();
  }
  setaccZ(double value){
    accZ.add(value);
    testStamp();
  }
  setgyroX(double value){
    gyroX.add(value);
    testStamp();
  }
  setgyroY(double value){
    gyroY.add(value);
  }
  setgyroZ(double value) {
    gyroZ.add(value);
    testStamp();
  }
  setlinAccX(double value){
    linAccX.add(value);
    testStamp();
  }
  setlinAccY(double value){
    linAccY.add(value);
    testStamp();
  }
  setlinAccZ(double value){
    linAccZ.add(value);
    testStamp();
  }

  reinitialize(){
    accX = [];
    accY = [];
    accZ = [];
    gyroX = [];
    gyroY = [];
    gyroZ = [];
    linAccX = [];
    linAccY = [];
    linAccZ = [];
  }
  testStamp(){
    if(gyroX.length >= TIME_STAMP && gyroY.length >= TIME_STAMP && gyroZ.length >= TIME_STAMP &&
        accX.length >= TIME_STAMP && accY.length >= TIME_STAMP && accZ.length >= TIME_STAMP &&
        linAccX.length >= TIME_STAMP && linAccY.length >= TIME_STAMP && linAccZ.length >= TIME_STAMP){
      ready = true;
    }
  }

}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {

  late SensorData sensorData;

  String activity = "";
  String assetName = "assets/Sitting.png";
  late final streamAcc;
  late final streamGyr;
  late final streamLin;
  bool semaphore = false;

  @override
  void initState() {
    super.initState();
    //loadModel();
    sensorData = SensorData();
    startSensorListeners();
  }

  register(SensorEvent event) async {
    if(event.sensorId == Sensors.GYROSCOPE){
      setState(() {
        sensorData.setgyroX(event.data[0]);
        sensorData.setgyroY(event.data[1]);
        sensorData.setgyroZ(event.data[2]);
      });
    }else if(event.sensorId == Sensors.LINEAR_ACCELERATION){
      setState(() {
        sensorData.setlinAccX(event.data[0]);
        sensorData.setlinAccY(event.data[1]);
        sensorData.setlinAccZ(event.data[2]);
      });
    }else if(event.sensorId == Sensors.ACCELEROMETER){
      setState(() {
        sensorData.setaccX(event.data[0]);
        sensorData.setaccY(event.data[1]);
        sensorData.setaccZ(event.data[2]);
      });
    }
    //if data is over 100 , then we try to predict activity
    if(SensorData.ready){
      //predictActivity(sensorData);
    }
  }

  Future<void> startSensorListeners() async {
    streamAcc = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: Sensors.SENSOR_DELAY_FASTEST
    );
    streamGyr = await SensorManager().sensorUpdates(
        sensorId: Sensors.GYROSCOPE,
        interval: Sensors.SENSOR_DELAY_FASTEST
    );
    streamLin = await SensorManager().sensorUpdates(
        sensorId: Sensors.LINEAR_ACCELERATION,
        interval: Sensors.SENSOR_DELAY_FASTEST
    );
    streamLin.listen(register);
    streamGyr.listen(register);
    streamAcc.listen(register);
  }

  /*Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_activity.tflite",
      labels: "assets/labels.txt",
    );
  }*/

  /*@override
  void dispose() {
    Tflite.close();
    super.dispose();
  }*/


  /*Future<void> predictActivity(SensorData data) async {

    List<double> predictData = [];
    predictData.addAll(data.accX.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.accY.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.accZ.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.gyroX.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.gyroY.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.gyroZ.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.linAccX.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.linAccY.sublist(0,SensorData.TIME_STAMP));
    predictData.addAll(data.linAccZ.sublist(0,SensorData.TIME_STAMP));
    Float32List floatData = Float32List.fromList(predictData);
    Uint8List binaryData = floatData.buffer.asUint8List();
    if(semaphore) return;
    semaphore = true;
    List? output = await Tflite.runModelOnBinary(
      binary: binaryData,
      numResults: 3,
      threshold: 0.5,
    );
    Tflite.close();
    String label = output![0]["label"];
    // load label from file
    //String labels = await rootBundle.loadString('assets/labels.txt');
    //List<String> labelList = labels.split('\n');
    setState(() {
      activity = label;
    });
    if(activity.contains("jogging")) {
      setState(() {
        activity = "Jogging";
        assetName = 'assets/Jogging.png';
      });
    } else if (activity.contains("standing")){
      setState(() {
        activity = "Standing";
        assetName = 'assets/Standing.png';
      });
    } else if (activity.contains("walking")){
      setState(() {
        activity = "Walking";
        assetName = 'assets/Walking.png';
      });
    }else if(activity.contains("sitting")) {
      setState(() {
        activity = "Sitting";
        assetName = 'assets/Sitting.png';
      });
    }else if(activity.contains('downstairs')) {
      setState(() {
        activity = "Downstairs";
        assetName = 'assets/Downstairs.png';
      });
    }else if(activity.contains("upstairs")) {
      setState(() {
        activity = "Upstairs";
        assetName = 'assets/Upstairs.png';
      });
    }else if(activity.contains("biking")) {
      setState(() {
        activity = "Biking";
        assetName = 'assets/Biking.png';
      });
    }
    semaphore = false;
    data.reinitialize();
  }*/


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.blue
        ),
        home: Scaffold(
          appBar: AppBar(title: const Center(child: Text("Activity prediction")),),
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Activity :", style: TextStyle(fontSize: 40, color: Colors.blue)),
                  Image.asset(assetName, width: 120, height: 120),
                  Text(activity, style: const TextStyle(color: Colors.deepOrange, fontSize: 30, fontWeight: FontWeight.w500)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("AX : ${sensorData.accX.length}", style: const TextStyle(fontSize: 23),),
                      Text("GX : ${sensorData.gyroX.length}", style: const TextStyle(fontSize: 23),),
                      Text("LX : ${sensorData.linAccX.length}", style: const TextStyle(fontSize: 23),),
                    ],
                  )
                ],
              )
          ),
        )
    );
  }
}

