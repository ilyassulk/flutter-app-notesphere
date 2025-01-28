import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:notesphere/Note.dart';


class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key,  required this.note});

  @override
  State<StatefulWidget> createState() => _NoteDetailScreen(note: note);
}

class _NoteDetailScreen extends State<NoteDetailScreen> {
  final Note note;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isRecording = false;
  bool isPlaying = false;

  _NoteDetailScreen({ required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
      ),
      body: Column(
          children: [
          if (note.audioPath != null)
        MaterialButton(
        onPressed: () async {
      if (audioPlayer.playing){
        audioPlayer.stop();
        setState(() {
          isPlaying = false;
        });
      } else {
        await audioPlayer.setFilePath(note.audioPath!);
        audioPlayer.play();
        setState(() {
          isPlaying = true;
        });
      }
    },
    child: Text(isPlaying ? "Stop playing" : "Start playing"),
    ),
    Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          note.content,
          style: TextStyle(fontSize: 16.0),
        ),
      ),]
    )
    );
  }
}