import 'package:flutter/material.dart';

import '../models/Note.dart';
import 'NoteEditingScreen.dart';

class NoteSearchScreen extends StatefulWidget {
  final List<Note> notes;

  const NoteSearchScreen({Key? key, required this.notes}) : super(key: key);

  @override
  _NoteSearchScreenState createState() => _NoteSearchScreenState();
}

class _NoteSearchScreenState extends State<NoteSearchScreen> {
  late List<String> tags = [];
  late TextEditingController tagController;
  late TextEditingController searchController;
  late List<Note> filteredNotes;

  @override
  void initState() {
    super.initState();
    tagController = TextEditingController();
    searchController = TextEditingController();
    filteredNotes = widget.notes;
  }

  void _filterNotes() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes = widget.notes.where((note) {
        final matchesTitle = note.title.toLowerCase().contains(query);
        final matchesTags = tags.every((tag) => note.tags.contains(tag));
        return matchesTitle && matchesTags;
      }).toList();
    });
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
                    tags.add(tagController.text.trim());
                    _filterNotes();
                  });
                }
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
        title: Text("Поиск по заметкам", style: TextStyle(color: Theme.of(context).primaryColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Поиск по названию заметки",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterNotes();
              },
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Теги:"),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    ...tags.map((tag) => Chip(
                      label: Text(tag, style: TextStyle(color: Colors.white)),
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      deleteIcon: Icon(Icons.close, size: 18, color: Colors.white),
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                          _filterNotes();
                        });
                      },
                    )),
                    IconButton(
                      onPressed: _showAddTagDialog,
                      icon: Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NoteEditingScreen(note: note)),
                    );
                  },
                  child: ListTile(
                    title: Text(note.title, style: TextStyle(color: Colors.white)),
                    subtitle: Text(note.tags.join(", "), style: TextStyle(color: Colors.white70)),

                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
