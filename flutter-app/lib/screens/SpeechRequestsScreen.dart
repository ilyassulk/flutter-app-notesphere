import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/SpeechBloc.dart';

/// Экран для просмотра speech-to-text запросов
class SpeechRequestsScreen extends StatelessWidget {
  const SpeechRequestsScreen({Key? key}) : super(key: key);

  /// Возвращает иконку для каждого статуса
  Icon _getStatusIcon(String status) {
    switch (status) {
      case "wait":
        return Icon(Icons.access_time, color: Colors.grey);
      case "proc":
        return Icon(Icons.autorenew, color: Colors.orange);
      case "ok":
        return Icon(Icons.check_circle, color: Color(0xFF39FF14));
      case "err":
        return Icon(Icons.error, color: Colors.red);
      default:
        return Icon(Icons.help, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Запросы Speech-to-Text", style: TextStyle(color: Theme.of(context).primaryColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<SpeechBloc, SpeechState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.requests.length,
            itemBuilder: (context, index) {
              final req = state.requests[index];
              return ListTile(
                title: Text(req.requestId, style: TextStyle(color: Colors.white)),
                trailing: _getStatusIcon(req.status),
              );
            },
          );
        },
      ),
    );
  }
}