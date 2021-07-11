library flutter_auto_label_input;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_offset/flutter_widget_offset.dart';

typedef ValueBuild = Widget Function(
  BuildContext context,
  int index,
);

typedef ValueBoxBuild = Widget Function(
  BuildContext context,
  List<Widget> children,
);

typedef SuggestionBuild = Widget Function(
  BuildContext context,
  int index,
);

typedef SuggestionBoxBuild = Widget Function(
  BuildContext context,
  SuggestionBuild suggestionBuild,
);

typedef ValueMatch = bool Function(String text);
typedef ValueAdder<T> = T Function(String text);

typedef OnChanged<T> = void Function(List<T> labels);

class AutoLabelInputController<T> extends ChangeNotifier {
  AutoLabelInputController({
    List<T>? source,
    List<T>? values,
  })  : this.source = source ?? [],
        this.values = values ?? [];

  static const none = -1;

  final List<T> source;
  final List<T> values;
  final List<T> suggestions = [];

  int selectSuggestionIndex = none;

  bool get isSelectSuggestion => none != selectSuggestionIndex;

  T? get selectSuggestion =>
      none == selectSuggestionIndex ? null : suggestions[selectSuggestionIndex];

  void add(T value) {
    values.add(value);
    selectSuggestionIndex = none;
    notifyListeners();
  }

  void remove(T value) {
    values.remove(value);
    notifyListeners();
  }

  void removeIndex(int i) {
    remove(values[i]);
  }

  void removeLast() {
    if (0 == values.length) return;
    values.removeLast();
    notifyListeners();
  }

  void upSuggestion() {
    selectSuggestionIndex--;
    if (selectSuggestionIndex < 0) {
      selectSuggestionIndex = suggestions.length - 1;
    }
  }

  void downSuggestion() {
    selectSuggestionIndex++;
    if (suggestions.length <= selectSuggestionIndex) {
      selectSuggestionIndex = 0;
    }
  }

  void cancelSuggestion() {
    selectSuggestionIndex = none;
  }
}

class AutoLabelInput<T> extends StatefulWidget {
  final ValueBuild? valueBuild;
  final ValueBoxBuild? valueBoxBuild;
  final SuggestionBuild? suggestionBuild;
  final SuggestionBoxBuild? suggestionBoxBuild;

  final AutoLabelInputController? autoLabelInputController;
  final TextEditingController? textEditingController;
  final ValueMatch? onValueMatch;
  final ValueAdder? onValueAdder;

  final InputDecoration? textFieldDecoration;
  final EdgeInsetsGeometry? textFieldPadding;
  final TextStyle? textFieldStyle;
  final StrutStyle? textFieldStrutStyle;
  final String hintText;
  final bool autofocus;
  final FocusNode? focusNode;
  final OnChanged? onChanged;
  final double minSuggestionBoxHeight;

  AutoLabelInput({
    Key? key,
    this.valueBuild,
    this.valueBoxBuild,
    this.suggestionBuild,
    this.suggestionBoxBuild,
    this.autoLabelInputController,
    this.textEditingController,
    this.onValueMatch,
    this.onValueAdder,
    this.textFieldDecoration,
    this.textFieldPadding,
    this.textFieldStyle,
    this.textFieldStrutStyle,
    this.hintText = "Add a label",
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
    this.minSuggestionBoxHeight = 100,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AutoLabelInputState();
  }
}

class _AutoLabelInputState<T> extends State<AutoLabelInput> {
  static const defaultFontSize = 16.0;

  final LayerLink _layerLink = LayerLink();
  late OverlayEntry? _overlayEntry;

  double _overlayEntryWidth = 100.0;
  double _overlayEntryHeight = 100.0;
  double _overlayEntryY = double.minPositive;
  AxisDirection _overlayEntryDir = AxisDirection.down;

  late AutoLabelInputController _autoLabelInputController;
  late TextEditingController _textEditingController;
  late OffsetDetectorController _offsetDetectorController;

