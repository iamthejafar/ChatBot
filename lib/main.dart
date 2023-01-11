import 'package:flutter/material.dart';
import 'speech_screen.dart';
import 'package:http/http.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  TextToSpeech.initTTS();
  HttpOverrides.global = new MyHttpOverrides();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title : 'ChatGPT',
      debugShowCheckedModeBanner: false,
      home: SpeechScreen(),
    );
  }
}
