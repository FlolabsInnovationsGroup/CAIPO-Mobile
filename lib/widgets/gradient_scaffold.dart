import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

/// A custom scaffold widget that provides a gradient background
/// and applies consistent styling from the ThemeProvider.
class GradientScaffold extends StatelessWidget {
  /// The primary content of the scaffold
  final Widget body;
  
  /// Optional app bar at the top of the scaffold
  final PreferredSizeWidget? appBar;
  
  /// Optional floating action button
  final Widget? floatingActionButton;
  
  /// Optional location for the floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  
  /// Optional bottom navigation bar
  final Widget? bottomNavigationBar;
  
  /// Optional drawer (e.g., for navigation menu)
  final Widget? drawer;
  
  /// Optional endDrawer (typically on the right side)
  final Widget? endDrawer;
  
  /// Whether to use the scaffoldGradient from ThemeProvider
  /// If false, uses a simpler gradient
  final bool useThemeGradient;
  
  /// Optional custom gradient to override the theme gradient
  final Gradient? customGradient;
  
  /// Whether to add a subtle pattern overlay to the gradient
  final bool usePatternOverlay;
  
  /// Optional custom padding for the scaffold body
  final EdgeInsetsGeometry? padding;
  
  /// Optional extra app bar elevation
  final double? appBarElevation;
  
  /// Optional callback for when the back button is pressed
  final Future<bool> Function()? onWillPop;
  
  /// Whether to resize the scaffold to avoid the bottom inset
  final bool? resizeToAvoidBottomInset;

  /// Creates a GradientScaffold with a consistent theme-based gradient
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.useThemeGradient = true,
    this.customGradient,
    this.usePatternOverlay = false,
    this.padding,
    this.appBarElevation,
    this.onWillPop,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    // Determine which gradient to use
    final gradient = customGradient ?? 
      (useThemeGradient && themeProvider.scaffoldGradient != null 
        ? themeProvider.scaffoldGradient! 
        : _getSimpleGradient(isDarkMode));
    
    // Build the scaffold with optional WillPopScope
    Widget scaffold = Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(appBar, themeProvider, isDarkMode),
          body: padding != null 
              ? Padding(padding: padding!, child: body) 
              : body,
          drawer: drawer,
          endDrawer: endDrawer,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
      ),
    );
    
    // Add pattern overlay if requested
    if (usePatternOverlay) {
      scaffold = Stack(
        children: [
          scaffold,
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 0.03 : 0.05,
              child: Image.asset(
                isDarkMode ? 'assets/pattern_dark.png' : 'assets/pattern_light.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ],
      );
    }
    
    // Add WillPopScope if onWillPop is provided
    if (onWillPop != null) {
      return WillPopScope(
        onWillPop: onWillPop!,
        child: scaffold,
      );
    }
    
    return scaffold;
  }
  
  /// Builds a customized AppBar if one is provided
  PreferredSizeWidget? _buildAppBar(
    PreferredSizeWidget? originalAppBar, 
    ThemeProvider themeProvider,
    bool isDarkMode,
  ) {
    if (originalAppBar == null) return null;
    
    // If the original app bar is an AppBar, customize it
    if (originalAppBar is AppBar) {
      return AppBar(
        // Copy all properties from the original AppBar
        title: originalAppBar.title,
        actions: originalAppBar.actions,
        leading: originalAppBar.leading,
        automaticallyImplyLeading: originalAppBar.automaticallyImplyLeading,
        flexibleSpace: originalAppBar.flexibleSpace,
        bottom: originalAppBar.bottom,
        centerTitle: originalAppBar.centerTitle,
        toolbarHeight: originalAppBar.toolbarHeight,
        toolbarTextStyle: originalAppBar.toolbarTextStyle,
        
        // Override certain properties with theme-based styling
        backgroundColor: originalAppBar.backgroundColor ?? 
            (isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.8)),
        elevation: appBarElevation ?? originalAppBar.elevation ?? 0,
        iconTheme: originalAppBar.iconTheme ?? const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: originalAppBar.titleTextStyle ?? const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    // If it's not an AppBar, return the original
    return originalAppBar;
  }
  
  /// Returns a simple gradient based on dark/light mode
  Gradient _getSimpleGradient(bool isDarkMode) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D),
            ]
          : [
              const Color(0xFFF5F5F5), // Very light gray
              Colors.white,
            ],
    );
  }
}