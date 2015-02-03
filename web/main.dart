library audioSampler;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'package:angular/animate/module.dart';

import 'package:audioSampler/sampler/sampler.dart';
import 'package:audioSampler/trackLine/trackLine.dart';
import 'package:audioSampler/sample/sample.dart';
import 'package:audioSampler/audioTrackService.dart';
import 'package:audioSampler/shareButton/shareButton.dart';
import 'package:audioSampler/filters/timerFilter.dart';

class AudioSamplerModule extends Module {
	AudioSamplerModule() {
		bind(AudioSamplerComponent);
		bind(TrackLineComponent);
		bind(SampleComponent);
		bind(ShareButtonComponent);
		bind(AudioTrackService);
		bind(TimerFilter);

		install(new AnimationModule());
	}
}

main() {
	applicationFactory()
	.addModule(new AudioSamplerModule())
	.run();
}