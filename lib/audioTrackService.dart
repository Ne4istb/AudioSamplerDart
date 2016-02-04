library audioTrackService;

import 'package:angular2/core.dart';
import 'dart:async';
import 'package:http/browser_client.dart';

@Injectable()
class AudioTrackService {
  final String URL = 'https://api.mongolab.com/api/1/databases/audio_sampler/collections/track';
  final String API_KEY = '?apiKey=6TBSTK-of8H_ChtTePQmtx-WclkspjPE';

  BrowserClient _httpClient;

  AudioTrackService() {
    this._httpClient = new BrowserClient();
  }

  Future<Map> loadData(String id) {
    var url = '$URL/$id$API_KEY';
    return _httpClient.get(url).then((response) {
      return response.body;
    });
  }

  Future saveData(String json) {
    return _httpClient.post(URL + API_KEY, body: json, headers: {'Content-Type': 'application/json'});
  }
}
