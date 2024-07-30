import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  // accentColor: Colors.amber,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  // Autres propriétés du thème...
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  // accentColor: Colors.orange,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.dark,
  // Autres propriétés du thème...
);
