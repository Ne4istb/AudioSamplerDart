library trackLine;

import 'package:angular/angular.dart';
import 'dart:html';

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
  
  void drop(MouseEvent e, int index){
    
    String sampleName = e.dataTransfer.getData('SampleName');
    String sampleHref = e.dataTransfer.getData('SampleHref');
    
    cells[index]= new TrackLineCell(sampleName: sampleName, href: sampleHref);
  }
  
  void allowDrop(MouseEvent e){
    e.preventDefault();
  }
  
  void onItemDragged(int index){
    cells[index] = new TrackLineCell();
  }
}

class TrackLineCell{
  String sampleName;
  String href;
  
  TrackLineCell({this.sampleName, this.href});
}