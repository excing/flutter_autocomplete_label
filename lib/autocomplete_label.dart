library flutter_autocomplete_label;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_offset/flutter_widget_offset.dart';

/// The type of [AutocompleteLabel] callback,
/// which returns a widget that displays the specified label.
///
/// The label can be obtained in the [AutocompleteLabelController.values] attribute.
///
/// See also:
///
///   * [AutocompleteLabel.valueViewBuilder], which is of this type.
typedef ValueViewBuilder<T> = Widget Function(
  BuildContext context,
  ValueOnDeleted onDeleted,
  int index,
  T value,
);

/// The type of [AutocompleteLabel] callback.
/// It returns a widget that wraps all labels and input boxes [textField],
/// and can call [valueViewBuilder] to create a label widget.
///
/// See also:
///
///   * [AutocompleteLabel.valueBoxBuilder], which is of this type.
typedef ValueBoxBuilder<T> = Widget Function(
  BuildContext context,
  ValueOnDeleted onDeleted,
  ValueViewBuilder valueViewBuilder,
  Widget textField,
  Iterable<T> values,
);

/// The type of the callback used by the [AutocompleteLabel] widget to indicate
/// that the user has deleted an entered label.
///
/// See also:
///
///   * [AutocompleteLabel.onDeleted], which is of this type.
typedef ValueOnDeleted = void Function(int index);

/// The type of [AutocompleteLabel] callback,
/// which returns a widget that displays the specified option.
///
/// See also:
///
///   * [AutocompleteLabel.optionViewBuilder], which is of this type.
typedef OptionViewBuilder<T> = Widget Function(
  BuildContext context,
  OnSelected onSelected,
  int index,
  T option,
  bool isHighlight,
);

/// The type of [AutocompleteLabel] callback,
/// which returns a widget that wraps all options.
///
/// See also:
///
///   * [AutocompleteLabel.optionBoxBuilder], which is of this type.
typedef OptionBoxBuilder<T> = Widget Function(
  BuildContext context,
  OnSelected onSelected,
  OptionViewBuilder optionViewBuilder,
  Iterable<T> options,
  int highlightIndex,
  AxisDirection boxDirection,
);

/// The type of the callback used by the [AutocompleteLabel] widget to indicate
/// that the user has selected an option.
///
/// See also:
///
///   * [AutocompleteLabel.onSelected], which is of this type.
typedef OnSelected<T extends Object> = void Function(int index);

/// The type of the [AutocompleteLabel] callback
/// which computes the list of optional completions
/// for the widget's field based on the text the user has entered so far.
///
/// See also:
///
///   * [AutocompleteLabel.optionsBuilder], which is of this type.
typedef OptionsBuilder<T> = Iterable<T> Function(String text);

/// The type of the Autocomplete callback which returns the widget that
/// contains the input [TextField] or [TextFormField].
///
/// See also:
///
///   * [AutocompleteLabel.fieldViewBuilder], which is of this type.
typedef FieldViewBuilder = Widget Function(
  BuildContext context,
  TextEditingController textEditingController,
  FocusNode focusNode,
  VoidCallback onFieldSubmitted,
);

/// The type of the [AutocompleteLabel] callback
/// which computes the value of label
/// for the widget's field based on the text the user has entered so far.
///
/// See also:
///
///   * [AutocompleteLabel.valueBuilder], which is of this type.
typedef ValueBuilder<T> = T Function(String text);

/// The type of the [AutocompleteLabel] callback that converts an option value to
/// a string which can be displayed in the widget's options menu.
///
/// See also:
///
///   * [AutocompleteLabel.displayStringForOption], which is of this type.
typedef OptionToString<T> = String Function(T option);

/// The type of the callback used by the [AutocompleteLabel] widget to indicate
/// that the values has changed.
///
/// See also:
///
///   * [AutocompleteLabel.onChanged], which is of this type.
typedef OnChanged<T> = void Function(Iterable<T> values);

/// A controller for an editable autocomplete label field.
class AutocompleteLabelController<T> extends ChangeNotifier {
  AutocompleteLabelController({
    List<T>? source,
    List<T>? values,
  })  : this.source = source ?? [],
        this.values = values ?? [];

  static const none = -1;

  final List<T> source;
  final List<T> values;
  final List<T> options = [];

  int selectOptionIndex = none;

  bool get isSelectOption => none != selectOptionIndex;

  T? get selectOption =>
      none == selectOptionIndex ? null : options[selectOptionIndex];

