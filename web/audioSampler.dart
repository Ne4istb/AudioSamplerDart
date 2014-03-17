import 'package:angular/angular.dart';
import 'package:intl/intl.dart';
import 'trackLine/trackLine.dart';
import 'sample/sample.dart';
import 'shareButton/shareButton.dart';

import 'audioTrackService.dart';
import 'package:uuid/uuid.dart';
import 'singleAudioContext.dart';

import 'dart:async';
import 'dart:html';
import 'dart:convert' show JSON;

@MirrorsUsed(targets: const ['trackLine', 'sample'], metaTargets: const
    [TrackLineCell, Sample], override: '*')
import 'dart:mirrors';


void main() {
  ngBootstrap(module: new Module()
      ..type(AudioSamplerController)
      ..type(TrackLineComponent)
      ..type(SampleComponent)
      ..type(ShareButtonComponent)
      ..type(AudioTrackService)
      ..type(TimerFilter));
}

@NgFilter(name:'timerFilter')
class TimerFilter {
  call(num value) {

    var formatter = new NumberFormat("00", "en_US");
    
    int minutes = value ~/ 60;
    String minutesStr = formatter.format(minutes);
    
    String seconds = formatter.format(value - value % 1 - (minutes * 60));
    
    formatter = new NumberFormat("000", "en_US");
    String millis = formatter.format(value % 1 * 1000);

    return "$minutesStr : $seconds : $millis";
  }
}

@NgController(selector: '[audioSampler]', publishAs: 'ctrl')
class AudioSamplerController {

  final String CLIENT_ID = 'clientId';
  final num SAMPLE_DURATION = 5.3;
  
  static int START_POSITION = 99;
  static int SAMPLE_WIDTH = 71;
  static int TRACK_LINE_WIDTH = 71;
  static num TRACK_LENGTH = 79.5;

  List<List<TrackLineCell>> trackLines = [];

  AudioTrackService _audioTrackService;
  String _id;
  String _trackOwner;
  Scope _scope;

  AudioSamplerController(this._scope, this._audioTrackService) {
    
    _id = _getClientId();
    _initTrackLines();
    
    window.onKeyDown.listen(onKeyPress);
    
    _scope.$on('sampleAdded', onSampleAdded);
    _scope.$on('sampleRemoved', onSampleRemoved);
  }
  var bankCategories =['Beat', 'Bass', 'Guitar', 'Effect', 'Keys', 'Jungle'];
  String currentBankCategory = 'Beat';
  
  void onSampleAdded(event, index, sampleName){
    if (_audioTrack!=null){
      _audioTrack.addSample(new Sample(sampleName), index*SAMPLE_DURATION);
    }
  }
  
  void onSampleRemoved(event, index, sampleName){
    if (_audioTrack!=null){
      _audioTrack.removeSample(new Sample(sampleName), index*SAMPLE_DURATION);
    }
  }

  String _getClientId() {
    String id = window.localStorage[CLIENT_ID];
    return id == null ? new UuidBase().v1() : id;
  }

  void _initTrackLines() {
    //TODO Simplify it using path on production
    var path = window.location.href;
    print(path);
    if (path.contains('#')) {
      var trackId = path.split('#')[1];

      _audioTrackService.loadData(trackId).then(restoreTrack).catchError((_) =>
          resetTrack());
    } else {
      resetTrack();
    }
  }

  bool playing = false;
  AudioTrack _audioTrack;
  
  void play() {

    playing = false;

    if (_audioTrack == null)
      _audioTrack = new AudioTrack();
    else
      _audioTrack.clear();
    
    trackLines.forEach((trackLine) {

      for (var i = 0; i < trackLine.length; i++) {
        if (trackLine[i] != null) {
          _audioTrack.addSample(new Sample(trackLine[i].href), i * SAMPLE_DURATION);
        }
      }
      ;
    });

    
    _audioTrack.onPlay.listen((_) {
      _setCursorStyle(timeToEnd: TRACK_LENGTH - _audioTrack.pauseTime);
      playing = true;
    });

    _audioTrack.play();
    runPlayTimer();
  }

  void stop() {
    
    playing = false;
    pausePosition = START_POSITION;
    
    _setCursorStyle();
    
    _playTimer.cancel();
    
    if (_audioTrack == null)
      return;
    
    _audioTrack.stop();
    _audioTrack = null;
  }

  var pausePosition = START_POSITION;
  
  void pause() {
    
    if (_audioTrack != null) _audioTrack.pause();
    
    playing = false;
    pausePosition = _cursorTimeToPosition;
    
    _setCursorStyle();
    
    _playTimer.cancel();
  }

