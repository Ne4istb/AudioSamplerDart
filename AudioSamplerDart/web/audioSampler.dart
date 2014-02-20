import 'dart:html';
import 'dart:web_audio';
import 'dart:async';

void main(){
  querySelector('#playButton').onClick.listen(play);
}

void play(Event e){
  
  var snare = new Sample('samples/snare.ogg');
  var guitar = new Sample('samples/guitar.ogg');
  var money = new Sample('samples/money.ogg');
    
  var audioTrack = new AudioTrack();
  
  audioTrack.addSample(guitar, 0);
  
  audioTrack.addSample(money, 2);
  audioTrack.addSample(money, 6);
  
  for (var i=4; i<12; i++){
    audioTrack.addSample(snare, i + 0.1);
  }
  
  audioTrack.play();  
}

class Sample{
  
  String _fileName;
  AudioBuffer _buffer;
  
  Sample (this._fileName);
 
  void load(AudioContext context){
    
    if (_buffer !=null)
      return;
    
    new HttpRequest()
      ..open('GET', _fileName, async: true)
      ..responseType = 'arraybuffer'
      ..onLoad.listen((e) => _onLoad(e, context))
      ..onError.listen((e) => print("BufferLoader: XHR error"))
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
          
        _buffer = buffer;
      })
      .catchError((error) => print("Error: $error"));
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
      for (var pattern in _patterns)
        playPattern(pattern);
    });
  }
  
  void playPattern(AudioPattern pattern){
    var source = _audioContext.createBufferSource();
    source.buffer = pattern.sample.buffer;
    source.connectNode(_audioContext.destination);
    source.start(pattern.startTime);
  }
}