library trackLine;

import 'package:angular/angular.dart';
import 'dart:html';
import 'dart:convert' show JSON;

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
  
  bool _clearCellAllowed = false;
  void drop(MouseEvent e, int index){
    
    if (!cells[index].isEmpty)
      return;
    
    String id = e.dataTransfer.getData('Id');
    if (id != (e.currentTarget as Element).id)
      _clearCellAllowed = true;
    
    String sampleName = e.dataTransfer.getData('SampleName');
    String sampleHref = e.dataTransfer.getData('SampleHref');
    
    cells[index]= new TrackLineCell(sampleName: sampleName, href: sampleHref);
  }
  
  bool _ctrlPressed;
  void allowDrop(MouseEvent e){
    _ctrlPressed = e.ctrlKey;
    e.preventDefault();
  }
  
  void onItemDragged(int index){
    if (!_ctrlPressed && _clearCellAllowed)
      clearCell(index);
    
    _ctrlPressed = false;
    _clearCellAllowed =  false;
  }
  
  void clearCell(int index){
    cells[index] = new TrackLineCell();
  }
}

class TrackLineCell {
  
  String sampleName;
  String href;
  
  TrackLineCell({this.sampleName, this.href});
  
  bool get isEmpty => (sampleName == null || sampleName.isEmpty) && (href == null || href.isEmpty);  
  
  TrackLineCell.fromJSON(String jsonString) {
    Map storedTrackLine = JSON.decode(jsonString);
    sampleName = storedTrackLine['n'] == "null" ? '' : storedTrackLine['n'];
    href = storedTrackLine['h'] == "null" ? '' : storedTrackLine['h'];
  }

  String toJson(){
    return  '{ "n": "$sampleName", "h": "$href" } '; 
  }
}