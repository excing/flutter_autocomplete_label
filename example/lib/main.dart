import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_autocomplete_label/autocomplete_label.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutocompleteLabel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AutocompleteLabel Example Home Page'),
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
  final AutocompleteLabelController _autocompleteLabelController =
  AutocompleteLabelController<String>(source: [
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

  bool _autoOptionHide = false;

  @override
  void dispose() {
    _autocompleteLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Switch(
            value: _autoOptionHide,
            onChanged: (value) {
              setState(() {
                _autoOptionHide = value;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: AutocompleteLabel<String>(
                  autoOptionHide: _autoOptionHide,
                  onChanged: (values) => print("$values"),
                  autocompleteLabelController: _autocompleteLabelController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
