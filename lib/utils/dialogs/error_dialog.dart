import 'package:flutter/material.dart';
import 'package:to_do_app/utils/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String message,
) {
  return showGenericDialog(
    context: context,
    title: "An Error Ocurred",
    content: message,
    optionsBuilder: () {
      return {"Ok": null};
    },
  );
}