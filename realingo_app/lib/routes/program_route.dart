import 'package:flutter/material.dart';
import 'package:realingo_app/services/user_program_services.dart';
import 'package:realingo_app/tech_services/db.dart';

class ProgramRouteArgs {
  final Db db;
  final UserProgram user;

  ProgramRouteArgs(this.db, this.user);
}

class ProgramRoute extends StatelessWidget {
  static const route = '/program';

  @override
  Widget build(BuildContext context) {
    final ProgramRouteArgs args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Center(child: Text("program")),
    );
  }
}
