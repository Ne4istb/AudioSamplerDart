import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/animate/module.dart';

import 'package:intl/intl.dart';

import 'trackLine/trackLine.dart';
import 'sample/sample.dart';
import 'shareButton/shareButton.dart';
import 'samples/samples.dart';

import 'audioTrackService.dart';
import 'audioTrack.dart';

import 'dart:async';
import 'dart:math' as math;
import 'dart:html';
import 'dart:convert' show JSON;


class AudioSamplerModule extends Module{
  AudioSamplerModule() {
    type(AudioSamplerController);
    type(TrackLineComponent);
    type(SampleComponent);
    type(ShareButtonComponent);
    type(AudioTrackService);
    type(TimerFilter);

    install(new AnimationModule());
  }
}

main() {
  applicationFactory()
    .addModule(new AudioSamplerModule())
    .run();
}

@Formatter(name:'timerFilter')
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

@Controller(selector: '[audioSampler]', publishAs: 'ctrl')
class AudioSamplerController {

  final String CLIENT_ID = 'clientId';
  final num SAMPLE_DURATION = 5.3;

  static int START_POSITION = 99;
  static int SAMPLE_WIDTH = 71;
  static int TRACK_LINE_WIDTH = 1065;
  static num TRACK_LENGTH = 79.5;

  var samples = new SamplesLib().list;
  
  List<List<TrackLineCell>> trackLines = [];
    
  AudioTrackService _audioTrackService;
  String _id;
  String _trackOwner;
  Scope _scope;

  AudioSamplerController(this._scope, this._audioTrackService) {

    _id = _getClientId();
    _initTrackLines();

    _scope.on('sampleAdded').listen(onSampleAdded);
    _scope.on('sampleRemoved').listen(onSampleRemoved);

    window.onKeyDown.listen(onKeyPress);
  }

  String _getClientId() {
    String id = window.localStorage[CLIENT_ID];
    return id == null ? _generateId() : id;
  }

  String _generateId() {
    var random = new math.Random();
    return ((1 + random.nextDouble()) * 1000000).toInt().toString();
  }

  void _initTrackLines() {
    //TODO Simplify it using path on production
    var path = window.location.href;

    if (path.contains('#')) {
      var trackId = path.split('#')[1];

      _audioTrackService.loadData(trackId).then(restoreTrack).catchError((_) => resetTrack());
    } else {
      resetTrack();
    }
  }

  var bankCategories = ['Beat', 'Bass', 'Guitar', 'Effect', 'Keys', 'Jungle'];
  String currentBankCategory = 'Beat';

  void onSampleAdded(ScopeEvent event) {
    if (_audioTrack != null) {
      _audioTrack.addSample(new Sample(event.data[1]), event.data[0] * SAMPLE_DURATION);
    }
  }

  void onSampleRemoved(ScopeEvent event) {
    if (_audioTrack != null) {
      _audioTrack.removeSample(new Sample(event.data[1]), event.data[0] * SAMPLE_DURATION);
    }
  }

  bool isPlaying = false;
  AudioTrack _audioTrack;

  void play() {

    if (isPlaying) return;

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
      isPlaying = true;
      runPlayTimer();
    });

    _audioTrack.play();
  }

  var cursorPosition = START_POSITION;

  void stop() {

    if (_audioTrack == null) return;

    _audioTrack.stop();
    _audioTrack = null;

    isPlaying = false;
    _playTimer.cancel();

    time = 0;

    cursorPosition = START_POSITION;
    _setCursorStyle();
  }

  void pause() {

    if (_audioTrack == null || !isPlaying)
      return;

    _audioTrack.pause();

    isPlaying = false;
    _playTimer.cancel();

    cursorPosition = _cursorTimeToPosition;
    _setCursorStyle();
  }

  num get _cursorTimeToPosition => _audioTrack.pauseTime * (TRACK_LINE_WIDTH / TRACK_LENGTH) + START_POSITION;
  num get _cursorPositionToTime => (cursorPosition - START_POSITION) / TRACK_LINE_WIDTH * TRACK_LENGTH;

  void setStartPosition(MouseEvent e) {

    if (isPlaying) return;

    cursorPosition = e.client.x - (e.currentTarget as Node).parent.parent.offsetLeft;
    _setCursorStyle();

    _audioTrack = new AudioTrack()
      ..pauseTime = time = _cursorPositionToTime;
  }

  String cursorStyle = "left: " + START_POSITION.toString() + "px;";

  void _setCursorStyle({num timeToEnd : 0}) {
    cursorStyle = "left: " + cursorPosition.toString() + "px; ";
    if (timeToEnd > 0) cursorStyle += "-webkit-animation: rightThenLeft " + timeToEnd.toString() + "s linear;";
  }

  void onKeyPress(KeyboardEvent e) {

    const int SPACE_KEY = 32;

    if (e.keyCode != SPACE_KEY) return;

    if (isPlaying)
      pause(); 
    else
      play();
  }

  Timer _playTimer;
  num time = 0;

  void runPlayTimer() {

    _playTimer = new Timer(new Duration(milliseconds: 100), () {

      if (_audioTrack != null && isPlaying)
        time = _audioTrack.currentTime;

      if(time > 79.5)
        stop();

      runPlayTimer();
    });
  }


  String volumeLevel = '100';
  void volumeLevelChanged(Event event) {

    String value = (event.target as dynamic).value;
    volumeLevel = value;
    num level = int.parse(value) / 100;

    if (_audioTrack != null) _audioTrack.setVolumeLevel(level);
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
    if (path.contains('#') && _trackOwner == _id)return path.split('#')[1];

    return _generateId();
  }

  void restoreTrack(Map json) {

    _trackOwner = json['owner'];

    trackLines.clear();

    (json['data'] as List).forEach((trackLine) {
      List value = [];
      (trackLine as List).forEach((cell) {
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
}
