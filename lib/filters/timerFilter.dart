library timer_filter;

import 'package:angular/angular.dart';
import 'package:intl/intl.dart';

@Formatter(name:'timerFilter')
class TimerFilter {
	call(num value) {

		if (value == null) return null;

		if (value < 0)	return "00 : 00 : 000";


		var formatter = new NumberFormat("00", "en_US");

		var minutes = value ~/ 60;
		String minutesStr = formatter.format(minutes);

		var seconds = value - value % 1 - (minutes * 60);
		String secondsStr = formatter.format(seconds);

		formatter = new NumberFormat("000", "en_US");

		var millis = value % 1 * 1000;
		String millisStr = formatter.format(millis);

		return "$minutesStr : $secondsStr : $millisStr";
	}
}