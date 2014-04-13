library audioTrackService;

import 'package:angular/angular.dart';
import 'dart:async';

@NgInjectableService()
class AudioTrackService {
  
  final String URL = 'https://api.mongolab.com/api/1/databases/audio_sampler/collections/track';
  final String API_KEY = '?apiKey=6TBSTK-of8H_ChtTePQmtx-WclkspjPE';
  
  Http _http;
  
  AudioTrackService(this._http);

  Future<Map> loadData(String id) {
    var url = '$URL/$id$API_KEY';
    return _http.get(url).then((response) { return response.data; });
  }
    
  Future saveData(String json) {
    return _http.post(URL + API_KEY, json, headers: {'Content-Type': 'application/json'});
  }
}