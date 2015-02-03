import 'package:angular/angular.dart';
import 'package:intl/intl.dart';

@Formatter(name:'timerFilter')
class TimerFilter {
	call(num value) {

		if (value == null)
			return null;

		var formatter = new NumberFormat("00", "en_US");

		int minutes = value ~/ 60;
		String minutesStr = formatter.format(minutes);

		String seconds = formatter.format(value - value % 1 - (minutes * 60));

		formatter = new NumberFormat("000", "en_US");
		String millis = formatter.format(value % 1 * 1000);

		return "$minutesStr : $seconds : $millis";
	}
}