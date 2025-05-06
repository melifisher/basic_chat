import 'package:basic_chat/models/context_cache.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/response_model.dart';

class LangchainService {
  final String baseUrl = 'http://192.168.239.18:5000/api'; //192.168.123.92

  Future<bool> initialize() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/initialize'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Initialization error: $e');
      return false;
    }
  }

  
  /// Ejemplo return:
  //    {
  //      "query": "Search query string",
  //      "response": "Search response string",
  //      "result_count": 2,
  //      "results": [
  //        {
  //          "content": "Detailed text content",
  //          "id": 1,
  //          "metadata": {"source": "source_file.txt"}
  //        },
  //        ...
  //      ],
  //      "status": "success"
  //  }

  Future<Response> search(
    String query,
    String oldquery,
    String oldresponsefull,
    List<HistoryEntry> historial, {
    int k = 5,
  }) async {
    try {
      print('query: $query');
      print('k: $k');
      print('oldquery: $oldquery');
      print('oldresponsefull: $oldresponsefull');
      List<String> summaries = historial.map((e) => e.summary).toList();
      print('summaries: $summaries');

      final response = await http.post(
        Uri.parse('$baseUrl/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'k': k,
          'oldquestion': oldquery,
          'oldresponsefull': oldresponsefull,
          'summaries': summaries,
        }),
      );
      print('Response status code: ${response.statusCode}');
      print(response.body);
      if (response.statusCode == 200) {
        return Response.fromJson(jsonDecode(response.body));;
      } else {
        print('Search failed with status code: ${response.statusCode}');
        throw {
          'error': 'Search failed',
          'status': 'error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Search error: $e');
      throw {'error': 'Search error: $e', 'status': 'error', 'statusCode': 500};
    }
  }

  Future<dynamic> feedback(
    String query,
    String responseAi,
    int rating,
    dynamic context,
  ) async {
    try {
      print('query: $query');
      print('response: $responseAi');
      print('rating: $rating');
      var jsonSerializableContext =
          context.map((item) => item.toJson()).toList();
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'response': responseAi,
          'rating': rating,
          'contexts': jsonSerializableContext,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        return jsonResponse['message'];
      } else {
        print('Search failed with status code: ${response.statusCode}');
        throw {
          'error': 'Search failed',
          'status': 'error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Search error: $e');
      throw {'error': 'Search error: $e', 'status': 'error', 'statusCode': 500};
    }
  }
}
