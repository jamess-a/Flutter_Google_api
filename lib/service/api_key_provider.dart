import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyProvider extends ChangeNotifier {
  late String _apiKey;

  ApiKeyProvider() {
    _apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';
  }

  String get apiKey => _apiKey;

  void updateApiKey(String newApiKey) {
    _apiKey = newApiKey;
    notifyListeners();
  }
}



