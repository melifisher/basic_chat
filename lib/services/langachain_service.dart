import 'package:basic_chat/models/context_cache.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/response_model.dart';

class LangchainService {
  final String baseUrl = 'http://192.168.0.7:5000/api'; //192.168.123.92

  /// Initializes the Langchain service
  /// Returns a Future<bool> indicating whether the Langchain service was successfully initialized
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

  /// Performs a search query in the Langchain system
  ///
  /// [query] The search query string
  /// [k] Number of results to return (default is 2)
  ///
  /// Example return format:
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
        final responseFinal = Response.fromJson(jsonDecode(response.body));
        responseFinal.id = DateTime.now().millisecondsSinceEpoch.toString();
        return responseFinal;
        // Verificar si hay resultados
        // if (jsonResponse['results'] != null && jsonResponse['results'] is List) {
        //   // Extraer todos los 'content' y unirlos con saltos de línea
        //   final contents = (jsonResponse['results'] as List)
        //       .map<String>((result) => result['content']?.toString() ?? '')
        //       .where((content) => content.isNotEmpty)
        //       .join('\n\n');

        //   return contents;
        // } else {
        //   return 'No results found';
        // }
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
