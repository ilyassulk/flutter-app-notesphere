import 'package:flutter/material.dart';
import 'package:notesphere/NoteDetailScreen.dart';
import 'package:hive/hive.dart';

part 'Note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String? audioPath;

  Note({required this.title, required this.content, this.audioPath});
}

class NoteWidget extends StatelessWidget {
  final Note note;

  const NoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      leading: Icon(Icons.note),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailScreen(note: note),
          ),
        );
      },
    );
  }
}