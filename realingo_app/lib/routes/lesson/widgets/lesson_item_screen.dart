import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_progress_bar.dart';
import 'package:realingo_app/services/texttospeech_service.dart';

import 'lesson_item_bottom_bar.dart';

class LessonItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget child) {
      LessonState state = lesson.state;
      debugPrint('lesson state changed to ${lesson.state.status}/${lesson.state.currentItemOrNull?.status}');

      return Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(StandardSizes.medium),
              child: Column(
                children: [
                  SizedBox(width: double.infinity, height: StandardSizes.medium),
                  LessonProgressBar(ratioCompleted: state.ratioCompleted),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Translate the sentence', style: Theme.of(context).textTheme.headline5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(state.currentItemOrNull.lessonItem.sentence.translation,
                          style: Theme.of(context).textTheme.headline6),
                    ),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => TextToSpeech.playAndCacheRecord(
                              lesson.learnedLanguage, state.currentItemOrNull.lessonItem.sentence),
                          tooltip: 'Play'),
                      Text(state.currentItemOrNull.hint.hintDisplayed, style: Theme.of(context).textTheme.headline6),
                    ],
                  )),
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text(state.currentItemOrNull.lastAnswer.answer, style: Theme.of(context).textTheme.bodyText2),
                  ),
                  LessonItemBottomBar(),
                ],
              )));
    });
  }
}
