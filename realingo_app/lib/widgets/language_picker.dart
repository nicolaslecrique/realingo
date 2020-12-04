import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';

@immutable
class LanguagePicker extends StatelessWidget {
  final List<Language> languages;
  final Language selected;
  final void Function(Language) onSelect;

  const LanguagePicker({@required this.languages, this.selected, @required this.onSelect, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: languages.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
              selected: languages[index] == selected,
              title: Text(languages[index].label),
              onTap: () => onSelect(languages[index]),
            ));
  }
}
