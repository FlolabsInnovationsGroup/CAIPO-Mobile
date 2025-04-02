import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class SettingsCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final bool showBadge;
  final Color? accentColor;

  const SettingsCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.trailing,
    this.onTap,
    this.isHighlighted = false,
    this.showBadge = false,
    this.accentColor,
  });

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Theme.of(context).extension<ThemeProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = widget.accentColor ?? Theme.of(context).primaryColor;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isHighlighted
                    ? [
                        color.withOpacity(isDarkMode ? 0.2 : 0.1),
                        color.withOpacity(isDarkMode ? 0.1 : 0.05),
                      ]
                    : isDarkMode
                        ? [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.3),
                          ]
                        : [
                            Colors.white,
                            Colors.white.withOpacity(0.9),
                          ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? color.withOpacity(0.3)
                    : isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? color.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 10 : 5,
                  offset: Offset(0, _isHovered ? 5 : 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.trailing != null) ...[
                        const SizedBox(width: 16),
                        widget.trailing!,
                      ],
                    ],
                  ),
                ),
                if (widget.showBadge)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 