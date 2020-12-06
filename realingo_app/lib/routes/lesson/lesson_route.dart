import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/model/lesson_states.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_progress_bar.dart';
import 'package:realingo_app/routes/lesson/widgets/mic_button.dart';

@immutable
class LessonRouteArgs {
  final List<LessonItem> lessonItems;

  const LessonRouteArgs(this.lessonItems);
}

@immutable
class LessonRoute extends StatefulWidget {
  static const route = '/lesson';

  const LessonRoute();

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

          return Scaffold(
              body: Padding(
                  padding: const EdgeInsets.all(StandardSizes.medium),
                  child: Column(
                    children: [
                      LessonProgressBar(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
                        child: Text('Translate the sentence'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: StandardSizes.medium),
                        child: Text('LAST RESULT'),
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text('translation'),
                        ],
                      )),
                      SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              OutlineButton.icon(
                                  icon: Icon(Icons.lightbulb_outline), label: Text('Hint'), onPressed: () => null),
                              SizedBox(width: StandardSizes.medium),
                              Expanded(child: MicButton()),
                            ],
                          )),
                    ],
                  )));
        }));
  }
}
