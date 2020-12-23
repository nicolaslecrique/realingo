import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/tech_services/database/db.dart';

class LessonSaver {
  static Future<void> saveLesson(List<UserItemToLearn> learnedItems) async {
    var modifiedItems = List<UserItemToLearn>.unmodifiable(learnedItems.map<UserItemToLearn>(
        (e) => UserItemToLearn((e.uri), e.serverUri, e.label, e.sentences, UserItemToLearnStatus.Learned)));
    await db.updateUserItemToLearnStatus(modifiedItems);
  }
}
