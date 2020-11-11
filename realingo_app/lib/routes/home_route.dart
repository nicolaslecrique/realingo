import 'package:flutter/material.dart';
import 'package:realingo_app/services/program_services.dart';
import 'package:realingo_app/services/user_program_services.dart';

class HomeRoute extends StatefulWidget {
  static const route = '/home';

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final UserProgram userProgram = UserProgramServices.getCurrentUserProgram();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // https://flutter.dev/docs/cookbook/lists/long-lists
    final List<ItemToLearn> items = userProgram.program.itemsToLearn;
    return Scaffold(
        body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(items[index].itemLabel));
            }));
  }
}
