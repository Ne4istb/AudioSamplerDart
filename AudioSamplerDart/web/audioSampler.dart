import 'package:angular/angular.dart';
import 'trackLine/trackLine.dart';
import 'sample/sample.dart';

import 'dart:web_audio';
import 'dart:async';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

void main() {
  ngBootstrap(module: new Module()
    ..type(AudioSamplerController)
    ..type(TrackLineComponent)
    ..type(SampleComponent));
}

@NgController(
    selector: '[audioSampler]',
    publishAs: 'ctrl')
class AudioSamplerController {
  
  AudioContext _audioContext;
  
  AudioSamplerController(){
    _audioContext=new AudioContext();
  }
  
  void play(){
    
    var beat = new Sample('samples/beat.ogg');
    var guitar = new Sample('samples/guitar.ogg');
    var jungle = new Sample('samples/jungle.ogg');
    var bass = new Sample('samples/bass.ogg');
    
    var audioTrack = new AudioTrack(_audioContext);
    
    audioTrack.addSample(guitar, 0);
    
    var sampleDuration = 5.3;
    
    for (var i = 0; i<7; i++){
      audioTrack.addSample(guitar, i*sampleDuration);
    }

    audioTrack.addSample(jungle, 2*sampleDuration);
    audioTrack.addSample(jungle, 5*sampleDuration);
    audioTrack.addSample(jungle, 6*sampleDuration);
    
    audioTrack.addSample(bass, 1*sampleDuration);
    audioTrack.addSample(bass, 2*sampleDuration);
    audioTrack.addSample(bass, 5*sampleDuration);
    audioTrack.addSample(bass, 6*sampleDuration);

    for (var i = 3; i<7; i++){
      audioTrack.addSample(beat, i*sampleDuration);
    }
    
    audioTrack.play();  
  }
  
  AudioContext get audioContext => _audioContext;
}

class AudioPattern{
  Sample sample;
  num startTime;
}

class AudioTrack{
  
  AudioContext _audioContext;
  List<AudioPattern> _patterns = [];
  
  AudioTrack(this._audioContext);
  
  void addSample(Sample sample, num startTime){
    
    sample.load(_audioContext);
    
    AudioPattern pattern = new AudioPattern()
      ..sample = sample
      ..startTime = startTime; 
    
    _patterns.add(pattern);
  }
   
  void play(){
    Timer timer = new Timer(new Duration(seconds: 1), (){
      _patterns.forEach(playPattern);
    });
  }
  
  void playPattern(AudioPattern pattern){
    pattern.sample.play(_audioContext, startTime: pattern.startTime);
  }
}