library trackLine;

import 'package:angular/angular.dart';

@NgComponent(
    selector: 'track',
    templateUrl: 'trackLine/trackLine.html',
    cssUrl: 'trackLine/trackLine.css',
    publishAs: 'cmp'
)
class TrackLineComponent {
  @NgAttr('number')
  String number;
  
  String get label => "Track " + number;
}