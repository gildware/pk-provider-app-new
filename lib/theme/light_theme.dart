import 'package:flutter/material.dart';

import 'app_text_theme.dart';
import 'custom_theme_colors.dart';
import 'theme_palette.dart';
import 'time_picker_theme.dart';

ThemeData light = ThemeData(
  fontFamily: 'Outfit',
  primaryColor: const Color(0xFF25274D),
  primaryColorLight: ThemePalette.lightForegroundOnBrand,
  primaryColorDark: const Color(0xff1A1C38),
  scaffoldBackgroundColor: ThemePalette.lightSurface,
  cardColor: ThemePalette.lightCard,
  shadowColor: const Color(0xFFD1D5DB),
  canvasColor: ThemePalette.lightCard,
  secondaryHeaderColor: const Color(0xFF8797AB),
  disabledColor: const Color(0xFF9E9E9E),
  brightness: Brightness.light,
  hintColor: const Color(0xFF838383),
  focusColor: const Color(0xFFFEFEFE),
  hoverColor: const Color(0xFF25274D),
  dividerColor: ThemePalette.lightBorder,
  textTheme: AppTextTheme.light,
  iconTheme: const IconThemeData(color: ThemePalette.lightText),
  listTileTheme: const ListTileThemeData(
    textColor: ThemePalette.lightText,
    iconColor: ThemePalette.lightText,
  ),
  extensions: <ThemeExtension<CustomThemeColors>>[
    CustomThemeColors.light(),
  ],
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF25274D),
    onPrimary: ThemePalette.lightForegroundOnBrand,
    onSurface: ThemePalette.lightText,
    secondary: Color(0xff3979E1),
    tertiary: Color(0xffF58F2A),
    onTertiary: Color(0xFFffda6d),
    onSecondaryContainer: Color(0xFF3E9665),
  ).copyWith(
    surface: ThemePalette.lightSurface,
    error: const Color(0xFFFF6767),
  ),
  timePickerTheme: AppTimePickerTheme.forBrightness(Brightness.light),
  datePickerTheme: const DatePickerThemeData(),
  dividerTheme: const DividerThemeData(thickness: 0.5),
);