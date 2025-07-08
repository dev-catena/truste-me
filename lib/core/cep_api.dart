import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../features/common/data/models/location_model.dart';
import '../features/common/domain/entities/location.dart';

class CepAPI {
  final String _host = 'viacep.com.br';

  Future<Location> getCep(String cep, [Map<String, dynamic>? params]) async {
    cep = 'ws/$cep/json';

    final Uri url;
    url = Uri.https(_host, cep, params);

    debugPrint('$runtimeType - GET url $url');

    final http.Response response = await http.get(url).timeout(const Duration(seconds: 10));
    final location = LocationModel.fromJson(jsonDecode(response.body)).toEntity();

    return location;
  }
}