  void add(T value) {
    values.add(value);
    selectOptionIndex = none;
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

  void upOption() {
    selectOptionIndex--;
    if (selectOptionIndex < 0) {
      selectOptionIndex = options.length - 1;
    }
  }

  void downOption() {
    selectOptionIndex++;
    if (options.length <= selectOptionIndex) {
      selectOptionIndex = 0;
    }
  }

  void cancelOption() {
    selectOptionIndex = none;
  }
}

class AutocompleteLabel<T> extends StatefulWidget {
  final ValueViewBuilder valueViewBuilder;
  final ValueBoxBuilder valueBoxBuilder;
  final OptionViewBuilder optionViewBuilder;
  final OptionBoxBuilder optionBoxBuilder;
  final FieldViewBuilder fieldViewBuilder;

  final AutocompleteLabelController autocompleteLabelController;
  final TextEditingController textEditingController;

  final OptionsBuilder? optionsBuilder;
  final ValueBuilder valueBuilder;
  final OptionToString displayStringForOption;

  final FocusNode focusNode;
  final OnChanged? onChanged;

  final double minOptionBoxHeight;
  final bool autoOptionHide;
  final VerticalDirection? optionBoxDirection;

  AutocompleteLabel({
    Key? key,
    this.valueViewBuilder = defaultValueViewBuilder,
    this.valueBoxBuilder = defaultValueBoxBuilder,
    this.optionViewBuilder = defaultOptionViewBuilder,
    this.optionBoxBuilder = defaultOptionBoxBuild,
    this.fieldViewBuilder = defaultFieldViewBuilder,
    AutocompleteLabelController? autocompleteLabelController,
    TextEditingController? textEditingController,
    this.optionsBuilder,
    this.valueBuilder = defaultValueBuilder,
    FocusNode? focusNode,
    this.onChanged,
    this.minOptionBoxHeight = 100,
    this.autoOptionHide = false,
    this.displayStringForOption = defaultStringForOption,
    this.optionBoxDirection,
  })  : this.focusNode = focusNode ?? FocusNode(),
        this.autocompleteLabelController =
            autocompleteLabelController ?? AutocompleteLabelController(),
        this.textEditingController =
            textEditingController ?? TextEditingController(),
        super(key: key);
  static const defaultFontSize = 16.0;

  static Widget defaultValueViewBuilder(BuildContext context,
      ValueOnDeleted onDeleted, int index, dynamic value) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onDeleted(index),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(value.toString(), style: TextStyle(fontSize: defaultFontSize)),
            Icon(
              Icons.close,
              size: defaultFontSize,
            ),
          ],
        ),
      ),
    );
  }

  static Widget defaultValueBoxBuilder(
    BuildContext context,
    ValueOnDeleted onDeleted,
    ValueViewBuilder valueViewBuilder,
    Widget textField,
    Iterable<dynamic> values,
  ) {
    List<Widget> valueItems = [];
    for (var i = 0; i < values.length; i++) {
      var value = values.elementAt(i);
      valueItems.add(valueViewBuilder(context, onDeleted, i, value));
    }
    valueItems.add(textField);

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
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
        runSpacing: 3,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.end,
        textDirection: TextDirection.ltr,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: valueItems,
      ),
    );
  }

  static Widget defaultOptionViewBuilder(BuildContext context,
      OnSelected onSelected, int index, dynamic option, bool isHighlight) {
    return InkWell(
      onTap: () => onSelected(index),
      child: Container(
        padding: EdgeInsets.all(10.0),
        color: isHighlight ? Colors.grey[350] : null,
        child: Text(option.toString()),
      ),
    );
  }

  static Widget defaultOptionBoxBuild(
    BuildContext context,
    OnSelected onSelected,
    OptionViewBuilder optionViewBuilder,
    Iterable<dynamic> options,
    int highlightIndex,
    AxisDirection boxDirection,
  ) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, index) {
        return optionViewBuilder(context, onSelected, index,
            options.elementAt(index), highlightIndex == index);
      },
    );
  }

  static Widget defaultFieldViewBuilder(
    BuildContext context,
    TextEditingController textEditingController,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 68),
      child: DryIntrinsicWidth(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: TextField(
            focusNode: focusNode,
            style: TextStyle(fontSize: AutocompleteLabel.defaultFontSize),
            strutStyle: StrutStyle(height: 1.0),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              isDense: true,
              border: InputBorder.none,
              hintText: "Write label",
            ),
            autofocus: true,
            controller: textEditingController,
            textInputAction: TextInputAction.next,
            onEditingComplete: onFieldSubmitted,
          ),
        ),
      ),
    );
  }

  static dynamic defaultValueBuilder(String value) {
    return value.trim();
  }

  /// The default way to convert an option to a string in
  /// [displayStringForOption].
  ///
  /// Simply uses the `toString` method on the option.
  static String defaultStringForOption(dynamic option) {
    return option.toString().trim();
  }

  @override
  State<StatefulWidget> createState() {
    return _AutocompleteLabelState();
  }
}

class _AutocompleteLabelState<T> extends State<AutocompleteLabel> {
  final LayerLink _layerLink = LayerLink();
  late OverlayEntry? _overlayEntry;

