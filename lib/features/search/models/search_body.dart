class SearchBody {
  final String q;
  final String searchIn;
  final int page;
  final int pageSize;

  SearchBody({
    required this.q,
    this.searchIn = 'title',
    this.page = 1,
    this.pageSize = 15,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'q': q,
      'searchIn': searchIn,
      'page': page,
      'pageSize': pageSize,
    };
  }

  factory SearchBody.fromMap(Map<String, dynamic> map) {
    return SearchBody(
      q: map['q'] as String? ?? '',
      searchIn: map['searchIn'] as String? ?? '',
      page: map['page'] as int? ?? 0,
      pageSize: map['pageSize'] as int? ?? 0,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory SearchBody.fromJson(String source) => SearchBody.fromMap(json.decode(source) as Map<String, dynamic>);
}
