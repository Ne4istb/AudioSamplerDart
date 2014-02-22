library sample;

import 'package:angular/angular.dart';
import 'dart:web_audio';
import 'dart:html';
import 'dart:async';

@NgComponent(
    selector: 'sample',
    templateUrl: 'sample/sample.html',
    cssUrl: 'sample/sample.css',
    publishAs: 'cmp'
)
class SampleComponent {
  @NgAttr('name')
  String name;
  
  @NgAttr('href')
  String href;

  AudioContext _audioContext;
  SampleComponent(){
    _audioContext = new AudioContext();
  }
  
  Sample _sample;
  
  void drag(Event e){
    print('drag');
  }
  
  void playSample(){
    
    if (_sample == null){
      _sample = new Sample(href)
        ..load(_audioContext);
    }
      
    Timer timer = new Timer(new Duration(milliseconds: 500), (){
      _sample.play(_audioContext);
    });
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
  
  void play(AudioContext context, {num startTime: 0}){
    context.createBufferSource()
        ..buffer = _buffer
        ..connectNode(context.destination)
        ..start(startTime);
  }
}
