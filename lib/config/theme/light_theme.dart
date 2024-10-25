import 'package:flutter/material.dart';

const Color _turquoiseLight = Color(0xFF425C5A); 
const Color _orangeLight = Color.fromARGB(255, 141, 236, 90);
const Color _pers = Color(0xFF425C5A);
const Color _blackColor = Colors.black;
const Color _bodyTextColor = Colors.black87; // Puedes ajustar la opacidad

ThemeData lightTheme = ThemeData.from(
  colorScheme: const ColorScheme.light(
    primary: _pers,
    secondary: _turquoiseLight,
    onPrimary: _blackColor, // Color de texto sobre el primary
    onSecondary:
        _blackColor, // Color de texto sobre el secondary// Color de texto sobre el fondo
    onSurface: _blackColor, // Color de texto sobre elementos de la interfaz
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: _blackColor, // Color para título grande
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.bold,
      color: _blackColor, // Color para título mediano
    ),
    titleSmall: TextStyle(
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.bold,
      color:
          _turquoiseLight, // Mantén este color si lo prefieres para títulos pequeños
    ),
    bodyLarge: TextStyle(
      color: _bodyTextColor, // Color para texto del cuerpo
    ),
    bodyMedium: TextStyle(
      color: _bodyTextColor, // Color para texto del cuerpo
    ),
  ),
).copyWith(
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: _blackColor, // Asegurar que el título del AppBar sea negro
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: const IconThemeData(
    color: _orangeLight,
  ),
);
