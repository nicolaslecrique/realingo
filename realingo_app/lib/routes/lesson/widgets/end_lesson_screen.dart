import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/common_screens/one_button_screen.dart';
import 'package:realingo_app/common_widgets/future_builder_wrapper.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/home/home_route.dart';
import 'package:realingo_app/services/program_services.dart';

class EndLessonScreen extends StatelessWidget {
  final LearningProgram program;
  final Lesson completedLesson;

  const EndLessonScreen({Key? key, required this.program, required this.completedLesson}) : super(key: key);

  // we use dummy "int" for future because FutureBuilderWrapper requires a data result
  // to work
  Future<int> updateProgram(BuildContext context) async {
    await ProgramServices.setUserProgramNextLesson(program, completedLesson.uri);
    var model = Provider.of<UserProgramModel>(context, listen: false);
    await model.reload();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper<int>(
      loadingMessage: 'Saving lesson',
      future: updateProgram(context),
      childBuilder: (int? _) => OneButtonScreen(
        buttonText: 'Ok',
        onButtonPressed: () => Navigator.pushNamedAndRemoveUntil(context, HomeRoute.route, (route) => false),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Congratulations!', style: StandardFonts.bigFunny),
            Text('Lesson completed', style: StandardFonts.bigFunnyAccent),
          ],
        ),
      ),
    );
  }
}
