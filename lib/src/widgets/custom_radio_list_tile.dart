import 'package:flutter/material.dart';

/// [CustomRadioListTile] is a substitute for [RadioListTile] because
/// [RadioListTile] lets you click on the radio button separately and it does
/// not show ink splash on the list tile when the radio button is clicked.
// TODO: 2/15/2022 Change it when the radio list tile issue is resolved
class CustomRadioListTile extends ListTile {
  CustomRadioListTile({
    Key? key,
    Widget? title,
    GestureTapCallback? onTap,
    required Object value,
    Object? groupValue,
  }) : super(
          key: key,
          leading: AbsorbPointer(
            child: Radio(
              visualDensity: VisualDensity.compact,
              value: value,
              groupValue: groupValue,
              onChanged: (value) {},
            ),
          ),
          title: title,
          onTap: onTap,
        );
}
