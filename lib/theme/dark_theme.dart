
import 'package:flutter/material.dart';

import 'app_text_theme.dart';
import 'custom_theme_colors.dart';
import 'theme_palette.dart';
import 'time_picker_theme.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Outfit',
  primaryColor: const Color(0xFF25274D),
  primaryColorLight: ThemePalette.darkForegroundOnBrand,
  primaryColorDark: ThemePalette.darkText,
  scaffoldBackgroundColor: ThemePalette.darkScaffold,
  cardColor: ThemePalette.darkCard,
  shadowColor: ThemePalette.invert(const Color(0xFFD1D5DB)),
  canvasColor: ThemePalette.darkScaffold,
  secondaryHeaderColor: ThemePalette.darkTextSecondary,
  disabledColor: const Color(0xFF484848),
  brightness: Brightness.dark,
  hintColor: ThemePalette.darkTextSecondary,
  focusColor: ThemePalette.darkMutedSurface,
  hoverColor: ThemePalette.darkTextSecondary,
  dividerColor: ThemePalette.darkBorder,
  textTheme: AppTextTheme.dark,
  iconTheme: const IconThemeData(color: ThemePalette.darkText),
  listTileTheme: const ListTileThemeData(
    textColor: ThemePalette.darkText,
    iconColor: ThemePalette.darkText,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ThemePalette.darkCard,
    foregroundColor: ThemePalette.darkText,
    iconTheme: IconThemeData(color: ThemePalette.darkText),
    titleTextStyle: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: ThemePalette.darkText,
    ),
  ),
  timePickerTheme: AppTimePickerTheme.forBrightness(Brightness.dark),
  datePickerTheme: const DatePickerThemeData(backgroundColor: Color(0xFF25274D)),
  extensions: <ThemeExtension<CustomThemeColors>>[
    CustomThemeColors.dark(),
  ],
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF25274D),
    onPrimary: ThemePalette.darkText,
    onSurface: ThemePalette.darkText,
    secondary: Color(0xFF033969),
    onSecondaryContainer: Color(0xFF3E9665),
    tertiary: Color(0xffe78c35),
    onTertiary: Color(0xffe8b41d),
    error: Color(0xFFdd3135),
  ).copyWith(surface: ThemePalette.darkSurface),
  dividerTheme: const DividerThemeData(thickness: 0.5),
);
