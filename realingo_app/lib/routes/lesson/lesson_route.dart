import 'package:flutter/material.dart';
import 'package:realingo_app/model/user_program.dart';

enum LessonItemStatus { NotPlayed, Success, Failure }

class LessonItem {
  final UserItemToLearn userItemToLearn;
  final UserItemToLearnSentence sentence;
  LessonItemStatus status = LessonItemStatus.NotPlayed;

  LessonItem(this.userItemToLearn, this.sentence);
}

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

  @override
  Widget build(BuildContext context) {
    LessonRouteArgs args = ModalRoute.of(context).settings.arguments;
    _lessonItems = args.lessonItems;

    double progressRatio =
        _lessonItems.where((element) => element.status == LessonItemStatus.Success).length / _lessonItems.length;

    var currentItem = _lessonItems[_currentItemIndex];

    return Container(
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progressRatio,
          ),
          Text(currentItem.sentence.translation),
          Text(currentItem.sentence.sentence),
          ElevatedButton(child: Icon(Icons.mic), onPressed: () => null)
        ],
      ),
    );
  }
}
