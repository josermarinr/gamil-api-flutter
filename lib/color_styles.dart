import 'package:flutter/material.dart';

/// Interface for your base styles.
/// Add more styles here and then implement in
/// light_theme_colors.dart and dark_theme_colors.dart.
///
abstract class ColorStyles {
  /// * Available styles *

  static const Color primary = Color(0xfff2f9fe);
  static const Color secondary = Color(0xFFdbe4f3);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Colors.grey;
  static const Color red = Color(0xFFec5766);
  static const Color green = Color(0xFF43aa8b);
  static const Color blue = Color(0xFF28c2ff);
  static const Color buttoncolor = Color(0xff3e4784);
  static const Color mainFontColor = Color(0xff565c95);
  static const Color arrowbgColor = Color(0xffe4e9f7);
  
  // general
  Color get background;
  Color get primaryContent;
  Color get primaryAccent;

  Color get surfaceBackground;
  Color get surfaceContent;

  // app bar
  Color get appBarBackground;
  Color get appBarPrimaryContent;

  // buttons
  Color get buttonBackground;
  Color get buttonPrimaryContent;

  // bottom tab bar
  Color get bottomTabBarBackground;

  // bottom tab bar - icons
  Color get bottomTabBarIconSelected;
  Color get bottomTabBarIconUnselected;

  // bottom tab bar - label
  Color get bottomTabBarLabelUnselected;
  Color get bottomTabBarLabelSelected;

  // e.g. add a new style
  // Uncomment the below:
  // Color get iconBackground;

  // Then implement in color in:
  // /resources/themes/styles/light_theme_colors
  // /resources/themes/styles/dark_theme_colors
}
