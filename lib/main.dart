import 'dart:io';
import 'dart:ui';

import 'package:file_info/ui/widget/filelistitem.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';
import 'package:window_manager/window_manager.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    setWindowTitle('GetFileInfo2');

    windowManager.setMaximumSize(const Size(800, 600));
    windowManager.setMinimumSize(const Size(800, 480));
  }

  // Request permission for Android
  if (Platform.isAndroid) {
    PermissionStatus access = await Permission.manageExternalStorage.status;
    if (access.isDenied) {
      access = await Permission.manageExternalStorage.request();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GetFileInfo2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _directoryController = TextEditingController();
  // To manage focus state of widget
  final _focusNode = FocusNode();
  List<FileSystemEntity> _files = [];
  bool start = true;

  void _scanDirectory() async {
    String directoryPath = _directoryController.text;
    start = false;

    if (Platform.isAndroid) {
      directoryPath = './storage/emulated/0/${_directoryController.text}';
    }

    if (directoryPath == '' || directoryPath.characters.first == '.') {
      setState(() {
        _files = [];
      });
      return;
    }

    final directory = Directory(directoryPath);
    try {
      final filesList = directory.list();
      Iterable<FileSystemEntity> files = await filesList.toList();
      files = files.where((file) =>
          file.statSync().type == FileSystemEntityType.file ||
          file.statSync().type == FileSystemEntityType.directory);
      setState(() {
        _files = files.toList();
      });
    } catch (e) {
      // Handle errors, e.g., show a snackbar or dialog
      debugPrint(e.toString());
    }
  }

  void _updateTextField(String basename) {
    _directoryController.text = '${_directoryController.text}/$basename';
    _scanDirectory();
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        debugPrint(path.basename(file.path));
        // debugPrint(file.statSync().toString());
        return FileListItem(
          file: file,
          tileColor: index % 2 == 0 ? Colors.grey.shade200 : null,
          updatePath: _updateTextField,
        );
      },
      // physics: const BouncingScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: Platform.isWindows
          ? null
          : AppBar(
              // TRY THIS: Try changing the color here to a specific color (to
              // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
              // change color while the other colors stay the same.
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(widget.title),
            ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.deepPurple.shade600,
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      focusNode: _focusNode,
                      onSubmitted: (_) {
                        _scanDirectory();
                        // To maintain focus even after hitting enter
                        _focusNode.requestFocus();
                      },
                      cursorColor: Colors.white,
                      controller: _directoryController,
                      style: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                List<String> pathParts =
                                    _directoryController.text.split('/');
                                pathParts.removeLast();
                                String newPath = pathParts.join('/');
                                _directoryController.text = newPath;
                                _scanDirectory();
                              },
                              icon: const Icon(FontAwesomeIcons.arrowLeft), color: Colors.white),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0.35,
                                  style: BorderStyle.none)),
                          hintText: 'Enter directory path here',
                          hintStyle: TextStyle(
                              color: Colors.grey[300],
                              fontWeight: FontWeight.w300,
                              fontSize: 15),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                    ),
                  ),
                  const SizedBox(width: 8.0, height: 0),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0))),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 0.0)),
                      onPressed: _scanDirectory,
                      child: const Text('Scan'),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4.0),
              color: const Color.fromARGB(255, 208, 215, 255),
              child: Text(
                '${_files.length} item(s)',
                style: const TextStyle(
                    fontSize: 13.0, color: Color.fromARGB(221, 53, 53, 53)),
              ),
            ),
            Expanded(
                child: _files.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            start
                                ? const Text('')
                                : const Text('No file found in directory')
                          ])
                    : _buildList()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
