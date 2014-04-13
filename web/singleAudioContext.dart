library singleAudioContext;

import 'dart:web_audio';
import 'dart:async';
import 'dart:typed_data';

class SingleAudioContext {

  static AudioContext _audioContext = new AudioContext();
  static final SingleAudioContext _singleton = new SingleAudioContext._internal();

  factory SingleAudioContext() {
    return _singleton;
  }

  SingleAudioContext._internal();

  AudioDestinationNode get destination => _audioContext.destination;
  double get currentTime => _audioContext.currentTime;

  Future<AudioBuffer> decodeAudioData(ByteBuffer audioData) {
    return _audioContext.decodeAudioData(audioData);
  }

  List<AudioBufferSourceNode> _currentSources = [];
  GainNode gainNode;
  
  var startTime = 0;
  void playFromBuffer([AudioBuffer buffer, num startTime, num offset]) {
    
    if (gainNode == null){
      gainNode = _audioContext.createGain();
    }
    
    AudioBufferSourceNode source = _audioContext.createBufferSource()
        ..buffer = buffer
        ..connectNode (gainNode);
    
    gainNode.connectNode(_audioContext.destination);
    
    source.start(_audioContext.currentTime + startTime, offset);

    _currentSources.add(source);
  }
  
  void setVolume(num level){
    gainNode.gain.setValueAtTime(level, _audioContext.currentTime);
  }

  void stopAll() {
    _currentSources.forEach(_stopSource);
    _currentSources = [];
  }

  void _stopSource(AudioBufferSourceNode source) {
    source.stop(0);
  }
}
