library audio_sampler.bank_category_pipe;

import 'package:angular2/core.dart';
import 'package:audioSampler/samples/samples.dart';

@Pipe(name: 'bankCategoryPipe')
class BankCategoryPipe extends PipeTransform {
  @override
  transform(List<SampleItem> value, List args) {
    return value.where((sample) => sample.name.startsWith(args[0])).toList();
  }
}
