import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../features/common/domain/entities/user.dart';

class ApiProvider {
  ApiProvider([this.useToken = true]);

  final String _host = 'api-trustme.catenasystem.com.br';
  final bool useToken;

  // final _header = {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer ${userLoggedIn?.token ?? ''}'};

  Map<String, String> get _header {
    final tokenizedHeader = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${useToken ? userLoggedIn.authToken : ''}',
    };
    final tokenlessHeader = {'Content-Type': 'application/json; charset=UTF-8'};

    if (useToken) {
      return tokenizedHeader;
    } else {
      return tokenlessHeader;
    }
  }

  Future<Map<String, dynamic>> get(String endPoint, [Map<String, dynamic>? params]) async {
    endPoint = 'api/$endPoint';

    final Uri url;
    url = Uri.https(_host, endPoint, params);

    final Map<String, dynamic> responseData;
    debugPrint('$runtimeType - GET url $url');

    try {
      final http.Response response = await http.get(url, headers: _header).timeout(const Duration(seconds: 10));
      debugPrint('$runtimeType - GET response ${response.body}');

      if (response.statusCode == 200) {
        //O IF abaixo é necessário pois nem todos os endpoints retornam um Map, alguns retornam apenas uma List de itens
        if (jsonDecode(response.body) is List<dynamic>) {
          final Map<String, dynamic> mapData = {'data': jsonDecode(response.body)};
          return mapData;
        }

        responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw HttpException('error ${response.statusCode}');
      }
    } catch (e, s) {
      debugPrint('$runtimeType - Error: $e\nStack:$s');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String endPoint, String content) async {
    endPoint = 'api/$endPoint';
    final Uri url;
    url = Uri.https(_host, endPoint);
    final http.Response response;

    debugPrint('$runtimeType - POST url $url - content $content');

    try {
      response = await http.post(url, body: content, headers: _header).timeout(const Duration(seconds: 7));

      debugPrint('$runtimeType - POST response ${response.body}');

      if (jsonDecode(response.body) is List<dynamic>) {
        final Map<String, dynamic> mapData = {'data': jsonDecode(response.body)};
        return mapData;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e, s) {
      debugPrint('$runtimeType - Error: $e\nStack:$s');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(String endPoint, String content) async {
    endPoint = 'api/$endPoint';
    final Uri url;
    url = Uri.https(_host, endPoint);
    final http.Response response;

    debugPrint('$runtimeType - POST url $url - content $content');

    try {
      response = await http.patch(url, body: content, headers: _header).timeout(const Duration(seconds: 7));

      debugPrint('$runtimeType - POST response ${response.body}');

      if (jsonDecode(response.body) is List<dynamic>) {
        final Map<String, dynamic> mapData = {'data': jsonDecode(response.body)};
        return mapData;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e, s) {
      debugPrint('$runtimeType - Error: $e\nStack:$s');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endPoint, String content) async {
    endPoint = 'api/$endPoint';
    final Uri url;
    url = Uri.https(_host, endPoint);
    final http.Response response;

    try {
      response = await http
          .put(
            url,
            body: content,
            headers: _header,
          )
          .timeout(const Duration(seconds: 10));
    } catch (e, s) {
      debugPrint('$runtimeType - Error: $e\nStack:$s');
      rethrow;
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'response': response.body};
    } else {
      debugPrint(
          '$runtimeType PUT: Status code: ${response.statusCode}\nResponse: ${response.reasonPhrase}\n${response.body}');
      return {};
    }
  }

  Future<void> delete(String endPoint, [String? content]) async {
    endPoint = 'api/$endPoint';

    final http.Response response;
    final Uri url;
    url = Uri.https(_host, endPoint);

    response = await http.delete(url, headers: _header, body: content);
  }

  Future<Map<String, dynamic>> postWithFiles(String endPoint, List<File> files,
      [Map<String, dynamic>? otherFields]) async {
    endPoint = 'api/$endPoint';
    final http.StreamedResponse response;

    final Uri url;
    if (kReleaseMode) {
      url = Uri.https(_host, endPoint);
    } else {
      url = Uri.https(_host, endPoint);
    }

    final http.MultipartRequest request = http.MultipartRequest('POST', url);

    request.headers.addAll(_header);

    for (final file in files) {
      request.files
          .add(await http.MultipartFile.fromPath('anexos[]', file.path, contentType: MediaType('image', 'jpg')));
    }

    if (otherFields != null) {
      for (final entry in otherFields.entries) {
        request.fields[entry.key] = entry.value.toString();
      }
    }

    try {
      response = await request.send().timeout(const Duration(seconds: 10));
    } catch (e, s) {
      // ExceptionMessageResolver(e,s).getExceptionMessage();
      debugPrint('erro $e\nstack: $s');
      rethrow;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'response': response.reasonPhrase, 'statusCode': response.statusCode};
    } else {
      return {
        'response': {
          'error': '${response.reasonPhrase}',
          'statusCode': '${response.statusCode}',
        },
      };
    }
  }
}
