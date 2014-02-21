import 'package:angular/angular.dart';
import 'trackLine/trackLine.dart';

import 'dart:web_audio';
import 'dart:async';
import 'dart:html';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

void main() {
  ngBootstrap(module: new Module()
    ..type(AudioSamplerController)
    ..type(TrackLineComponent));
}

@NgController(
    selector: '[audioSampler]',
    publishAs: 'ctrl')
class AudioSamplerController {
  AudioSamplerController();
  
  void play(){
    
    var beat = new Sample('samples/beat.ogg');
    var guitar = new Sample('samples/guitar.ogg');
    var jungle = new Sample('samples/jungle.ogg');
    var bass = new Sample('samples/bass.ogg');
    
    var audioTrack = new AudioTrack();
    
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
}

class Sample{
  
  String _fileName;
  AudioBuffer _buffer;
  
  bool isLoading = false;
  
  Sample (this._fileName);
 
  void load(AudioContext context){
    
    if (isLoading || _buffer !=null)
      return;

    isLoading = true;
    
    new HttpRequest()
      ..open('GET', _fileName, async: true)
      ..responseType = 'arraybuffer'
      ..onLoad.listen((e) => _onLoad(e, context))
      ..onError.listen(_onLoadError)
      ..send();
  }
  
  void _onLoad (Event e, AudioContext context){
    context
      .decodeAudioData((e.target as HttpRequest).response)
      .then((AudioBuffer buffer){

        if (buffer == null) {
          print("Error decoding file data: $_fileName");
          return;
        }
        print(_fileName + " - " + buffer.duration.toString());  
        _buffer = buffer;
      })
      .catchError((error) => print("Error: $error"))
      .whenComplete(() {isLoading == false;});
  }
  
  void _onLoadError (Event e){
    print("BufferLoader: XHR error");
    isLoading == false;
  }
  
  AudioBuffer get buffer => _buffer; 
}

class AudioPattern{
  Sample sample;
  num startTime;
}

class AudioTrack{
  
  AudioContext _audioContext;
  List<AudioPattern> _patterns = [];
  
  AudioTrack(){
    _audioContext = new AudioContext();
  }
  
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
    _audioContext.createBufferSource()
        ..buffer = pattern.sample.buffer
        ..connectNode(_audioContext.destination)
        ..start(pattern.startTime);
  }
}