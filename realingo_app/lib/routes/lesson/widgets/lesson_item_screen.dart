import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_progress_bar.dart';
import 'package:realingo_app/routes/lesson/widgets/reply_rich_text.dart';
import 'package:realingo_app/services/texttospeech_service.dart';

import 'lesson_item_bottom_bar.dart';

class LessonItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget? child) {
      // TODO REFACTO: WE CAN SET LessonState as constructor parameter
      LessonState state = lesson.state;
      debugPrint('lesson state changed to ${lesson.state.status}/${lesson.state.currentExerciseOrNull?.status}');
      ExerciseState currentItem = lesson.state.currentExerciseOrNull!;

      return Scaffold(
          body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
                left: StandardSizes.medium, right: StandardSizes.medium, bottom: StandardSizes.medium),
            child: Column(
              children: [
                SizedBox(width: double.infinity, height: StandardSizes.medium),
                LessonProgressBar(ratioCompleted: state.ratioCompleted),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_getInstructions(currentItem.exercise.exerciseType),
                          style: Theme.of(context).textTheme.headline5)),
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text(currentItem.exercise.sentence.translation, style: Theme.of(context).textTheme.headline6),
                    ),
                    Row(
                      children: [
                        Ink(
                          decoration: const ShapeDecoration(
                            color: StandardColors.brandBlue,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                              icon: Icon(Icons.volume_up),
                              onPressed: currentItem.status == ExerciseStatus.OnAnswerFeedback ||
                                      (currentItem.status == ExerciseStatus.ReadyForFirstAnswer &&
                                          currentItem.exercise.exerciseType == ExerciseType.Repeat)
                                  ? () => TextToSpeech.play(lesson.learnedLanguageUri, currentItem.exercise.sentence)
                                  : null,
                              tooltip: 'Play'),
                        ),
                        SizedBox(width: StandardSizes.medium),
                        ReplyRichText(exerciseState: currentItem),
                      ],
                    ),
                  ],
                )),
                LessonItemBottomBar(),
              ],
            )),
      ));
    });
  }

  static String _getInstructions(ExerciseType exerciseType) {
    switch (exerciseType) {
      case ExerciseType.TranslateToLearningLanguage:
        return 'Translate the sentence';
      case ExerciseType.Repeat:
        return 'Repeat the sentence';
    }
  }
}
