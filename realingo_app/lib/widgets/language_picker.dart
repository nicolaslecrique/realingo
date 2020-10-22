import 'package:flutter/material.dart';
import 'package:realingo_app/services/program_services.dart';

class LanguagePicker extends StatelessWidget {
  final List<Language> languages;
  final Language selected;
  final void Function(Language) onSelect;

  LanguagePicker(
      {@required this.languages,
      @required this.selected,
      @required this.onSelect,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: languages
          .map((e) => Container(
                color: e == selected ? Colors.blue : Colors.white,
                child: ListTile(
                  title: Text(e.languageLabel),
                  onTap: () => onSelect(e),
                ),
              ))
          .toList(),
    );
  }
}
