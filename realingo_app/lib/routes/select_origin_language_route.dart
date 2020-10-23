import 'package:flutter/material.dart';
import 'package:realingo_app/routes/program_route.dart';
import 'package:realingo_app/screens/one_button_screen.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/widgets/future_builder_wrapper.dart';
import 'package:realingo_app/widgets/language_picker.dart';

class SelectOriginLanguageRouteArgs {
  final Language targetLanguage;

  SelectOriginLanguageRouteArgs(this.targetLanguage);
}

class SelectOriginLanguageRoute extends StatefulWidget {
  static const route = '/select_origin_language';
  final SelectOriginLanguageRouteArgs args;

  SelectOriginLanguageRoute(this.args, {Key key}) : super(key: key);

  @override
  _SelectOriginLanguageRouteState createState() =>
      _SelectOriginLanguageRouteState(this.args.targetLanguage);
}

class _SelectOriginLanguageRouteState extends State<SelectOriginLanguageRoute> {
  Future<List<Language>> futureLanguages;
  Language selectedLanguage;
  final Language targetLanguage;

  _SelectOriginLanguageRouteState(this.targetLanguage);

  @override
  void initState() {
    super.initState();
    futureLanguages =
        ProgramServices.getAvailableOriginLanguages(targetLanguage);
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
            : () => Navigator.pushNamed(context, ProgramRoute.route),
      ),
    );
  }
}
