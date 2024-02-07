import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
//import 'package:path_provider/path_provider.dart';


const String baseUri = "http://43.201.9.0:8081";
const int targetWidth = 48;
const int targetHeight = 48;

class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraView({super.key, required this.cameras});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // 카메라 컨트롤러 인스턴스 생성
  late CameraController controller;
  bool isFrontCamera = false;
  bool isFlashOn = false;
  File? responseImage;

  void setCamera(bool isFront) {
    controller = CameraController(
        isFront ? widget.cameras.last : widget.cameras.first,
        ResolutionPreset.max,
        enableAudio: false);

    controller.initialize().then((_) {
      // 카메라가 작동되지 않을 경우
      if (!this.mounted) {
        print("이니셜라이즈 실패");
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

  @override
  void initState() {
    super.initState();
    // 사용 가능한 카메라 확인
    setCamera(isFrontCamera);
  }

  // 사진을 찍는 함수
  Future<void> _takePicture() async {
    if (!controller.value.isInitialized || controller == null) {
      return;
    }

    try {
      // 사진 촬영
      late final XFile? _reduceFile;
      late final File? _resizeFile;
      final file = await controller.takePicture();
      /*_reduceFile = await compressFile(file);
      if(_reduceFile != null) {
        _resizeFile = await resizeImage(_reduceFile!);
      }
      if(_resizeFile != null){
        await uploadImage(_resizeFile);
        setState(() {
          responseImage = _resizeFile;
        });
      }*/

      /*else
        return;*/


      /*//final bytes = await File(path).readAsBytes();
      //final img.Image? image = img.decodeImage(bytes);

      // import 'dart:io';
      // 사진을 저장할 경로 : 기본경로(storage/emulated/0/)
      Directory directory = Directory('storage/emulated/0/DCIM/MyImages');

      // 지정한 경로에 디렉토리를 생성하는 코드
      // .create : 디렉토리 생성    recursive : true - 존재하지 않는 디렉토리일 경우 자동 생성
      await Directory(directory.path).create(recursive: true);

      // 지정한 경로에 사진 저장
      await File(file.path).copy('${directory.path}/${file.name}');*/
    } catch (e) {
      print('Error taking picture: $e');
    }
  }
  Future<void> uploadImage(File file) async {

    try{
      // 파일 경로를 통해 formData 생성
      var dio = Dio();
      var formData = FormData.fromMap({
        'multipartFile' : await MultipartFile.fromFile(file.path)
      });

      // 업로드 요청
      final response = await dio.post(baseUri + '/image-upload', data: formData);
      if(response.statusCode != 200){
        print(await response.statusMessage);
      }
      print(response.data.toString());
      //dynamic imageMap = jsonDecode(response.data.toString());

      //print("upload response${imageMap['imageUrl']}");
      /*setState(() {
        responseImage = response.data;
      });*/

      return;
    }
    catch(e){
      print('Error taking picture: $e');
    }
  }

  /*Future<File?> resizeImage (XFile _image) async{
    late final img.Image resizedImage;
    final path = _image.path;
    final bytes = await File(path).readAsBytes();
    final img.Image? image = img.decodeImage(bytes);

    if(image != null){
      resizedImage = img.copyResize(image, width: targetWidth, height: targetHeight);
      String tempPath = (await getTemporaryDirectory()).path;
      return File(tempPath).writeAsBytes(img.encodePng(resizedImage));
    }
    else{
      return null;
    }

  }*/

  Future<XFile?> compressFile(XFile file) async {

    final filePath = file.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.path, outPath,
      quality: 5,
    );

    if(result != null)
    print(await result.length());
    //print(file.lengthSync());
    //print(result?lengthSync());

    return result;
  }


  @override
  void dispose() {
    // 카메라 컨트롤러 해제
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 카메라가 준비되지 않으면 아무것도 띄우지 않음
    if (!controller.value.isInitialized) {
      return SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: const Text('카메라 준비 안됨'),
        ),
      );
    }
    // 카메라 인터페이스와 위젯을 겹쳐 구성할 예정이므로 Stack 위젯 사용
    return Stack(
      children: [
        // 화면 전체를 차지하도록 Positioned.fill 위젯 사용
        Positioned.fill(
          // 카메라 촬영 화면이 보일 CameraPrivew
          child: CameraPreview(controller),
        ),
        // 하단 중앙에 위치도록 Align 위젯 설정
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              // 버튼 클릭 이벤트 정의를 위한 GestureDetector
              child: GestureDetector(
                onTap: () {
                  // 사진 찍기 함수 호출
                  _takePicture()
                      .then((value) => print("takepicutre finish"))
                      .catchError((Object e) {
                    print('Error during take picture: $e');
                  });
                },
                // 버튼으로 표시될 Icon
                child: const Icon(
                  CupertinoIcons.camera,
                  size: 70,
                  color: CupertinoColors.white,
                ),
              )),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GestureDetector(
              onTap: () {
                isFrontCamera = !isFrontCamera;
                setCamera(isFrontCamera);
              },
              child: const Icon(
                CupertinoIcons.camera_rotate,
                size: 30,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                  controller.setFlashMode(
                      isFlashOn ? FlashMode.always : FlashMode.off);
                });
              },
              child: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                size: 30,
              ),
            ),
          ),
        ),
        responseImage != null ? Align(
          alignment: Alignment.center,
          child: Image.file(
            responseImage!,
            width: 48,
            height: 48,
          ),
        ) : Container(width: 48, height: 48,)
      ],
    );
  }
}
