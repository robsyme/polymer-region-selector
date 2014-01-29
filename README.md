polymer-region-selector
=======================

A widget that selects max and min bounds on a genomic sequence of a given length. This is my first forey into Dart and Polymer, so expect things to change.

Usage is pretty easy. In the header, include:

    <link rel="import" href="../lib/region_selector.html">

Somewhere in your html, put something like

          <region-selector id="my-selector" totalLength="1000"></region-selector>

This will render something like:

![Example region selector](img/selector.png)