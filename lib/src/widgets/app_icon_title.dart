import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sublime/src/utilities/constants.dart';

class AppIconTitle extends StatelessWidget {
  const AppIconTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'lib/assets/images/app_icon.svg',
          width: 30,
          height: 30,
        ),
        const SizedBox(width: 4),
        const Text(
          appTitle,
          style: TextStyle(
            fontFamily: 'Lobster Two',
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
