import 'package:angular/angular.dart';
import 'trackLine/trackLine.dart';
import 'sample/sample.dart';

import 'dart:web_audio';
import 'dart:async';
import 'dart:html';
import 'dart:collection';

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
  
  List<List<TrackLineCell>> trackLines = [];
  
  AudioSamplerController(){
    
    for (var i=0; i<5; i++){
      var value = new List<TrackLineCell>.filled(15, new TrackLineCell());
      trackLines.add(value);
    }
  }
  
  void drag(MouseEvent e){
    e.dataTransfer.setData('Source', 'Container');
    print(e.currentTarget);
  }
  
  void drop(MouseEvent e){
    print('dragover ' + e.currentTarget.toString());
  }
  
  void allowDrop(MouseEvent e){
    e.preventDefault();
  }
  
  void play(){

    AudioContext audioContext=new AudioContext();
    var audioTrack = new AudioTrack(audioContext);
  
    var sampleDuration = 5.3;
//
//    trackLines.add(guitarLine);
//    trackLines.add(beatLine);
//    trackLines.add(jungleLine);
//    trackLines.add(bassLine);
    
    trackLines.forEach((trackLine){
      
      for (var i=0; i<trackLine.length; i++){
        
        String href = trackLine[i].href;
        
        if(href != null && href.isNotEmpty){
          audioTrack.addSample(href, i*sampleDuration);
        }
      };
    });
    
    audioTrack.play();  
  }
  
//  List<TrackLineCell> guitarLine = [
//    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
//    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
//    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
//    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
//    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
//    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg'),
//    new TrackLineCell(sampleName: 'Guitar', href: 'samples/guitar.ogg')
//  ];
//  
//  List<TrackLineCell> beatLine = [
//    new TrackLineCell(),
//    new TrackLineCell(),
//    new TrackLineCell(),
//    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg'),
//    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg'),
//    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg'),
//    new TrackLineCell(sampleName: 'Beat', href: 'samples/beat.ogg')
//  ];
//  
//  List<TrackLineCell> bassLine = [
//    new TrackLineCell(),
//    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg'),
//    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg'),
//    new TrackLineCell(),
//    new TrackLineCell(),
//    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg'),
//    new TrackLineCell(sampleName: 'Bass', href: 'samples/bass.ogg')
//  ];
//  
//  List<TrackLineCell> jungleLine = [
//    new TrackLineCell(),
//    new TrackLineCell(),
//    new TrackLineCell(sampleName: 'Jungle', href: 'samples/jungle.ogg'),
//    new TrackLineCell(),
//    new TrackLineCell(),
//    new TrackLineCell(sampleName: 'Jungle', href: 'samples/jungle.ogg'),
//    new TrackLineCell(sampleName: 'Jungle', href: 'samples/jungle.ogg')
//  ];
}

class AudioPattern{
  Sample sample;
  num startTime;
}

class AudioTrack{
  
  AudioContext _audioContext;
  List<AudioPattern> _patterns = [];
  Map<String, Sample> cachedSamples = new Map<String, Sample>();
  
  AudioTrack(this._audioContext);
  
  void addSample(String href, num startTime){
    
    if (!cachedSamples.containsKey(href))
      cachedSamples[href] = new Sample(href);
    
    Sample sample = cachedSamples[href];
    
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