import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/NoteBloc.dart';
import '../models/Note.dart';



/// Экран редактирования заметки
class NoteEditingScreen extends StatefulWidget {
  final Note note;
  const NoteEditingScreen({Key? key, required this.note}) : super(key: key);

  @override
  _NoteEditingScreenState createState() => _NoteEditingScreenState();
}

class _NoteEditingScreenState extends State<NoteEditingScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController tagController;
  bool isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);
    tagController = TextEditingController();
  }

  void _saveNote() {
    final updatedNote = Note(
      id: widget.note.id,
      folderId: widget.note.folderId,
      title: titleController.text.trim(),
      content: contentController.text,
      lastModified: DateTime.now(),
      tags: widget.note.tags,
    );
    BlocProvider.of<NoteBloc>(context).add(UpdateNoteEvent(updatedNote));
    Navigator.of(context).pop();
  }

  void _deleteNote() {
    BlocProvider.of<NoteBloc>(context).add(DeleteNoteEvent(widget.note.id));
    Navigator.of(context).pop();
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Добавить тег", style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: TextField(
            controller: tagController,
            decoration: InputDecoration(hintText: "Введите тег"),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
                tagController.clear();
              },
            ),
            TextButton(
              child: Text("Добавить"),
              onPressed: () {
                if (tagController.text.trim().isNotEmpty) {
                  setState(() {
                    if (widget.note.tags.isNotEmpty) {
                      widget.note.tags.add(tagController.text.trim());
                    }
                    else {
                      widget.note.tags = [tagController.text.trim()];
                    }
                  });
                }
                print(widget.note.tags);
                Navigator.of(context).pop();
                tagController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isEditingTitle = true;
                });
              },
              child: isEditingTitle
                  ? TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                autofocus: true,
                onSubmitted: (_) {
                  setState(() {
                    isEditingTitle = false;
                  });
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                ),
              )
                  : Text(
                titleController.text,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Последнее изменение: ${widget.note.lastModified.toLocal()}'.split('.')[0],
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ...widget.note.tags.map((tag) => Chip(
                  label: Text(tag, style: TextStyle(color: Colors.white)),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                  deleteIcon: Icon(Icons.close, size: 18, color: Colors.white),
                  onDeleted: () {
                    setState(() {
                      widget.note.tags.remove(tag);
                    });
                  },
                )),
                // Кнопка "+"

                IconButton(
                  onPressed: _showAddTagDialog,
                  icon: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),


            SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: contentController,
                style: TextStyle(color: Colors.white),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Начните вводить заметку...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                  onPressed: _deleteNote,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}