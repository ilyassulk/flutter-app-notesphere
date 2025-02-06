import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/NoteBloc.dart';
import '../models/Folder.dart';
import '../widgets/NoteCard.dart';
import '../widgets/SpeechRecordingWidget.dart';
import 'NoteSearchScreen.dart';
import 'SpeechRequestsScreen.dart';



/// Главный экран (просмотр заметок и папок)
class NoteHomeScreen extends StatelessWidget {
  const NoteHomeScreen({Key? key}) : super(key: key);

  void _showAddFolderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Новая папка', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Введите название папки',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  BlocProvider.of<NoteBloc>(context)
                      .add(AddFolderEvent(controller.text.trim()));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final bloc = BlocProvider.of<NoteBloc>(context);
    final folders = bloc.state.folders;
    if (folders.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text('Нет папок', style: TextStyle(color: Colors.white)),
            content: Text('Сначала создайте папку', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Выберите папку', style: TextStyle(color: Colors.white)),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: folders.map((folder) {
                return ListTile(
                  title: Text(folder.name, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    BlocProvider.of<NoteBloc>(context)
                        .add(AddNoteEvent(folder.id));
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showRenameFolderDialog(BuildContext context, Folder folder) {
    final TextEditingController controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Переименовать папку', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Новое название',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  BlocProvider.of<NoteBloc>(context)
                      .add(RenameFolderEvent(folder.id, controller.text.trim()));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteFolder(BuildContext context, Folder folder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Удалить папку?', style: TextStyle(color: Colors.white)),
          content: Text('Удаление папки удалит все заметки в ней.', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
              onPressed: () {
                BlocProvider.of<NoteBloc>(context)
                    .add(DeleteFolderEvent(folder.id));
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: Theme.of(context).primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NoteSphere', style: TextStyle(color: Theme.of(context).primaryColor)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.note_add),
            onPressed: () => _showAddNoteDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.create_new_folder),
            onPressed: () => _showAddFolderDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
              final state = BlocProvider.of<NoteBloc>(context).state;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteSearchScreen(notes: state.notes)),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          BlocBuilder<NoteBloc, NoteState>(
            builder: (context, state) {
              return ListView(
                padding: EdgeInsets.only(bottom: 120),
                children: [
                  Container(
                    color: Colors.grey[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Всё", style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text('${state.notes.length}', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  ...state.notes.map((note) => NoteCard(note: note)).toList(),
                  ...state.folders.map((folder) {
                    final folderNotes = state.notes
                        .where((note) => note.folderId == folder.id)
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            BlocProvider.of<NoteBloc>(context)
                                .add(ToggleFolderEvent(folder.id));
                          },
                          onLongPress: () async {
                            final result = await showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(100, 100, 100, 100),
                              items: [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                                ),
                              ],
                            );
                            if (result == 'rename') {
                              _showRenameFolderDialog(context, folder);
                            } else if (result == 'delete') {
                              _confirmDeleteFolder(context, folder);
                            }
                          },
                          child: Container(
                            color: Colors.grey[900],
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(folder.name, style: TextStyle(color: Colors.white, fontSize: 18)),
                                Row(
                                  children: [
                                    Text('${folderNotes.length}', style: TextStyle(color: Colors.white)),
                                    SizedBox(width: 8),
                                    Icon(
                                      folder.isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (folder.isExpanded)
                          ...folderNotes.map((note) => NoteCard(note: note)).toList(),
                      ],
                    );
                  }).toList(),
                ],
              );
            },
          ),
          // Плавающая кнопка микрофона
          Positioned(
            bottom: 60,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  isDismissible: false,
                  builder: (_) => SpeechRecordingWidget(),
                );
              },
              child: Icon(Icons.mic, color: Theme.of(context).primaryColor, size: 36),
            ),
          ),
          // Кнопка для перехода на экран запросов Speech-to-Text
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 - 20,
            child: IconButton(
              icon: Icon(Icons.list, color: Theme.of(context).primaryColor, size: 32),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SpeechRequestsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}