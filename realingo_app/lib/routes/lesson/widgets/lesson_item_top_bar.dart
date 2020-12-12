import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/routes/lesson/model/lesson_model.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_progress_bar.dart';
import 'package:realingo_app/routes/lesson/widgets/lesson_settings.dart';

class LessonItemTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LessonModel>(builder: (BuildContext context, LessonModel lesson, Widget child) {
      return Row(
        children: [
          Expanded(child: LessonProgressBar(ratioCompleted: 0.5)),
          IconButton(
            icon: Icon(Icons.settings),
            //color: Colors.white,
            onPressed: () {
              showDialog<LessonSettings>(
                  context: context,
                  builder: (BuildContext context) {
                    return LessonSettings();
                  });
            },
          )
        ],
      );
    });
  }
}
