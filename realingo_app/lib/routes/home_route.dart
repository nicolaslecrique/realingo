import 'package:flutter/material.dart';

class HomeRouteArgs {
  final String userProgramUri;

  HomeRouteArgs(this.userProgramUri);
}

class HomeRoute extends StatefulWidget {
  static const route = '/home';

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final HomeRouteArgs args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Center(child: Text("Home:" + args.userProgramUri)),
    );
  }
}
