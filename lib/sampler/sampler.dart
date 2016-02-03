library sampler;

import 'package:angular2/core.dart';

import 'package:audioSampler/audioTrackService.dart';
import 'package:audioSampler/trackLine/trackLine.dart';
import 'package:audioSampler/samples/samples.dart';
import 'package:audioSampler/sample/sample.dart';
import 'package:audioSampler/audioTrack.dart';

//import 'trackLine/trackLine.dart';
//import 'sample/sample.dart';
//import 'shareButton/shareButton.dart';
//import 'samples/samples.dart';
//
//import 'audioTrackService.dart';
//import 'audioTrack.dart';

import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;
import 'dart:convert' show JSON;

@Component(
  selector: 'audio-sampler',
  templateUrl: 'sampler.html',
  directives: const[TrackLineComponent],
  styleUrls: const ['sampler.css'])
class AudioSamplerComponent {
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

  AudioSamplerComponent(this._audioTrackService) {
    _id = _getClientId();
    _initTrackLines();

    html.window.onKeyDown.listen(onKeyPress);
  }

  void set scope(Scope scope) {
//		scope.on('sampleAdded').listen(onSampleAdded);
//		scope.on('sampleRemoved').listen(onSampleRemoved);
  }

  String _getClientId() {
    String id = html.window.localStorage[CLIENT_ID];
    return id == null ? _generateId() : id;
  }

  String _generateId() {
    var random = new math.Random();
    return ((1 + random.nextDouble()) * 1000000).toInt().toString();
  }

  void _initTrackLines() {
    //TODO Simplify it using path on production
    var path = html.window.location.href;

    if (path.contains('#')) {
      var trackId = path.split('#')[1];

      _audioTrackService.loadData(trackId).then(restoreTrack).catchError((_) => resetTrack());
    } else {
      resetTrack();
    }
  }

  var bankCategories = ['Beat', 'Bass', 'Guitar', 'Effect', 'Keys', 'Jungle'];
  String currentBankCategory = 'Beat';

//	void onSampleAdded(ScopeEvent event) {
//		if (_audioTrack != null) {
//			_audioTrack.addSample(new Sample(event.data[1]), event.data[0] * SAMPLE_DURATION);
//		}
//	}
//
//	void onSampleRemoved(ScopeEvent event) {
//		if (_audioTrack != null) {
//			_audioTrack.removeSample(new Sample(event.data[1]), event.data[0] * SAMPLE_DURATION);
//		}
//	}

  bool isPlaying = false;
  AudioTrack _audioTrack;

  void play() {
    if (isPlaying) return;

    if (_audioTrack == null) _audioTrack = new AudioTrack();
    else _audioTrack.clear();

    trackLines.forEach((trackLine) {
      for (var i = 0; i < trackLine.length; i++) {
        if (trackLine[i] != null) {
          _audioTrack.addSample(new Sample(trackLine[i].href), i * SAMPLE_DURATION);
        }
      }
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
    if (_playTimer != null) _playTimer.cancel();

    time = 0;

    cursorPosition = START_POSITION;
    _setCursorStyle();
  }

  void pause() {
    if (_audioTrack == null || !isPlaying) return;

    _audioTrack.pause();

    isPlaying = false;
    _playTimer.cancel();

    cursorPosition = _cursorTimeToPosition;
    _setCursorStyle();
  }

  void stepBack() {
    if (_audioTrack == null) return;

    if (SAMPLE_DURATION > _audioTrack.pauseTime) {
      var continuePlaying = isPlaying;
      stop();

      if (continuePlaying) play();

      return;
    }

    _step(-SAMPLE_DURATION);
  }

  void stepForward() {
    if (_audioTrack == null) return;

    if (_audioTrack.pauseTime >= TRACK_LENGTH - SAMPLE_DURATION) {
      pause();
      _step(TRACK_LENGTH - _audioTrack.pauseTime);
      return;
    }

    _step(SAMPLE_DURATION);
  }

  void _step(num step) {
    if (isPlaying) _audioTrack.pause();

    _audioTrack.moveTo(step);

    if (isPlaying) _audioTrack.play();

    cursorPosition = _cursorTimeToPosition;
    _setCursorStyle();
  }

  num get _cursorTimeToPosition => _audioTrack.pauseTime * (TRACK_LINE_WIDTH / TRACK_LENGTH) + START_POSITION;

  num get _cursorPositionToTime => (cursorPosition - START_POSITION) / TRACK_LINE_WIDTH * TRACK_LENGTH;

  void setStartPosition(html.MouseEvent e) {
    if (isPlaying) return;

    cursorPosition = e.client.x - (e.currentTarget as html.Node).parent.parent.offsetLeft;
    _setCursorStyle();

    _audioTrack = new AudioTrack()..pauseTime = time = _cursorPositionToTime;
  }

  String cursorStyle = "left: " + START_POSITION.toString() + "px;";

  void _setCursorStyle({num timeToEnd: 0}) {
    cursorStyle = "left: " + cursorPosition.toString() + "px; ";
    if (timeToEnd > 0) cursorStyle += "-webkit-animation: rightThenLeft " + timeToEnd.toString() + "s linear;";
  }

  void onKeyPress(html.KeyboardEvent e) {
    const int SPACE_KEY = 32;

    if (e.keyCode != SPACE_KEY) return;

    if (isPlaying) pause();
    else play();
  }

  Timer _playTimer;
  num time = 0;

  void runPlayTimer() {
    _playTimer = new Timer(new Duration(milliseconds: 100), () {
      if (_audioTrack != null && isPlaying) time = _audioTrack.currentTime;

      if (time > 79.5) stop();

      runPlayTimer();
    });
  }

  String volumeLevel = '100';

  void volumeLevelChanged(html.Event event) {
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

    html.window.localStorage[CLIENT_ID] = _id;

    _audioTrackService.saveData(json).then((_) {
      html.window.location.replace(html.window.location.pathname + '#$trackId');
    });
  }

  String _getTrackId() {
    var path = html.window.location.href;
    if (path.contains('#') && _trackOwner == _id) return path.split('#')[1];

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
