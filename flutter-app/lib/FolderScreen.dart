import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notesphere/Folder.dart';
import 'package:notesphere/Note.dart';
import 'package:notesphere/NewNoteScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(FolderAdapter());
  await Hive.openBox<Folder>('foldersBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Folders and Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FolderListScreen(),
    );
  }
}

class FolderListScreen extends StatefulWidget {
  const FolderListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FolderListScreen();
}

class _FolderListScreen extends State<FolderListScreen> {
  late List<Folder> folders;

  _FolderListScreen(){
    folders = readFolders();
  }

  Future<void> addFolder(String folderName) async {
    setState(() {
      var box = Hive.box<Folder>('foldersBox');
      final newFolder = Folder(name: folderName, notes: []);
      folders.add(newFolder);
      box.add(newFolder);
    });
  }

  List<Folder> readFolders() {
    var box = Hive.box<Folder>('foldersBox');
    return box.values.toList();
  }

  void updateFolder(int index, Folder folder){
    var box = Hive.box<Folder>('foldersBox');

    box.putAt(index, folder);
  }

  void deleteFolder(int index){
    var box = Hive.box<Folder>('foldersBox');
    box.deleteAt(index);
  }

  void closeBox(){
    Hive.box('foldersBox').close();
  }

  void showAddFolderDialog() {
    TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить папку'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: 'Введите название папки'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Добавить'),
              onPressed: () {
                String folderName = folderNameController.text;
                if (folderName.isNotEmpty) {
                  addFolder(folderName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void addNoteToFolder(Note note, String folderName) {
    setState(() {
      var box = Hive.box<Folder>('foldersBox');

      late int index;
      for (var i = 0; i < box.length; i++) {
        var currentFolder = box.getAt(i)!;
        if (currentFolder.name == folderName) {
          index = box.keyAt(i);
          break;
        }
      }



      Folder updatedFolder = box.getAt(index)!;
      updatedFolder.notes.add(note);
      updateFolder(index, updatedFolder);
    });
  }

  void navigateToCreateNoteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewNoteScreen(folders: folders),
      ),
    );

    if (result != null) {
      addNoteToFolder(result['note'], result['folderName']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folders'),
        actions: [
          MaterialButton(onPressed: (){
            setState(() {
              showAddFolderDialog();
            });
          },
          child: Icon(Icons.create_new_folder_rounded),)
        ],
      ),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          return FolderWidget(folder: folders[index]);
        },
      ),
        floatingActionButton: FloatingActionButton(
                onPressed: navigateToCreateNoteScreen,
                tooltip: 'Add new note',
                child: const Icon(Icons.mic),
              ),
    );
  }
}
