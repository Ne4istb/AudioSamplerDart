library sample;

import '../singleAudioContext.dart';
import 'package:angular/angular.dart';
import 'dart:html';
import 'dart:async';
import 'dart:web_audio';

@NgComponent(
    selector: 'sample',
    templateUrl: 'sample/sample.html',
    cssUrl: 'sample/sample.css',
    publishAs: 'cmp'
)
class SampleComponent {
  @NgAttr('id')
  String id;
  
  @NgAttr('name')
  String name;
  
  @NgAttr('href')
  String href;
  
  @NgCallback('onItemDragged')
  var onItemDragged;
  
  @NgCallback('onRightClick')
  var onRightClick;

  SingleAudioContext _audioContext;
  SampleComponent(){
    _audioContext = new SingleAudioContext();
  }
  
  void drag(MouseEvent e){
    e.dataTransfer.setData('id', (e.currentTarget as Element).id);
    e.dataTransfer.setData('SampleName', name);
    e.dataTransfer.setData('SampleHref', href);
  }
  
  void dragEnd(MouseEvent e){
    onItemDragged();
  }
  
  void onContextMenu (Event e){
    onRightClick();
    e.preventDefault();
  }
  
  Sample _sample;
  void playSample(){
    
    if (_sample == null){
      _sample = new Sample(href)..load();
    }
    
    new SingleAudioContext().stop();
    
    Timer timer = new Timer(new Duration(milliseconds: 250), (){
      _sample.play();
    });
  }
  
  String getColors(){
    if (href.contains("beat"))
      return '#3F3EE5, #3E93E5';
    
    if (href.contains("key"))
      return '#97218D, #D86FCF';
    
    if (href.contains("guitar"))
      return '#E5983E, #DBAC75';
    
    if (href.contains("bass"))
      return '#2B4C20, #4F9C35';
    
    return '#CBA610, #D4BD5E';
  }
}

class Sample{
  
  String _fileName;
  AudioBuffer _buffer;
  
  bool isLoading = false;

  static Map<String, Sample> _cache;

  factory Sample(String fileName) {
    if (_cache == null) {
      _cache = {};
    }

    if (_cache.containsKey(fileName)) {
      return _cache[fileName];
    } else {
      final sample = new Sample._internal(fileName);
      _cache[fileName] = sample;
      return sample;
    }
  }

  Sample._internal(this._fileName);
 
  void load(){
    
    SingleAudioContext context = new SingleAudioContext();
    
    if (isLoading || _buffer !=null)
      return;

    isLoading = true;
    
    new HttpRequest()
      ..open('GET', _fileName, async: true)
      ..responseType = 'arraybuffer'
      ..onLoad.listen((e) => _onLoad(e))
      ..onError.listen(_onLoadError)
      ..send();
  }
  
  void _onLoad (Event e){
    
    SingleAudioContext context = new SingleAudioContext();
    
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
  
  void play({num startTime: 0}){       
    SingleAudioContext context = new SingleAudioContext();
    context.playFromBuffer(_buffer, startTime: startTime);
  }
}
