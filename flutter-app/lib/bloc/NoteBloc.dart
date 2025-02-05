import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/Folder.dart';
import '../models/Note.dart';
import '../repositories/LocalStorageRepository.dart';

abstract class NoteEvent {}
class LoadDataEvent extends NoteEvent {}

class AddFolderEvent extends NoteEvent {
  final String name;
  AddFolderEvent(this.name);
}

class RenameFolderEvent extends NoteEvent {
  final int folderId;
  final String newName;
  RenameFolderEvent(this.folderId, this.newName);
}

class DeleteFolderEvent extends NoteEvent {
  final int folderId;
  DeleteFolderEvent(this.folderId);
}

class ToggleFolderEvent extends NoteEvent {
  final int folderId;
  ToggleFolderEvent(this.folderId);
}

class AddNoteEvent extends NoteEvent {
  final int folderId;
  AddNoteEvent(this.folderId);
}

class UpdateNoteEvent extends NoteEvent {
  final Note note;
  UpdateNoteEvent(this.note);
}

class DeleteNoteEvent extends NoteEvent {
  final int noteId;
  DeleteNoteEvent(this.noteId);
}

/// Событие для добавления заметки по результатам распознавания речи (folderId = 0)
class AddSpeechNoteEvent extends NoteEvent {
  final String title;
  final String content;
  AddSpeechNoteEvent({required this.title, required this.content});
}

class NoteState {
  final List<Folder> folders;
  final List<Note> notes;

  NoteState({
    required this.folders,
    required this.notes,
  });

  NoteState copyWith({
    List<Folder>? folders,
    List<Note>? notes,
  }) {
    return NoteState(
      folders: folders ?? this.folders,
      notes: notes ?? this.notes,
    );
  }
}

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final LocalStorageRepository repository;

  NoteBloc({LocalStorageRepository? repository})
      : repository = repository ?? LocalStorageRepository(),
        super(NoteState(folders: [], notes: [])) {
    on<LoadDataEvent>(_onLoadData);
    on<AddFolderEvent>(_onAddFolder);
    on<RenameFolderEvent>(_onRenameFolder);
    on<DeleteFolderEvent>(_onDeleteFolder);
    on<ToggleFolderEvent>(_onToggleFolder);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<AddSpeechNoteEvent>(_onAddSpeechNote);
  }

  Future<void> _onLoadData(
      LoadDataEvent event, Emitter<NoteState> emit) async {
    final folders = await repository.loadFolders();
    final notes = await repository.loadNotes();
    emit(NoteState(folders: folders, notes: notes));
  }

  Future<void> _saveData(NoteState state) async {
    await repository.saveFolders(state.folders);
    await repository.saveNotes(state.notes);
  }

  void _onAddFolder(AddFolderEvent event, Emitter<NoteState> emit) {
    final newId = state.folders.isNotEmpty
        ? state.folders.map((f) => f.id).reduce(max) + 1
        : 1;
    final newFolder = Folder(id: newId, name: event.name);
    final newFolders = List<Folder>.from(state.folders)..add(newFolder);
    final newState = state.copyWith(folders: newFolders);
    emit(newState);
    _saveData(newState);
  }

  void _onRenameFolder(RenameFolderEvent event, Emitter<NoteState> emit) {
    final newFolders = state.folders.map((folder) {
      if (folder.id == event.folderId) {
        folder.name = event.newName;
      }
      return folder;
    }).toList();
    final newState = state.copyWith(folders: newFolders);
    emit(newState);
    _saveData(newState);
  }

  void _onDeleteFolder(DeleteFolderEvent event, Emitter<NoteState> emit) {
    final newFolders =
    state.folders.where((folder) => folder.id != event.folderId).toList();
    // Удаляем заметки, принадлежащие этой папке
    final newNotes =
    state.notes.where((note) => note.folderId != event.folderId).toList();
    final newState = state.copyWith(folders: newFolders, notes: newNotes);
    emit(newState);
    _saveData(newState);
  }

  void _onToggleFolder(ToggleFolderEvent event, Emitter<NoteState> emit) {
    final newFolders = state.folders.map((folder) {
      if (folder.id == event.folderId) {
        folder.isExpanded = !folder.isExpanded;
      }
      return folder;
    }).toList();
    final newState = state.copyWith(folders: newFolders);
    emit(newState);
    _saveData(newState);
  }

  void _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) {
    final newId = state.notes.isNotEmpty
        ? state.notes.map((n) => n.id).reduce(max) + 1
        : 1;
    final newNote = Note(
      id: newId,
      folderId: event.folderId,
      title: 'Новая заметка',
      content: '',
      lastModified: DateTime.now(),
    );
    final newNotes = List<Note>.from(state.notes)..add(newNote);
    final newState = state.copyWith(notes: newNotes);
    emit(newState);
    _saveData(newState);
  }

  void _onUpdateNote(UpdateNoteEvent event, Emitter<NoteState> emit) {
    final newNotes = state.notes.map((note) {
      if (note.id == event.note.id) {
        return event.note;
      }
      return note;
    }).toList();
    final newState = state.copyWith(notes: newNotes);
    emit(newState);
    _saveData(newState);
  }

  void _onDeleteNote(DeleteNoteEvent event, Emitter<NoteState> emit) {
    final newNotes =
    state.notes.where((note) => note.id != event.noteId).toList();
    final newState = state.copyWith(notes: newNotes);
    emit(newState);
    _saveData(newState);
  }

  void _onAddSpeechNote(AddSpeechNoteEvent event, Emitter<NoteState> emit) {
    final newId = state.notes.isNotEmpty
        ? state.notes.map((n) => n.id).reduce(max) + 1
        : 1;
    final newNote = Note(
      id: newId,
      folderId: 0,
      title: event.title,
      content: event.content,
      lastModified: DateTime.now(),
    );
    final newNotes = List<Note>.from(state.notes)..add(newNote);
    final newState = state.copyWith(notes: newNotes);
    emit(newState);
    _saveData(newState);
  }
}