  double _overlayEntryWidth = 100.0;
  double _overlayEntryHeight = 100.0;
  double _overlayEntryY = double.minPositive;
  AxisDirection _overlayEntryDir = AxisDirection.down;

  late OffsetDetectorController _offsetDetectorController;

  bool isOpened = false;
  bool _isSelectOption = false;
  GlobalKey _textFieldKey = GlobalKey();

  void _openOptionBox() {
    if (this.isOpened) return;
    assert(this._overlayEntry != null);
    Overlay.of(context)!.insert(this._overlayEntry!);
    this.isOpened = true;
  }

  void _closeOptionBox() {
    if (!this.isOpened) return;
    assert(this._overlayEntry != null);
    this._overlayEntry!.remove();
    this.isOpened = false;
  }

  void _updateOptionBox() {
    if (!this.isOpened) return;
    assert(this._overlayEntry != null);
    this._overlayEntry!.markNeedsBuild();
  }

  @override
  void initState() {
    super.initState();

    widget.autocompleteLabelController.addListener(_handleValuesChanged);
    widget.textEditingController.addListener(_handleTextChanged);
    _offsetDetectorController = OffsetDetectorController();
    SchedulerBinding.instance!.addPostFrameCallback((duration) {
      if (mounted) {
        _overlayEntry = _createOverlayEntry();
      }
    });

    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant AutocompleteLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
    if (widget.autocompleteLabelController !=
        oldWidget.autocompleteLabelController) {
      oldWidget.autocompleteLabelController
          .removeListener(_handleValuesChanged);
      widget.autocompleteLabelController.addListener(_handleValuesChanged);
    }
    if (widget.textEditingController != oldWidget.textEditingController) {
      oldWidget.textEditingController.removeListener(_handleTextChanged);
      widget.textEditingController.addListener(_handleTextChanged);
    }
    SchedulerBinding.instance!.addPostFrameCallback((Duration _) {
      _updateOptionBox();
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.autocompleteLabelController.removeListener(_handleValuesChanged);
    widget.textEditingController.removeListener(_handleTextChanged);
    widget.focusNode.removeListener(_handleFocusChanged);
    _detachKeyboardIfAttached();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final optionsBox = Material(
          elevation: 2.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: _overlayEntryHeight,
            ),
            child: widget.optionBoxBuilder(
              context,
              _onSelected,
              widget.optionViewBuilder,
              widget.autocompleteLabelController.options,
              widget.autocompleteLabelController.selectOptionIndex,
              _overlayEntryDir,
            ),
          ),
        );
        final optionsBoxPositioned = Positioned(
            width: _overlayEntryWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              followerAnchor: _overlayEntryDir == AxisDirection.down
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              targetAnchor: Alignment.bottomLeft,
              offset: Offset(0.0, _overlayEntryY),
              child: optionsBox,
            ));
        return widget.autoOptionHide
            ? Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _closeOptionBox(),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  optionsBoxPositioned,
                ],
              )
            : optionsBoxPositioned;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget textField = widget.fieldViewBuilder(
        context, widget.textEditingController, widget.focusNode, () {
      _onEditingComplete();
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          // FocusScope.of(context).requestFocus(FocusNode());
          widget.focusNode.requestFocus();
        },
        child: OffsetDetector(
          controller: _offsetDetectorController,
          onChanged: _onBoxOffsetChanged,
          onKeyboard: _onKeyboardState,
          child: widget.valueBoxBuilder(
            context,
            _onDeleted,
            widget.valueViewBuilder,
            Container(
              key: _textFieldKey,
              child: textField,
            ),
            widget.autocompleteLabelController.values,
          ),
        ),
      ),
    );
  }

  void _onDeleted(int index) {
    widget.autocompleteLabelController.removeIndex(index);
  }

  void _onSelected(int index) {
    widget.autocompleteLabelController
        .add(widget.autocompleteLabelController.options[index]);
  }

  void _onBoxOffsetChanged(
      Size size, EdgeInsets offset, EdgeInsets rootPadding) {
    RenderBox? box =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || box.hasSize == false) {
      return;
    }

    double textFieldHeight = box.size.height;
    double cursorOffsetTop = offset.top + size.height - textFieldHeight;

    // print("cursorOffsetTop: $cursorOffsetTop, _courseHeight: $_courseHeight");
    if (widget.optionBoxDirection == VerticalDirection.down ||
        (widget.optionBoxDirection == null &&
            (widget.minOptionBoxHeight < offset.bottom ||
                cursorOffsetTop < offset.bottom))) {
      _overlayEntryHeight = offset.bottom - 5.0;
      _overlayEntryY = 1.0;
      _overlayEntryDir = AxisDirection.down;
    } else {
      _overlayEntryHeight = cursorOffsetTop - 5.0;
      _overlayEntryY = -textFieldHeight - 1.0;
      _overlayEntryDir = AxisDirection.up;
    }

    _overlayEntryWidth = size.width;

    _updateOptionBox();
  }

  void _handleOptionsBuilder(String text) {
    for (int i = 0; i < widget.autocompleteLabelController.source.length; i++) {
      var item = widget.autocompleteLabelController.source[i];
      if (widget
              .displayStringForOption(item)
              .toLowerCase()
              .contains(text.trim().toLowerCase()) &&
          !widget.autocompleteLabelController.values.contains(item)) {
        widget.autocompleteLabelController.options.add(item);
      }
    }
  }

  void _handleTextChanged() {
    if (_isSelectOption) {
      _isSelectOption = false;
      return;
    }

    widget.autocompleteLabelController.options.clear();
    widget.autocompleteLabelController.cancelOption();

    String value = widget.textEditingController.text;

    if (value == "") {
      _closeOptionBox();
      return;
    }

    final lastChar = value.substring(value.length - 1);
    if (lastChar == '\n' || lastChar == "," || lastChar == "，") {
      _onAddLabel(widget.valueBuilder(value.substring(0, value.length - 1)));
      return;
    }

    if (widget.optionsBuilder != null) {
      widget.autocompleteLabelController.options
          .addAll(widget.optionsBuilder!(value));
    } else {
      _handleOptionsBuilder(value);
    }

    if (0 < widget.autocompleteLabelController.options.length) {
      _openOptionBox();
      _offsetDetectorController.notifyStateChanged();
    }
  }

  void _onEditingComplete() {
    if (widget.autocompleteLabelController.isSelectOption) {
      _onAddLabel(widget.autocompleteLabelController.selectOption);
    } else if (widget.textEditingController.text.isNotEmpty) {
      _onAddLabel(widget.valueBuilder(widget.textEditingController.text));
    }
    FocusScope.of(context).requestFocus(widget.focusNode);
  }

  void _onAddLabel(T value) {
    _closeOptionBox();
    widget.autocompleteLabelController.add(value);
    widget.textEditingController.text = "";
  }

  void _selectOption() {
    _isSelectOption = true;
    final optionText = widget.displayStringForOption(
        widget.autocompleteLabelController.selectOption);
    widget.textEditingController.value = TextEditingValue(
      text: optionText,
      selection: TextSelection.collapsed(offset: optionText.length),
    );

    _updateOptionBox();
  }

  void _onKeyEvent(RawKeyEvent value) {
    _onKeyDownEvent(value);
    _onKeyUpEvent(value);
  }

  void _onKeyDownEvent(RawKeyEvent value) {
    if (!(value is RawKeyDownEvent)) return;

    if (widget.textEditingController.text == "" &&
        value.logicalKey == LogicalKeyboardKey.backspace) {
      widget.autocompleteLabelController.removeLast();
    } else if (value.logicalKey == LogicalKeyboardKey.escape) {
      if (!isOpened) return;
      if (widget.autocompleteLabelController.selectOptionIndex ==
          AutocompleteLabelController.none) {
        _closeOptionBox();
      } else {
        widget.autocompleteLabelController.cancelOption();
        assert(_overlayEntry != null);
        _overlayEntry!.markNeedsBuild();
      }
    }
  }

  void _onKeyUpEvent(RawKeyEvent value) {
    if (!(value is RawKeyUpEvent)) return;

    if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (!isOpened) return;
      widget.autocompleteLabelController.upOption();
      _selectOption();
    } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (!isOpened) return;
      widget.autocompleteLabelController.downOption();
      _selectOption();
    }
  }

  void _handleFocusChanged() {
    if (widget.focusNode.hasFocus)
      _attachKeyboardIfDetached();
    else
      _detachKeyboardIfAttached();
  }

  bool _listening = false;

  void _attachKeyboardIfDetached() {
    print("_attachKeyboardIfDetached");
    if (_listening) return;
    RawKeyboard.instance.addListener(_handleRawKeyEvent);
    _listening = true;
  }

  void _detachKeyboardIfAttached() {
    print("_detachKeyboardIfAttached");
    if (!_listening) return;
    RawKeyboard.instance.removeListener(_handleRawKeyEvent);
    _listening = false;
  }

  void _handleRawKeyEvent(RawKeyEvent event) {
    _onKeyEvent.call(event);
  }

  void _handleValuesChanged() {
    if (!mounted) return;
    _closeOptionBox();
    setState(() {});
    if (widget.onChanged != null) {
      widget.onChanged!(widget.autocompleteLabelController.values);
    }
    widget.textEditingController.text = "";
    _offsetDetectorController.notifyStateChanged();
  }

  void _onKeyboardState(bool state) {
    if (widget.autoOptionHide && !state) {
      widget.focusNode.unfocus();
      _closeOptionBox();
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
