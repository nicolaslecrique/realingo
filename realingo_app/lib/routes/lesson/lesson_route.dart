import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/common_widgets/result_wrapper.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';
import 'package:realingo_app/routes/lesson/widgets/end_lesson_screen.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_exercise_screen.dart';
import 'package:realingo_app/services/program_services.dart';

@immutable
class LessonRouteArgs {
  final UserLearningProgram userLearningProgram;
  final LessonInProgram lesson;

  const LessonRouteArgs(this.userLearningProgram, this.lesson);
}

@immutable
class LessonRoute extends StatefulWidget {
  static const route = '/lesson';

  const LessonRoute({Key? key}) : super(key: key);

  @override
  _LessonRouteState createState() => _LessonRouteState();
}

class _LessonRouteState extends State<LessonRoute> {
  @override
  Widget build(BuildContext context) {
    LessonRouteArgs args = ModalRoute.of(context)!.settings.arguments as LessonRouteArgs;

    return ResultWrapper<Lesson>(
      loadingMessage: 'Loading lesson',
      futureResultBuilder: () => ProgramServices.getLesson(args.userLearningProgram.program, args.lesson.uri),
      childBuilder: (Lesson lesson) => ChangeNotifierProvider(
        create: (context) => LessonModel(args.userLearningProgram, lesson),
        child: Consumer<LessonModel>(builder: (BuildContext context, LessonModel lessonModel, Widget? child) {
          LessonState state = lessonModel.state;
          if (state.status == LessonStatus.WaitForVoiceServiceReady) {
            return LoadingScreen(message: 'Loading lesson');
          } else if (state.status == LessonStatus.Completed) {
            return EndLessonScreen(program: args.userLearningProgram.program, completedLesson: lessonModel.lesson);
          } else {
            return LessonItemExercise();
          }
        }),
      ),
    );
  }
}
