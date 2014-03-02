import 'package:angular/angular.dart';
import 'trackLine/trackLine.dart';
import 'sample/sample.dart';
import 'audioTrackService.dart';
import 'package:uuid/uuid.dart';
import 'singleAudioContext.dart';

import 'dart:async';
import 'dart:html';
import 'dart:convert' show JSON;

@MirrorsUsed(
targets: const [
    'angular.core',
    'angular.core.dom',
    'angular.core.parser',
    'angular.core.zone',
    NodeTreeSanitizer,
    DynamicParser,
    DynamicParserBackend,
    Injector,
    'trackLine',
    'sample'
],
metaTargets: const [
    NgInjectableService,
    NgComponent,
    NgDirective,
    NgController,
    NgAttr,
    NgOneWay,
    NgOneWayOneTime,
    NgTwoWay,
    NgCallback,
    NgZone,
    TrackLineCell,
    Sample
],
override: '*'
)
import 'dart:mirrors';


void main() {
  ngBootstrap(module: new Module()
    ..type(AudioSamplerController)
    ..type(TrackLineComponent)
    ..type(SampleComponent)
    ..type(AudioTrackService));
}

@NgController(
    selector: '[audioSampler]',
    publishAs: 'ctrl')
class AudioSamplerController {
  
  final String CLIENT_ID = 'clientId';
  final num SAMPLE_DURATION = 5.3;
  
  AudioTrackService _audioTrackService;
  
  List<List<TrackLineCell>> trackLines = [];
  
  String _id;
  String _trackOwner;
  
  AudioSamplerController(this._audioTrackService){ 
    _id = _getClientId();
    _initTrackLines();
  }
  
  String _getClientId(){
    String id = window.localStorage[CLIENT_ID];
    return id == null ? new UuidBase().v1() : id;
  }

  void _initTrackLines() {
    
    var path = window.location.href;
    
    if (path.contains('#'))
    {
      var trackId = path.split('#')[1];
      
      _audioTrackService.loadData(trackId)
        .then(restoreTrack)
        .catchError((_) => resetTrack());
    }
    else
    {
       resetTrack();   
    }
  }

  bool playing = false;
  void play(){

    new SingleAudioContext().stopAll();
    playing = false;
    
    var audioTrack = new AudioTrack();

    trackLines.forEach((trackLine){
      
      for (var i=0; i<trackLine.length; i++){       
        if(trackLine[i] !=null){
          audioTrack.addSample(new Sample(trackLine[i].href), i*SAMPLE_DURATION);
        }
      };
    });
    
    audioTrack.onPlay.listen((_){
      playing = true;
    });
    
    audioTrack.play();
  }
  
  void stop(){
    playing = false;
    new SingleAudioContext().stopAll();
  }
//  
//  void pause(){
//    new SingleAudioContext().pause();
//  }
//  
//  void resume(){
//    new SingleAudioContext().resume();
//  }
  
  void save(){
   
    var trackId = _getTrackId();
    
    Map data = new Map()
      ..['_id'] = trackId
      ..['owner'] = _id
      ..['data'] = trackLines;
      
    String json = JSON.encode(data, toEncodable: (pattern){
      return (pattern as TrackLineCell).toJson();
    });
    
    window.localStorage[CLIENT_ID] = _id;
    
    _audioTrackService.saveData(json)
      .then((_) {  
        window.location.replace(window.location.pathname + '#$trackId'); 
      });
  }
  
  String _getTrackId(){
    
    var path = window.location.href;
    if (path.contains('#') && _trackOwner == _id)
      return path.split('#')[1];
    
    return _generateTrackId();
  }

  String _generateTrackId() => new UuidBase().v1().hashCode.toString();

  void restoreTrack(Map json){
    
    _trackOwner = json['owner'];
    
    trackLines.clear();
    
    (json['data'] as List).forEach((trackline){
      List value = [];
      (trackline as List).forEach((cell){
          value.add(cell == null ? null : new TrackLineCell.fromJSON(cell));  
      });
      
      trackLines.add(value);
    });
  }
  
  void resetTrack(){
    
    trackLines.clear();
    
    for (var i=0; i<5; i++){
      var value = new List<TrackLineCell>.filled(15, null);
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
  
  StreamController _playController = new StreamController.broadcast();
  List<AudioPattern> _patterns = [];
  
  AudioTrack();
  
  void addSample(Sample sample, num startTime){

    AudioPattern pattern = new AudioPattern()
      ..sample = sample
      ..startTime = startTime; 
    
    _patterns.add(pattern);
  }

  void play(){
    
    new Timer(new Duration(milliseconds:100), (){

      if (_patterns.any((pattern) => !pattern.sample.loaded))
        play();
      else 
        _play();
    });
  }
  
  void _play(){
    _patterns.forEach(_playPattern); 
    _playController.add("playing");
  }
  
  void _playPattern(AudioPattern pattern)=> pattern.sample.play(startTime: pattern.startTime);
  
  Stream get onPlay => _playController.stream;
}