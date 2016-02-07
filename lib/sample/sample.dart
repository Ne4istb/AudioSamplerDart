library sample;

import 'dart:html';

import 'package:angular2/core.dart';

import 'package:audioSampler/singleAudioContext.dart';
import 'package:audioSampler/models/sample.dart';

@Component(selector: 'sample', templateUrl: 'sample.html', styleUrls: const ['sample.css'])
class SampleComponent {

  String id;

  @Input() String name;
  @Input() String href;

  @Output() EventEmitter onItemDragged = new EventEmitter();
  @Output() EventEmitter onRightClick = new EventEmitter();

  void onDragStart(MouseEvent e) {
    print('onDragStart');
    e.dataTransfer.setData('id', (e.currentTarget as Element).id);
    e.dataTransfer.setData('SampleName', name);
    e.dataTransfer.setData('SampleHref', href);
  }

  void onDragEnd(MouseEvent e) {
    print('dragend');
    onItemDragged.emit(e);
  }

  void onContextMenu(Event e) {
    onRightClick.emit(e);
    e.preventDefault();
  }

  void playSample() {
    new SingleAudioContext().stopAll();
    new Sample(href).play();
  }

  get background => 'linear-gradient(to top, ${_getColors()})';

  String _getColors() {
    if (href.contains("beat")) return '#3F3EE5, #3E93E5';
    if (href.contains("key")) return '#97218D, #D86FCF';
    if (href.contains("guitar")) return '#E5983E, #DBAC75';
    if (href.contains("bass")) return '#2B4C20, #4F9C35';
    return '#CBA610, #D4BD5E';
  }
}
