import 'package:flutter/material.dart';
import 'package:realingo_app/routes/select_origin_language_route.dart';
import 'package:realingo_app/screens/loading_screen.dart';
import 'package:realingo_app/screens/one_button_screen.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/widgets/language_picker.dart';

class SelectTargetLanguageRoute extends StatefulWidget {
  static const route = '/select_target_language';

  @override
  _SelectTargetLanguageRouteState createState() =>
      _SelectTargetLanguageRouteState();
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
    return FutureBuilder(
      future: futureLanguages,
      builder: (context, AsyncSnapshot<List<Language>> snapshot) {
        if (snapshot.hasData) {
          return OneButtonScreen(
            child: LanguagePicker(
              languages: snapshot.data,
              selected: selectedLanguage,
              onSelect: (e) => setState(() {
                selectedLanguage = e;
              }),
            ),
            title: "Courses",
            buttonText: "OK",
            onButtonPressed: selectedLanguage == null
                ? null
                : () {
                    Navigator.pushNamed(
                        context, SelectOriginLanguageRoute.route);
                  },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("error"));
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
