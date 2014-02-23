import 'package:angular/angular.dart';
import 'trackLine/trackLine.dart';
import 'sample/sample.dart';

import 'dart:web_audio';
import 'dart:async';
import 'dart:html';
import 'dart:convert' show JSON;

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
  
  final String TRACK_KEY = 'trackMix';
  final num SAMPLE_DURATION = 5.3;
  
  List<List<TrackLineCell>> trackLines = [];

  AudioSamplerController(){
    initTrack();
  }
  
  void initTrack(){
    String storedTrack = window.localStorage[TRACK_KEY];
    if (storedTrack == null)
      resetTrack();
    else
      restoreTrack(storedTrack);
  }
  
  
  bool playing = false;
  void play(){

    playing = false;
    
    AudioContext audioContext=new AudioContext();
    var audioTrack = new AudioTrack(audioContext);

    trackLines.forEach((trackLine){
      
      for (var i=0; i<trackLine.length; i++){
        
        String href = trackLine[i].href;
        
        if(href != null && href.isNotEmpty){
          audioTrack.addSample(href, i*SAMPLE_DURATION);
        }
      };
    });
    
    Timer timer = new Timer(new Duration(seconds: 1), (){
      audioTrack.play();
      playing = true;
    });
  }
  
  void save(){
    
    String json = JSON.encode(trackLines, toEncodable: (pattern){
      return (pattern as TrackLineCell).toJson();
    });
    
    window.localStorage[TRACK_KEY] = json; 
  }
  
  void restoreTrack(String json){
    
    trackLines = JSON.decode(json, reviver: (key, value){
      
      if (value is String)
        return new TrackLineCell.fromJSON(value);
      else
        return value;
    });
  }
  
  void resetTrack(){

    trackLines.clear();
    
    for (var i=0; i<5; i++){
      var value = new List<TrackLineCell>.filled(15, new TrackLineCell());
      trackLines.add(value);
    }             
  }
  
  var samples = [
    { 'name' : 'Beat 00', 'href' : 'samples/beat.ogg'},
    { 'name' : 'Beat 01', 'href' : 'samples/beat01.ogg'},
    { 'name' : 'Beat 02', 'href' : 'samples/beat02.ogg'},
    { 'name' : 'Beat 03', 'href' : 'samples/beat03.ogg'},
    { 'name' : 'Beat 04', 'href' : 'samples/beat04.ogg'},
    { 'name' : 'Beat 05', 'href' : 'samples/beat05.ogg'},
    { 'name' : 'Beat 06', 'href' : 'samples/beat06.ogg'},
    { 'name' : 'Beat 07', 'href' : 'samples/beat07.ogg'},
    { 'name' : 'Beat 08', 'href' : 'samples/beat08.ogg'},
    { 'name' : 'Beat 09', 'href' : 'samples/beat09.ogg'},
    { 'name' : 'Beat 10', 'href' : 'samples/beat10.ogg'},
    { 'name' : 'Keys 00', 'href' : 'samples/keys01.ogg'},
    { 'name' : 'Keys 01', 'href' : 'samples/keys02.ogg'},
    { 'name' : 'Keys 02', 'href' : 'samples/keys03.ogg'},
    { 'name' : 'Keys 03', 'href' : 'samples/keys04.ogg'},
    { 'name' : 'Keys 04', 'href' : 'samples/keys05.ogg'},
    { 'name' : 'Keys 05', 'href' : 'samples/keys06.ogg'},
    { 'name' : 'Keys 06', 'href' : 'samples/keys07.ogg'},
    { 'name' : 'Keys 07', 'href' : 'samples/keys08.ogg'},
    { 'name' : 'Jungle', 'href' : 'samples/jungle.ogg'},
    { 'name' : 'Bass 00', 'href' : 'samples/bass.ogg'},
    { 'name' : 'Bass 01', 'href' : 'samples/bass01.ogg'},
    { 'name' : 'Bass 02', 'href' : 'samples/bass02.ogg'},
    { 'name' : 'Bass 03', 'href' : 'samples/bass03.ogg'},
    { 'name' : 'Bass 04', 'href' : 'samples/bass04.ogg'},
    { 'name' : 'Bass 05', 'href' : 'samples/bass05.ogg'},
    { 'name' : 'Bass 06', 'href' : 'samples/bass06.ogg'},
    { 'name' : 'Bass 07', 'href' : 'samples/bass07.ogg'},
    { 'name' : 'Bass 08', 'href' : 'samples/bass08.ogg'},
    { 'name' : 'Bass 09', 'href' : 'samples/bass09.ogg'},
    { 'name' : 'Bass 10', 'href' : 'samples/bass10.ogg'},
    { 'name' : 'Guitar 00', 'href' : 'samples/guitar.ogg'},
    { 'name' : 'Guitar 01', 'href' : 'samples/guitar01.ogg'},
    { 'name' : 'Guitar 02', 'href' : 'samples/guitar02.ogg'},
    { 'name' : 'Guitar 03', 'href' : 'samples/guitar03.ogg'},
    { 'name' : 'Guitar 04', 'href' : 'samples/guitar04.ogg'},
    { 'name' : 'Guitar 05', 'href' : 'samples/guitar05.ogg'},
    { 'name' : 'Guitar 06', 'href' : 'samples/guitar06.ogg'},
    { 'name' : 'Guitar 07', 'href' : 'samples/guitar07.ogg'},
    { 'name' : 'Guitar 08', 'href' : 'samples/guitar08.ogg'},
    { 'name' : 'Guitar 09', 'href' : 'samples/guitar09.ogg'},
    { 'name' : 'Guitar 10', 'href' : 'samples/guitar10.ogg'},
    { 'name' : 'Effect 00', 'href' : 'samples/fx00.ogg'},
    { 'name' : 'Effect 01', 'href' : 'samples/fx01.ogg'},
    { 'name' : 'Effect 02', 'href' : 'samples/fx02.ogg'},
    { 'name' : 'Effect 03', 'href' : 'samples/fx03.ogg'},
    { 'name' : 'Effect 04', 'href' : 'samples/fx04.ogg'},
    { 'name' : 'Effect 05', 'href' : 'samples/fx05.ogg'},
    { 'name' : 'Effect 06', 'href' : 'samples/fx06.ogg'},
    { 'name' : 'Effect 07', 'href' : 'samples/fx07.ogg'},
    { 'name' : 'Effect 08', 'href' : 'samples/fx08.ogg'},
    { 'name' : 'Effect 09', 'href' : 'samples/fx09.ogg'},
    { 'name' : 'Effect 10', 'href' : 'samples/fx10.ogg'}
  ];
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
    _patterns.forEach(playPattern);
  }
  
  void playPattern(AudioPattern pattern){
    pattern.sample.play(_audioContext, startTime: pattern.startTime);
  }
}