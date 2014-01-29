import 'dart:html';
import 'package:polymer/polymer.dart';

PolymerElement selector;

void main() {
  initPolymer();
  print("Hi there, from run.dart");
  
  selector = querySelector('region-selector');
  selector.onMouseMove.listen(updateCoordinates);
  querySelector('#coords').text = "(${selector.regionStart},${selector.regionStop})";
}

void updateCoordinates(MouseEvent e) {
  querySelector('#coords').text = "(${selector.regionStart},${selector.regionStop})";
}