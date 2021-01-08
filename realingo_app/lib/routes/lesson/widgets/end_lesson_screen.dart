import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/one_button_screen.dart';
import 'package:realingo_app/common_widgets/future_builder_wrapper.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home/home_route.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';
import 'package:realingo_app/routes/lesson/model/lesson_saver.dart';

class EndLessonScreen extends StatelessWidget {
  final List<LessonItem> lessonItems;

  const EndLessonScreen({Key key, @required this.lessonItems}) : super(key: key);

  // we use dummy "int" for future because FutureBuilderWrapper requires a data result
  // to work
  Future<int> updateProgram(BuildContext context) async {
    final userItems = List<UserItemToLearn>.unmodifiable(lessonItems.map<UserItemToLearn>((e) => e.userItemToLearn));
    await LessonSaver.saveLesson(userItems);
    var model = Provider.of<UserProgramModel>(context, listen: false);
    await model.reload();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper<int>(
      loadingMessage: 'Saving lesson',
      future: updateProgram(context),
      childBuilder: (int _) => OneButtonScreen(
        title: 'Lesson completed',
        child: Center(child: Text('Congratulation')),
        buttonText: 'OK',
        onButtonPressed: () => Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (route) => false),
      ),
    );
  }
}