  late InputDecoration _textFieldDecoration;
  late EdgeInsetsGeometry _textFieldPadding;
  late TextStyle _textFieldStyle;
  late StrutStyle? _textFieldStrutStyle;

  bool isOpened = false;

  double get _courseHeight =>
      // final line height of fontSize * (height + leading) + padding.vertical logical pixels.
      (_textFieldStrutStyle != null
          ? (_textFieldStrutStyle!.fontSize ??
                  _textFieldStyle.fontSize ??
                  defaultFontSize) *
              ((_textFieldStrutStyle!.height ?? 1.0) +
                  (_textFieldStrutStyle!.leading ?? 1.0))
          : (_textFieldStyle.fontSize ?? defaultFontSize)) +
      (_textFieldDecoration.contentPadding?.vertical ?? 0) +
      _textFieldPadding.vertical;

  void _openSuggestionBox() {
    if (this.isOpened) return;
    assert(this._overlayEntry != null);
    Overlay.of(context)!.insert(this._overlayEntry!);
    this.isOpened = true;
  }

  void _closeSuggestionBox() {
    if (!this.isOpened) return;
    assert(this._overlayEntry != null);
    this._overlayEntry!.remove();
    this.isOpened = false;
  }

  void _updateSuggestionBox() {
    if (!this.isOpened) return;
    assert(this._overlayEntry != null);
    this._overlayEntry!.markNeedsBuild();
  }

  @override
  void initState() {
    super.initState();

    _textFieldDecoration = widget.textFieldDecoration ??
        InputDecoration(
          contentPadding: EdgeInsets.zero,
          isDense: true,
          border: InputBorder.none,
          hintText: widget.hintText,
        );
    _textFieldPadding = widget.textFieldPadding ?? EdgeInsets.all(3);
    _textFieldStyle =
        widget.textFieldStyle ?? TextStyle(fontSize: defaultFontSize);
    _textFieldStrutStyle =
        widget.textFieldStrutStyle ?? StrutStyle(height: 1.5);

    _textEditingController =
        widget.textEditingController ?? TextEditingController();
    _autoLabelInputController =
        widget.autoLabelInputController ?? AutoLabelInputController<T>();
    _autoLabelInputController.addListener(_handleValuesChanged);
    _offsetDetectorController = OffsetDetectorController();
    WidgetsBinding.instance!.addPostFrameCallback((duration) {
      if (mounted) {
        _overlayEntry = _createOverlayEntry();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AutoLabelInput oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _autoLabelInputController.removeListener(_handleValuesChanged);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final suggestionsBox = Material(
          elevation: 2.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: _overlayEntryHeight,
            ),
            child: widget.suggestionBoxBuild != null
                ? widget.suggestionBoxBuild!(
                    context, widget.suggestionBuild ?? _suggestionBuild)
                : _suggestionBoxBuild(
                    context, widget.suggestionBuild ?? _suggestionBuild),
          ),
        );
        return Positioned(
            width: _overlayEntryWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              followerAnchor: _overlayEntryDir == AxisDirection.down
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              targetAnchor: Alignment.bottomLeft,
              offset: Offset(0.0, _overlayEntryY),
              child: suggestionsBox,
              // child: _overlayEntryDir == AxisDirection.down
              //     ? suggestionsBox
              //     : FractionalTranslation(
              //         translation:
              //             Offset(0.0, -1.0), // visually flips list to go up
              //         child: suggestionsBox,
              //       ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> valueItems = [];
    for (var i = 0; i < _autoLabelInputController.values.length; i++) {
      valueItems.add((widget.valueBuild ?? _valueBuild)(context, i));
    }

    valueItems.add(ConstrainedBox(
      constraints: BoxConstraints(minWidth: 68),
      child: DryIntrinsicWidth(
        child: RawKeyboardListener(
          focusNode: widget.focusNode ?? FocusNode(),
          onKey: _onKeyEvent,
          child: Padding(
            padding: _textFieldPadding,
            child: TextField(
              style: _textFieldStyle,
              strutStyle: _textFieldStrutStyle,
              decoration: _textFieldDecoration,
              autofocus: widget.autofocus,
              controller: _textEditingController,
              textInputAction: TextInputAction.next,
              onChanged: _onInputChanged,
              onEditingComplete: () {
                _onEditingComplete();
                FocusScope.of(context).requestFocus();
              },
            ),
          ),
        ),
      ),
    ));

    return CompositedTransformTarget(
      link: _layerLink,
      child: OffsetDetector(
        controller: _offsetDetectorController,
        onChanged: _onBoxOffsetChanged,
        child: widget.valueBoxBuild != null
            ? widget.valueBoxBuild!(context, valueItems)
            : _valueBoxBuild(context, valueItems),
      ),
    );
  }

  Widget _valueBuild(BuildContext context, int index) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(_autoLabelInputController.values[index].toString(),
            style: TextStyle(fontSize: defaultFontSize)),
        InkWell(
          onTap: () => _autoLabelInputController.removeIndex(index),
          child: Padding(
            padding: EdgeInsets.all(3),
            child: Icon(
              Icons.close,
              size: defaultFontSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _valueBoxBuild(BuildContext context, List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 1.0,
          style: BorderStyle.solid,
        )),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.end,
        textDirection: TextDirection.ltr,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }

  Widget _suggestionBuild(BuildContext context, int index) {
    return Container(
      padding: EdgeInsets.all(6.0),
      color: _autoLabelInputController.selectSuggestionIndex == index
          ? Colors.grey[350]
          : Colors.white,
      child: Text(_autoLabelInputController.suggestions[index].toString()),
    );
  }

  Widget _suggestionBoxBuild(
      BuildContext context, SuggestionBuild suggestionBuild) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      reverse: _overlayEntryDir != AxisDirection.down,
      itemCount: _autoLabelInputController.suggestions.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _autoLabelInputController
              .add(_autoLabelInputController.suggestions[index]),
          child: suggestionBuild(context, index),
        );
      },
    );
  }

