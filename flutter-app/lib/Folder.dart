import 'package:flutter/material.dart';
import 'package:notesphere/Note.dart';
import 'package:hive/hive.dart';

part 'Folder.g.dart';

@HiveType(typeId: 1)
class Folder {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<Note> notes;

  Folder({required this.name, this.notes = const []});
}

class FolderWidget extends StatelessWidget {
  final Folder folder;

  const FolderWidget({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(folder.name),
      leading: Icon(Icons.folder),
      children: folder.notes.map((note) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: NoteWidget(note: note),
      )).toList(),
    );
  }
}
