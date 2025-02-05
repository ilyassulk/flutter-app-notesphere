import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/Folder.dart';
import '../models/Note.dart';

class LocalStorageRepository {
  static const String foldersKey = 'folders';
  static const String notesKey = 'notes';

  Future<List<Folder>> loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final foldersString = prefs.getString(foldersKey);
    if (foldersString == null) return [];
    final List<dynamic> jsonData = json.decode(foldersString);
    return jsonData.map((item) => Folder.fromJson(item)).toList();
  }

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString(notesKey);
    if (notesString == null) return [];
    final List<dynamic> jsonData = json.decode(notesString);
    return jsonData.map((item) => Note.fromJson(item)).toList();
  }

  Future<void> saveFolders(List<Folder> folders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(folders.map((f) => f.toJson()).toList());
    await prefs.setString(foldersKey, jsonString);
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(notesKey, jsonString);
  }
}