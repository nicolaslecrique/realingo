import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/lesson_controller.dart';
import 'package:realingo_app/services/voice_service.dart';

class LessonRouteArgs {
  final List<LessonItem> lessonItems;

  LessonRouteArgs(this.lessonItems);
}

class LessonRoute extends StatefulWidget {
  static const route = '/lesson';

  @override
  _LessonRouteState createState() => _LessonRouteState();
}

class _LessonRouteState extends State<LessonRoute> {
  List<LessonItem> _lessonItems;
  int _currentItemIndex = 0;

  VoiceService _voiceService;
  VoiceServiceStatus _voiceServiceStatus;
  String _lastResult = "";

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService.get();
    _voiceService.register(_onVoiceStatusChanged, _onResult);
  }

  @override
  void dispose() {
    super.dispose();
    _voiceService.unregister();
    _voiceService.stopListening();
  }

  void _onVoiceStatusChanged(VoiceServiceStatus voiceServiceStatus) {
    setState(() {
      _voiceServiceStatus = voiceServiceStatus;
    });
  }

  void _onResult(String result) {
    setState(() {
      _lastResult = result;
    });
  }

  void _startMicButtonPress() {
    _voiceService.startListening();
  }

  void _stopMicButtonPress() {
    _voiceService.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    LessonRouteArgs args = ModalRoute.of(context).settings.arguments;
    _lessonItems = args.lessonItems;

    double progressRatio =
        _lessonItems.where((element) => element.status == LessonItemStatus.Success).length / _lessonItems.length;

    var currentItem = _lessonItems[_currentItemIndex];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(StandardSizes.medium),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progressRatio,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
              child: Text("Translate the sentence"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
              child: Text(_lastResult),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(currentItem.sentence.translation),
                Text(""),
              ],
            )),
            SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    OutlineButton.icon(icon: Icon(Icons.add_circle), label: Text("Hint"), onPressed: () => null),
                    SizedBox(width: StandardSizes.medium),
                    Expanded(
                        child: ElevatedButton.icon(
                            icon: Icon(Icons.mic),
                            label: Text("Reply"),
                            onPressed: _voiceServiceStatus == VoiceServiceStatus.Ready
                                ? _startMicButtonPress
                                : _voiceServiceStatus == VoiceServiceStatus.Listening
                                    ? _stopMicButtonPress
                                    : null)),
                  ],
                )),
            Row(
              children: [Text(_voiceServiceStatus.toString())],
            ) // TODO NICO for debug, to remove
          ],
        ),
      ),
    );
  }
}
