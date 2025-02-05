import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/NoteBloc.dart';
import '../models/Note.dart';
import '../screens/NoteEditingScreen.dart';

/// Виджет для отображения карточки заметки
class NoteCard extends StatefulWidget {
  final Note note;
  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool showDelete = false;

  void _deleteNote() {
    BlocProvider.of<NoteBloc>(context)
        .add(DeleteNoteEvent(widget.note.id));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => NoteEditingScreen(note: widget.note)),
        );
      },
      onLongPress: () {
        setState(() {
          showDelete = true;
        });
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showDelete = false;
            });
          }
        });
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.note.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  '${widget.note.lastModified.toLocal()}'.split('.')[0],
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(widget.note.preview,
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          if (showDelete)
            Positioned(
              right: 24,
              top: 16,
              child: IconButton(
                icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                onPressed: _deleteNote,
              ),
            ),
        ],
      ),
    );
  }
}