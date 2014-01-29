import 'dart:svg';
import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';

@CustomTag('region-selector')
class RegionSelector extends PolymerElement {
  @published int totalLength;
  @observable int regionStart;
  @observable int regionStop;
  @observable double pxStart;
  @observable double pxStop;
  
  // Different types of dragging types
  static const _DRAGMODE_NODRAG = 0;
  static const _DRAGMODE_LEFT_ADJUST = 1;
  static const _DRAGMODE_RIGHT_ADJUST = 2;
  static const _DRAGMODE_TRANSLATE = 3;
  static const _DRAGMODE_RESET = 4;
  int _dragmode = _DRAGMODE_NODRAG;
  
  double pixelWidth;
  
  final double _BUFFER = 70.0;
  
  RegionSelector.created() : super.created() {
    regionStart = 0;
    regionStop = totalLength;
  }
  
  @override
  void enteredView() {
    super.enteredView();
    setupWidths();
    print("RegionSelector enteredView() - totalLength=$totalLength");
    window.onResize.listen(refreshWidths);
  }
  
  void setupWidths() {
    regionStop = totalLength;
    refreshWidths(new CustomEvent('dummy'));
  }
  
  void selectStartMarker(MouseEvent e) {
    _dragmode = _DRAGMODE_LEFT_ADJUST;
    e.stopPropagation();
  }
  
  void selectStopMarker(MouseEvent e) {
    _dragmode = _DRAGMODE_RIGHT_ADJUST;
    e.stopPropagation();
  }
  
  void selectMarkerRegion(MouseEvent e) {
    _dragmode = _DRAGMODE_TRANSLATE;
    e.stopPropagation();
  }
  
  void selectReset(MouseEvent e) {
    _dragmode = _DRAGMODE_RESET;
    double newPos = min(max(e.offset.x - _BUFFER, 0.0), pixelWidth - 1.0);
    pxStart = newPos;
    pxStop = newPos + 1;
    regionStart = translatePixelToCoords(pxStart);
    regionStop = translatePixelToCoords(pxStop);
  }
  
  double translateCoordsToPixels(int position) {
    return position / totalLength * pixelWidth;
  }
  
  int translatePixelToCoords(double pixel) {
    return (pixel / pixelWidth * totalLength).toInt();
  }
  
  void refreshWidths(Event e) {
    pixelWidth = $['minimap'].clientWidth - 2 * _BUFFER;
    pxStart = translateCoordsToPixels(regionStart);
    pxStop = translateCoordsToPixels(regionStop);
    $['minimapSelector'].attributes['transform'] = "translate($_BUFFER, 40)";
    redrawScale();
  }
  
  void mousewheel(WheelEvent e) {
    double frac = (pxStop - pxStart) * 0.05;
    if(e.deltaY > 0) {
      attemptStartPositionMove(pxStart + frac);
      attemptStopPositionMove(pxStop - frac);
    } else {
      attemptStartPositionMove(pxStart - frac);
      attemptStopPositionMove(pxStop + frac);
    }
    e.preventDefault();
  }
  
  void mousemove(MouseEvent e) {
    // Is a drag event happening right now?
    switch(_dragmode) {
      // If not, don't worry about anything.
      case _DRAGMODE_NODRAG :
        break;
      // If we're making an adjustent on the start position, update the pxStart variable.
      case _DRAGMODE_LEFT_ADJUST:
        attemptStartPositionMove(e.offset.x - _BUFFER);
        break;
      case _DRAGMODE_RIGHT_ADJUST:
        attemptStopPositionMove(e.offset.x - _BUFFER);
        break;
      case _DRAGMODE_TRANSLATE:
        attemptStartPositionMove(pxStart + e.movement.x);
        attemptStopPositionMove(pxStop + e.movement.x);
        break;
      case _DRAGMODE_RESET:
        attemptStopPositionMove(e.offset.x - _BUFFER);
    }
    e.preventDefault();
  }
  
