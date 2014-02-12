import 'dart:html';
import 'package:polymer/polymer.dart';

PolymerElement selector;

void main() {
  initPolymer().run(() {
    selector = querySelector('region-selector');
    selector.onMouseMove.listen(updateCoordinates);
    querySelector('#coords').text = "(${selector.regionStart},${selector.regionStop})";
    
    ButtonElement doubleButton = new ButtonElement()
    ..text = "Double region length"
    ..onClick.listen((MouseEvent e) {
      selector.totalLength *= 2;
      updateCoordinates(e);
    });
    
    ButtonElement halveButton = new ButtonElement()
    ..text = "Halve region length"
    ..onClick.listen((MouseEvent e) {
      selector.totalLength = selector.totalLength ~/ 2;
      updateCoordinates(e);
    });
    
    querySelector('body').children.add(halveButton);
    querySelector('body').children.add(doubleButton);
  });
}

void updateCoordinates(MouseEvent e) {
  querySelector('#coords').text = "(${selector.regionStart},${selector.regionStop})";
}