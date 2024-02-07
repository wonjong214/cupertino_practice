import 'package:camera/camera.dart';
import 'package:cupertino_practice/s_camera_view.dart';
import 'package:flutter/cupertino.dart';

late final List<CameraDescription> _cameras;

Future<void> main() async{
  // 앱이 실행되기 전에 필요한 초기화 작업을 수행하는 메서드
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        child: SafeArea(
          child: CameraView(cameras: _cameras,)
        ),
        navigationBar: CupertinoNavigationBar(
          middle: Text("Cupertino"),
        ),
      ),
    );
  }
}

/*
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// 사용가능한 카메라 장치의 목록을 저장하는 변수
late List<CameraDescription> _cameras;

Future<void> main() async {
  // 앱이 실행되기 전에 필요한 초기화 작업을 수행하는 메서드
  // main 함수에서만 호출 가능
  // 사용가능한 카메라를 확인하기 위함
  WidgetsFlutterBinding.ensureInitialized();

  // 사용 가능한 카메라 확인
  _cameras = await availableCameras();

  runApp(
    MaterialApp(
      home: Scaffold(
        body: const SafeArea(child: CameraApp()),
        // 바텀 네비게이션 바 정의
        bottomNavigationBar: BottomNavigationBar(items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "테스트1"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "테스트2"),
        ]),
      ),
    ),
  );
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => CameraAppState();
}

class CameraAppState extends State<CameraApp> {
  // 카메라 컨트롤러 인스턴스 생성
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    // 카메라 컨트롤러 초기화
    // _cameras[0] : 사용 가능한 카메라
    controller =
        CameraController(_cameras[0], ResolutionPreset.max, enableAudio: false);

    controller.initialize().then((_) {
      // 카메라가 작동되지 않을 경우
      if (!mounted) {
        return;
      }
      // 카메라가 작동될 경우
      setState(() {
        // 코드 작성
      });
    })
    // 카메라 오류 시
        .catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("CameraController Error : CameraAccessDenied");
            // Handle access errors here.
            break;
          default:
            print("CameraController Error");
            // Handle other errors here.
            break;
        }
      }
    });
  }

  // 사진을 찍는 함수
  Future<void> _takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }

    try {
      // 사진 촬영
      final XFile file = await controller.takePicture();

      */
