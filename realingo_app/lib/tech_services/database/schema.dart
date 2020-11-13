import 'package:realingo_app/tech_services/database/table/item_to_learn.dart';
import 'package:realingo_app/tech_services/database/table/user_program.dart';

import 'table/learning_program.dart';

class DB {
  static final TableItemToLearn itemToLearn = TableItemToLearn();
  static final TableLearningProgram learningProgram = TableLearningProgram();
  static final TableUserProgram userProgram = TableUserProgram();
}
