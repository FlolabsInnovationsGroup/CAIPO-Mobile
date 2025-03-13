import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../widgets/export_transcription_dialog.dart';

class TranscriptionExporter {
  /// Exports transcription data to a file in the specified format
  static Future<String> exportTranscription({
    required Map<String, dynamic> transcriptionData,
    required ExportFormat format,
    required bool includeTimestamps,
    required bool includeConfidence,
  }) async {
    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    
    // Generate a filename based on format and current timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'transcription_$timestamp${_getFileExtension(format)}';
    final filePath = '${directory.path}/$fileName';
    
    // Create the file content based on the format
    String content = '';
    switch (format) {
      case ExportFormat.plainText:
        content = _formatAsPlainText(transcriptionData);
        break;
      case ExportFormat.richText:
        content = _formatAsRichText(transcriptionData, includeTimestamps, includeConfidence);
        break;
      case ExportFormat.json:
        content = _formatAsJson(transcriptionData, includeTimestamps);
        break;
      case ExportFormat.srt:
        content = _formatAsSrt(transcriptionData);
        break;
      case ExportFormat.vtt:
        content = _formatAsVtt(transcriptionData);
        break;
      case ExportFormat.docx:
        // For DOCX, we'd typically use a package like 'docx' to generate the file
        // This is a placeholder - you'd need to implement actual DOCX generation
        content = _formatAsPlainText(transcriptionData);
        break;
    }
    
    // Write the content to the file
    final file = File(filePath);
    await file.writeAsString(content);
    
    return filePath;
  }
  
  /// Returns the file extension for the given format
  static String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.plainText:
        return '.txt';
      case ExportFormat.richText:
        return '.rtf';
      case ExportFormat.json:
        return '.json';
      case ExportFormat.srt:
        return '.srt';
      case ExportFormat.vtt:
        return '.vtt';
      case ExportFormat.docx:
        return '.docx';
    }
  }
  
  /// Formats transcription data as plain text
  static String _formatAsPlainText(Map<String, dynamic> transcriptionData) {
    // Extract the text from the transcription data
    final text = transcriptionData['text'] ?? '';
    return text;
  }
  
  /// Formats transcription data as rich text (RTF)
  static String _formatAsRichText(Map<String, dynamic> transcriptionData, bool includeTimestamps, bool includeConfidence) {
    // Simple RTF formatting - in a real app, you'd want to use a proper RTF library
    String rtf = '{\\rtf1\\ansi\\ansicpg1252\\cocoartf2580\\cocoasubrtf220\n';
    rtf += '{\\fonttbl\\f0\\fswiss\\fcharset0 Helvetica;}\n';
    rtf += '{\\colortbl;\\red0\\green0\\blue0;\\red128\\green128\\blue128;}\n';
    rtf += '\\margl1440\\margr1440\\vieww11520\\viewh8400\\viewkind0\n';
    rtf += '\\pard\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\tx5040\\tx5760\\tx6480\\tx7200\\tx7920\\tx8640\\pardirnatural\\partightenfactor0\n\n';
    
    // Add the transcription text
    rtf += '\\f0\\fs24 \\cf0 ';
    
    if (includeTimestamps || includeConfidence) {
      final segments = transcriptionData['segments'] as List<dynamic>? ?? [];
      
      for (final segment in segments) {
        if (includeTimestamps) {
          final start = segment['start'] ?? 0.0;
          final end = segment['end'] ?? 0.0;
          rtf += '\\cf2 [${_formatTime(start)} - ${_formatTime(end)}] \\cf0 ';
        }
        
        rtf += segment['text'] ?? '';
        
        if (includeConfidence) {
          final confidence = segment['confidence'] ?? 0.0;
          rtf += ' \\cf2 (${(confidence * 100).toStringAsFixed(1)}%)\\cf0 ';
        }
        
        rtf += '\\par\n';
      }
    } else {
      rtf += transcriptionData['text'] ?? '';
    }
    
    rtf += '\n}';
    
    return rtf;
  }
  
  /// Formats transcription data as JSON
  static String _formatAsJson(Map<String, dynamic> transcriptionData, bool includeTimestamps) {
    Map<String, dynamic> exportData = {};
    
    if (includeTimestamps) {
      // Include all data
      exportData = Map.from(transcriptionData);
    } else {
      // Only include the text
      exportData = {
        'text': transcriptionData['text'] ?? '',
        'language': transcriptionData['language'] ?? 'en',
      };
    }
    
    return JsonEncoder.withIndent('  ').convert(exportData);
  }
  
  /// Formats transcription data as SubRip (SRT) format
  static String _formatAsSrt(Map<String, dynamic> transcriptionData) {
    String srt = '';
    final segments = transcriptionData['segments'] as List<dynamic>? ?? [];
    
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final start = _formatSrtTime(segment['start'] ?? 0.0);
      final end = _formatSrtTime(segment['end'] ?? 0.0);
      final text = segment['text'] ?? '';
      
      srt += '${i + 1}\n';
      srt += '$start --> $end\n';
      srt += '$text\n\n';
    }
    
    return srt;
  }
  
  /// Formats transcription data as WebVTT format
  static String _formatAsVtt(Map<String, dynamic> transcriptionData) {
    String vtt = 'WEBVTT\n\n';
    final segments = transcriptionData['segments'] as List<dynamic>? ?? [];
    
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final start = _formatVttTime(segment['start'] ?? 0.0);
      final end = _formatVttTime(segment['end'] ?? 0.0);
      final text = segment['text'] ?? '';
      
      vtt += '${i + 1}\n';
      vtt += '$start --> $end\n';
      vtt += '$text\n\n';
    }
    
    return vtt;
  }
  
  /// Formats time in seconds to HH:MM:SS format
  static String _formatTime(double seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).floor().toString().padLeft(2, '0');
    
    return '$hours:$minutes:$secs';
  }
  
  /// Formats time in seconds to SRT time format (HH:MM:SS,mmm)
  static String _formatSrtTime(double seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).floor().toString().padLeft(2, '0');
    final millis = ((seconds * 1000) % 1000).floor().toString().padLeft(3, '0');
    
    return '$hours:$minutes:$secs,$millis';
  }
  
  /// Formats time in seconds to WebVTT time format (HH:MM:SS.mmm)
  static String _formatVttTime(double seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).floor().toString().padLeft(2, '0');
    final millis = ((seconds * 1000) % 1000).floor().toString().padLeft(3, '0');
    
    return '$hours:$minutes:$secs.$millis';
  }
} 