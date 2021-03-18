import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_state.dart';
import 'package:realingo_app/routes/lesson/widgets/end_lesson_screen.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_item_screen.dart';

@immutable
class LessonRouteArgs {
  final LearningProgram program;
  final Lesson lesson;

  const LessonRouteArgs(this.program, this.lesson);
}

@immutable
class LessonRoute extends StatefulWidget {
  static const route = '/lesson';

  const LessonRoute({Key key}) : super(key: key);

  @override
  _LessonRouteState createState() => _LessonRouteState();
}

class _LessonRouteState extends State<LessonRoute> {
  @override
  Widget build(BuildContext context) {
    LessonRouteArgs args = ModalRoute.of(context).settings.arguments as LessonRouteArgs;

    return ChangeNotifierProvider(
        create: (context) => LessonModel(args.program.learnedLanguageUri, args.lesson),
        child: Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget child) {
          LessonState state = lesson.state;
          if (state.status == LessonStatus.WaitForVoiceServiceReady) {
            return LoadingScreen(message: 'Loading lesson');
          } else if (state.status == LessonStatus.Completed) {
            return EndLessonScreen(program: args.program, completedLesson: args.lesson);
          } else {
            return LessonItemScreen();
          }
        }));
  }
}
