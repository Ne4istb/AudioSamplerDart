library audio_sampler.sample;

import 'package:angular2/core.dart';
import 'dart:html';
import 'dart:async';
import 'dart:web_audio';

import 'package:audioSampler/singleAudioContext.dart';

class Sample {
  SingleAudioContext _context = new SingleAudioContext();
  StreamController _loadedController = new StreamController.broadcast();

  String _fileName;

  AudioBuffer _buffer;

  bool get loaded => _buffer != null;

  static Map<String, Sample> _cache;

  factory Sample(String fileName) {
    if (_cache == null) _cache = {};

    if (_cache.containsKey(fileName)) return _cache[fileName];

    final sample = new Sample._internal(fileName);
    _cache[fileName] = sample;

    return sample;
  }

  Sample._internal(this._fileName) {
    _load();
  }

  void _load() {
    new HttpRequest()
      ..open('GET', _fileName, async: true)
      ..responseType = 'arraybuffer'
      ..onLoad.listen(_onLoadSuccess)
      ..onError.listen(_onLoadError)
      ..send();
  }

  void _onLoadSuccess(Event e) {
    _context.decodeAudioData((e.target as HttpRequest).response).then((AudioBuffer buffer) {
      if (buffer == null) {
        print("Error decoding file data: $_fileName");
        return;
      }

      print(_fileName + " - " + buffer.duration.toString());
      _buffer = buffer;

      _loadedController.add("loaded");
    }).catchError((error) => print("Error: $error"));
  }

  void _onLoadError(Event e) => print("BufferLoader: XHR error");

  void play([num startTime, num offset]) {
    if (startTime == null) startTime = 0.0;
    if (offset == null) offset = 0.0;

    if (_buffer == null) {
      _loadedController.stream.listen((_) {
        _play(startTime, offset);
      });
    } else _play(startTime, offset);
  }

  void _play(num startTime, num offset) => _context.playFromBuffer(_buffer, startTime, offset);
}
