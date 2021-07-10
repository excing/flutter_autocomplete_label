import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_label_input/auto_label_input.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoLabelInput Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AutoLabelInput Example Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AutoLabelInputController _autoLabelInputController =
      AutoLabelInputController<String>(source: [
    "Android",
    "iOS",
    "Flutter",
    "Windows",
    "Web",
    "Fuchsia",
    "Dart",
    "Golang",
    "Java",
    "Python",
    "Ruby",
    "c/c++",
    "Kotlin",
    "Swift",
    "HTML",
    "CSS",
    "JavaScript",
    "PHP",
    "GitHub",
    "Google",
    "Facebook",
    "KnowlGraph",
    "Twitter",
    "Tiktok",
    "StackOverflow",
    "WeiXin",
    "Alibaba",
    "youtube",
  ]);

  @override
  void dispose() {
    _autoLabelInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: AutoLabelInput<String>(
                  autoLabelInputController: _autoLabelInputController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
