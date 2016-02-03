library audioTrackService;

import 'package:angular2/core.dart';
import 'dart:async';
import 'package:http/http.dart';

@Injectable()
class AudioTrackService {

	final String URL = 'https://api.mongolab.com/api/1/databases/audio_sampler/collections/track';
	final String API_KEY = '?apiKey=6TBSTK-of8H_ChtTePQmtx-WclkspjPE';

	Client _httpClient;

	AudioTrackService(this._httpClient);

	Future<Map> loadData(String id) {
		var url = '$URL/$id$API_KEY';
		return _httpClient.get(url).then((Response response) {
			return response.body;
		});
	}

	Future saveData(String json) {
		return _httpClient.post(URL + API_KEY, body: json, headers: {
			'Content-Type': 'application/json'
		});
	}
}