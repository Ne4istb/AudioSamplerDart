library audioTrack;

import 'sample/sample.dart';

import 'singleAudioContext.dart';

import 'dart:async';

class AudioPattern {
  Sample sample;
  num startTime;
}

class AudioTrack {

  final num SAMPLE_DURATION = 5.3;

  StreamController _playController = new StreamController.broadcast();
  List<AudioPattern> _patterns = [];
  double _startTime = 0.0;
  double _startOffset = 0.0;
  bool _isPlaying = false;

  AudioTrack();

  void setVolumeLevel(num level) {
    new SingleAudioContext().setVolume(level);
  }

  num get pauseTime => _startOffset;

  void set pauseTime(num pauseTime) {
    _startOffset = pauseTime;
  }

  void addSample(Sample sample, num startTime) {

    AudioPattern pattern = new AudioPattern()
      ..sample = sample
      ..startTime = startTime;

    _patterns.add(pattern);

    if (_isPlaying)_playSample(pattern);
  }

  void removeSample(Sample sample, num startTime) {

    _patterns.removeWhere((pattern) => pattern.sample == sample && pattern.startTime == startTime);

    if (_isPlaying) {
      pause();
      _play();
    }
  }

  void clear() {
    _patterns = [];
  }

  void play() {

    stop();

    new Timer(new Duration(milliseconds: 100), () {

      if (_patterns.any((pattern) => !pattern.sample.loaded))
        play();
      else
        _play();
    });
  }

  void _play() {

    _startTime = new SingleAudioContext().currentTime - _startOffset;

    _patterns.where((pattern) => pattern.startTime >= _startOffset - SAMPLE_DURATION).forEach((pattern) {
      _playPattern(pattern, _startOffset);
    });

    _isPlaying = true;
    _playController.add("playing");
  }

  void _playPattern(AudioPattern pattern, double startOffset) {

    num offset = 0;
    if (pattern.startTime < startOffset)offset = startOffset - pattern.startTime;

    pattern.sample.play(pattern.startTime - startOffset, offset);
  }

  void pause() {
    _startOffset = currentTime;

    stop();
  }

  void moveTo (num step){
    _startOffset = _startOffset + step;
  }

  double get currentTime => new SingleAudioContext().currentTime - _startTime;

  void stop() {

    new SingleAudioContext().stopAll();

    _isPlaying = false;
  }

  Stream get onPlay => _playController.stream;

  void _playSample(AudioPattern pattern) {

    new Timer(new Duration(milliseconds: 100), () {

      if (pattern.sample.loaded)
        _playPattern(pattern, currentTime);
      else
        _playSample(pattern);
    });
  }
}
