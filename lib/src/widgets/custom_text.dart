import 'package:flutter/material.dart';

/// [CustomText] is a substitute for [Text] when [maxLines] is 1
/// [overflow: TextOverflow.ellipsis] in [Text] cuts whole words instead of
/// characters wasting a lot of space.
/// https://github.com/flutter/flutter/issues/18761
/// Working around by using [CustomText] instead of [Text] which leads to
/// another problem of compromising several [FontFeature] functionalities.
// TODO: 11/2/2021 Change it when the text overflow ellipsis issue is resolved
class CustomText extends Text {
  const CustomText(
    String data, {
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    TextOverflow? overflow = TextOverflow.ellipsis,
    double? textScaleFactor,
    String? semanticsLabel,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
  }) : super(
          data,
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: false,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: 1,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
        );

  @override
  String? get data => super.data == null
      ? null
      : Characters(super.data!).toList().join("\u{200B}");
}
