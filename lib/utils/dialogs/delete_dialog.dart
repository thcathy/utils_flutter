import 'package:flutter/cupertino.dart';

import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context, String content) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Confirm delete',
    content: content,
    optionsBuilder: () => {
      'Cancel': false,
      'Ok': true
    },
  ).then((value) => value ?? false);
}
