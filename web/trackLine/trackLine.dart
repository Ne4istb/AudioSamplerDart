library trackLine;

import 'package:angular/angular.dart';
import 'dart:html';
import 'dart:convert' show JSON;

@NgComponent(
    selector: 'track', 
    templateUrl: 'trackLine/trackLine.html', 
    cssUrl: 'trackLine/trackLine.css', 
    publishAs: 'cmp')
class TrackLineComponent {
  @NgAttr('number')
  String number;

  String get label => "Track " + number;

  @NgTwoWay('cells')
  List<TrackLineCell> cells;

  Scope _scope;
  TrackLineComponent(this._scope);
    
  bool _clearCellAllowed = false;
  void drop(MouseEvent e, int index) {

    if (cells[index] != null) return;

    String id = e.dataTransfer.getData('Id');
    if (id != (e.currentTarget as Element).id) _clearCellAllowed = true;

    String sampleName = e.dataTransfer.getData('SampleName');
    String sampleHref = e.dataTransfer.getData('SampleHref');

    cells[index] = new TrackLineCell(sampleName, sampleHref);
    
    _scope.emit('sampleAdded', [index, sampleHref]);
  }

  bool _ctrlPressed;
  void allowDrop(MouseEvent e) {
    _ctrlPressed = e.ctrlKey;
    e.preventDefault();
  }

  void onItemDragged(int index) {
    
    if (!_ctrlPressed && _clearCellAllowed) removeSample(index);

    _ctrlPressed = false;
    _clearCellAllowed = false;
  }
  
  void removeSample (int index){
    
    _scope.emit('sampleRemoved', [index, cells[index].href]);
    
    cells[index] = null;
  }
}

class TrackLineCell {

  String sampleName;
  String href;

  TrackLineCell(this.sampleName, this.href);

  TrackLineCell.fromJSON(String jsonString) {
    Map storedTrackLine = JSON.decode(jsonString);
    sampleName = storedTrackLine['n'] == "null" ? '' : storedTrackLine['n'];
    href = storedTrackLine['h'] == "null" ? '' : storedTrackLine['h'];
  }

  String toJson() {
    return '{ "n": "$sampleName", "h": "$href" } ';
  }
}
