library flutter_auto_label_input;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  final List<T> source;
  final List<T> values;
  final List<T> suggestions = [];
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
  final TextStyle? textFieldStyle;
  final StrutStyle? textFieldStrutStyle;
  final String hintText;
  final bool autofocus;
  final FocusNode? focusNode;
  final OnChanged? onChanged;

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
    this.textFieldStyle,
    this.textFieldStrutStyle,
    this.hintText = "Add a label",
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AutoLabelInputState();
  }
}

class _AutoLabelInputState<T> extends State<AutoLabelInput> {
  final LayerLink _layerLink = LayerLink();
  late OverlayEntry? _overlayEntry;

  double _overlayEntryWidth = 100.0;
  double _overlayEntryHeight = 100.0;
  double _overlayEntryY = double.minPositive;
  AxisDirection _overlayEntryDir = AxisDirection.down;

  late AutoLabelInputController _autoLabelInputController;
  late TextEditingController _textEditingController;

  bool isOpened = false;

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

  @override
  void initState() {
    super.initState();

    _textEditingController =
        widget.textEditingController ?? TextEditingController();
    _autoLabelInputController =
        widget.autoLabelInputController ?? AutoLabelInputController<T>();
    WidgetsBinding.instance!.addPostFrameCallback((duration) {
      if (mounted) {
        _overlayEntry = _createOverlayEntry();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final suggestionsBox = Material(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: _overlayEntryHeight,
            ),
            child: Scrollbar(
              child: widget.suggestionBoxBuild != null
                  ? widget.suggestionBoxBuild!(
                      context, widget.suggestionBuild ?? _suggestionBuild)
                  : _suggestionBoxBuild(
                      context, widget.suggestionBuild ?? _suggestionBuild),
            ),
          ),
        );
        return Positioned(
            width: _overlayEntryWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, _overlayEntryY),
              child: _overlayEntryDir == AxisDirection.down
                  ? suggestionsBox
                  : FractionalTranslation(
                      translation:
                          Offset(0.0, -1.0), // visually flips list to go up
                      child: suggestionsBox,
                    ),
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
        child: OffsetDetector(
          onChanged: _onOffsetChanged,
          child: TextField(
            focusNode: widget.focusNode,
            style: widget.textFieldStyle,
            strutStyle: widget.textFieldStrutStyle,
            decoration: widget.textFieldDecoration ??
                InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                ),
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
    ));

    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.valueBoxBuild != null
          ? widget.valueBoxBuild!(context, valueItems)
          : _valueBoxBuild(context, valueItems),
    );
  }

  Widget _valueBuild(BuildContext context, int index) {
    return Text(_autoLabelInputController.values[index].toString());
  }

  Widget _valueBoxBuild(BuildContext context, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 1.0,
          style: BorderStyle.solid,
        )),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 13,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.end,
        textDirection: TextDirection.ltr,
        children: children,
      ),
    );
  }

  Widget _suggestionBuild(BuildContext context, int index) {
    return Text(_autoLabelInputController.suggestions[index].toString());
  }

  Widget _suggestionBoxBuild(
      BuildContext context, SuggestionBuild suggestionBuild) {
    return ListView.builder(
      itemCount: _autoLabelInputController.suggestions.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          child: suggestionBuild(context, index),
        );
      },
    );
  }

  void _onOffsetChanged(Size size, EdgeInsets offset, EdgeInsets rootPadding) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || box.hasSize == false) return;

    if (offset.top < offset.bottom) {
      _overlayEntryHeight = offset.bottom - 5.0;
      _overlayEntryY = box.size.height + 1.0;
      _overlayEntryDir = AxisDirection.down;
    } else {
      _overlayEntryHeight = offset.top;
      _overlayEntryY = box.size.height - size.height - 5.0;
      _overlayEntryDir = AxisDirection.up;
    }
  }

  bool _valueMatch(String text, T value) {
    return value.toString().toLowerCase().contains(text.trim().toLowerCase());
  }

  void _onInputChanged(String value) {
    _autoLabelInputController.suggestions.clear();

    if (value == "") {
      _closeSuggestionBox();
      return;
    }

    final lastChar = value.substring(value.length - 1);
    if (lastChar == '\n' || lastChar == "," || lastChar == "，") {
      _onAddLabel(value.substring(0, value.length - 1));
      return;
    }

    if (widget.onValueMatch != null) {
      widget.onValueMatch!(value);
    } else {
      for (int i = 0; i < _autoLabelInputController.source.length; i++) {
        if (_valueMatch(value, _autoLabelInputController.source[i])) {
          _autoLabelInputController.suggestions
              .add(_autoLabelInputController.source[i]);
        }
      }
    }

    if (0 < _autoLabelInputController.suggestions.length) _openSuggestionBox();
  }

  void _onEditingComplete() {
    if (_textEditingController.text.isNotEmpty)
      _onAddLabel(_textEditingController.text);
  }

  void _onAddLabel(String value) {
    _closeSuggestionBox();
    setState(() {
      if (widget.onValueAdder != null) {
        _autoLabelInputController.values.add(widget.onValueAdder!(value));
      } else {
        _autoLabelInputController.values.add(value.trim());
      }
    });
    _textEditingController.text = "";
    if (widget.onChanged != null) {
      widget.onChanged!(_autoLabelInputController.values);
    }
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
