import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_states.dart';
import 'package:realingo_app/routes/lesson/widgets/end_lesson_screen.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_item_screen.dart';

@immutable
class LessonRouteArgs {
  final List<LessonItem> lessonItems;

  const LessonRouteArgs(this.lessonItems);
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
        create: (context) => LessonModel(args.lessonItems),
        child: Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget child) {
          LessonState state = lesson.state;
          if (state.status == LessonStatus.WaitForVoiceServiceReady) {
            return LoadingScreen();
          } else if (state.status == LessonStatus.Completed) {
            return EndLessonScreen();
          } else {
            return LessonItemScreen();
          }
        }));
  }
}
