import 'package:flutter/material.dart';
import 'package:to_do_app/utils/dialogs/generic_dialog.dart';

Future<bool> showDeleteNoteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Delete Note",
    content: "Are you sure you want to delete this note?",
    optionsBuilder: () {
      return {"Cancel": false, "Yes": true};
    },
  ).then((value) => value ?? false);
}
