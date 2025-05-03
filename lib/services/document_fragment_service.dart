import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ml_linalg/linalg.dart';
import '../models/fragment_models/document_fragment.dart';
import '../models/fragment_models/document_fragment_with_matches.dart';

class SpanishStopwords {
  static final Set<String> stopwords = {
    'a', 'al', 'algo', 'algunas', 'algunos', 'ante', 'antes', 'como',
    'con', 'contra', 'cual', 'cuando', 'de', 'del', 'desde', 'donde',
    'durante', 'e', 'el', 'ella', 'ellas', 'ellos', 'en', 'entre',
    'era', 'erais', 'eran', 'eras', 'eres', 'es', 'esa', 'esas',
    'ese', 'eso', 'esos', 'esta', 'estaba', 'estabais', 'estaban',
    'estabas', 'estad', 'estada', 'estadas', 'estado', 'estados',
    'estamos', 'estando', 'estar', 'estaremos', 'estará', 'estarán',
    'estarás', 'estaré', 'estaréis', 'estaría', 'estaríais', 'estaríamos',
    'estarían', 'estarías', 'estas', 'este', 'estemos', 'esto', 'estos',
    'estoy', 'estuve', 'estuviera', 'estuvierais', 'estuvieran', 'estuvieras',
    'estuvieron', 'estuviese', 'estuvieseis', 'estuviesen', 'estuvieses', 'estuvimos',
    'estuviste', 'estuvisteis', 'estuviéramos', 'estuviésemos', 'estuvo', 'está',
    'estábamos', 'estáis', 'están', 'estás', 'esté', 'estéis', 'estén', 'estés',
    'fue', 'fuera', 'fuerais', 'fueran', 'fueras', 'fueron', 'fuese', 'fueseis',
    'fuesen', 'fueses', 'fui', 'fuimos', 'fuiste', 'fuisteis', 'fuéramos',
    'fuésemos', 'ha', 'habida', 'habidas', 'habido', 'habidos', 'habiendo',
    'habremos', 'habrá', 'habrán', 'habrás', 'habré', 'habréis', 'habría',
    'habríais', 'habríamos', 'habrían', 'habrías', 'habéis', 'había', 'habíais',
    'habíamos', 'habían', 'habías', 'han', 'has', 'hasta', 'hay', 'haya',
    'hayamos', 'hayan', 'hayas', 'hayáis', 'he', 'hemos', 'hube', 'hubiera',
    'hubierais', 'hubieran', 'hubieras', 'hubieron', 'hubiese', 'hubieseis',
    'hubiesen', 'hubieses', 'hubimos', 'hubiste', 'hubisteis', 'hubiéramos',
    'hubiésemos', 'hubo', 'la', 'las', 'le', 'les', 'lo', 'los', 'me', 'mi',
    'mis', 'mucho', 'muchos', 'muy', 'más', 'mí', 'mía', 'mías', 'mío', 'míos',
    'nada', 'ni', 'no', 'nos', 'nosotras', 'nosotros', 'nuestra', 'nuestras',
    'nuestro', 'nuestros', 'o', 'os', 'otra', 'otras', 'otro', 'otros', 'para',
    'pero', 'poco', 'por', 'porque', 'que', 'quien', 'quienes', 'qué', 'se',
    'sea', 'seamos', 'sean', 'seas', 'seremos', 'será', 'serán', 'serás',
    'seré', 'seréis', 'sería', 'seríais', 'seríamos', 'serían', 'serías',
    'seáis', 'si', 'sido', 'siendo', 'sin', 'sobre', 'sois', 'somos', 'son',
    'soy', 'su', 'sus', 'suya', 'suyas', 'suyo', 'suyos', 'sí', 'también',
    'tanto', 'te', 'tendremos', 'tendrá', 'tendrán', 'tendrás', 'tendré',
    'tendréis', 'tendría', 'tendríais', 'tendríamos', 'tendrían', 'tendrías',
    'tened', 'tenemos', 'tenga', 'tengamos', 'tengan', 'tengas', 'tengo',
    'tengáis', 'tenida', 'tenidas', 'tenido', 'tenidos', 'teniendo', 'tenéis',
    'tenía', 'teníais', 'teníamos', 'tenían', 'tenías', 'ti', 'tiene', 'tienen',
    'tienes', 'todo', 'todos', 'tu', 'tus', 'tuve', 'tuviera', 'tuvierais',
    'tuvieran', 'tuvieras', 'tuvieron', 'tuviese', 'tuvieseis', 'tuviesen',
    'tuvieses', 'tuvimos', 'tuviste', 'tuvisteis', 'tuviéramos', 'tuviésemos',
    'tuvo', 'tuya', 'tuyas', 'tuyo', 'tuyos', 'tú', 'un', 'una', 'uno', 'unos',
    'vosotras', 'vosotros', 'vuestra', 'vuestras', 'vuestro', 'vuestros', 'y',
    'ya', 'yo', 'él', 'éramos',
  };

