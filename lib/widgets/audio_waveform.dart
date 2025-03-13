import 'dart:math';
import 'package:flutter/material.dart';

/// A customizable audio waveform widget that visualizes audio amplitude data.
class AudioWaveform extends StatefulWidget {
  /// List of amplitude values (between 0.0 and 1.0)
  final List<double> samples;
  
  /// Width of each waveform bar
  final double barWidth;
  
  /// Gap between bars
  final double spacing;
  
  /// Current playback position (0.0 to 1.0)
  final double position;
  
  /// Color of bars that have been played
  final Color activeColor;
  
  /// Color of bars that have not been played
  final Color inactiveColor;
  
  /// Whether to animate changes to the samples
  final bool animate;
  
  /// Whether the waveform is being generated (shows pulsing animation)
  final bool isGenerating;
  
  /// Minimum height of bars (as a percentage of the container height)
  final double minBarHeight;
  
  const AudioWaveform({
    super.key,
    required this.samples,
    this.barWidth = 3.0,
    this.spacing = 2.0,
    this.position = 0.0,
    this.activeColor = Colors.blueAccent,
    this.inactiveColor = Colors.grey,
    this.animate = true,
    this.isGenerating = false,
    this.minBarHeight = 0.05,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<double> _currentSamples = [];
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    if (widget.isGenerating) {
      _animationController.repeat(reverse: true);
    }
    
    _currentSamples = List.filled(widget.samples.length, 0.0);
    
    if (!widget.animate) {
      _currentSamples = List.from(widget.samples);
      _initialized = true;
    }
  }
  
  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle animation state
    if (widget.isGenerating != oldWidget.isGenerating) {
      if (widget.isGenerating) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
    
    // Update samples if changed
    if (widget.samples.length != oldWidget.samples.length) {
      if (!widget.animate) {
        _currentSamples = List.from(widget.samples);
        _initialized = true;
      } else {
        // Initialize with new length but keep values for animation
        final newSamples = List.filled(widget.samples.length, 0.0);
        
        // Copy over any existing values that fit
        final minLength = min(_currentSamples.length, newSamples.length);
        for (int i = 0; i < minLength; i++) {
          newSamples[i] = _currentSamples[i];
        }
        
        _currentSamples = newSamples;
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Animate to new samples if needed
    if (widget.animate && !_initialized) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _currentSamples = List.from(widget.samples);
            _initialized = true;
          });
        }
      });
    } else if (widget.animate && _initialized) {
      // Gradually transition to new values
      for (int i = 0; i < min(_currentSamples.length, widget.samples.length); i++) {
        if (_currentSamples[i] != widget.samples[i]) {
          _currentSamples[i] = _currentSamples[i] + (widget.samples[i] - _currentSamples[i]) * 0.1;
        }
      }
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // Calculate how many bars can fit
        final barCount = ((width + widget.spacing) / (widget.barWidth + widget.spacing)).floor();
        
        // Adjust sample count to fit
        final List<double> displaySamples = [];
        if (barCount >= widget.samples.length) {
          // If we have more space than samples, use all samples
          displaySamples.addAll(_currentSamples);
        } else {
          // Otherwise, sample down to fit
          final samplesPerBar = widget.samples.length / barCount;
          for (int i = 0; i < barCount; i++) {
            final start = (i * samplesPerBar).floor();
            final end = ((i + 1) * samplesPerBar).floor();
            
            // Calculate average for this segment
            double sum = 0;
            for (int j = start; j < end && j < _currentSamples.length; j++) {
              sum += _currentSamples[j];
            }
            displaySamples.add(sum / (end - start));
          }
        }
        
        // Calculate position index
        final positionIndex = (widget.position * displaySamples.length).floor();
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Pulse factor for generating animation
            final pulseFactor = widget.isGenerating
                ? 0.7 + 0.3 * _animationController.value
                : 1.0;
                
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                displaySamples.length,
                (index) {
                  // Calculate bar height
                  final rawValue = displaySamples[index].clamp(0.0, 1.0);
                  final baseHeight = max(rawValue, widget.minBarHeight);
                  
                  // Apply pulse animation if generating
                  final barHeight = widget.isGenerating
                      ? baseHeight * pulseFactor
                      : baseHeight;
                  
                  // Determine if this bar is before or after the playhead
                  final isActive = index <= positionIndex;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : widget.spacing / 2,
                      right: index == displaySamples.length - 1 ? 0 : widget.spacing / 2,
                    ),
                    width: widget.barWidth,
                    height: height * barHeight,
                    decoration: BoxDecoration(
                      color: isActive ? widget.activeColor : widget.inactiveColor,
                      borderRadius: BorderRadius.circular(widget.barWidth / 2),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// A widget that generates waveform data from an audio file
class AudioWaveformGenerator extends StatefulWidget {
  /// Path to the audio file
  final String audioFilePath;
  
  /// Width of each waveform bar
  final double barWidth;
  
  /// Gap between bars
  final double spacing;
  
  /// Current playback position (0.0 to 1.0)
  final double position;
  
  /// Color of bars that have been played
  final Color activeColor;
  
  /// Color of bars that have not been played
  final Color inactiveColor;
  
  /// Number of samples to generate
  final int sampleCount;
  
  /// Duration of the audio in milliseconds
  final int audioDuration;
  
  const AudioWaveformGenerator({
    super.key,
    required this.audioFilePath,
    this.barWidth = 3.0,
    this.spacing = 2.0,
    this.position = 0.0,
    this.activeColor = Colors.blueAccent,
    this.inactiveColor = Colors.grey,
    this.sampleCount = 100,
    this.audioDuration = 0,
  });

  @override
  State<AudioWaveformGenerator> createState() => _AudioWaveformGeneratorState();
}

class _AudioWaveformGeneratorState extends State<AudioWaveformGenerator> {
  List<double> _samples = [];
  bool _isLoading = true;
  bool _isError = false;
  
  @override
  void initState() {
    super.initState();
    _generateWaveform();
  }
  
  @override
  void didUpdateWidget(AudioWaveformGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.audioFilePath != oldWidget.audioFilePath ||
        widget.sampleCount != oldWidget.sampleCount) {
      _generateWaveform();
    }
  }
  
  Future<void> _generateWaveform() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      
      // In a real app, you would analyze the audio file
      // For demo purposes, we'll generate random data
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final random = Random();
      
      // Create a semi-realistic waveform with varying amplitudes
      final samples = <double>[];
      
      // Generate a smoothed random waveform
      double prevValue = 0.2 + random.nextDouble() * 0.3;
      for (int i = 0; i < widget.sampleCount; i++) {
        // Apply some smoothing to make it look more natural
        final change = (random.nextDouble() - 0.5) * 0.2;
        final newValue = (prevValue + change).clamp(0.1, 0.9);
        samples.add(newValue);
        prevValue = newValue;
      }
      
      if (mounted) {
        setState(() {
          _samples = samples;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _samples = List.filled(widget.sampleCount, 0.2);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? AudioWaveform(
            samples: List.filled(widget.sampleCount, 0.2),
            barWidth: widget.barWidth,
            spacing: widget.spacing,
            position: widget.position,
            activeColor: widget.activeColor.withOpacity(0.5),
            inactiveColor: widget.inactiveColor.withOpacity(0.3),
            isGenerating: true,
          )
        : AudioWaveform(
            samples: _isError
                ? List.filled(widget.sampleCount, 0.2)
                : _samples,
            barWidth: widget.barWidth,
            spacing: widget.spacing,
            position: widget.position,
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
          );
  }
} 