import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FileListItem extends StatelessWidget {
  // The detail of a file
  final FileSystemEntity file;
  final Color? tileColor;
  final NumberFormat numberFormat = NumberFormat('###,###');

  FileListItem({super.key, required this.file, this.tileColor});
  // Can put functions here for stuff like filtering or formatting

  IconData _getIcon(FileSystemEntityType type) {
    if (type == FileSystemEntityType.file) {
      return FontAwesomeIcons.file;
    } else if (type == FileSystemEntityType.directory) {
      return FontAwesomeIcons.folder;
    }
    return FontAwesomeIcons.circle;
  }

  String _formatSize(int size) {
    if (size / 1024 < 1) {
      return '$size bytes';
    }
    return '${numberFormat.format(size / 1024)} KB';
  }

  String _formatDate(DateTime date) {
    DateFormat dateFormat = DateFormat.yMd().add_jm();
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: tileColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ListTile(
                title: Text(path.basename(file.path)),
                subtitle: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    _getIcon(file.statSync().type),
                    size: 16,
                    weight: 0.25,
                    color: const Color.fromARGB(255, 0, 132, 194),
                  ),
                  const SizedBox(width: 4.0),
                  Text(file.statSync().type.toString())
                ]),
                contentPadding: const EdgeInsets.all(8.0),
                hoverColor: const Color.fromARGB(255, 236, 120, 74),
                // mouseCursor: SystemMouseCursors.click,
                enabled: true,
              ),
            ),
            Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: _formatSize(file.statSync().size)));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('File size copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2)
                      ));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple.shade500,
                    side:
                        const BorderSide(color: Colors.transparent, width: 0.0),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  ),
                  child: Text(_formatSize(file.statSync().size),
                      style: const TextStyle(fontWeight: FontWeight.w400)),
                )),
            const SizedBox(width: 8.0),
            Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: _formatSize(file.statSync().size)));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Modified date copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2)
                      ));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple.shade500,
                    side:
                        const BorderSide(color: Colors.transparent, width: 0.0),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  ),
                  child: Text(_formatDate(file.statSync().modified),
                      style: const TextStyle(fontWeight: FontWeight.w400)),
                )),
          ],
        ));
  }
}
