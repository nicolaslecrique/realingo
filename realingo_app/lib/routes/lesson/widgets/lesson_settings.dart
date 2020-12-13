import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';

class LessonSettings extends StatefulWidget {
  @override
  _LessonSettingsState createState() => _LessonSettingsState();
}

class _LessonSettingsState extends State<LessonSettings> {
  double _currentSpeechTolerance = 1.0;

  void _onSliderSpeechTolerance(double value) {
    setState(() {
      _currentSpeechTolerance = value;
    });
  }

  static String _getPronunciationLabel(double value) {
    if (value == 0.0) {
      return 'Easy';
    } else if (value == 1.0) {
      return 'Medium';
    } else if (value == 2.0) {
      return 'Hard';
    } else if (value == 3.0) {
      return 'Expert';
    } else {
      debugPrint('_getPronunciationLabel: bug: unexpected value $value');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        /*https://medium.com/flutterdevs/custom-dialog-in-flutter-7ca5c2a8d33a trick to size to content*/
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(StandardSizes.medium),
            child: Column(
              children: [
                Align(child: Text('Speech recognition'), alignment: Alignment.centerLeft),
                Slider(
                  value: _currentSpeechTolerance,
                  min: 0,
                  max: 3,
                  divisions: 3,
                  onChanged: _onSliderSpeechTolerance,
                  label: _getPronunciationLabel(_currentSpeechTolerance),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
