import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LabelInputStyle {}

class LabelValueStyle {}

class LabelValueBoxStyle {
  /// see [Container.alignment]
  final AlignmentGeometry? alignment;

  /// see [Container.padding]
  final EdgeInsets padding;

  /// see [Container.color]
  final Color? color;

  /// see [Container.decoration]
  final Decoration? decoration;

  /// see [Container.foregroundDecoration]
  final Decoration? foregroundDecoration;

  /// see [Container.constraints]
  final BoxConstraints? constraints;
  final double? width;
  final double? height;

  /// see [Container.margin]
  final EdgeInsetsGeometry? margin;

  /// see [Container.transform]
  final Matrix4? transform;

  /// see [Container.transformAlignment]
  final AlignmentGeometry? transformAlignment;

  /// see [Container.clipBehavior]
  final Clip clipBehavior;

  const LabelValueBoxStyle({
    this.alignment,
    this.padding = const EdgeInsets.all(5.0),
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });

  const LabelValueBoxStyle.styleDefault({
    this.alignment,
    this.padding = const EdgeInsets.all(10.0),
    this.color,
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      border: Border(
          bottom: BorderSide(
        color: Colors.grey,
        width: 1.0,
        style: BorderStyle.solid,
      )),
    ),
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });
}

class LabelOptionStyle {}

class LabelOptionBoxStyle {}
