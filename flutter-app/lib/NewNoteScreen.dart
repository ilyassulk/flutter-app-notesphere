import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';

import 'Folder.dart';
import 'Note.dart';

class NewNoteScreen extends StatefulWidget {
  final List<Folder> folders;

  const NewNoteScreen({required this.folders});

  @override
  State<StatefulWidget> createState() => _NewNoteScreen();
}

class _NewNoteScreen extends State<NewNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedFolder;

  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isRecording = false;
  bool isPlaying = false;
  String? recordingPath;

  @override
  void dispose() {
    audioRecorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Note"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Заголовок'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: 'Содержание'),
            maxLines: 5,
          ),
          SizedBox(height: 16),
          DropdownButton<String>(
            value: _selectedFolder,
            hint: Text('Выберите папку'),
            items: widget.folders.map((folder) {
              return DropdownMenuItem(
                value: folder.name,
                child: Text(folder.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFolder = value;
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty &&
                  _selectedFolder != null) {
                final note = Note(
                  title: _titleController.text,
                  content: _contentController.text,
                  audioPath: recordingPath
                );
                Navigator.pop(context, {
                  'note': note,
                  'folderName': _selectedFolder,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Заполните все поля и выберите папку')),
                );
              }
            },
            child: Text('Сохранить'),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: buildUI()),
        ],
      ),
      floatingActionButton: recordingButton(),
    );
  }

  Widget recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();

            // TODO: individual file name for every note
            final String filePath =
                path.join(appDocumentsDir.path, "recording.opus");

            await audioRecorder.start(const RecordConfig(encoder: AudioEncoder.opus), path: filePath);
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
        }
      },
      child: Icon(isRecording ? Icons.stop : Icons.mic),
    );
  }

  Widget buildUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          if (recordingPath != null)
            MaterialButton(
              onPressed: () async {
                if (audioPlayer.playing){
                  audioPlayer.stop();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audioPlayer.setFilePath(recordingPath!);
                  audioPlayer.play();
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              child: Text(isPlaying ? "Stop playing" : "Start playing"),
            ),
          if (recordingPath == null) const Text("No recording"),
        ],
      ),
    );
  }
}
