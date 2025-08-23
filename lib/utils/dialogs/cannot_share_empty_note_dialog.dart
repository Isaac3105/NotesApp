import 'package:flutter/material.dart';
import 'package:to_do_app/utils/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: "You cannot share an empty note!",
    optionsBuilder: () => {"Ok": null},
  );
}
