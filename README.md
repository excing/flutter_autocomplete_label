# flutter_autocomplete_label

A widget of highly customizable of autocomplete label (tag) field（高度可定制的自动完成标签（标签）字段的小部件）.

- Support setting tag source
- Support pre-setting the selected label
- Support for creating text input box
- Support to create a list of optional tags
- Support to create a list of confirmed tags
- Support setting the vertical direction of the optional tag list
- And more

<img src="https://github.com/excing/flutter_autocomplete_label/raw/main/example/example.gif" alt="flutter_autocomplete_label example" width="100%">

```dart
AutocompleteLabel<String>(
  onChanged: (values) => print("$values"),
)
```
### Example

```dart
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

  bool _keepAutofocus = false;

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
            value: _keepAutofocus,
            onChanged: (value) {
              setState(() {
                _keepAutofocus = value;
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
                  keepAutofocus: _keepAutofocus,
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
```