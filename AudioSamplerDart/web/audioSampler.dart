import 'dart:html';
import 'dart:web_audio';

void main(){
  querySelector('#playButton').onClick.listen(play);
}

void play(Event e){
  var sample = new Sample('samples/Moneta.mp3');
  
  var audioTrack = new AudioTrack();
  audioTrack.addSample(sample, 0);
  audioTrack.play();  
}

class Sample{
  
  String _fileName;
  AudioBuffer _buffer;
  
  Sample (String fileName){
    _fileName = fileName;
  }

  void load(AudioContext context) {
    var request = new HttpRequest();
    request.open('GET', _fileName, async: true);
    request.responseType = 'arraybuffer';
    
    request.onLoad.listen((e) {
      print('loaded');
      context
        .decodeAudioData(request.response)
        .then((AudioBuffer buffer){
          
          if (buffer == null) {
            window.alert("Error decoding file data: $_fileName");
          
            return;
          }
          
          _buffer = buffer;
        })
        .catchError((error)=>   print(error));
    });
     
    request.onError.listen((e)=> print("BufferLoader: XHR error"));

    request.send();
  }
  
  AudioBuffer get buffer => _buffer; 
}

class AudioTrack{
  
  AudioContext _audioContext;
  Sample _sample;
  int _startTime;
  
  AudioTrack(){
    _audioContext = new AudioContext();
  }
  
  void addSample(Sample sample, int startTime){
    _sample = sample;
    _sample.load(_audioContext);
    
    _startTime =startTime;
  }
   
  void play(){
    var source = _audioContext.createBufferSource();
    source.buffer = _sample.buffer;
    
    source.connectNode(_audioContext.destination);
    source.start(_startTime);
  }
}