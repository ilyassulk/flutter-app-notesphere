import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/NoteBloc.dart';
import '../bloc/SpeechBloc.dart';
import 'EqualizerWidget.dart';


/// Виджет для записи речи – выдвигается снизу
class SpeechRecordingWidget extends StatefulWidget {
  const SpeechRecordingWidget({Key? key}) : super(key: key);

  @override
  _SpeechRecordingWidgetState createState() => _SpeechRecordingWidgetState();
}

class _SpeechRecordingWidgetState extends State<SpeechRecordingWidget> {
  @override
  void initState() {
    super.initState();
    // При первом отображении виджета запускаем запись
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<SpeechBloc>(context).add(SpeechStartRecordingEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpeechBloc, SpeechState>(
      listenWhen: (previous, current) =>
      previous.completedRequest != current.completedRequest,
      listener: (context, state) {
        // Если распознавание завершилось успешно, добавляем заметку и закрываем виджет
        if (state.completedRequest != null) {
          final resultText = state.completedRequest!.result ?? "";
          BlocProvider.of<NoteBloc>(context)
              .add(AddSpeechNoteEvent(title: "Начало", content: resultText));
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop();
          });
        }
      },
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.isRecording
                    ? "Запись: ${state.recordingDuration}s"
                    : "Нейросети уже трудятся над расшифровкой",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              const EqualizerWidget(),
              const SizedBox(height: 16),
              // Если запись идёт, показываем кнопку остановки
              if (state.isRecording)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    BlocProvider.of<SpeechBloc>(context)
                        .add(SpeechStopRecordingEvent());
                  },
                  icon: Icon(Icons.stop, color: Theme.of(context).primaryColor, size: 32),
                  label: Text("Остановить",
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
            ],
          ),
        );
      },
    );
  }
}