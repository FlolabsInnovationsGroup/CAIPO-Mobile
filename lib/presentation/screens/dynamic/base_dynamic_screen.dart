import 'package:flutter/material.dart';

abstract class BaseDynamicScreen extends StatefulWidget {
  final String command;
  final dynamic commandData;

  const BaseDynamicScreen({
    super.key,
    required this.command,
    this.commandData,
  });

  @override
  BaseDynamicScreenState createState();
}

abstract class BaseDynamicScreenState<T extends BaseDynamicScreen>
    extends State<T> with TickerProviderStateMixin {
  // Protected animation controllers and animations
  @protected
  late AnimationController backgroundController;

  @protected
  late Animation<Color?> backgroundStartAnimation;

  @protected
  late Animation<Color?> backgroundEndAnimation;

  // Screen transition animations
  late AnimationController _screenTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize background animations
    backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize screen transition animations
    _screenTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _screenTransitionController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _screenTransitionController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _screenTransitionController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    setupBackgroundAnimation();
    backgroundController.repeat(reverse: true);
    _screenTransitionController.forward();
  }

  @override
  void dispose() {
    backgroundController.dispose();
    _screenTransitionController.dispose();
    super.dispose();
  }

  @protected
  void setupBackgroundAnimation();

  @protected
  Widget buildScreenContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        backgroundController,
        _screenTransitionController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      backgroundStartAnimation.value ?? Colors.transparent,
                      backgroundEndAnimation.value ?? Colors.transparent,
                    ],
                  ),
                ),
                child: buildScreenContent(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
