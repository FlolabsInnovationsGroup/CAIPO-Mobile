import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class TranscriptionModel {
  final String id;
  final String name;
  final String description;
  final bool isPremium;
  final List<String> supportedLanguages;
  final Map<String, dynamic> capabilities;
  
  const TranscriptionModel({
    required this.id,
    required this.name,
    required this.description,
    this.isPremium = false,
    required this.supportedLanguages,
    required this.capabilities,
  });
}

class TranscriptionModelMenu extends StatefulWidget {
  final TranscriptionModel selectedModel;
  final List<TranscriptionModel> availableModels;
  final Function(TranscriptionModel) onModelSelected;
  final VoidCallback? onClose;
  
  const TranscriptionModelMenu({
    super.key,
    required this.selectedModel,
    required this.availableModels,
    required this.onModelSelected,
    this.onClose,
  });

  @override
  State<TranscriptionModelMenu> createState() => _TranscriptionModelMenuState();
}

class _TranscriptionModelMenuState extends State<TranscriptionModelMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(themeProvider.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: themeProvider.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select AI Model',
                          style: themeProvider.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: widget.onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Models List
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.availableModels.length,
                    itemBuilder: (context, index) {
                      final model = widget.availableModels[index];
                      final isSelected = model.id == widget.selectedModel.id;
                      
                      return _buildModelItem(
                        model: model,
                        isSelected: isSelected,
                        themeProvider: themeProvider,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                ),
                
                const Divider(height: 1),
                
                // Footer with info
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: themeProvider.accentColor.withOpacity(0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Premium models offer higher accuracy and more features',
                          style: themeProvider.bodySmall.copyWith(
                            color: themeProvider.secondaryTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildModelItem({
    required TranscriptionModel model,
    required bool isSelected,
    required ThemeProvider themeProvider,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: () {
        widget.onModelSelected(model);
        widget.onClose?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? themeProvider.accentColor.withOpacity(isDarkMode ? 0.2 : 0.1)
              : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model icon with premium badge if applicable
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.smart_toy,
                      color: themeProvider.accentColor,
                      size: 20,
                    ),
                  ),
                ),
                if (model.isPremium)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Model info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        model.name,
                        style: themeProvider.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? themeProvider.accentColor : themeProvider.primaryTextColor,
                        ),
                      ),
                      if (model.isPremium) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRO',
                            style: themeProvider.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model.description,
                    style: themeProvider.bodySmall.copyWith(
                      color: themeProvider.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Capabilities
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (model.capabilities.containsKey('speakerDiarization') &&
                          model.capabilities['speakerDiarization'] as bool)
                        _buildCapabilityChip(
                          'Speaker ID',
                          Icons.people,
                          themeProvider,
                          isDarkMode,
                        ),
                        
                      if (model.capabilities.containsKey('multilingual') &&
                          model.capabilities['multilingual'] as bool)
                        _buildCapabilityChip(
                          'Multilingual',
                          Icons.language,
                          themeProvider,
                          isDarkMode,
                        ),
                        
                      if (model.capabilities.containsKey('realtime') &&
                          model.capabilities['realtime'] as bool)
                        _buildCapabilityChip(
                          'Real-time',
                          Icons.timelapse,
                          themeProvider,
                          isDarkMode,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: themeProvider.accentColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCapabilityChip(
    String label,
    IconData icon,
    ThemeProvider themeProvider,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: themeProvider.bodySmall.copyWith(
              fontSize: 10,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// Sample model data
final List<TranscriptionModel> sampleModels = [
  TranscriptionModel(
    id: 'caipo-standard',
    name: 'CAIPO Standard',
    description: 'General purpose transcription with good accuracy',
    isPremium: false,
    supportedLanguages: ['English', 'Spanish', 'French', 'German', 'Italian'],
    capabilities: {
      'speakerDiarization': false,
      'multilingual': false,
      'realtime': true,
    },
  ),
  TranscriptionModel(
    id: 'caipo-premium',
    name: 'CAIPO Premium',
    description: 'Enhanced accuracy with speaker identification',
    isPremium: true,
    supportedLanguages: [
      'English', 'Spanish', 'French', 'German', 'Italian',
      'Japanese', 'Chinese', 'Korean', 'Portuguese', 'Russian',
    ],
    capabilities: {
      'speakerDiarization': true,
      'multilingual': true,
      'realtime': true,
    },
  ),
  TranscriptionModel(
    id: 'caipo-specialized',
    name: 'CAIPO Medical',
    description: 'Specialized for medical terminology and dictation',
    isPremium: true,
    supportedLanguages: ['English'],
    capabilities: {
      'speakerDiarization': true,
      'multilingual': false,
      'realtime': false,
    },
  ),
  TranscriptionModel(
    id: 'caipo-legal',
    name: 'CAIPO Legal',
    description: 'Specialized for legal terminology and proceedings',
    isPremium: true,
    supportedLanguages: ['English'],
    capabilities: {
      'speakerDiarization': true,
      'multilingual': false,
      'realtime': false,
    },
  ),
]; 