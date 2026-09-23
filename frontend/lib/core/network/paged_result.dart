class PagedResult<T> {
  const PagedResult({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  bool get hasNext => next != null && next!.isNotEmpty;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic item) fromJsonItem,
  ) {
    return PagedResult(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>? ?? [])
          .map(fromJsonItem)
          .toList(),
    );
  }
}
