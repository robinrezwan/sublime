import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageBackground extends StatelessWidget {
  final String assetName;
  final bool isSvgImage;
  final double? imageWidth;
  final double? imageHeight;
  final EdgeInsetsGeometry? imageMargin;
  final String title;
  final String? subtitle;

  const PageBackground({
    Key? key,
    required this.assetName,
    required this.isSvgImage,
    this.imageWidth,
    this.imageHeight,
    this.imageMargin,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: imageMargin,
            child: isSvgImage
                ? SvgPicture.asset(
                    assetName,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    assetName,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  subtitle != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption!.color),
            ),
        ],
      ),
    );
  }
}