  void _onBoxOffsetChanged(
      Size size, EdgeInsets offset, EdgeInsets rootPadding) {
    var cursorOffsetTop = offset.top + size.height - _courseHeight;

    // print("cursorOffsetTop: $cursorOffsetTop, _courseHeight: $_courseHeight");
    if (widget.minSuggestionBoxHeight < offset.bottom ||
        cursorOffsetTop < offset.bottom) {
      _overlayEntryHeight = offset.bottom - 5.0;
      _overlayEntryY = 1.0;
      _overlayEntryDir = AxisDirection.down;
    } else {
      _overlayEntryHeight = cursorOffsetTop - 5.0;
      _overlayEntryY = -_courseHeight - 1.0;
      _overlayEntryDir = AxisDirection.up;
    }

    _overlayEntryWidth = size.width;

    _updateSuggestionBox();
  }

  bool _valueMatch(String text, T value) {
    return value.toString().toLowerCase().contains(text.trim().toLowerCase());
  }

  void _onInputChanged(String value) {
    _autoLabelInputController.suggestions.clear();
    _autoLabelInputController.cancelSuggestion();

    if (value == "") {
      _closeSuggestionBox();
      return;
    }

    final lastChar = value.substring(value.length - 1);
    if (lastChar == '\n' || lastChar == "," || lastChar == "，") {
      _onAddLabel(widget.onValueAdder != null
          ? widget.onValueAdder!(_textEditingController.text)
          : value.substring(0, value.length - 1).trim());
      return;
    }

    if (widget.onValueMatch != null) {
      widget.onValueMatch!(value);
    } else {
      for (int i = 0; i < _autoLabelInputController.source.length; i++) {
        var item = _autoLabelInputController.source[i];
        if (_valueMatch(value, item) &&
            !_autoLabelInputController.values.contains(item)) {
          _autoLabelInputController.suggestions.add(item);
        }
      }
    }

    if (0 < _autoLabelInputController.suggestions.length) {
      _openSuggestionBox();
      _offsetDetectorController.notifyStateChanged();
    }
  }

