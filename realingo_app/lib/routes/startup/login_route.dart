import 'package:flutter/material.dart';
import 'package:realingo_app/routes/new_program/select_learned_language_route.dart';

class LoginRoute extends StatelessWidget {
  static const route = '/login';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          child: Text("Start"),
          onPressed: () => {Navigator.pushNamed(context, SelectLearnedLanguageRoute.route)},
        ),
      ),
    );
  }
}
