import 'package:flutter/material.dart';
import '../utils/animation_constants.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> navigateTo<T>(Widget page, {bool slide = true}) {
    final route = slide 
        ? AnimationConstants.slideTransition<T>(page)
        : AnimationConstants.fadeTransition<T>(page);
    
    return navigatorKey.currentState!.push(route);
  }

  static Future<T?> replaceTo<T>(Widget page, {bool slide = true}) {
    final route = slide 
        ? AnimationConstants.slideTransition<T>(page)
        : AnimationConstants.fadeTransition<T>(page);
    
    return navigatorKey.currentState!.pushReplacement(route);
  }

  static void goBack<T>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: navigatorKey.currentState!.context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(navigatorKey.currentState!.context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AnimationConstants.fadeInWidget(
          AnimationConstants.scaleInWidget(child),
        );
      },
      transitionDuration: AnimationConstants.mediumDuration,
    );
  }
} 