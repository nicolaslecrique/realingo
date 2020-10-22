import 'package:realingo_app/tech_services/db.dart';

class UserProgram {
  final String uri;

  UserProgram(this.uri);
}

class UserProgramServices {
  final Db _db;

  UserProgramServices(this._db);

  UserProgram getCurrentUserProgramOrNull() {
    var currentUserProgramUriOrNull = _db.getCurrentUserProgramUriOrNull();
    if (currentUserProgramUriOrNull != null) {
      var userProgram = _db.getUserProgram(currentUserProgramUriOrNull);
      return UserProgram(userProgram.uri);
    } else {
      return null;
    }
  }
}
