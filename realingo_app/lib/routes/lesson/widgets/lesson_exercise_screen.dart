import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_progress_bar.dart';
import 'package:realingo_app/routes/lesson/widgets/reply_rich_text.dart';
import 'package:realingo_app/tech_services/analytics.dart';

import 'lesson_exercise_bottom_bar.dart';

class LessonItemExercise extends StatelessWidget {
  void askCloseConfirmation(BuildContext context, LessonModel lessonModel) {
    showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Are you sure you want to quit?'),
              content: Text('All your progress will be lost.'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // quit dialog
                      Navigator.of(context).pop(); // quit lesson
                      Analytics.quitLesson(lessonModel.userLearningProgram, lessonModel.lesson, lessonModel.state);
                    },
                    style: TextButton.styleFrom(primary: StandardColors.accentColor),
                    child: const Text('Quit lesson')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Resume lesson'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget? child) {
      // TODO REFACTO: WE CAN SET LessonState as constructor parameter
      LessonState state = lesson.state;
      debugPrint('lesson state changed to ${lesson.state.status}/${lesson.state.currentExerciseOrNull?.status}');
      ExerciseState currentItem = lesson.state.currentExerciseOrNull!;

      return WillPopScope(
        onWillPop: () async {
          askCloseConfirmation(context, lesson);
          return false;
        },
        child: Scaffold(
            body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: StandardSizes.medium, right: StandardSizes.medium, bottom: StandardSizes.medium),
              child: Column(
                children: [
                  SizedBox(width: double.infinity, height: StandardSizes.medium),
                  Row(
                    children: [
                      // https://stackoverflow.com/questions/50381157/how-do-i-remove-flutter-iconbutton-big-padding
                      // so that icon is aligned at left with other content (no additional padding), SizedBox make right margin
                      GestureDetector(onTap: () => askCloseConfirmation(context, lesson), child: Icon(Icons.close)),
                      SizedBox(width: StandardSizes.medium),
                      Expanded(child: LessonProgressBar(ratioCompleted: state.ratioCompleted)),
                    ],
                  ),
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
                        child: Text(currentItem.exercise.sentence.translation,
                            style: Theme.of(context).textTheme.headline6),
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
                                    ? () => lesson.playCurrentSentenceRecording()
                                    : null,
                                tooltip: 'Play'),
                          ),
                          SizedBox(width: StandardSizes.medium),
                          ReplyRichText(exerciseState: currentItem),
                        ],
                      ),
                    ],
                  )),
                  LessonExerciseBottomBar(),
                ],
              )),
        )),
      );
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
