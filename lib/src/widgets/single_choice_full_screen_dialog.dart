import 'package:flutter/material.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';
import 'package:sublime/src/widgets/custom_radio_list_tile.dart';

class _SingleChoiceFullScreenDialog extends StatelessWidget {
  const _SingleChoiceFullScreenDialog({
    this.title,
    required this.itemList,
    this.selectedItem,
  });

  final Widget? title;
  final List<String> itemList;
  final String? selectedItem;

  @override
  Widget build(BuildContext context) {
    String? selectedValue =
        itemList.contains(selectedItem) ? selectedItem : null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomIconButton(
          icon: const Icon(CustomIcons.close),
          tooltip: "Close",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: title,
        actions: [
          CustomIconButton(
            icon: const Icon(CustomIcons.check),
            tooltip: "Done",
            onPressed: () {
              Navigator.pop(context, selectedValue);
            },
          ),
        ],
      ),
      body: StatefulBuilder(
        builder: (context, setDialogState) {
          return ListView.builder(
            itemCount: itemList.length,
            itemBuilder: (context, index) {
              return CustomRadioListTile(
                value: itemList.elementAt(index),
                groupValue: selectedValue,
                title: Text(itemList.elementAt(index)),
                onTap: () {
                  setDialogState(() {
                    selectedValue = itemList.elementAt(index);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

Future<String?> showSingleChoiceFullScreenDialog({
  required BuildContext context,
  Widget? title,
  required List<String> itemList,
  String? selectedItem,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _SingleChoiceFullScreenDialog(
        title: title,
        itemList: itemList,
        selectedItem: selectedItem,
      ),
    ),
  );
}