  num get _cursorTimeToPosition => _audioTrack.pauseTime * (TRACK_LINE_WIDTH/TRACK_LENGTH) + START_POSITION;
  num get _cursorPositionToTime => (pausePosition - START_POSITION) / TRACK_LINE_WIDTH * TRACK_LENGTH;   
  
  void setStartPosition (MouseEvent e){
    
    if (playing) return;
    
    pausePosition = e.client.x - (e.currentTarget as Node).parent.parent.offsetLeft;
    _setCursorStyle();
    
    _audioTrack = new AudioTrack()
        ..pauseTime = _cursorPositionToTime;
    
    time = _audioTrack.pauseTime;
  }
  
  String cursorStyle = "left: " + START_POSITION.toString() +"px;";
  void _setCursorStyle({num timeToEnd : 0}){
    
    cursorStyle = "left: " + pausePosition.toString() + "px; ";
    if (timeToEnd > 0)
      cursorStyle += "-webkit-animation: rightThenLeft " + timeToEnd.toString() + "s linear;";
  }

  void onKeyPress(KeyboardEvent e){
    
    const int SPACE_KEY = 32;
    
    if (e.keyCode != SPACE_KEY) return;
    
    if (playing)
      pause();
    else
      play();
  }
  
  Timer _playTimer;
  num time = 0;
  void runPlayTimer(){
    _playTimer = new Timer(new Duration(milliseconds: 100), () {
      
      if (_audioTrack != null)
        time = _audioTrack.currentTime;
      
      runPlayTimer();
    });
  }
  
  void volumeLevelChanged(Event event){
    String value = (event.target as dynamic).value;
    num level =  int.parse(value) /100;
    
    if (_audioTrack != null)
      _audioTrack.setVolumeLevel(level);
  }
  
  void save() {

    var trackId = _getTrackId();

    Map data = new Map()
        ..['_id'] = trackId
        ..['owner'] = _id
        ..['data'] = trackLines;

    String json = JSON.encode(data, toEncodable: (pattern) {
      return (pattern as TrackLineCell).toJson();
    });

    window.localStorage[CLIENT_ID] = _id;

    _audioTrackService.saveData(json).then((_) {
      window.location.replace(window.location.pathname + '#$trackId');
    });
  }

  String _getTrackId() {

    var path = window.location.href;
    if (path.contains('#') && _trackOwner == _id) return path.split('#')[1];

    return _generateTrackId();
  }

  String _generateTrackId() => new UuidBase().v1().hashCode.toString();

  void restoreTrack(Map json) {

    _trackOwner = json['owner'];

    trackLines.clear();

    (json['data'] as List).forEach((trackline) {
      List value = [];
      (trackline as List).forEach((cell) {
        value.add(cell == null ? null : new TrackLineCell.fromJSON(cell));
      });

      trackLines.add(value);
    });
  }

  void resetTrack() {

    trackLines.clear();

    for (var i = 0; i < 5; i++) {
      var value = new List<TrackLineCell>.filled(15, null);
      trackLines.add(value);
    }
  }

