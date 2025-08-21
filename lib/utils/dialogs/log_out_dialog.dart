import 'package:flutter/material.dart';
import 'package:to_do_app/utils/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Log Out",
    content: "Are you sure you want to log out?",
    optionsBuilder: () {
      return {"Cancel": false, "Yes": true};
    },
  ).then((value) => value ?? false);
}
