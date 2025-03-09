import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: themeProvider.themeMode == ThemeMode.dark 
          ? Colors.black 
          : Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: themeProvider.scaffoldGradient,
          ),
          child: body,
        ),
      ),
    );
  }
}