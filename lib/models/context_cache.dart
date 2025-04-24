import 'package:basic_chat/models/response_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class ContextCache {
  static final Logger logger = Logger();
  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'local_context_cache.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS context (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            answer_full TEXT NOT NULL,
            answer_summary TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          );
        ''');
      },
    );

    logger.i("Local context cache initialized at $path");
  }

  Future<void> addEntry({
    required String question,
    required List<Result> answerFull,
    required String answerSummary,
  }) async {
    final buffer = StringBuffer();

    for (int i = 0; i < answerFull.length; i++) {
      buffer.write(answerFull[i].content);
      if (i < answerFull.length - 1) {
        buffer.write('\n\n');
      }
    }
    await _db.insert('context', {
      'question': question,
      'answer_full': buffer.toString(),
      'answer_summary': answerSummary,
    });
  }

  Future<List<ContextEntry>> getHistory({int limit = 10}) async {
    final maps = await _db.query(
      'context',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => ContextEntry.fromMap(map)).toList();
  }

  Future<String?> getUltimateQuestion() async {
    final result = await _db.query(
      'context',
      columns: ['question'],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    return result.isNotEmpty ? result.first['question'] as String? : null;
  }

  Future<String?> getUltimateAnswerFull() async {
    final result = await _db.query(
      'context',
      columns: ['answer_full'],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    return result.isNotEmpty ? result.first['answer_full'] as String? : null;
  }

  Future<void> clearHistory() async {
    await _db.delete('context');
  }

  Future<void> close() async {
    await _db.close();
  }
}

class ContextEntry {
  final int id;
  final String question;
  final String answerFull;
  final String answerSummary;
  final DateTime timestamp;

  ContextEntry({
    required this.id,
    required this.question,
    required this.answerFull,
    required this.answerSummary,
    required this.timestamp,
  });

  factory ContextEntry.fromMap(Map<String, dynamic> map) {
    return ContextEntry(
      id: map['id'] as int,
      question: map['question'] as String,
      answerFull: map['answer_full'] as String,
      answerSummary: map['answer_summary'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
