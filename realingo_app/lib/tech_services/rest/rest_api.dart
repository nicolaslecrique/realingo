import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/app_config.dart';
import 'package:realingo_app/tech_services/rest/rest_data.dart';
import 'package:realingo_app/tech_services/result.dart';

/*
Rest API wrapper
 */
class RestApi {
  static const String _restApiBaseUrl = '${AppConfig.apiUrl}/api/v0';

  static Future<Result<T>> _runGet<T>(String request, T Function(dynamic decodedBody) bodyToResult,
      {dynamic Function(http.Response response)? decodeResponse}) async {
    try {
      http.Response response = await http.get(Uri.parse('$_restApiBaseUrl/$request')).timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        return Result.ko(AppError.RestRequestFailed);
      }

      dynamic jsonDecoded;
      if (decodeResponse == null) {
        jsonDecoded = json.decode(response.body);
      } else {
        jsonDecoded = decodeResponse(response);
      }

      T result = bodyToResult(jsonDecoded);
      return Result.ok(result);
    } on TimeoutException catch (_) {
      return Result.ko(AppError.RestRequestFailed);
    }
  }

  static Future<Result<List<Language>>> getAvailableOriginLanguages(String learnedLanguageUri) async {
    return _runGet('available_origin_languages?learned_language_uri=$learnedLanguageUri', (dynamic decodedBody) {
      final languages = List<Language>.unmodifiable((decodedBody as List<dynamic>)
          .map((dynamic i) => RestLanguage.fromJson(i as Map<String, dynamic>))
          .map<Language>((e) => Language(e.uri, e.label)));
      return languages;
    });
  }

  static Future<Result<List<Language>>> getAvailableLearnedLanguages() async {
    return _runGet('available_learned_languages', (dynamic decodedBody) {
      final languages = List<Language>.unmodifiable((decodedBody as List<dynamic>)
          .map((dynamic i) => RestLanguage.fromJson(i as Map<String, dynamic>))
          .map<Language>((e) => Language(e.uri, e.label)));

      return languages;
    });
  }

  static Future<Result<LearningProgram>> getProgramByLanguage(Language learnedLanguage, Language originLanguage) async {
    return _runGet(
        'program_by_language?learned_language_uri=${learnedLanguage.uri}&origin_language_uri=${originLanguage.uri}',
        (dynamic decodedBody) {
      return _programFromRest(decodedBody);
    });
  }

  static Future<Result<LearningProgram>> getProgram(String programUri) async {
    return _runGet('program?program_uri=$programUri', (dynamic decodedBody) {
      return _programFromRest(decodedBody);
    });
  }

  static LearningProgram _programFromRest(dynamic responseBody) {
    final restProgram = RestLearningProgram.fromJson(responseBody as Map<String, dynamic>);

    final lessons = List<LessonInProgram>.unmodifiable(
        restProgram.lessons.map<LessonInProgram>((e) => LessonInProgram(e.uri, e.label, e.description)));

    return LearningProgram(restProgram.uri, restProgram.learnedLanguageUri, restProgram.originLanguageUri, lessons);
  }

  static Future<Result<Lesson>> getLesson(String programUri, String lessonUri) async {
    return _runGet('lesson?program_uri=$programUri&lesson_uri=$lessonUri', (dynamic decodedBody) {
      final restLesson = RestLesson.fromJson(decodedBody as Map<String, dynamic>);

      final exercises = List<Exercise>.unmodifiable(restLesson.exercises.map<Exercise>((e) => Exercise(
          e.uri,
          fromRest(e.exerciseType),
          Sentence(
              e.sentence.uri,
              e.sentence.sentence,
              e.sentence.translation,
              e.sentence.hint,
              List<ItemInSentence>.unmodifiable(e.sentence.items.map<ItemInSentence>((e) => ItemInSentence(
                  e.startIndex,
                  e.endIndex,
                  e.label,
                  List<ItemTranslation>.unmodifiable(e.translations
                      .map<ItemTranslation>((e) => ItemTranslation(e.translation, e.englishDefinition))))))))));

      return Lesson(restLesson.uri, restLesson.label, restLesson.description, exercises);
    });
  }

  static ExerciseType fromRest(RestExerciseType exerciseType) {
    switch (exerciseType) {
      case RestExerciseType.TranslateToLearningLanguage:
        return ExerciseType.TranslateToLearningLanguage;
      case RestExerciseType.Repeat:
        return ExerciseType.Repeat;
    }
  }

  static Future<Result<Uint8List>> getRecord(String languageUri, String sentence) async {
    return _runGet('sentence_record?language_uri=$languageUri&sentence=$sentence',
        (dynamic decodedBody) => decodedBody as Uint8List,
        decodeResponse: (http.Response response) => response.bodyBytes);
  }
}
