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
  
  @NgTwoWay('cells')
  List<TrackLineCell> cells;
}

class TrackLineCell{
  String sampleName;
  String href;
  
  TrackLineCell({this.sampleName, this.href});
}