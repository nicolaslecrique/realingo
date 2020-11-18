import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/building_program_route.dart';
import 'package:realingo_app/screens/one_button_screen.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/widgets/future_builder_wrapper.dart';
import 'package:realingo_app/widgets/language_picker.dart';

class SelectOriginLanguageRouteArgs {
  final Language learnedLanguage;

  SelectOriginLanguageRouteArgs(this.learnedLanguage);
}

class SelectOriginLanguageRoute extends StatefulWidget {
  static const route = '/select_origin_language';
  final SelectOriginLanguageRouteArgs args;

  SelectOriginLanguageRoute(this.args, {Key key}) : super(key: key);

  @override
  _SelectOriginLanguageRouteState createState() => _SelectOriginLanguageRouteState(this.args.learnedLanguage);
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
      childBuilder: (languages) => OneButtonScreen(
        child: LanguagePicker(
          languages: languages,
          selected: selectedLanguage,
          onSelect: (e) => setState(() => selectedLanguage = e),
        ),
        title: "Native language",
        buttonText: "OK",
        onButtonPressed: selectedLanguage == null
            ? null
            : () => Navigator.pushNamed(context, BuildingProgramRoute.route,
                arguments: BuildingProgramRouteArgs(selectedLanguage, learnedLanguage)),
      ),
    );
  }
}
