import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';
import 'package:trustme/core/utils/http/custom_http_result.dart';

import 'package:trustme/features/common/data/models/auth_model.dart';
import 'package:trustme/features/common/domain/entities/auth.dart';
import 'package:trustme/main.dart';
import 'package:trustme/core/global/global_variables.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/core/utils/preferences/app_preferences.dart';
import 'package:synchronized/synchronized.dart';

enum Response401Result {
  NO_401,
  TRY_AGAIN,
  USER_LOGGED_OUT,
}

enum RefreshTokenResult {
  TOKEN_REFRESHED,
  TOKEN_NOT_REFRESHED,
  TOKEN_IS_REFRESHING, // When other thread is processing refreshToken method
}

class ApiProvider {
  static const DEF_MAX_ATTEMPT = 5;
  static const DEF_USE_HTTPS = false;

  /// Use this object to prevent concurrent access to data
  static final _lock = Lock();

  ApiProvider();

  // final String _host = GlobalVariables.DEF_USE_DEV_ENVIRONMENT
  //     ? 'api-trustme-dev.catenasystem.com.br:8443'
  //     : 'api-trustme.catenasystem.com.br';

  final String _host = GlobalVariables.DEF_USE_DEV_ENVIRONMENT
      ? '10.102.0.11:8011'
      : 'api-trustme.dyndns.org:7980';

  Map<String, String> _getHeader(bool useToken) {
    final tokenizedHeader = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${useToken ? (authData?.authToken ?? '') : ''}',
    };
    final tokenlessHeader = {'Content-Type': 'application/json; charset=UTF-8'};

