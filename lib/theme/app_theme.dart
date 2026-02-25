import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Custom Colors class to avoid conflicts
class AppColors {
  static const primary = Color(0xFFD4E5D3); // Light green card background
  static const primaryDark = Color(0xFF006E1F); // Dark green
  static const primaryLight = Color(0xFFE8F6E8); // Very light green
  static const secondary = Color(0xFF6B7280); // Neutral gray
  static const accent = Color(0xFFD4E5D3); // Light green accent
  static const error = Color(0xFFD32F2F); // Darker red
  static const warning = Color(0xFFFFB74D);
  static const success = Color(0xFF006E1F); // Dark green

  // Gradient colors for UI effects
  static const gradientStart = Color(0xFFD4E5D3);
  static const gradientEnd = Color(0xFF006E1F);
  static const gradientLight = Color(0xFFE8F6E8);

  // ============================================================================
  // LIGHT THEME COLORS - Only affects light mode
  // ============================================================================
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF111827);
  static const lightOnBackground = Color(0xFF111827);

  // ============================================================================
  // DARK THEME COLORS - Only affects dark mode - EDIT THESE FOR DARK THEME
  // ============================================================================
  static const darkBackground = Color(0xFF1C211B); // Dark green-gray background
  static const darkSurface = Color(0xFF2B3C29); // Card background
  static const darkGreen = Color(
    0xFF7DDB7D,
  ); // DARK THEME: Primary accent color
  static const darkOnSurface = Color(0xFFFFFFFF);
  static const darkOnBackground = Color(0xFFFFFFFF);
}

class AppTheme {
  // Static color getters for backward compatibility
  static Color get primaryColor => AppColors.primary;
  static Color get secondaryColor => AppColors.secondary;
  static Color get errorColor => AppColors.error;
  static Color get warningColor => AppColors.warning;
  static Color get successColor => AppColors.success;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Off White background
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFD4E5D3), // Light Sage Green
        onPrimary: const Color(0xFF111827), // Charcoal text on light sage
        secondary: const Color(0xFF006E1F), // Forest Green for accents
        onSecondary: Colors.white,
        tertiary: AppColors.primaryLight, // Light green tertiary
        error: AppColors.error,
        onError: Colors.white,
        surface: const Color(0xFFD4E5D3), // Light Sage Green cards
        onSurface: const Color(0xFF111827), // Charcoal text
        background: const Color(0xFFFAFAFA), // Off White background
        onBackground: const Color(0xFF111827),
        surfaceContainer: const Color(
          0xFFD4E5D3,
        ), // Light Sage Green card backgrounds
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: AppColors.lightOnSurface,
          displayColor: AppColors.lightOnSurface,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF006E1F), // Forest Green
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // GREEN
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary, // GREEN
          side: BorderSide(color: AppColors.primary), // GREEN
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2), // GREEN
        ),
        labelStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 16),
        hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF2E7D32), // Dark green
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          } // GREEN
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          } // GREEN
          return null;
        }),
      ),
    );
  }

  // ============================================================================
  // DARK THEME IMPLEMENTATION - Only affects dark mode
  // ============================================================================
  // Edit colors below to customize dark theme appearance
  // All colors reference AppColors.dark* constants defined above
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor:
          AppColors.darkBackground, // DARK THEME: Scaffold background
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkGreen,
        onPrimary: Colors.black,
        secondary: AppColors.darkGreen, // DARK THEME: Secondary color
        onSecondary: Colors.white,
        tertiary: AppColors.darkGreen, // DARK THEME: Tertiary color
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        background: AppColors.darkBackground, // DARK THEME: Main background
        onBackground: AppColors.darkOnBackground,
        surfaceContainer: AppColors.darkSurface, // DARK THEME: Card backgrounds
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.darkOnSurface,
          displayColor: AppColors.darkOnSurface,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            AppColors.darkSurface, // DARK THEME: App bar matches cards
        foregroundColor: AppColors.darkOnSurface, // DARK THEME: White text
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen, // DARK THEME: Button background
          foregroundColor: Colors.black, // DARK THEME: Button text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.darkGreen, // DARK THEME: Outlined button text
          side: BorderSide(
            color: AppColors.darkGreen,
          ), // DARK THEME: Button border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface, // DARK THEME: Input field background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkGreen, // DARK THEME: Focused input border
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16),
        hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkGreen, // DARK THEME: FAB background
        foregroundColor: Colors.black, // DARK THEME: FAB icon color
        shape: const CircleBorder(),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkGreen; // DARK THEME: Selected checkbox color
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors
                .darkGreen; // DARK THEME: Selected radio button color
          }
          return null;
        }),
      ),
    );
  }

  // ============================================================================
  // END OF DARK THEME IMPLEMENTATION
  // ============================================================================
}

// Theme provider for switching between light and dark themes
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeMode();
    notifyListeners();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt(_themeKey);
      if (savedThemeIndex != null) {
        _themeMode = ThemeMode.values[savedThemeIndex];
        notifyListeners();
      }
    } catch (e) {
      // Handle any errors and use default theme
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      // Handle save error silently
    }
  }
}
