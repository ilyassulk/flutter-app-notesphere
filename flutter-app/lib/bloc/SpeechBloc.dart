import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/SpeechRequest.dart';
import '../repositories/SpeechRepository.dart';

abstract class SpeechEvent {}

class SpeechStartRecordingEvent extends SpeechEvent {}

class SpeechTickEvent extends SpeechEvent {
  final int seconds;
  SpeechTickEvent(this.seconds);
}

class SpeechStopRecordingEvent extends SpeechEvent {}

class SpeechPollEvent extends SpeechEvent {}

class SpeechUpdateRequestEvent extends SpeechEvent {
  final SpeechRequest request;
  SpeechUpdateRequestEvent(this.request);
}

class SpeechRemoveRequestEvent extends SpeechEvent {
  final String requestId;
  SpeechRemoveRequestEvent(this.requestId);
}

class SpeechState {
  final bool isRecording;
  final int recordingDuration; // секунды
  final String? currentFilePath;
  final List<SpeechRequest> requests;
  final SpeechRequest? completedRequest;

  SpeechState({
    this.isRecording = false,
    this.recordingDuration = 0,
    this.currentFilePath,
    this.requests = const [],
    this.completedRequest,
  });

  SpeechState copyWith({
    bool? isRecording,
    int? recordingDuration,
    String? currentFilePath,
    List<SpeechRequest>? requests,
    SpeechRequest? completedRequest,
  }) {
    return SpeechState(
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      currentFilePath: currentFilePath ?? this.currentFilePath,
      requests: requests ?? this.requests,
      completedRequest: completedRequest,
    );
  }
}

class SpeechBloc extends Bloc<SpeechEvent, SpeechState> {
  final SpeechRepository repository;
  final Dio dio;
  final AudioRecorder _recorder = AudioRecorder();

  Timer? _recordingTimer;
  Timer? _pollingTimer;

  SpeechBloc({SpeechRepository? repository, Dio? dio})
      : repository = repository ?? SpeechRepository(),
        dio = dio ?? Dio(),
        super(SpeechState()) {
    on<SpeechStartRecordingEvent>(_onStartRecording);
    on<SpeechTickEvent>(_onTick);
    on<SpeechStopRecordingEvent>(_onStopRecording);
    on<SpeechPollEvent>(_onPoll);
    on<SpeechUpdateRequestEvent>(_onUpdateRequest);
    on<SpeechRemoveRequestEvent>(_onRemoveRequest);

    _loadRequests();
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      add(SpeechPollEvent());
    });
  }

  Future<void> _loadRequests() async {
    final list = await repository.loadRequests();
    emit(state.copyWith(requests: list));
  }

  Future<void> _saveRequests() async {
    await repository.saveRequests(state.requests);
  }

  Future<void> _onStartRecording(
      SpeechStartRecordingEvent event, Emitter<SpeechState> emit) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recording.opus';
    // Запускаем запись аудио в формате opus (попробуйте задать путь, если нужно)
    bool hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;
    // Запускаем запись – имя файла формируется автоматически
    await _recorder.start(new RecordConfig(
      encoder: AudioEncoder.opus, // если поддерживается
      bitRate: 128000,
    ),
        path: filePath
    );
    int seconds = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds++;
      add(SpeechTickEvent(seconds));
      if (seconds >= 60) {
        add(SpeechStopRecordingEvent());
        timer.cancel();
      }
    });
    emit(state.copyWith(isRecording: true, recordingDuration: 0, currentFilePath: null));
  }

  void _onTick(SpeechTickEvent event, Emitter<SpeechState> emit) {
    emit(state.copyWith(recordingDuration: event.seconds));
  }

  Future<void> _onStopRecording(
      SpeechStopRecordingEvent event, Emitter<SpeechState> emit) async {
    if (!state.isRecording) return;
    _recordingTimer?.cancel();
    final filePath = await _recorder.stop();
    emit(state.copyWith(isRecording: false, currentFilePath: filePath));
    if (filePath != null) {
      try {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            filePath,
            filename: 'recording.opus',
            contentType: MediaType("audio", "opus"),
          )
        });
        Response response = await dio.post(
          "http://notesphere.ddns.net/ai/speech-to-text/request",
          data: formData,
          options: Options(
            contentType: "multipart/form-data",
          ),
        );
        final data = response.data;
        final newRequest = SpeechRequest.fromJson(data);
        final newList = List<SpeechRequest>.from(state.requests)..add(newRequest);
        emit(state.copyWith(requests: newList));
        await _saveRequests();
      } catch (e) {
        print("Ошибка загрузки аудио: $e");
      }
    }
  }

  Future<void> _onPoll(SpeechPollEvent event, Emitter<SpeechState> emit) async {
    for (var req in state.requests) {
      if (req.status == "wait" || req.status == "proc") {
        try {
          Response response = await dio.get(
              "http://notesphere.ddns.net/ai/speech-to-text/result/${req.requestId}");
          final data = response.data;
          final updatedRequest = SpeechRequest.fromJson(data);
          if (updatedRequest.status == "err") {
            add(SpeechRemoveRequestEvent(req.requestId));
          } else if (updatedRequest.status == "ok") {
            add(SpeechUpdateRequestEvent(updatedRequest));
          } else {
            add(SpeechUpdateRequestEvent(updatedRequest));
          }
        } catch (e) {
          print("Ошибка опроса запроса ${req.requestId}: $e");
        }
      }
    }
  }

  void _onUpdateRequest(
      SpeechUpdateRequestEvent event, Emitter<SpeechState> emit) {
    List<SpeechRequest> newList = state.requests.map((r) {
      if (r.requestId == event.request.requestId) {
        return event.request;
      }
      return r;
    }).toList();
    SpeechRequest? completed;
    if (event.request.status == "ok") {
      completed = event.request;
      newList.removeWhere((r) => r.requestId == event.request.requestId);
    }
    emit(state.copyWith(requests: newList, completedRequest: completed));
    _saveRequests();
  }

  void _onRemoveRequest(
      SpeechRemoveRequestEvent event, Emitter<SpeechState> emit) {
    List<SpeechRequest> newList =
    state.requests.where((r) => r.requestId != event.requestId).toList();
    emit(state.copyWith(requests: newList));
    _saveRequests();
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _pollingTimer?.cancel();
    return super.close();
  }
}