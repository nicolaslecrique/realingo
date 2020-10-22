import 'package:flutter/material.dart';
import 'package:realingo_app/services/user_program_services.dart';
import 'package:realingo_app/tech_services/db.dart';

class ProgramScreenArgs {
  final Db db;
  final UserProgram user;

  ProgramScreenArgs(this.db, this.user);
}

class ProgramScreen extends StatelessWidget {
  static const routeName = '/program_screen';

  @override
  Widget build(BuildContext context) {
    final ProgramScreenArgs args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Center(child: Text("program")),
    );
  }
}