  static String removeStopwords(String text) {
    List<String> words = text.toLowerCase().split(RegExp(r'\s+'));
    return words.where((word) => !stopwords.contains(word)).join(' ');
  }
}

// Service to handle API requests and local data storage
class DocumentFragmentService {
  static final String apiUrl = 'http://192.168.0.24:5000/api';

  // Fetch fragments from API
  static Future<List<DocumentFragment>> fetchFragments(String collectionName) async {
    final url = Uri.parse('$apiUrl/export_fragments/$collectionName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> fragmentsJson = data['fragments'];
      
      List<DocumentFragment> fragments = fragmentsJson.map((json) {
        return DocumentFragment(
          documentId: json['document_id'],
          text: json['text'],
          embedding: List<double>.from(json['embedding']),
          metadata: Map<String, dynamic>.from(json['metadata']),
        );
      }).toList();
      
      // Store fragments in local Hive DB
      final fragmentsBox = Hive.box<DocumentFragment>('fragments');
      await fragmentsBox.clear();
      await fragmentsBox.addAll(fragments);
      
      return fragments;
    } else {
      throw Exception('Failed to load fragments: ${response.statusCode}');
    }
  }

  // Get all available collections
  static Future<List<String>> getCollections() async {
    print('in getCollections');
    final url = Uri.parse('$apiUrl/collections');
    print(url);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['collections']);
    } else {
      throw Exception('Failed to load collections');
    }
  }
  
  // Method to search fragments with keywords
  List<DocumentFragmentWithMatches> searchByKeywords(String query) {
    final fragmentsBox = Hive.box<DocumentFragment>('fragments');
    final fragments = fragmentsBox.values.toList();
    
    // Remove stopwords from query
    final cleanQuery = SpanishStopwords.removeStopwords(query.toLowerCase());
    final queryTerms = cleanQuery.split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
    
    // Enhanced keyword matching with match count
    return fragments.map((fragment) {
      final text = fragment.text.toLowerCase();
      int matchCount = 0;
      
      for (final term in queryTerms) {
        // Count occurrences of each term
        final matches = term.allMatches(text);
        matchCount += matches.length;
      }
      
      return DocumentFragmentWithMatches(
        fragment: fragment,
        matchCount: matchCount,
      );
    })
    .where((result) => result.matchCount > 0)
    .toList()
    ..sort((a, b) => b.matchCount.compareTo(a.matchCount)); // Sort by match count
  }
  
  // Method to search by vector similarity
  static Future<List<DocumentFragment>> searchBySimilarity(
      String query, {int limit = 5}) async {
    // This would normally call your API to create an embedding for the query
    // But for simplicity, we'll simulate it with a local approach
    
    // In a real implementation, you would:
    // 1. Call your API to get the embedding for the query
    // 2. Compare it with stored embeddings
    
    // Simulating the process for demonstration:
    final fragmentsBox = Hive.box<DocumentFragment>('fragments');
    final fragments = fragmentsBox.values.toList();
    
    // Clean query (remove stopwords)
    final cleanQuery = SpanishStopwords.removeStopwords(query.toLowerCase());
    
    // In a real implementation, you would get this from your API:
    // final queryEmbedding = await apiService.getEmbedding(cleanQuery); 
    
    // For demo purposes, let's assume we have the query embedding:
    // (In reality, you'd call your API to get this)
    
    // Instead, we'll use keyword-based scoring for the demo
    Map<DocumentFragment, double> scores = {};
    
    for (var fragment in fragments) {
      // Calculate similarity score (in a real app, use cosine similarity)
      double score = _calculateKeywordSimilarity(fragment.text, cleanQuery);
      scores[fragment] = score;
    }
    
    // Sort fragments by similarity score
    final sortedFragments = fragments.toList()
      ..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    
    // Return top results
    return sortedFragments.take(limit).toList();
  }
  
  // Simple keyword similarity function (for demo purposes)
  static double _calculateKeywordSimilarity(String text, String query) {
    text = text.toLowerCase();
    query = query.toLowerCase();
    
    final queryTerms = query.split(RegExp(r'\s+'));
    int matches = 0;
    
    for (var term in queryTerms) {
      if (text.contains(term)) matches++;
    }
    
    return matches / queryTerms.length;
  }
  
  // Method to calculate cosine similarity between two vectors
  static double cosineSimilarity(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length) {
      throw Exception('Vectors must have the same dimensions');
    }
    
    // Convert to ml_linalg vectors
    final vector1 = Vector.fromList(vec1);
    final vector2 = Vector.fromList(vec2);
    
    return vector1.dot(vector2) / (vector1.norm() * vector2.norm());
  }
}