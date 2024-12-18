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
  final Function? updatePath;
  final NumberFormat numberFormat = NumberFormat('###,###');

  FileListItem(
      {super.key, required this.file, this.tileColor, this.updatePath});
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
    if (size == 0) {
      return '-';
    } else if (size / 1024 < 1) {
      return '$size bytes';
    }
    return '${numberFormat.format(size / 1024)} KB';
  }

  String _formatDate(DateTime date) {
    DateFormat dateFormat = DateFormat('MM/dd/yyyy hh:mm a');
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    int fileSize = file.statSync().size;
    DateTime modifiedDate = file.statSync().modified;
    FileSystemEntityType fileType = file.statSync().type;

    return Container(
        color: tileColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ListTile(
                onTap: () {
                  if (fileType == FileSystemEntityType.directory) {
                    updatePath!(path.basename(file.path));
                  }
                },
                title: Text(path.basename(file.path)),
                subtitle: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    _getIcon(fileType),
                    size: 16,
                    weight: 0.25,
                    color: const Color.fromARGB(255, 0, 132, 194),
                  ),
                  const SizedBox(width: 4.0),
                  Text(fileType.toString())
                ]),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatSize(fileSize)),
                    Text(_formatDate(modifiedDate)),
                  ],
                ),
                // contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                contentPadding: const EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
                hoverColor: const Color.fromARGB(255, 120, 90, 228),
                mouseCursor: fileType == FileSystemEntityType.directory
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                enabled: true,
              ),
            ),
            Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: _formatSize(fileSize)));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2)));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple.shade500,
                    backgroundColor: Colors.white,
                    side:
                        const BorderSide(color: Colors.deepPurple, width: 1.25),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  ),
                  child: const Text('File size',
                      style: TextStyle(fontWeight: FontWeight.w400)),
                )),
            const SizedBox(width: 8.0),
            Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: _formatDate(modifiedDate)));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2)));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple.shade500,
                    backgroundColor: Colors.white,
                    side:
                        const BorderSide(color: Colors.deepPurple, width: 1.25),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  ),
                  child: const Text('Modified date',
                      style: TextStyle(fontWeight: FontWeight.w400)),
                )),
          ],
        ));
  }
}
