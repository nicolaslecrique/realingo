import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/lesson/lesson_route.dart';

import 'widgets/lesson_card.dart';

class HomeRoute extends StatefulWidget {
  static const route = '/home';

  const HomeRoute({Key key}) : super(key: key);

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> startLesson() async {
    var model = Provider.of<UserProgramModel>(context, listen: false);
    UserLearningProgram userProgram = model.program;

    LessonRouteArgs lessonRouteArgs = LessonRouteArgs(userProgram.program, userProgram.nextLesson);
    await Navigator.pushNamed(context, LessonRoute.route, arguments: lessonRouteArgs);
  }

  @override
  Widget build(BuildContext context) {
    // for now no need to use consumer, we suppose it cannot change while we are on this route
    var model = Provider.of<UserProgramModel>(context, listen: false);
    UserLearningProgram userProgram = model.program;

    // https://flutter.dev/docs/cookbook/lists/long-lists
    final List<LessonInProgram> lessons = userProgram.program.lessons;
    int nextLessonIndex = lessons.indexWhere((element) => element.uri == userProgram.nextLesson.uri);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StandardSizes.medium),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      return LessonCard(
                        lessonInProgram: lesson,
                        status: index < nextLessonIndex
                            ? LessonInProgramStatus.Learned
                            : index == nextLessonIndex
                                ? LessonInProgramStatus.Current
                                : LessonInProgramStatus.NotLearned,
                      );
                    }),
              ),
              SizedBox(height: StandardSizes.medium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => startLesson(),
                  child: Text('Start lesson'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
