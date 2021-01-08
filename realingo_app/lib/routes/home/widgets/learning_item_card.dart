import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/user_program.dart';

class LearningItemCard extends StatelessWidget {
  final String itemLabel;
  final UserItemToLearnStatus status;

  const LearningItemCard({Key key, @required this.itemLabel, @required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon icon;
    switch (status) {
      case UserItemToLearnStatus.SkippedAtStart:
        icon = Icon(
          Icons.check,
          color: StandardColors.brandBlue,
        );
        break;
      case UserItemToLearnStatus.Learned:
        icon = Icon(
          Icons.check,
          color: StandardColors.brandBlue,
        );
        break;
      case UserItemToLearnStatus.Skipped:
        icon = null;
        break;
      case UserItemToLearnStatus.NotLearned:
        icon = null;
        break;
    }

    return Card(
      child: ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
          itemLabel,
          style: StandardFonts.wordItem,
        ),
        subtitle: Text(
          'traduction',
          style: StandardFonts.wordItem,
        ),
        onTap: () => null,
        trailing: icon,
      ),
    );
  }
}
