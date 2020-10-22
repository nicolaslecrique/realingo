import 'package:flutter/material.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/widgets/language_picker.dart';

class SelectTargetLanguageScreen extends StatefulWidget {
  static const routeName = '/select_target_language_screen';

  @override
  _SelectTargetLanguageScreenState createState() =>
      _SelectTargetLanguageScreenState();
}

class _SelectTargetLanguageScreenState
    extends State<SelectTargetLanguageScreen> {
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
    return Scaffold(
      body: FutureBuilder(
        future: futureLanguages,
        builder: (context, AsyncSnapshot<List<Language>> snapshot) {
          if (snapshot.hasData) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: LanguagePicker(
                languages: snapshot.data,
                selected: selectedLanguage,
                onSelect: (e) => setState(() {
                  selectedLanguage = e;
                }),
              ),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text("error"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
