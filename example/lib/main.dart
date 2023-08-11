// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

const Color themeColor = Color(0xff00bc56);

String? packageVersion;

void main() {
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  AssetPicker.registerObserve();
  // Enables logging with the photo_manager.
  PhotoManager.setLog(true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DLHome(),
    );
  }
}

class DLHome extends StatefulWidget {
  const DLHome({super.key});

  @override
  State<DLHome> createState() => _DLHomeState();
}

class _DLHomeState extends State<DLHome> {
  Uint8List? imageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('相册'),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Container(
              width: 200,
              height: 200,
              color: Colors.red,
              child: imageData != null
                  ? Image.memory(
                      imageData!,
                      fit: BoxFit.cover,
                    )
                  : Container(),
            ),
          ),
          GestureDetector(
            onTap: () {
              AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  textDelegate: const AssetPickerTextDelegate(),
                  enterClip: false,
                  requestType: RequestType.image,
                  pickerTheme: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                    primaryColor: Colors.white,
                    dividerColor: const Color(0xFFC9CDD4),
                    disabledColor: const Color(0xFFF2F3F5),
                    unselectedWidgetColor: Colors.white,
                    colorScheme: const ColorScheme(
                      brightness: Brightness.light,
                      primary: Colors.black,
                      onPrimary: Colors.black,
                      secondary: Color(0xFF725BFF),
                      onSecondary: Colors.black,
                      error: Colors.red,
                      onError: Colors.red,
                      background: Colors.white,
                      onBackground: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.white,
                    ),
                    textTheme: const TextTheme(
                        bodySmall: TextStyle(
                          color: Color(0xFF86909C),
                        ),
                        labelLarge: TextStyle(color: Color(0xFF1D2129))),
                    appBarTheme: const AppBarTheme(
                        systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.dark,
                    )),
                  ),
                  maxAssets: 9,
                  //maxAssetsCount,
                  // selectedAssets: assets,
                  specialPickerType: SpecialPickerType.noPreview,
                ),
              ).then((value) {
                print('************************ $value');
                if (value is Uint8List) {
                  setState(() {
                    imageData = value;
                  });
                }
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                '选择',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
