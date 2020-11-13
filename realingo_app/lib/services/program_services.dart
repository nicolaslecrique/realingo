import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/database/db.dart';
import 'package:realingo_app/tech_services/rest/rest_api.dart';
import 'package:realingo_app/tech_services/user_config.dart';

class ProgramServices {
  static Future<List<Language>> getAvailableTargetLanguages() async {
    return await RestApi.getAvailableTargetLanguages();
  }

  static Future<List<Language>> getAvailableOriginLanguages(Language targetLanguage) async {
    return await RestApi.getAvailableOriginLanguages(targetLanguage.uri);
  }

  static Future<UserProgram> buildUserProgram(Language targetLanguage, Language originLanguage) async {
    final program = await RestApi.getProgram(targetLanguage.uri, originLanguage.uri);

    final userProgram = UserProgram("${program.uri}-${DateTime.now()}", program);

    await Db.insertUserProgram(userProgram);

    UserConfig.setDefaultUserProgramUri(userProgram.uri);
    return userProgram;
  }

  static Future<UserProgram> getDefaultUserProgramOrNull() async {
    String uri = await UserConfig.getDefaultUserProgramUriOrNull();
    if (uri != null) {
      return await Db.getUserProgram(uri);
    } else {
      return null;
    }
  }
}
