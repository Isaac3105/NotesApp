import 'package:flutter/material.dart';
import 'package:notes_app/utils/dialogs/generic_dialog.dart';

Future<void> showEmailVerificationDialog(BuildContext context, String message) {
  return showGenericDialog(
    context: context,
    title: "Email Verification",
    content: message,
    optionsBuilder: () {
      return {"Ok": null};
    },
  );
}