    if (useToken) {
      return tokenizedHeader;
    } else {
      return tokenlessHeader;
    }
  }

  // TODO: Catch exception on caller
  Future<HttpResult> get(String endPoint, {bool useToken = true, bool checkErrors = true, int attempt = 0, Map<String, dynamic>? params}) async {
    endPoint = 'api/$endPoint';

    final Uri url;
    url = DEF_USE_HTTPS ? Uri.https(_host, endPoint, params) : Uri.http(_host, endPoint, params);
    Log.d('$runtimeType', 'GET url $url');

    try {
      final http.Response response = await http.get(url, headers: _getHeader(useToken)).timeout(const Duration(seconds: 10));
      // Log.d('$runtimeType', 'GET response ${response.body}');

      final httpResult = handleHttpResponse(response);
      return httpResult;
    } on ClientErrorException catch (e, s) {
      Log.e('$runtimeType', '❌ Client error on GET method.', e, s);

      if(GlobalVariables.DEF_CHECK_AUTH_ERRORS && checkErrors) {
        final error403 = await _checkError403(url, e.statusCode);

        if (!error403 && await _checkError401(url, e.statusCode, attempt) == Response401Result.TRY_AGAIN) {
          return get(
              endPoint,
              useToken: useToken,
              checkErrors: checkErrors,
              attempt: attempt + 1,
              params: params
          );
        }
      }

      rethrow;
    } on ServerErrorException catch (e, s) {
      Log.e('$runtimeType', '🔥 Server error on GET method.', e, s);
      rethrow;
    } on HttpRequestException catch (e, s) {
      Log.e('$runtimeType', '⚠️ Generic error on GET method.', e, s);
      rethrow;
    } on Exception catch(e, s) {
      Log.e('$runtimeType', '⛔ Error on GET method', e, s);
      rethrow;
    }
  }

  // TODO: Catch exception on caller
  Future<HttpResult> post(String endPoint, String content, {bool useToken = true, bool checkErrors = true, int attempt = 0}) async {
    endPoint = 'api/$endPoint';
    final Uri url;
    url = DEF_USE_HTTPS ? Uri.https(_host, endPoint) : Uri.http(_host, endPoint);
    final http.Response response;

    Log.d('$runtimeType', 'POST url $url - content $content');

    try {
      response = await http.post(url, body: content, headers: _getHeader(useToken)).timeout(const Duration(seconds: 7));
      Log.d('$runtimeType', 'POST response ${response.body}');

      final httpResult = handleHttpResponse(response);
      return httpResult;
    } on ClientErrorException catch (e, s) {
      Log.e('$runtimeType', '❌ Client error on POST method.', e, s);

      if(GlobalVariables.DEF_CHECK_AUTH_ERRORS && checkErrors) {
        final error403 = await _checkError403(url, e.statusCode);

        if (!error403 && await _checkError401(url, e.statusCode, attempt) == Response401Result.TRY_AGAIN) {
          return post(
              endPoint,
              content,
              useToken: useToken,
              checkErrors: checkErrors,
              attempt: attempt + 1
          );
        }
      }

      rethrow;
    } on ServerErrorException catch (e, s) {
      Log.e('$runtimeType', '🔥 Server error on POST method.', e, s);
      rethrow;
    } on HttpRequestException catch (e, s) {
      Log.e('$runtimeType', '⚠️ Generic error on POST method.', e, s);
      rethrow;
    } on Exception catch(e, s) {
      Log.e('$runtimeType', '⛔ Error on POST method', e, s);
      rethrow;
    }
  }

  // TODO: Catch exception on caller
  Future<HttpResult> patch(String endPoint, String content, {bool useToken = true, bool checkErrors = true, int attempt = 0}) async {
    endPoint = 'api/$endPoint';
    final Uri url;
    url = DEF_USE_HTTPS ? Uri.https(_host, endPoint) : Uri.http(_host, endPoint);
    final http.Response response;

    Log.d('$runtimeType', 'PATCH url $url - content $content');

    try {
      response = await http.patch(url, body: content, headers: _getHeader(useToken)).timeout(const Duration(seconds: 7));
      // Log.d(TAG, '$runtimeType - PATCH response ${response.body}');

      final httpResult = handleHttpResponse(response);
      return httpResult;
    } on ClientErrorException catch (e, s) {
      Log.e('$runtimeType', '❌ Client error on PATCH method.', e, s);

      if(GlobalVariables.DEF_CHECK_AUTH_ERRORS && checkErrors) {
        final error403 = await _checkError403(url, e.statusCode);

        if (!error403 && await _checkError401(url, e.statusCode, attempt) == Response401Result.TRY_AGAIN) {
          return patch(
            endPoint,
            content,
            useToken: useToken,
            checkErrors: checkErrors,
            attempt: attempt + 1,
          );
        }
      }

      rethrow;
    } on ServerErrorException catch (e, s) {
      Log.e('$runtimeType', '🔥 Server error on PATCH method.', e, s);
      rethrow;
    } on HttpRequestException catch (e, s) {
      Log.e('$runtimeType', '⚠️ Generic error on PATCH method.', e, s);
      rethrow;
    } on Exception catch(e, s) {
      Log.e('$runtimeType', '⛔ Error on PATCH method', e, s);
      rethrow;
    }
  }

  // TODO: Catch exception on caller
  Future<HttpResult> put(String endPoint, String content, {bool useToken = true, bool checkErrors = true, int attempt = 0}) async {
    endPoint = 'api/$endPoint';
    final Uri url;
    url = DEF_USE_HTTPS ? Uri.https(_host, endPoint) : Uri.http(_host, endPoint);
    final http.Response response;

    try {
      response = await http.put(url, body: content, headers: _getHeader(useToken),).timeout(const Duration(seconds: 10));
      // Log.d(TAG, '$runtimeType - PUT response ${response.body}');

      final httpResult = handleHttpResponse(response);
      return httpResult;
    } on ClientErrorException catch (e, s) {
      Log.e('$runtimeType', '❌ Client error on PUT method.', e, s);

      if(GlobalVariables.DEF_CHECK_AUTH_ERRORS && checkErrors) {
        final error403 = await _checkError403(url, e.statusCode);

        if (!error403 && await _checkError401(url, e.statusCode, attempt) == Response401Result.TRY_AGAIN) {
          return put(
            endPoint,
            content,
            useToken: useToken,
            checkErrors: checkErrors,
            attempt: attempt + 1,
          );
        }
      }

      rethrow;
    } on ServerErrorException catch (e, s) {
      Log.e('$runtimeType', '🔥 Server error on PUT method.', e, s);
      rethrow;
    } on HttpRequestException catch (e, s) {
      Log.e('$runtimeType', '⚠️ Generic error on PUT method.', e, s);
      rethrow;
    } on Exception catch(e, s) {
      Log.e('$runtimeType', '⛔ Error on PUT method', e, s);
      rethrow;
    }
  }

  // TODO: Catch exception on caller
  Future<HttpResult> delete(String endPoint, {bool useToken = true, bool checkErrors = true, int attempt = 0, String? content}) async {
    endPoint = 'api/$endPoint';

    final Uri url;
    url = DEF_USE_HTTPS ? Uri.https(_host, endPoint) : Uri.http(_host, endPoint);
    Log.d('$runtimeType', 'DELETE url $url');

    try {
      final http.Response response = await http.delete(url, headers: _getHeader(useToken), body: content);

      final httpResult = handleHttpResponse(response);
      return httpResult;
    } on ClientErrorException catch (e, s) {
      Log.e('$runtimeType', '❌ Client error on DELETE method.', e, s);

      if(GlobalVariables.DEF_CHECK_AUTH_ERRORS && checkErrors) {
        final error403 = await _checkError403(url, e.statusCode);

        if (!error403 && await _checkError401(url, e.statusCode, attempt) == Response401Result.TRY_AGAIN) {
          return delete(endPoint,
            content: content,
            useToken: useToken,
            checkErrors: checkErrors,
            attempt: attempt + 1,
          );
        }
      }

      rethrow;
    } on ServerErrorException catch (e, s) {
      Log.e('$runtimeType', '🔥 Server error on DELETE method.', e, s);
      rethrow;
    } on HttpRequestException catch (e, s) {
      Log.e('$runtimeType', '⚠️ Generic error on DELETE method.', e, s);
      rethrow;
    } on Exception catch(e, s) {
      Log.e('$runtimeType', '⛔ Error on DELETE method', e, s);
      rethrow;
    }
  }

  // TODO: Catch exception on caller
  Future<HttpResult> postWithFiles(String endPoint, List<File> files, {bool useToken = true, bool checkErrors = true, int attempt = 0, Map<String, dynamic>? otherFields}) async {
    endPoint = 'api/$endPoint';

    final Uri url;
    url = DEF_USE_HTTPS ? Uri.https(_host, endPoint) : Uri.http(_host, endPoint);

    final http.MultipartRequest request = http.MultipartRequest('POST', url);

    request.headers.addAll(_getHeader(useToken));

    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('anexos[]', file.path, contentType: MediaType('image', 'jpg')));
    }

    if (otherFields != null) {
      for (final entry in otherFields.entries) {
        request.fields[entry.key] = entry.value.toString();
      }
    }

    try {
      final http.StreamedResponse streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);

      final httpResult = handleHttpResponse(response);
      return httpResult;
    } on ClientErrorException catch (e, s) {
      Log.e('$runtimeType', '❌ Client error on POST_WITH_FILES method.', e, s);

      if(GlobalVariables.DEF_CHECK_AUTH_ERRORS && checkErrors) {
        final error403 = await _checkError403(url, e.statusCode);

        if (!error403 && await _checkError401(url, e.statusCode, attempt) == Response401Result.TRY_AGAIN) {
          return postWithFiles(
            endPoint,
            files,
            useToken: useToken,
            checkErrors: checkErrors,
            attempt: attempt + 1,
            otherFields: otherFields,
          );
        }
      }

      rethrow;
    } on ServerErrorException catch (e, s) {
      Log.e('$runtimeType', '🔥 Server error on POST_WITH_FILES method.', e, s);
      rethrow;
    } on HttpRequestException catch (e, s) {
      Log.e('$runtimeType', '⚠️ Generic error on POST_WITH_FILES method.', e, s);
      rethrow;
    } on Exception catch(e, s) {
      Log.e('$runtimeType', '⛔ Error on POST_WITH_FILES method', e, s);
      rethrow;
    }
  }

  //region ## AUX METHODS
  HttpResult handleHttpResponse(http.Response response) {
    final status = response.statusCode;

    // try to decode JSON if possible
    dynamic body;

    try {
      body = jsonDecode(response.body);
    } catch (_) {
      rethrow;
    }

    if (status >= 200 && status < 300) {
      // success: returns the content as Map<String, dynamic>
      Map<String, dynamic>? responseData;

      if(body is List<dynamic>) {
        responseData = {'data': body};
      } else if((body['result']?? body) is List<dynamic>){
        responseData = {'data': body['result']?? body};
      } else {
        responseData = body['result']?? body;
      }

      return HttpResult(
          statusCode: status,
          success: true,
          message: (body is Map)
              ? body['message']
              : null,
          result: responseData
      );
    } else if (status >= 400 && status < 500) {
      throw ClientErrorException(
          statusCode: status,
          message: body is Map && body['message'] != null
              ? body['message']
              : 'Erro na requisição (${status})',
          details: body,
          success: body['success']?? false,
          stackTrace: body['stack']
      );
    } else if (status >= 500 && status < 600) {
      throw ServerErrorException(
          statusCode: status,
          message: body is Map && body['message'] != null
              ? body['message']
              : 'Erro no servidor (${status})',
          details: body,
          success: body['success']?? false,
          stackTrace: body['stack']
      );
    } else {
      throw HttpRequestException(
          statusCode: status,
          message: 'Erro inesperado (${status})',
          details: body,
          success: body['success']?? false,
          stackTrace: body['stack']
      );
    }
  }

  Future<bool> _checkError403(Uri uri, int respStatusCode) async {
    // If it gets 403, log out!

    if(respStatusCode == 403) {
      Log.e('$runtimeType', 'RESPONSE CODE 403 for url (${uri.path}): The app will be logged out.');

      final prefs = AppPreferences();
      await prefs.setString(KeyPrefs.LAST_LOGOUT_REASON, '#403: O seu token de acesso foi bloqueado!');

      TrustMeApp.logout();
      return true;
    }

    return false;
  }

  Future<Response401Result> _checkError401(Uri uri, int respStatusCode, int attempt) async {
    // If it gets 401, try to refresh Tokiuz and try again!

    if(respStatusCode == 401) {

      final prefs = AppPreferences();

      if(attempt < DEF_MAX_ATTEMPT) {

        final refreshToken = (authData?.refreshToken ?? '');

        if(refreshToken == '' || refreshToken == 'REFRESH_TOKEN') {
          Log.e('$runtimeType', 'RESPONSE CODE 401 for url (${uri.path}): Attempt #$attempt, but no refresh token provided. The app will be logged out.');
          await prefs.setString(KeyPrefs.LAST_LOGOUT_REASON, '#401: O seu token de acesso é inválido e não foi possível restaurar o acesso.');
          TrustMeApp.logout();
          return Response401Result.USER_LOGGED_OUT;
        } else {

          RefreshTokenResult? tokenRefreshed = RefreshTokenResult.TOKEN_NOT_REFRESHED;

          try {
            tokenRefreshed = await refreshAuthToken();
          } catch(e, stack) {
            Log.e('$runtimeType', 'Tokiuz could not be refreshed! (ERROR)', e);
            //CrashlyticsUtil.reportError("$TAG: Tokiuz could not be refreshed! (ERROR)", e, stack);
          }

          if(tokenRefreshed == RefreshTokenResult.TOKEN_REFRESHED) {

            Log.e('$runtimeType', 'Tokiuz refreshed!');
            return Response401Result.TRY_AGAIN;

          } else if(tokenRefreshed == RefreshTokenResult.TOKEN_IS_REFRESHING) {

            Log.e('$runtimeType', 'Tokiuz is being refreshing. Wait a second to try again.');
            await Future.delayed(Duration(seconds: 1));
            return Response401Result.TRY_AGAIN;

          } else { // RefreshTokenResult.TOKEN_NOT_REFRESHED

            //Log.e(TAG, "Tokiuz could not be refreshed! (Return = FALSE)");

            Log.e('$runtimeType', 'RESPONSE CODE 401 for url (${uri.path}): Tokiuz could not be refreshed! The app will be logged out.');
            await prefs.setString(KeyPrefs.LAST_LOGOUT_REASON, '#401: O seu token de acesso é inválido e o mecanismo para restaurar o acesso falhou.');
            TrustMeApp.logout();
            return Response401Result.USER_LOGGED_OUT;
          }
        }
      } else {
        Log.e('$runtimeType', 'RESPONSE CODE 401 for url (${uri.path}): Attempt >= DEF_MAX_ATTEMPT. The app will be logged out.');
        await prefs.setString(KeyPrefs.LAST_LOGOUT_REASON, '#401: O seu token de acesso é inválido e as tentativas para restaurar o acesso falharam.');
        TrustMeApp.logout();
        return Response401Result.USER_LOGGED_OUT;
      }
    }

    return Response401Result.NO_401;
  }

  // WARNING: It will not be implemented for now. Maybe it is not needed for this project!
  Future<RefreshTokenResult> refreshAuthToken() async {

    if(!_lock.inLock) {
      return await _lock.synchronized(() async {

        final body = json.encode({
          'token': authData?.authToken,
          'refresh_token': authData?.refreshToken,
        });

        try {
          final rawData = await post('refresh', body, useToken: false, checkErrors: false);

          final auth = AuthModel.fromJson(rawData.result).toEntity();
          await setAuthData(auth);
          return RefreshTokenResult.TOKEN_REFRESHED;
        } catch(e) {
          Log.e('$runtimeType', 'Error trying to refresh an auth token', e);
          return RefreshTokenResult.TOKEN_NOT_REFRESHED;
        }
      });
    }

    return RefreshTokenResult.TOKEN_IS_REFRESHING;
  }
  //endregion
}
