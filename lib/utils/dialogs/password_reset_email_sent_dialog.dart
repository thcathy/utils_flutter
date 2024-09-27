import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showPasswordResetSentDialog({
  required BuildContext context
}) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content: 'An email is sent for password reset',
    optionsBuilder: () => { 'OK': null },
  );
}
