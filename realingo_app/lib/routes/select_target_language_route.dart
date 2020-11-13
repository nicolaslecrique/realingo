import 'package:flutter/material.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/routes/select_origin_language_route.dart';
import 'package:realingo_app/screens/one_button_screen.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/widgets/future_builder_wrapper.dart';
import 'package:realingo_app/widgets/language_picker.dart';

class SelectTargetLanguageRoute extends StatefulWidget {
  static const route = '/select_target_language';

  @override
  _SelectTargetLanguageRouteState createState() => _SelectTargetLanguageRouteState();
}

class _SelectTargetLanguageRouteState extends State<SelectTargetLanguageRoute> {
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
      future: futureLanguages,
      childBuilder: (languages) => OneButtonScreen(
        child: LanguagePicker(
          languages: languages,
          selected: selectedLanguage,
          onSelect: (e) => setState(() => selectedLanguage = e),
        ),
        title: "Courses",
        buttonText: "OK",
        onButtonPressed: selectedLanguage == null
            ? null
            : () => Navigator.pushNamed(context, SelectOriginLanguageRoute.route,
                arguments: SelectOriginLanguageRouteArgs(selectedLanguage)),
      ),
    );
  }
}