  void attemptStartPositionMove(double requestedPosition) {
    // Is the requested position above the minimum?
    if (requestedPosition > 0) {
      // Is the requested position below pxStop?
      if (requestedPosition <= pxStop) {
        pxStart = requestedPosition.toDouble();
      } else {
        // We need to push pxStop to the right.
        // Is there room for pxStop to move?
        if(pxStop < pixelWidth) {
          pxStop = requestedPosition + 1.0;
          pxStart = requestedPosition.toDouble();
          regionStop = translatePixelToCoords(pxStop);
        }
      }
    } else {
      pxStart = 0.0;
    }
    regionStart = translatePixelToCoords(pxStart);
  }
  
  double attemptStopPositionMove(double requestedPosition) {
    // Is the request below the maximum?
    if (requestedPosition <= pixelWidth) {
      // Is the requested position above pxStart?
      if (requestedPosition >= pxStart) {
        pxStop = requestedPosition.toDouble();
      } else {
        // We need to push pxStarto the left.
        // Is there room for pxStart to move?
        if (pxStart > 0) {
          pxStart = requestedPosition - 1.0;
          pxStop = requestedPosition.toDouble();
          regionStart = translatePixelToCoords(pxStart);
        }
      }
    regionStop = translatePixelToCoords(pxStop);
    } else {
      pxStop = pixelWidth.toDouble();
      regionStop = totalLength;
    }
  }
  
  void endSelection(MouseEvent e) {
    _dragmode = _DRAGMODE_NODRAG;
    //regionStart = translatePixelToCoords(pxStart);
    //regionStop = translatePixelToCoords(pxStop);
  }
  
  void redrawScale() {
    GElement scaleGroup = $['scaleGroup'];
    scaleGroup.children.clear();
    scaleGroup.attributes['transform'] = "translate($_BUFFER, 30)";
    
    PathElement baseline = new PathElement();
    baseline.attributes['d'] = "M 0 8 v -16 m 0 8 h $pixelWidth m 0 -8 v 16";
    baseline.style.setProperty('fill', 'none');
    baseline.style.setProperty('stroke-linejoin', 'round');
    baseline.style.setProperty('stroke', 'steelblue');
    baseline.style.setProperty('stroke-width', '1');
    scaleGroup.children.add(baseline);
    
    String majorTickString = (totalLength / (pixelWidth / 100)).toStringAsExponential(0);
    String significance = majorTickString.split("+").last;
    int majorTickWidthBp = num.parse(majorTickString).toInt();
    double majorTickWidthPx = pixelWidth / totalLength * majorTickWidthBp;
    
    String suffix = "bp";
    switch(significance) {
      case "0":
      case "1":
      case "2":
        break;
      case "3":
      case "4":
      case "5":
        majorTickWidthBp = majorTickWidthBp ~/ 1000;
        suffix = "kbp";
        break;
      default:
        majorTickWidthBp = majorTickWidthBp ~/ 1000000;
        suffix = "Mbp";
    }
    
    int minorTickCount = 2;
    for (int i = 1; (i * majorTickWidthPx / minorTickCount) <= pixelWidth; i++) {
      String xString = (i * majorTickWidthPx / minorTickCount).toString();
      LineElement tickLine = new LineElement();
      tickLine.attributes['x1'] = xString;
      tickLine.attributes['x2'] = xString;
      tickLine.attributes['y1'] = '0';
      if (i % minorTickCount == 0) {
        TextElement tickLabel = new TextElement();
        tickLabel.text = "${i * majorTickWidthBp ~/ minorTickCount} ${suffix}";
        tickLabel.attributes['text-anchor'] = "middle";
        tickLabel.attributes['x'] = (i * majorTickWidthPx / minorTickCount).toString();
        tickLabel.attributes['y'] = "-12";
        scaleGroup.children.add(tickLabel);
        tickLine.attributes['y2'] = '-7';
      } else {
        tickLine.attributes['y2'] = '-3';
      }
      scaleGroup.children.add(tickLine);
    }
  }
}
