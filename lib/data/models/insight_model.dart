/// money tips shown on the dashboard.
class InsightModel {
  const InsightModel({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const <String>[],
  });

  final int id;
  final String title;
  final String body;
  final List<String> tags;

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      body: json['body'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic tag) => tag.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'tags': tags,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InsightModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