  void _onEditingComplete() {
    if (_autoLabelInputController.isSelectSuggestion) {
      _onAddLabel(_autoLabelInputController.selectSuggestion);
    } else if (_textEditingController.text.isNotEmpty)
      _onAddLabel(widget.onValueAdder != null
          ? widget.onValueAdder!(_textEditingController.text)
          : _textEditingController.text.trim());
  }

  void _onAddLabel(T value) {
    _closeSuggestionBox();
    _autoLabelInputController.add(value);
    _textEditingController.text = "";
  }

  void _selectSuggestion() {
    final suggestionText =
        _autoLabelInputController.selectSuggestion.toString();
    _textEditingController.value = TextEditingValue(
      text: suggestionText,
      selection: TextSelection.collapsed(offset: suggestionText.length),
    );

    _updateSuggestionBox();
  }

  void _onKeyEvent(RawKeyEvent value) {
    _onKeyDownEvent(value);
    _onKeyUpEvent(value);
  }

  void _onKeyDownEvent(RawKeyEvent value) {
    if (!(value is RawKeyDownEvent)) return;

    if (_textEditingController.text == "" &&
        value.logicalKey == LogicalKeyboardKey.backspace) {
      _autoLabelInputController.removeLast();
    } else if (value.logicalKey == LogicalKeyboardKey.tab) {
      if (!isOpened) return;
      if (_autoLabelInputController.isSelectSuggestion) {
        _onAddLabel(_autoLabelInputController.selectSuggestion);
      }
    } else if (value.logicalKey == LogicalKeyboardKey.escape) {
      if (!isOpened) return;
      if (_autoLabelInputController.selectSuggestionIndex ==
          AutoLabelInputController.none) {
        _closeSuggestionBox();
      } else {
        _autoLabelInputController.cancelSuggestion();
        assert(_overlayEntry != null);
        _overlayEntry!.markNeedsBuild();
      }
    }
  }

  void _onKeyUpEvent(RawKeyEvent value) {
    if (!(value is RawKeyUpEvent)) return;

    if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (!isOpened) return;
      _autoLabelInputController.upSuggestion();
      _selectSuggestion();
    } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (!isOpened) return;
      _autoLabelInputController.downSuggestion();
      _selectSuggestion();
    }
  }

  void _handleValuesChanged() {
    if (!mounted) return;
    _closeSuggestionBox();
    setState(() {});
    if (widget.onChanged != null) {
      widget.onChanged!(_autoLabelInputController.values);
    }
    _textEditingController.text = "";
    _offsetDetectorController.notifyStateChanged();
  }
}

/// Same as `IntrinsicWidth` except that when this widget is instructed
/// to `computeDryLayout()`, it doesn't invoke that on its child, instead
/// it computes the child's intrinsic width.
///
/// This widget is useful in situations where the `child` does not
/// support dry layout, e.g., `TextField` as of 01/02/2021.
///
/// see [dry_layout_stop_gap.dart](https://gist.github.com/matthew-carroll/65411529a5fafa1b527a25b7130187c6)
class DryIntrinsicWidth extends SingleChildRenderObjectWidget {
  const DryIntrinsicWidth({Key? key, Widget? child})
      : super(key: key, child: child);

  @override
  _RenderDryIntrinsicWidth createRenderObject(BuildContext context) =>
      _RenderDryIntrinsicWidth();
}

class _RenderDryIntrinsicWidth extends RenderIntrinsicWidth {
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      final width = child!.computeMinIntrinsicWidth(constraints.maxHeight);
      final height = child!.computeMinIntrinsicHeight(width);
      return Size(width, height);
    } else {
      return Size.zero;
    }
  }
}
