import 'package:flutter/cupertino.dart';
import 'package:realingo_app/model/user_program.dart';

enum LessonItemStatus { NotPlayed, Success, Failure }

@immutable
class LessonItem {
  final UserItemToLearn userItemToLearn;
  final UserItemToLearnSentence sentence;

  const LessonItem(this.userItemToLearn, this.sentence);
}

enum ItemSkippedOrSelected { Skipped, Selected }

@immutable
class ConsideredItem {
  final int indexInUserProgram;
  final ItemSkippedOrSelected choice;
  final List<int> indexesOfSelectedSentences; // null before we select sentences or if choice is skipped

  const ConsideredItem(this.indexInUserProgram, this.choice, this.indexesOfSelectedSentences);
}

class LessonController {
  static const NbItemsByLesson = 3;
  static const NbSentencesByLessonItem = 3;

  static List<LessonItem> buildLesson(UserLearningProgram program, List<ConsideredItem> modifiedItems) {
    List<LessonItem> lessonItems = [];

    Iterable<ConsideredItem> selectedItems =
        modifiedItems.where((element) => element.choice == ItemSkippedOrSelected.Selected);
    for (int sentenceIndex = 0; sentenceIndex < NbSentencesByLessonItem; sentenceIndex++) {
      for (ConsideredItem item in selectedItems) {
        if (sentenceIndex < item.indexesOfSelectedSentences.length) {
          lessonItems.add(LessonItem(program.itemsToLearn[item.indexInUserProgram],
              program.itemsToLearn[item.indexInUserProgram].sentences[item.indexesOfSelectedSentences[sentenceIndex]]));
        }
      }
    }
    return lessonItems;
  }
}
