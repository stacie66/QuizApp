import 'package:flutter/material.dart';
import 'package:flashcards/src/utils/constants/colors.dart';

class TAppTheme {
  TAppTheme._();

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins',
    elevatedButtonTheme: _elevatedButtonThemeData,
    outlinedButtonTheme: _outlinedButtonThemeData,
    textButtonTheme: _textButtonThemeData,
    inputDecorationTheme: _inputDecorationThemeLight,
    appBarTheme: _appBarThemeLight,
    checkboxTheme: _checkboxThemeData,
    bottomNavigationBarTheme: _bottomNavigationBarThemeLight,
    textTheme: _textTheme,
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: TColors.dark,
    fontFamily: 'Poppins',
    elevatedButtonTheme: _elevatedButtonThemeData,
    outlinedButtonTheme: _outlinedButtonThemeData,
    textButtonTheme: _textButtonThemeData,
    inputDecorationTheme: _inputDecorationThemeDark,
    appBarTheme: _appBarThemeDark,
    checkboxTheme: _checkboxThemeData,
    bottomNavigationBarTheme: _bottomNavigationBarThemeDark,
    textTheme: _textTheme,
  );

  // Elevated Button Theme
  static final ElevatedButtonThemeData _elevatedButtonThemeData = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: TColors.primary,
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Outlined Button Theme
  static final OutlinedButtonThemeData _outlinedButtonThemeData = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TColors.primary,
      side: BorderSide(color: TColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: TextStyle(
        fontSize: 16,
        color: TColors.primary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Text Button Theme
  static final TextButtonThemeData _textButtonThemeData = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: TColors.primary,
      textStyle: TextStyle(
        fontSize: 16,
        color: TColors.primary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Input Decoration Theme (Light)
  static const InputDecorationTheme _inputDecorationThemeLight = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.all(16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: TColors.borderPrimary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: TColors.borderPrimary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: TColors.textPrimary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: TColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: TColors.error),
    ),
    labelStyle: TextStyle(color: TColors.textSecondary),
    hintStyle: TextStyle(color: TColors.textSecondary),
  );

  // Input Decoration Theme (Dark)
  static const InputDecorationTheme _inputDecorationThemeDark = InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2A2A2A),
    contentPadding: EdgeInsets.all(16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.white),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: TColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: TColors.error),
    ),
    labelStyle: TextStyle(color: Colors.white70),
    hintStyle: TextStyle(color: Colors.white70),
  );

  // App Bar Theme (Light)
  static final AppBarTheme _appBarThemeLight = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(color: TColors.black, size: 24),
    actionsIconTheme: const IconThemeData(color: TColors.black, size: 24),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.black,
    ),
  );

  // App Bar Theme (Dark)
  static final AppBarTheme _appBarThemeDark = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(color: TColors.white, size: 24),
    actionsIconTheme: const IconThemeData(color: TColors.white, size: 24),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.white,
    ),
  );

  // Checkbox Theme
  static CheckboxThemeData _checkboxThemeData = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    checkColor: MaterialStateProperty.resolveWith((states) {
      return Colors.white;
    }),
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return TColors.primary;
      }
      return Colors.transparent;
    }),
  );

  // Bottom Navigation Bar Theme (Light)
  static final BottomNavigationBarThemeData _bottomNavigationBarThemeLight =
  BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: TColors.primary,
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  );

  // Bottom Navigation Bar Theme (Dark)
  static final BottomNavigationBarThemeData _bottomNavigationBarThemeDark =
  BottomNavigationBarThemeData(
    backgroundColor: TColors.dark,
    selectedItemColor: TColors.primary,
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  );

  // Text Theme
  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.w500,
    ),
  );
}