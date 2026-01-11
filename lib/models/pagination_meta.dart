class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total_items'] as int? ?? 0,
    );
  }
}
