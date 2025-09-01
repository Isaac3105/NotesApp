import 'package:flutter/material.dart';
import 'package:notes_app/utils/dialogs/generic_dialog.dart';

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