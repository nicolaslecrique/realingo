import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';

class LanguagePicker extends StatelessWidget {
  final List<Language> languages;
  final Language selected;
  final void Function(Language) onSelect;

  LanguagePicker({@required this.languages, this.selected, this.onSelect, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: languages
          .map((e) => ListTile(
                selected: e == selected,
                title: Text(e.label),
                onTap: () => onSelect(e),
              ))
          .toList(),
    );
  }
}
