class Response {
  final String query;
  final String response;
  final int resultCount;
  final List<Result> results;
  final String status;
  final String id;

  Response({
    required this.query,
    required this.response,
    required this.resultCount,
    required this.results,
    required this.status,
    required this.id,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      query: json['query'] ?? '',
      response: json['response'] ?? '',
      resultCount: json['resultCount'] ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => Result(
                    content: item['content'] ?? '',
                    id: item['id'] ?? 0,
                    metadata: item['metadata'],
                  ))
              .toList() ??
          [],
      status: json['status'] ?? 'error',
      id: json['response_id'] ?? '',
    );
  }
}

class Result {
  final String content;
  final int id;
  final dynamic metadata;

  Result({
    required this.content,
    required this.id,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'id': id,
      'metadata': metadata,
    };
  }
}