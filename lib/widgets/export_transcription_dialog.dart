import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/transcription_exporter.dart';
import 'package:share_plus/share_plus.dart';

// Add the missing enum definition
enum ExportFormat {
  plainText,
  richText,
  json,
  srt,
  vtt,
  docx,
}

class ExportTranscriptionDialog extends StatefulWidget {
  final Map<String, dynamic> transcriptionData;
  
  const ExportTranscriptionDialog({
    super.key,
    required this.transcriptionData,
  });

  @override
  _ExportTranscriptionDialogState createState() => _ExportTranscriptionDialogState();
}

class _ExportTranscriptionDialogState extends State<ExportTranscriptionDialog> {
  ExportFormat _selectedFormat = ExportFormat.plainText;
  bool _includeTimestamps = true;
  bool _includeConfidence = false;
  bool _isExporting = false;
  String? _errorMessage;
  
  Widget _buildFormatSelection(ThemeProvider themeProvider, bool isDarkMode) {
    final formatOptions = [
      {'format': ExportFormat.plainText, 'label': 'Plain Text (.txt)', 'icon': Icons.text_snippet},
      {'format': ExportFormat.richText, 'label': 'Rich Text (.rtf)', 'icon': Icons.text_format},
      {'format': ExportFormat.json, 'label': 'JSON (.json)', 'icon': Icons.code},
      {'format': ExportFormat.srt, 'label': 'SubRip (.srt)', 'icon': Icons.closed_caption},
      {'format': ExportFormat.vtt, 'label': 'WebVTT (.vtt)', 'icon': Icons.subtitles},
      {'format': ExportFormat.docx, 'label': 'Word (.docx)', 'icon': Icons.description},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: formatOptions.map((option) {
          final format = option['format'] as ExportFormat;
          final isSelected = _selectedFormat == format;
          
          return InkWell(
            onTap: () {
              setState(() {
                _selectedFormat = format;
              });
            },
            borderRadius: BorderRadius.circular(themeProvider.borderRadius / 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? themeProvider.accentColor.withOpacity(isDarkMode ? 0.2 : 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    option['icon'] as IconData,
                    color: isSelected
                        ? themeProvider.accentColor
                        : themeProvider.secondaryIconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option['label'] as String,
                    style: themeProvider.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? themeProvider.accentColor
                          : themeProvider.primaryTextColor,
                    ),
                  ),
                  const Spacer(),
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
        }).toList(),
      ),
    );
  }
  
  Widget _buildOptionsSection(ThemeProvider themeProvider, bool isDarkMode) {
    // Determine which options to show based on selected format
    final showTimestamps = _selectedFormat != ExportFormat.plainText;
    final showConfidence = _selectedFormat == ExportFormat.richText || 
                          _selectedFormat == ExportFormat.docx;
    
    if (!showTimestamps && !showConfidence) {
      return Text(
        'No additional options available for this format.',
        style: themeProvider.bodyMedium.copyWith(
          color: themeProvider.secondaryTextColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Column(
      children: [
        if (showTimestamps)
          SwitchListTile(
            title: Text(
              'Include Timestamps',
              style: themeProvider.bodyMedium,
            ),
            subtitle: Text(
              'Add time markers to the transcription',
              style: themeProvider.bodySmall.copyWith(
                color: themeProvider.secondaryTextColor,
              ),
            ),
            value: _includeTimestamps,
            onChanged: (value) {
              setState(() {
                _includeTimestamps = value;
              });
            },
            activeColor: themeProvider.accentColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          
        if (showConfidence)
          SwitchListTile(
            title: Text(
              'Include Confidence Scores',
              style: themeProvider.bodyMedium,
            ),
            subtitle: Text(
              'Show AI confidence level for each segment',
              style: themeProvider.bodySmall.copyWith(
                color: themeProvider.secondaryTextColor,
              ),
            ),
            value: _includeConfidence,
            onChanged: (value) {
              setState(() {
                _includeConfidence = value;
              });
            },
            activeColor: themeProvider.accentColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
      ],
    );
  }
  
  // Handle the export process
  Future<void> _handleExport() async {
    try {
      setState(() {
        _isExporting = true;
        _errorMessage = null;
      });
      
      // Export the file
      final filePath = await TranscriptionExporter.exportTranscription(
        transcriptionData: widget.transcriptionData,
        format: _selectedFormat,
        includeTimestamps: _includeTimestamps,
        includeConfidence: _includeConfidence,
      );
      
      // Close the dialog
      if (mounted) {
        Navigator.of(context).pop(filePath);
      }
      
      // Share the file
      await Share.shareFiles([filePath]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error exporting file: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeProvider.borderRadius),
      ),
      backgroundColor: isDarkMode
          ? Colors.grey.shade900
          : Colors.white,
      elevation: 8,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.file_download_outlined,
                    color: themeProvider.accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Export Transcription',
                    style: themeProvider.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Format selection
              Text(
                'File Format',
                style: themeProvider.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildFormatSelection(themeProvider, isDarkMode),
              const SizedBox(height: 24),
              
              // Options
              Text(
                'Options',
                style: themeProvider.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildOptionsSection(themeProvider, isDarkMode),
              const SizedBox(height: 24),
              
              // Error message if any
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: themeProvider.bodyMedium.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: themeProvider.textButtonStyle,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  _isExporting
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.file_download),
                          label: const Text('Export'),
                          onPressed: _handleExport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(themeProvider.borderRadius),
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 