  var samples = [{
      'name': 'Beat 00',
      'href': 'samples/beat.ogg'
    }, {
      'name': 'Beat 01',
      'href': 'samples/beat01.ogg'
    }, {
      'name': 'Beat 02',
      'href': 'samples/beat02.ogg'
    }, {
      'name': 'Beat 03',
      'href': 'samples/beat03.ogg'
    }, {
      'name': 'Beat 04',
      'href': 'samples/beat04.ogg'
    }, {
      'name': 'Beat 05',
      'href': 'samples/beat05.ogg'
    }, {
      'name': 'Beat 06',
      'href': 'samples/beat06.ogg'
    }, {
      'name': 'Beat 07',
      'href': 'samples/beat07.ogg'
    }, {
      'name': 'Beat 08',
      'href': 'samples/beat08.ogg'
    }, {
      'name': 'Beat 09',
      'href': 'samples/beat09.ogg'
    }, {
      'name': 'Beat 10',
      'href': 'samples/beat10.ogg'
    }, {
      'name': 'Keys 00',
      'href': 'samples/keys01.ogg'
    }, {
      'name': 'Keys 01',
      'href': 'samples/keys02.ogg'
    }, {
      'name': 'Keys 02',
      'href': 'samples/keys03.ogg'
    }, {
      'name': 'Keys 03',
      'href': 'samples/keys04.ogg'
    }, {
      'name': 'Keys 04',
      'href': 'samples/keys05.ogg'
    }, {
      'name': 'Keys 05',
      'href': 'samples/keys06.ogg'
    }, {
      'name': 'Keys 06',
      'href': 'samples/keys07.ogg'
    }, {
      'name': 'Keys 07',
      'href': 'samples/keys08.ogg'
    }, {
      'name': 'Jungle',
      'href': 'samples/jungle.ogg'
    }, {
      'name': 'Bass 00',
      'href': 'samples/bass.ogg'
    }, {
      'name': 'Bass 01',
      'href': 'samples/bass01.ogg'
    }, {
      'name': 'Bass 02',
      'href': 'samples/bass02.ogg'
    }, {
      'name': 'Bass 03',
      'href': 'samples/bass03.ogg'
    }, {
      'name': 'Bass 04',
      'href': 'samples/bass04.ogg'
    }, {
      'name': 'Bass 05',
      'href': 'samples/bass05.ogg'
    }, {
      'name': 'Bass 06',
      'href': 'samples/bass06.ogg'
    }, {
      'name': 'Bass 07',
      'href': 'samples/bass07.ogg'
    }, {
      'name': 'Bass 08',
      'href': 'samples/bass08.ogg'
    }, {
      'name': 'Bass 09',
      'href': 'samples/bass09.ogg'
    }, {
      'name': 'Bass 10',
      'href': 'samples/bass10.ogg'
    }, {
      'name': 'Guitar 00',
      'href': 'samples/guitar.ogg'
    }, {
      'name': 'Guitar 01',
      'href': 'samples/guitar01.ogg'
    }, {
      'name': 'Guitar 02',
      'href': 'samples/guitar02.ogg'
    }, {
      'name': 'Guitar 03',
      'href': 'samples/guitar03.ogg'
    }, {
      'name': 'Guitar 04',
      'href': 'samples/guitar04.ogg'
    }, {
      'name': 'Guitar 05',
      'href': 'samples/guitar05.ogg'
    }, {
      'name': 'Guitar 06',
      'href': 'samples/guitar06.ogg'
    }, {
      'name': 'Guitar 07',
      'href': 'samples/guitar07.ogg'
    }, {
      'name': 'Guitar 08',
      'href': 'samples/guitar08.ogg'
    }, {
      'name': 'Guitar 09',
      'href': 'samples/guitar09.ogg'
    }, {
      'name': 'Guitar 10',
      'href': 'samples/guitar10.ogg'
    }, {
      'name': 'Effect 00',
      'href': 'samples/fx00.ogg'
    }, {
      'name': 'Effect 01',
      'href': 'samples/fx01.ogg'
    }, {
      'name': 'Effect 02',
      'href': 'samples/fx02.ogg'
    }, {
      'name': 'Effect 03',
      'href': 'samples/fx03.ogg'
    }, {
      'name': 'Effect 04',
      'href': 'samples/fx04.ogg'
    }, {
      'name': 'Effect 05',
      'href': 'samples/fx05.ogg'
    }, {
      'name': 'Effect 06',
      'href': 'samples/fx06.ogg'
    }, {
      'name': 'Effect 07',
      'href': 'samples/fx07.ogg'
    }, {
      'name': 'Effect 08',
      'href': 'samples/fx08.ogg'
    }, {
      'name': 'Effect 09',
      'href': 'samples/fx09.ogg'
    }, {
      'name': 'Effect 10',
      'href': 'samples/fx10.ogg'
    }];
}

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

  void setVolumeLevel(num level){
    new SingleAudioContext().setVolume(level);
  }
  
  num get pauseTime => _startOffset; 
  
  void set pauseTime(num pauseTime){
    _startOffset = pauseTime; 
  } 
  
  void addSample(Sample sample, num startTime) {

    AudioPattern pattern = new AudioPattern()
        ..sample = sample
        ..startTime = startTime;

    _patterns.add(pattern);
    
    if (_isPlaying)
      _playSample(pattern);
  }
  
  void removeSample(Sample sample, num startTime) {

    _patterns.removeWhere((pattern) => pattern.sample == sample && pattern.startTime == startTime);
    
    if (_isPlaying){
      pause();
      _play();
    }
  }
  
  void clear(){
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

    _patterns
      .where((pattern) => pattern.startTime>= _startOffset - SAMPLE_DURATION)
      .forEach((pattern) { _playPattern(pattern, _startOffset); });
    
    _isPlaying = true;
    _playController.add("playing");
  }

  void _playPattern(AudioPattern pattern, double startOffset) {
    
    num offset = 0;
    if (pattern.startTime <startOffset)
      offset = startOffset - pattern.startTime; 
      
    pattern.sample.play(pattern.startTime - startOffset, offset); 
  }

  void pause() {
    _startOffset = currentTime;
    
    stop();
  }

  double get currentTime => new SingleAudioContext().currentTime - _startTime;

  void stop(){
    
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
