import 'dart:html';
import 'package:polymer/polymer.dart';

PolymerElement selector;

void main() {
  initPolymer();
  
  selector = querySelector('region-selector');
  selector.onMouseMove.listen(updateCoordinates);
  querySelector('#coords').text = "(${selector.regionStart},${selector.regionStop})";
}

void updateCoordinates(MouseEvent e) {
  querySelector('#coords').text = "(${selector.regionStart},${selector.regionStop})";
}