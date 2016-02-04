library audioSampler;

import 'package:angular2/angular2.dart';
import 'package:angular2/bootstrap.dart';

import 'package:audioSampler/sampler/sampler.dart';
import 'package:audioSampler/trackLine/trackLine.dart';
import 'package:audioSampler/sample/sample.dart';
import 'package:audioSampler/audioTrackService.dart';
import 'package:audioSampler/shareButton/shareButton.dart';
import 'package:audioSampler/filters/timerFilter.dart';

main() {
  bootstrap(AudioSamplerComponent, [TimerFilter, SampleComponent,
    TrackLineComponent, AudioTrackService, ShareButtonComponent]);
}

//
//class AudioSamplerModule extends Module {
//	AudioSamplerModule() {
//		bind(AudioSamplerComponent);
//		bind(TrackLineComponent);
//		bind(SampleComponent);
//		bind(ShareButtonComponent);
//		bind(AudioTrackService);
//		bind(TimerFilter);
//
//		install(new AnimationModule());
//	}
//}