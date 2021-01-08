import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';

import '../lesson/select_word_and_sentences_route.dart';
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

  @override
  Widget build(BuildContext context) {
    // for now no need to use consumer, we suppose it cannot change while we are on this route
    var model = Provider.of<UserProgramModel>(context, listen: false);
    UserLearningProgram userProgram = model.program;

    // https://flutter.dev/docs/cookbook/lists/long-lists
    final List<UserItemToLearn> items = userProgram.itemsToLearn;

    return Scaffold(
      body: Padding(
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
                child: Text('Start lesson'),
                onPressed: () => Navigator.pushNamed(context, SelectWordAndSentencesRoute.route,
                    arguments: SelectWordAndSentencesRouteArgs(userProgram, const [])),
              ),
            )
          ],
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
