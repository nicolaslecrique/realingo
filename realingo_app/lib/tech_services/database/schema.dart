import 'package:realingo_app/tech_services/database/table/user_item_sentence.dart';
import 'package:realingo_app/tech_services/database/table/user_item_to_learn.dart';
import 'package:realingo_app/tech_services/database/table/user_learning_program.dart';

class DB {
  static final TableUserItemToLearn userItemToLearn = TableUserItemToLearn();
  static final TableUserLearningProgram userLearningProgram = TableUserLearningProgram();
  static final TableUserItemSentence userItemSentence = TableUserItemSentence();
}
