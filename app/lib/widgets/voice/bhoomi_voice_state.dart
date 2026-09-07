/// Universal 12 conceptual interaction states for Bhoomi Voice-First design system.
enum BhoomiVoiceState {
  idle,
  ready,
  permissionRequired,
  listening,
  recording,
  stopping,
  processing,
  transcriptionConfirmation,
  speaking,
  paused,
  completed,
  error,
}

/// Extension helpers for [BhoomiVoiceState].
extension BhoomiVoiceStateX on BhoomiVoiceState {
  bool get isIdle => this == BhoomiVoiceState.idle;
  bool get isReady => this == BhoomiVoiceState.ready;
  bool get isPermissionRequired => this == BhoomiVoiceState.permissionRequired;
  bool get isListening => this == BhoomiVoiceState.listening;
  bool get isRecording => this == BhoomiVoiceState.recording;
  bool get isStopping => this == BhoomiVoiceState.stopping;
  bool get isProcessing => this == BhoomiVoiceState.processing;
  bool get isTranscriptionConfirmation =>
      this == BhoomiVoiceState.transcriptionConfirmation;
  bool get isSpeaking => this == BhoomiVoiceState.speaking;
  bool get isPaused => this == BhoomiVoiceState.paused;
  bool get isCompleted => this == BhoomiVoiceState.completed;
  bool get isError => this == BhoomiVoiceState.error;

  /// Whether active microphone capture is ongoing.
  bool get isMicActive =>
      this == BhoomiVoiceState.listening ||
      this == BhoomiVoiceState.recording ||
      this == BhoomiVoiceState.stopping;

  /// Whether audio output is active or paused.
  bool get isAudioActive =>
      this == BhoomiVoiceState.speaking || this == BhoomiVoiceState.paused;
}
