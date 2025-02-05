import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/NoteBloc.dart';
import 'bloc/SpeechBloc.dart';
import 'models/Folder.dart';
import 'models/Note.dart';
import 'screens/NoteHomeScreen.dart';
import 'screens/SpeechRequestsScreen.dart';
import 'theme.dart';

/// Точка входа
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(NoteSphereApp());
}

class NoteSphereApp extends StatelessWidget {
  const NoteSphereApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteBloc>(
            create: (_) => NoteBloc()..add(LoadDataEvent())),
        BlocProvider<SpeechBloc>(create: (_) => SpeechBloc()),
      ],
      child: MaterialApp(
        title: 'NoteSphere',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.generalTheme,
        home: NoteHomeScreen(),
      ),
    );
  }
}
