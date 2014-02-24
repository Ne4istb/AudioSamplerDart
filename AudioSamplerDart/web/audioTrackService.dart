library audioTrackService;

import 'package:angular/angular.dart';
import 'dart:html';
import 'dart:async';

@NgInjectableService()
class AudioTrackService {
  
  final String URL = 'https://api.mongolab.com/api/1/databases/audio_sampler/collections/track';
  final String API_KEY = '?apiKey=NVrNVeIvJnMveyK08uDABFDAgStD1MrL';
  
  AudioTrackService();

  Future<String> loadData(String id) {
    var url = '$URL/$id$API_KEY';
    return HttpRequest.getString(url);
  }
  
  void saveData(String json) {
    print(json);
    new HttpRequest()
      ..onReadyStateChange.listen(_onReadyStateChanged)
      ..open("POST", URL + API_KEY, async: false)
      ..setRequestHeader('Content-Type', 'application/json')
      ..send(json);
  }
  
  void _onReadyStateChanged(Event e){
    var request = (e.target as HttpRequest);
    
    if (request.readyState == HttpRequest.DONE &&
        (request.status == 200 || request.status == 0)) {
    
      print(request.responseText);
    }   
  }
}