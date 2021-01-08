import 'package:flutter/material.dart';
import 'package:realingo_app/common_screens/one_button_screen.dart';
import 'package:realingo_app/common_widgets/future_builder_wrapper.dart';
import 'package:realingo_app/common_widgets/language_picker.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/new_program/select_origin_language_route.dart';
import 'package:realingo_app/services/program_services.dart';

@immutable
class SelectLearnedLanguageRoute extends StatefulWidget {
  static const route = '/select_learned_language';

  const SelectLearnedLanguageRoute({Key key}) : super(key: key);

  @override
  _SelectLearnedLanguageRouteState createState() => _SelectLearnedLanguageRouteState();
}

class _SelectLearnedLanguageRouteState extends State<SelectLearnedLanguageRoute> {
  Future<List<Language>> futureLanguages;
  Language selectedLanguage;

  @override
  void initState() {
    super.initState();
    futureLanguages = ProgramServices.getAvailableTargetLanguages();
    selectedLanguage = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper(
      loadingMessage: 'Loading programs',
      future: futureLanguages,
      childBuilder: (List<Language> languages) => OneButtonScreen(
        child: LanguagePicker(
          languages: languages,
          selected: selectedLanguage,
          onSelect: (e) => setState(() => selectedLanguage = e),
        ),
        title: 'I want to learn...',
        buttonText: 'OK',
        onButtonPressed: selectedLanguage == null
            ? null
            : () => Navigator.pushNamed(context, SelectOriginLanguageRoute.route,
                arguments: SelectOriginLanguageRouteArgs(selectedLanguage)),
      ),
    );
  }
}
