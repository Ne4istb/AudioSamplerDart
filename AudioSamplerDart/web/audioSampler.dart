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
   
    var audioTrack = new AudioTrack(_audioContext);
  
    var sampleDuration = 5.3;

    trackLines.add(guitarLine);
    trackLines.add(beatLine);
    trackLines.add(jungleLine);
    trackLines.add(bassLine);
    
    trackLines.forEach((trackLine){
      for (var i=0; i<trackLine.length; i++){
        String href = trackLine[i].href;
        if(href != null && href.isNotEmpty){
          audioTrack.addSample(new Sample(href), i*sampleDuration);
        }
      };
    });
    
    audioTrack.play();  
  }
  
  AudioContext get audioContext => _audioContext;
  
  List<List<TrackLineCell>> trackLines = [];
  
  List<TrackLineCell> guitarLine = [
    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg')
  ];
  
  List<TrackLineCell> beatLine = [
    new TrackLineCell(),
    new TrackLineCell(),
    new TrackLineCell(),
    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg'),
    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg'),
    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg'),
    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg')
  ];
  
  List<TrackLineCell> bassLine = [
    new TrackLineCell(),
    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg'),
    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg'),
    new TrackLineCell(),
    new TrackLineCell(),
    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg'),
    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg')
  ];
  
  List<TrackLineCell> jungleLine = [
    new TrackLineCell(),
    new TrackLineCell(),
    new TrackLineCell(sampleName: 'Jungle', href: 'samples/jungle.ogg'),
    new TrackLineCell(),
    new TrackLineCell(),
    new TrackLineCell(sampleName: 'Jungle', href: 'samples/jungle.ogg'),
    new TrackLineCell(sampleName: 'Jungle', href: 'samples/jungle.ogg')
  ];
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