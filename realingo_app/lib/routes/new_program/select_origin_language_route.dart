import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/new_program/building_program_route.dart';
import 'package:realingo_app/screens/one_button_screen.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/widgets/future_builder_wrapper.dart';
import 'package:realingo_app/widgets/language_picker.dart';

@immutable
class SelectOriginLanguageRouteArgs {
  final Language learnedLanguage;

  const SelectOriginLanguageRouteArgs(this.learnedLanguage);
}

@immutable
class SelectOriginLanguageRoute extends StatefulWidget {
  static const route = '/select_origin_language';
  final SelectOriginLanguageRouteArgs args;

  const SelectOriginLanguageRoute(this.args, {Key key}) : super(key: key);

  @override
  _SelectOriginLanguageRouteState createState() => _SelectOriginLanguageRouteState(args.learnedLanguage);
}

class _SelectOriginLanguageRouteState extends State<SelectOriginLanguageRoute> {
  Future<List<Language>> futureLanguages;
  Language selectedLanguage;
  final Language learnedLanguage;

  _SelectOriginLanguageRouteState(this.learnedLanguage);

  @override
  void initState() {
    super.initState();
    futureLanguages = ProgramServices.getAvailableOriginLanguages(learnedLanguage);
    selectedLanguage = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper(
      future: futureLanguages,
      childBuilder: (List<Language> languages) => OneButtonScreen(
        child: LanguagePicker(
          languages: languages,
          selected: selectedLanguage,
          onSelect: (e) => setState(() => selectedLanguage = e),
        ),
        title: 'Native language',
        buttonText: 'OK',
        onButtonPressed: selectedLanguage == null
            ? null
            : () => Navigator.pushNamed(context, BuildingProgramRoute.route,
                arguments: BuildingProgramRouteArgs(selectedLanguage, learnedLanguage)),
      ),
    );
  }
}
