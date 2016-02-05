library audioSampler;

import 'package:angular2/bootstrap.dart';

import 'package:audioSampler/sampler/sampler.dart';
import 'package:audioSampler/trackLine/trackLine.dart';
import 'package:audioSampler/sample/sample.dart';
import 'package:audioSampler/audioTrackService.dart';
import 'package:audioSampler/shareButton/shareButton.dart';
import 'package:audioSampler/pipes/timer-pipe.dart';
import 'package:audioSampler/pipes/bank-category-pipe.dart';

main() {
  bootstrap(AudioSamplerComponent, [TimerPipe, BankCategoryPipe, SampleComponent,
    TrackLineComponent, AudioTrackService, ShareButtonComponent]);
}