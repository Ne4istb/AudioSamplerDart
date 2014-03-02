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
  
  Future<AudioBuffer> decodeAudioData(ByteBuffer audioData){
    return _audioContext.decodeAudioData(audioData);
  }
  
  List<AudioBufferSourceNode> currentSources = [];
  
  var startTime = 0;
  void playFromBuffer (AudioBuffer buffer, {num startTime: 0}){
    AudioBufferSourceNode source = _audioContext.createBufferSource()
        ..buffer = buffer
        ..connectNode(_audioContext.destination)
        ..start(_audioContext.currentTime + startTime);
    
    currentSources.add(source);
  }

  void stopAll(){
    currentSources.forEach(_stopSource);   
    currentSources = [];
  }
  
  void _stopSource(AudioBufferSourceNode source){
    source.stop();
  }
  
  var startOffset = 0;
  
  
  void pause(){

    startOffset += _audioContext.currentTime - startTime;
    
    currentSources.forEach((source) { source.stop(); });   
    startOffset += _audioContext.currentTime - startTime;
  }
}