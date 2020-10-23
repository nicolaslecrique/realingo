import 'package:flutter/material.dart';
import 'package:realingo_app/services/program_services.dart';

class SelectOriginLanguageRouteArgs {
  final Language targetLanguage;

  SelectOriginLanguageRouteArgs(this.targetLanguage);
}

class SelectOriginLanguageRoute extends StatefulWidget {
  static const route = '/select_origin_language';

  SelectOriginLanguageRoute({Key key}) : super(key: key);

  @override
  _SelectOriginLanguageRouteState createState() =>
      _SelectOriginLanguageRouteState();
}

class _SelectOriginLanguageRouteState extends State<SelectOriginLanguageRoute> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
