import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/lesson/lesson_route.dart';
import 'package:realingo_app/routes/lesson/model/lesson_builder.dart';

import 'widgets/learning_item_card.dart';

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

    List<ConsideredItem> lessonItems = <ConsideredItem>[];
    int idxFirstWord =
        userProgram.itemsToLearn.indexWhere((UserItemToLearn e) => e.status == UserItemToLearnStatus.NotLearned);
    for (int i = idxFirstWord;
        i < min(idxFirstWord + LessonBuilder.NbItemsByLesson, userProgram.itemsToLearn.length);
        i++) {
      int nb_sentences = min(userProgram.itemsToLearn[i].sentences.length, LessonBuilder.NbSentencesByLessonItem);
      var lessonItemSentenceIndexes = List.generate(nb_sentences, (index) => index);
      lessonItems.add(ConsideredItem(i, ItemSkippedOrSelected.Selected, lessonItemSentenceIndexes));
    }

    List<LessonItem> lesson = LessonBuilder.buildLesson(userProgram, lessonItems);

    LessonRouteArgs lessonRouteArgs = LessonRouteArgs(userProgram.learnedLanguage, lesson);
    await Navigator.pushNamed(context, LessonRoute.route, arguments: lessonRouteArgs);
  }

  @override
  Widget build(BuildContext context) {
    // for now no need to use consumer, we suppose it cannot change while we are on this route
    var model = Provider.of<UserProgramModel>(context, listen: false);
    UserLearningProgram userProgram = model.program;

    // https://flutter.dev/docs/cookbook/lists/long-lists
    final List<UserItemToLearn> items = userProgram.itemsToLearn;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StandardSizes.medium),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return LearningItemCard(
                        itemLabel: item.label,
                        status: item.status,
                      );
                    }),
              ),
              SizedBox(height: StandardSizes.medium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Start lesson', style: StandardFonts.button),
                  onPressed: () => startLesson(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /*
        floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, SelectWordAndSentencesRoute.route,
            arguments: SelectWordAndSentencesRouteArgs(userProgram, const [])),
        label: Text('Start lesson'),
        icon: Icon(Icons.arrow_forward_ios),
      ),
   */

}
