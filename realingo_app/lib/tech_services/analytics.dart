import 'package:flutter/scheduler.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';

class Analytics {
  static Mixpanel? _mixpanel;

  // following https://developer.mixpanel.com/docs/flutter
  static Future<void> init(String userId) async {
    _mixpanel = await Mixpanel.init('bd2013ac83669dc2539fd16abe1464e6', optOutTrackingDefault: false);
    _mixpanel!.setServerURL('https://api-eu.mixpanel.com');
    _mixpanel!.identify(userId);
  }

  // properties are prefixed with underscore so they are not mixed by with default mixpanel properties in mixpanel UI
  static Map<String, dynamic> _getProgramProps(UserLearningProgram program) {
    int nextLessonIdx = program.program.lessons.indexWhere((element) => element.uri == program.nextLessonUri);
    return <String, dynamic>{
      '_program_uri': program.program.uri,
      '_program_learned_language_uri': program.program.learnedLanguageUri,
      '_program_origin_language_uri': program.program.originLanguageUri,
      '_program_next_lesson_uri': program.nextLessonUri,
      '_program_next_lesson_idx_in_program': nextLessonIdx
    };
  }

  static Map<String, dynamic> _getLessonProps(UserLearningProgram program, LessonInProgram lesson) {
    int startedLessonIdx = program.program.lessons.indexWhere((element) => element.uri == lesson.uri);

    var lessonProps = <String, dynamic>{
      '_lesson_uri': lesson.uri,
      '_lesson_idx_in_program': startedLessonIdx,
      '_lesson_label': lesson.label
    };

    lessonProps.addAll(_getProgramProps(program));

    return lessonProps;
  }

  static Map<String, dynamic> _getLessonStateProps(
      UserLearningProgram program, Lesson lesson, LessonState lessonState) {
    final lessonStateProps = <String, dynamic>{
      '_lesson_ratio_completed': lessonState.ratioCompleted,
    };

    if (lessonState.currentExerciseOrNull != null) {
      ExerciseState exerciseState = lessonState.currentExerciseOrNull!;
      Exercise exercise = exerciseState.exercise;
      final int exerciseIdx = lesson.exercises.indexWhere((element) => element.uri == exercise.uri);

      lessonStateProps.addAll(<String, dynamic>{
        '_exercise_uri': exercise.uri,
        '_exercise_idx_in_lesson': exerciseIdx,
        '_exercise_type': exercise.exerciseType.toString(), // it doesn't accept enum, only string / number
        '_exercise_sentence_uri': exercise.sentence.uri,
        '_exercise_sentence': exercise.sentence.sentence,
        '_exercise_status': exerciseState.status.toString()
      });

      if (exerciseState.lastAnswerOrNull != null) {
        final AnswerResult lastAnswer = exerciseState.lastAnswerOrNull!;
        lessonStateProps.addAll(<String, dynamic>{
          '_last_answer_raw_answer': lastAnswer.rawAnswer,
          '_last_answer_status': lastAnswer.answerStatus.toString()
        });
      }

      if (exerciseState.AnswerWaitingForConfirmationOrNull != null) {
        final WaitingAnswer waitingAnswer = exerciseState.AnswerWaitingForConfirmationOrNull!;
        lessonStateProps.addAll(<String, dynamic>{
          '_waiting_answer_raw_answer': waitingAnswer.rawAnswer,
          '_waiting_answer_guessed_answer': waitingAnswer.guessedAnswer
        });
      }
    }

    lessonStateProps.addAll(_getLessonProps(program, lesson.lessonInProgram));

    return lessonStateProps;
  }

  // ok
  static void setDefaultProgram(UserLearningProgram program) {
    if (_mixpanel != null) {
      final programProps = _getProgramProps(program);
      programProps.forEach((String key, dynamic value) {
        _mixpanel!.getPeople().set('default_$key', value);
      });
    }
  }

  static void _track(String eventName, Map<String, dynamic> Function() props) {
    if (_mixpanel != null) {
      SchedulerBinding.instance!
          .scheduleTask(() => _mixpanel!.track(eventName, properties: props()), Priority.animation)
          .then((value) => null);
      // for now, Priority is not idle because it is not executed before the end of the lesson because of the progress bar
      // cf. https://github.com/flutter/flutter/issues/73766
    }
  }

  static void startLesson(UserLearningProgram program, LessonInProgram lesson) {
    _track('start_lesson', () => _getLessonProps(program, lesson));
  }

  static void completeLesson(UserLearningProgram program, LessonInProgram lesson) {
    _track('complete_lesson', () => _getLessonProps(program, lesson));
  }

  // TODO
  static void quitLesson(UserLearningProgram program, Lesson lesson, LessonState lessonState) {
    _track('quit_lesson', () => _getLessonStateProps(program, lesson, lessonState));
  }

  static void cancelAnswer(UserLearningProgram program, Lesson lesson, LessonState lessonState) {
    _track('cancel_answer', () => _getLessonStateProps(program, lesson, lessonState));
  }

  static void confirmAnswer(UserLearningProgram program, Lesson lesson, LessonState lessonState) {
    _track('confirm_answer', () => _getLessonStateProps(program, lesson, lessonState));
  }

  static void playSentenceRecording(UserLearningProgram program, Lesson lesson, LessonState lessonState) {
    _track('play_sentence_recording', () => _getLessonStateProps(program, lesson, lessonState));
  }
}
