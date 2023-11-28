import 'package:flutter/material.dart';
import 'package:wise_bean/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: "Something went wrong",
    content: text,
    optionsBuilder: () => {
      'OK' : null,

    },
  );
}
