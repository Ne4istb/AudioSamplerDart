library main_test;

import 'package:unittest/unittest.dart';
import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:audioSampler/filters/timerFilter.dart';

import '../web/main.dart';

main() {
	setUp(() {
		setUpInjector();
		module((Module m) => m.install(new AudioSamplerModule()));
	});

	tearDown(tearDownInjector);

	group('timerFilter', () {
		test('should return subset', inject((TimerFilter filter) {
			expect(filter(0), equals('00 : 00 : 000'));
			expect(filter(0.001), equals('00 : 00 : 001'));
			expect(filter(59.999), equals('00 : 59 : 999'));
			expect(filter(60), equals('01 : 00 : 000'));
			expect(filter(6001.001), equals('100 : 01 : 001'));
			expect(filter(4.1245), equals('00 : 04 : 125'));
			expect(filter(145.458), equals('02 : 25 : 458'));
			expect(filter(43.0), equals('00 : 43 : 000'));
			expect(filter(543.11), equals('09 : 03 : 110'));
			expect(filter(-5.7745), equals('00 : 00 : 000'));
			expect(filter(null), equals(null));
		}));
	}
);
}
